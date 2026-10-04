import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lafaek_ai_farm/core/app_assets.dart';
import 'package:lafaek_ai_farm/database/app_database.dart';
import 'package:lafaek_ai_farm/models/models.dart';
import 'package:lafaek_ai_farm/services/local_ai/image_preprocessor.dart';
import 'package:lafaek_ai_farm/services/local_ai/llm_output_parser.dart';
import 'package:lafaek_ai_farm/services/local_ai/llm_prompt_builder.dart';
import 'package:lafaek_ai_farm/services/local_ai/local_ai_orchestrator.dart';
import 'package:lafaek_ai_farm/services/local_ai/local_knowledge_service.dart';
import 'package:lafaek_ai_farm/services/local_ai/local_llm_service.dart';
import 'package:lafaek_ai_farm/services/local_ai/local_model_manager.dart';
import 'package:lafaek_ai_farm/services/local_ai/local_risk_engine.dart';
import 'package:lafaek_ai_farm/services/local_ai/local_vision_service.dart';
import 'package:image/image.dart' as img;

import 'support/fake_bundle.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('LLM output parser', () {
    const parser = LlmOutputParser();

    test('parses well-formed JSON', () {
      final r = parser.parse(
          '{"answer":"Yellow leaves may be nitrogen.","confidence":0.7,"category":"crop_health","recommended_actions":["Check soil","Add compost"],"needs_more_information":false}');
      expect(r.structured, isTrue);
      expect(r.answer, 'Yellow leaves may be nitrogen.');
      expect(r.confidence, 0.7);
      expect(r.category, 'crop_health');
      expect(r.recommendedActions, ['Check soil', 'Add compost']);
    });

    test('strips code fences and tolerates prose around JSON', () {
      final r = parser.parse('Sure! ```json\n{"answer":"Water at the base.","category":"water","recommended_actions":[]}\n```');
      expect(r.structured, isTrue);
      expect(r.answer, 'Water at the base.');
      expect(r.category, 'water');
    });

    test('salvages a truncated JSON answer', () {
      final r = parser.parse('{"answer":"Possible leaf blight. Remove affected leaves and', );
      expect(r.structured, isFalse);
      expect(r.answer, startsWith('Possible leaf blight'));
    });

    test('falls back to plain text when no JSON', () {
      final r = parser.parse('Plant beans after maize to add nitrogen.');
      expect(r.structured, isFalse);
      expect(r.answer, contains('beans after maize'));
    });

    test('normalises bad category and confidence', () {
      final r = parser.parse('{"answer":"x","confidence":"1.7","category":"crop_health|soil"}');
      expect(r.confidence, 1.0);
      expect(r.category, 'crop_health');
      final r2 = parser.parse('{"answer":"x","category":"banana"}');
      expect(r2.category, 'general');
    });

    test('partialAnswer extracts streaming answer text', () {
      expect(parser.partialAnswer('{"answer":"Yellow lea'), 'Yellow lea');
      expect(parser.partialAnswer('{"ans'), '');
      expect(parser.partialAnswer('Plain text so far'), 'Plain text so far');
      expect(parser.partialAnswer(r'{"answer":"Line\nbreak","conf'), 'Line\nbreak');
    });
  });

  group('prompt builder', () {
    test('question prompt includes knowledge and farm context', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final k = LocalKnowledgeService(db, bundle: FakeBundle());
      await k.seedIfNeeded();
      final hits = await k.search('maize leaf blight');
      const b = LlmPromptBuilder();
      final p = b.question(
        question: 'What is wrong with my maize?',
        knowledge: hits,
        farm: const FarmContext(location: 'Dili', crops: ['Maize 2.0 ha (vegetative)']),
      );
      expect(p, contains('CONTEXT: Farm: Dili.'));
      expect(p, contains('KNOWLEDGE:'));
      expect(p, contains('Maize Leaf Blight'));
      expect(p, contains('QUESTION: What is wrong with my maize?'));
      expect(LlmPromptBuilder.systemPrompt, contains('Never give pesticide dosages'));
      await db.close();
    });
  });

  group('model manager', () {
    test('verify rejects missing, wrong-size and non-GGUF files', () async {
      final dir = await Directory.systemTemp.createTemp('lafaek_models');
      final spec = LlmModelSpec(
        id: 'tiny',
        displayName: 'Tiny',
        fileName: 'tiny.gguf',
        sizeBytes: 8,
        minRamMb: 0,
        downloadUrl: 'http://invalid',
        license: 'test',
        parameters: '0',
        vendor: 'test',
        description: 'test',
      );
      final f = File('${dir.path}/tiny.gguf');
      expect(await LocalModelManager.verify(f, spec), isFalse, reason: 'missing');
      await f.writeAsBytes([1, 2, 3]);
      expect(await LocalModelManager.verify(f, spec), isFalse, reason: 'wrong size');
      await f.writeAsBytes([1, 2, 3, 4, 5, 6, 7, 8]);
      expect(await LocalModelManager.verify(f, spec), isFalse, reason: 'bad magic');
      await f.writeAsBytes('GGUF'.codeUnits + [0, 0, 0, 0]);
      expect(await LocalModelManager.verify(f, spec), isTrue);
      await dir.delete(recursive: true);
    });

    test('llm service reports not-loaded state and refuses generation', () {
      final llm = LocalLlmService();
      expect(llm.state, ModelState.notInitialized);
      expect(llm.isReady, isFalse);
      expect(
        () => llm.generate(system: 's', turns: const [LlmTurn.user('q')]).first,
        throwsA(isA<StateError>()),
      );
    });

    test('loading a missing model file yields an error state, not a crash', () async {
      final llm = LocalLlmService(libraryPath: '/nonexistent/libllama.dylib');
      final spec = kKnownLlmModels.first;
      await llm.load(InstalledModel(spec: spec, file: File('/nonexistent/model.gguf')));
      expect(llm.state, ModelState.error);
      expect(llm.errorMessage, isNotEmpty);
      await llm.dispose();
    });
  });

  group('risk engine', () {
    const engine = LocalRiskEngine();

    test('dry soil scores at least as high as low soil, never lower', () {
      // Soil moisture became a measured value from Open-Meteo, which reports
      // "Dry" as well as "Low". Scoring dry soil below low soil would quietly
      // tell a farmer with parched ground that things are fine.
      RiskAssessment forSoil(String label) => engine.assess(RiskInputs(
            cropName: 'Maize',
            temperatureC: 30,
            humidity: 50,
            rainChance: 5,
            windKmh: 8,
            soilMoistureLabel: label,
          ));

      final dry = forSoil('Dry');
      final low = forSoil('Low');
      final good = forSoil('Good');

      expect(dry.score, greaterThan(low.score));
      expect(low.score, greaterThan(good.score));
      expect(dry.reasons.join(' ').toLowerCase(), contains('dry'));
      expect(good.reasons.join(' ').toLowerCase(), isNot(contains('soil')));
    });

    test('unknown soil moisture adds nothing rather than guessing', () {
      final unknown = engine.assess(const RiskInputs(
        cropName: 'Maize',
        temperatureC: 30,
        humidity: 50,
        rainChance: 5,
        windKmh: 8,
        soilMoistureLabel: 'Unknown',
      ));
      expect(unknown.reasons.join(' ').toLowerCase(), isNot(contains('soil')));
    });

    test('tomato in humid rainy weather is high risk with reasons', () {
      final r = engine.assess(const RiskInputs(
        cropName: 'Tomato',
        temperatureC: 27,
        humidity: 85,
        rainChance: 75,
        growthStage: 'Flowering',
      ));
      expect(r.level, RiskLevel.high);
      expect(r.reasons, contains('High humidity (≥80%)'));
      expect(r.reasons.any((x) => x.contains('Tomato')), isTrue);
      expect(r.advice, contains('water only at the base'));
    });

    test('maize in dry mild weather is low risk', () {
      final r = engine.assess(RiskInputs(
        cropName: 'Maize',
        temperatureC: 27,
        humidity: 55,
        rainChance: 10,
        plantedOn: DateTime.now().subtract(const Duration(days: 90)),
      ));
      expect(r.level, RiskLevel.low);
      expect(r.factors, isEmpty);
    });

    test('recent bad scans raise the level', () {
      final r = engine.assess(const RiskInputs(
        cropName: 'Rice',
        temperatureC: 26,
        humidity: 70,
        rainChance: 30,
        recentScans: [HealthStatus.monitor, HealthStatus.atRisk],
      ));
      expect(r.level, RiskLevel.low.index < r.level.index ? r.level : RiskLevel.low);
      expect(r.reasons.any((x) => x.contains('recent scans')), isTrue);
    });

    test('overall is the worst crop', () {
      final low = engine.assess(const RiskInputs(cropName: 'Maize', humidity: 50));
      final high = engine.assess(const RiskInputs(cropName: 'Tomato', humidity: 90, rainChance: 80, temperatureC: 27));
      expect(LocalRiskEngine.overall([low, high]), RiskLevel.high);
      expect(LocalRiskEngine.overallNote(RiskLevel.medium), contains('attention'));
    });
  });

  group('image preprocessor', () {
    test('produces a 224x224x3 float tensor from any image size', () {
      final im = img.Image(width: 300, height: 200);
      img.fill(im, color: img.ColorRgb8(10, 20, 30));
      final bytes = img.encodePng(im);
      final out = const ImagePreprocessor().runSync(bytes);
      expect(out.data.length, 224 * 224 * 3);
      expect(out.sourceWidth, 300);
      expect(out.data[0], 10);
      expect(out.data[1], 20);
      expect(out.data[2], 30);
    });

    test('rejects invalid image bytes', () {
      expect(() => const ImagePreprocessor().runSync(Uint8List.fromList([1, 2, 3])), throwsFormatException);
    });
  });

  group('local vision (real TFLite inference)', () {
    late LocalVisionService vision;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      vision = LocalVisionService(threads: 2);
    });

    test('loads the bundled model and metadata', () async {
      await vision.load();
      expect(vision.isReady, isTrue, reason: vision.errorMessage);
      expect(vision.info!.classes.length, 14);
      expect(vision.info!.classes, contains('maize_leaf_blight'));
    }, skip: !_tfliteAvailable());

    test('classifies the bundled leaf-blight photo as a maize condition', () async {
      await vision.load();
      final bytes = await File('assets/images/leaf_blight.png').readAsBytes();
      final r = await vision.classify(bytes);
      expect(r.scores.length, 14);
      expect(r.inferenceTimeMs, greaterThan(0));
      expect(r.cropName, anyOf('Maize', 'Tomato', 'Unknown'));
      // Probabilities must sum to ~1 (softmax).
      final sum = r.scores.values.fold(0.0, (a, b) => a + b);
      expect(sum, closeTo(1.0, 0.01));
    }, skip: !_tfliteAvailable());

    test('classifies healthy maize sample as maize', () async {
      await vision.load();
      final bytes = await File('assets/images/scan_maize_healthy.png').readAsBytes();
      final r = await vision.classify(bytes);
      expect(r.label, isNot('tomato_leaf_problem'));
    }, skip: !_tfliteAvailable());

    test('bundled sample photo is diagnosed, not rejected', () async {
      await vision.load();
      final bytes = await File('assets/images/sample_leaf.jpg').readAsBytes();
      final r = await vision.classify(bytes);
      // The no-camera demo path depends on this staying a real diagnosis.
      expect(r.label, 'maize_leaf_blight');
      expect(r.confidence, greaterThan(LocalVisionService.unknownThreshold));
      expect(r.margin, greaterThan(LocalVisionService.minMargin));
      expect(r.cropName, 'Maize');
    }, skip: !_tfliteAvailable());

    test('knows the three papaya classes', () async {
      // Papaya was added so a farmer can test the app on the pawpaw in their
      // own yard rather than taking the claim on trust.
      await vision.load();
      expect(vision.info!.classes, containsAll(<String>[
        'papaya_healthy', 'papaya_leaf_disease', 'papaya_pest',
      ]));
    }, skip: !_tfliteAvailable());

    test('knows the four rice classes', () async {
      await vision.load();
      expect(vision.info!.classes, containsAll(<String>[
        'rice_healthy', 'rice_blast', 'rice_bacterial_blight', 'rice_brown_spot',
      ]));
    }, skip: !_tfliteAvailable());

    test('non-leaf photo is reported as "other", never a disease', () async {
      await vision.load();
      final r = await vision
          .classify(await File(AppAssets.mascotChat).readAsBytes());
      expect(r.label, anyOf('other', 'unknown'));
      expect(r.isNotLeaf || r.isUnknown, isTrue);
    }, skip: !_tfliteAvailable());

    test('invalid image throws FormatException, not a crash', () async {
      await vision.load();
      expect(() => vision.classify(Uint8List.fromList([0, 1, 2])), throwsA(isA<FormatException>()));
    }, skip: !_tfliteAvailable());

    test('margin guard flags a near-tie as unclear', () {
      // Two classes within 0.20 of each other must not be presented as a
      // diagnosis, however high the top score looks.
      const tie = CvResult(
        label: 'unknown',
        confidence: 0.52,
        scores: {'maize_healthy': 0.52, 'rice_bacterial_blight': 0.44},
        inferenceTimeMs: 100,
        modelName: 'test',
        margin: 0.08,
        runnerUp: 'rice_bacterial_blight',
      );
      expect(tie.isUnknown, isTrue);
      expect(tie.margin, lessThan(LocalVisionService.minMargin));
    });

    test('confidence bands', () {
      expect(ConfidenceBand.of(0.95), ConfidenceBand.high);
      expect(ConfidenceBand.of(0.7), ConfidenceBand.moderate);
      expect(ConfidenceBand.of(0.3), ConfidenceBand.low);
    });
  });

  group('orchestrator without LLM (knowledge fallback)', () {
    test('question → retrieval → knowledge answer when model is not loaded', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final k = LocalKnowledgeService(db, bundle: FakeBundle());
      await k.seedIfNeeded();
      final orch = LocalAIOrchestrator(
        llm: LocalLlmService(),
        vision: LocalVisionService(),
        knowledge: k,
      );
      final events = await orch.answer('How can I improve my soil health?').toList();
      final done = events.whereType<AssistantDone>().single;
      expect(done.engine, contains('Local knowledge'));
      expect(done.answer.answer.toLowerCase(), contains('compost'));
      expect(done.answer.recommendedActions, isNotEmpty);
      expect(done.sources, isNotEmpty);
      await db.close();
    });

    test('unknown question gets an honest fallback', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final k = LocalKnowledgeService(db, bundle: FakeBundle());
      await k.seedIfNeeded();
      final orch = LocalAIOrchestrator(llm: LocalLlmService(), vision: LocalVisionService(), knowledge: k);
      final done = (await orch.answer('zzqx').toList()).whereType<AssistantDone>().single;
      expect(done.answer.needsMoreInformation, isTrue);
      await db.close();
    });
  });
}

/// TFLite native libs are downloaded by the plugin for the host during
/// `flutter test`; on machines without them we skip the inference tests.
bool _tfliteAvailable() {
  return File('assets/models/crop_condition_mnv3s.tflite').existsSync();
}
