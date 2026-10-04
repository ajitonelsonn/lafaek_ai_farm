import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../database/app_database.dart';
import '../../models/models.dart';
import 'llm_output_parser.dart';
import 'llm_prompt_builder.dart';
import '../cloud/ai_router.dart';
import '../cloud/online_analysis_service.dart' as cloud;
import '../cloud/online_analysis_service.dart' show OnlineAnalysisService;
import '../connectivity_service.dart';
import 'local_knowledge_service.dart';
import 'local_llm_service.dart';
import 'local_risk_engine.dart';
import 'local_vision_service.dart';

/// Events emitted while answering a question.
sealed class AssistantEvent {
  const AssistantEvent();
}

/// Status line for the UI ("Preparing local AI…", "Searching knowledge…").
class AssistantStatus extends AssistantEvent {
  const AssistantStatus(this.message);
  final String message;
}

/// Growing visible answer text while the model streams.
class AssistantPartial extends AssistantEvent {
  const AssistantPartial(this.text);
  final String text;
}

/// Final structured answer.
class AssistantDone extends AssistantEvent {
  const AssistantDone({
    required this.answer,
    required this.engine,
    required this.sources,
    required this.elapsedMs,
  });
  final StructuredAnswer answer;

  /// "Llama 3.2 1B" or "Local knowledge (model not loaded)".
  final String engine;
  final List<String> sources;
  final int elapsedMs;
}

/// Events emitted during a crop scan.
sealed class ScanEvent {
  const ScanEvent();
}

class ScanStep extends ScanEvent {
  const ScanStep(this.step);
  final AnalysisStepKind step;
}

class ScanDone extends ScanEvent {
  const ScanDone(this.analysis);
  final CropAnalysis analysis;
}

enum AnalysisStepKind {
  identifyingCrop,
  checkingLeafHealth,
  detectingDiseases,
  preparingRecommendations,
}

/// Combines the specialised local components (spec §17):
///
/// * question → retrieval → farm context → Llama → structured answer
/// * image → CV → knowledge → Llama → explanation + actions
/// * farm context → risk engine → knowledge → (optional) Llama explanation
///
/// Every path has a knowledge-only fallback so the app still answers when the
/// LLM is not installed, clearly labelled as such.
class LocalAIOrchestrator {
  LocalAIOrchestrator({
    required LocalLlmService llm,
    required LocalVisionService vision,
    required LocalKnowledgeService knowledge,
    LocalRiskEngine risk = const LocalRiskEngine(),
    LlmPromptBuilder prompts = const LlmPromptBuilder(),
    LlmOutputParser parser = const LlmOutputParser(),
    Future<void> Function()? ensureLlm,
    OnlineAnalysisService online = const OnlineAnalysisService(),
    NetworkQuality Function()? networkQuality,
  })  : _llm = llm,
        _online = online,
        _networkQuality = networkQuality,
        _vision = vision,
        _knowledge = knowledge,
        _risk = risk,
        _prompts = prompts,
        _parser = parser,
        _ensureLlm = ensureLlm;

  final LocalLlmService _llm;
  final LocalVisionService _vision;
  final LocalKnowledgeService _knowledge;
  final LocalRiskEngine _risk;
  final LlmPromptBuilder _prompts;
  final LlmOutputParser _parser;
  final OnlineAnalysisService _online;

  /// Reads the measured connection. Null in tests, which keeps everything
  /// local — the cloud is never reached by accident.
  final NetworkQuality Function()? _networkQuality;

  /// Lazily loads the LLM (provided by the engine). May complete with the
  /// model still unavailable; we then fall back to knowledge.
  final Future<void> Function()? _ensureLlm;

  static const String knowledgeEngine = 'Local knowledge';

  // ------------------------------------------------------------------
  // Text question
  // ------------------------------------------------------------------

  Stream<AssistantEvent> answer(
    String question, {
    FarmContext? farm,
    List<LlmTurn> history = const [],
    String language = 'en',
  }) async* {
    final sw = Stopwatch()..start();
    yield const AssistantStatus('Searching local knowledge…');
    final hits = await _knowledge.search(question, limit: 3, cropHint: _cropHint(question, farm));
    final sources = hits.map((h) => h.article.title).toList();

    if (!_llm.isReady && _ensureLlm != null) {
      yield const AssistantStatus('Preparing local AI…');
      try {
        await _ensureLlm();
      } catch (e) {
        debugPrint('ensureLlm failed: $e');
      }
    }

    // Route before doing any work. The offline library answers when it
    // genuinely has the answer; Claude is asked only when it does not and the
    // link measured fast; the on-device model covers everything else.
    final bestScore = hits.isEmpty ? 0.0 : hits.first.score;
    final quality = _networkQuality?.call() ?? NetworkQuality.none;
    final route = AiRouter.forQuestion(
      quality: quality,
      knowledgeScore: bestScore,
      localModelReady: _llm.isReady,
    );

    if (route == AiRoute.cloud) {
      yield const AssistantStatus('Asking Claude…');
      final reply = await _online.ask(
        question: question,
        farm: cloud.FarmContext(
          crop: farm?.crops.isNotEmpty == true ? farm!.crops.first : '',
          location: farm?.location ?? '',
          soilMoisture: farm?.weatherSummary ?? '',
        ),
        knowledge: hits.isEmpty ? '' : hits.first.article.summary,
        language: language,
      );
      if (reply != null && reply.answer.trim().isNotEmpty) {
        yield AssistantDone(
          answer: StructuredAnswer(
            answer: reply.answer,
            recommendedActions: reply.actions,
            needsMoreInformation: reply.askAPerson,
            structured: true,
          ),
          engine: 'Claude Haiku (online)',
          sources: sources,
          elapsedMs: sw.elapsedMilliseconds,
        );
        return;
      }
      // Claude unreachable — carry on down the local path.
      debugPrint('online ask failed, answering locally');
    }

    if (!_llm.isReady) {
      // Knowledge-only fallback: honest, deterministic, no model.
      yield AssistantDone(
        answer: _knowledgeOnlyAnswer(question, hits),
        engine: '$knowledgeEngine (model not loaded)',
        sources: sources,
        elapsedMs: sw.elapsedMilliseconds,
      );
      return;
    }

    yield AssistantStatus('Thinking with ${_llm.displayName}…');
    final userTurn = _prompts.question(question: question, knowledge: hits, farm: farm);
    final turns = [..._trimHistory(history), LlmTurn.user(userTurn)];
    final buf = StringBuffer();
    try {
      await for (final tok in _llm.generate(
        system: LlmPromptBuilder.systemPrompt,
        turns: turns,
        maxTokens: 360,
      )) {
        buf.write(tok);
        final visible = _parser.partialAnswer(buf.toString());
        if (visible.isNotEmpty) yield AssistantPartial(visible);
      }
    } catch (e, st) {
      debugPrint('LLM generation failed: $e\n$st');
      if (buf.isEmpty) {
        yield AssistantDone(
          answer: _knowledgeOnlyAnswer(question, hits),
          engine: '$knowledgeEngine (model error)',
          sources: sources,
          elapsedMs: sw.elapsedMilliseconds,
        );
        return;
      }
    }
    final parsed = _parser.parse(buf.toString());
    yield AssistantDone(
      answer: parsed,
      engine: _llm.displayName,
      sources: sources,
      elapsedMs: sw.elapsedMilliseconds,
    );
  }

  StructuredAnswer _knowledgeOnlyAnswer(String question, List<KnowledgeHit> hits) {
    if (hits.isEmpty) {
      return const StructuredAnswer(
        answer:
            'I could not find this in the local farming library. Try asking about a specific crop, pest, disease, soil or watering question — or check with your local extension officer.',
        recommendedActions: ['Rephrase with the crop name', 'Ask your extension officer'],
        needsMoreInformation: true,
        structured: false,
      );
    }
    final a = hits.first.article;
    final b = StringBuffer(a.summary);
    final sym = a.symptoms.take(3).toList();
    if (sym.isNotEmpty) b.write('\n\nSigns to look for: ${sym.join('; ')}.');
    if (hits.length > 1) {
      b.write('\n\nAlso see: ${hits.skip(1).map((h) => h.article.title).join(', ')}.');
    }
    return StructuredAnswer(
      answer: b.toString(),
      confidence: hits.first.score.clamp(0.0, 1.0),
      category: _categoryFor(a.category),
      recommendedActions: a.actions.take(4).toList(),
      structured: false,
    );
  }

  static String _categoryFor(String c) {
    switch (c) {
      case 'disease':
        return 'disease';
      case 'pest':
        return 'pest';
      case 'soil':
        return 'soil';
      case 'irrigation':
        return 'water';
      case 'planting':
        return 'planting';
      case 'climate':
        return 'weather';
      default:
        return 'general';
    }
  }

  static String? _cropHint(String q, FarmContext? farm) {
    final l = q.toLowerCase();
    for (final c in ['maize', 'corn', 'rice', 'tomato', 'chili', 'chilli', 'beans', 'cassava']) {
      if (l.contains(c)) return c == 'corn' ? 'maize' : (c == 'chilli' ? 'chili' : c);
    }
    return null;
  }

  /// Keep the last few turns so a 2k context is never overflowed.
  static List<LlmTurn> _trimHistory(List<LlmTurn> h) {
    const keep = 4;
    final list = h.length > keep ? h.sublist(h.length - keep) : h;
    return list
        .map((t) => t.content.length > 600
            ? (t.role == 'user'
                ? LlmTurn.user('${t.content.substring(0, 600)}…')
                : LlmTurn.assistant('${t.content.substring(0, 600)}…'))
            : t)
        .toList();
  }

  // ------------------------------------------------------------------
  // Crop scan
  // ------------------------------------------------------------------

  Stream<ScanEvent> analyzeImage(
    Uint8List imageBytes, {
    required String imagePath,
    FarmContext? farm,
    CropRow? matchedCrop,
    bool explainWithLlm = true,
  }) async* {
    final sw = Stopwatch()..start();
    if (!_vision.isReady) await _vision.load();
    if (!_vision.isReady) {
      throw StateError(_vision.errorMessage ?? 'Vision model unavailable');
    }

    // 1. Identify crop + condition in one pass (single classifier).
    final cv = await _vision.classify(imageBytes);
    yield const ScanStep(AnalysisStepKind.identifyingCrop);
    yield const ScanStep(AnalysisStepKind.checkingLeafHealth);

    // 2. Knowledge lookup for the detected condition.
    final article = (cv.isUnknown || cv.isNotLeaf) ? null : await _knowledge.forCondition(_articleIdFor(cv));
    yield const ScanStep(AnalysisStepKind.detectingDiseases);

    // 3. Explanation: LLM when available, otherwise knowledge text.
    final label = _hedgedLabel(cv);
    var explanation = _knowledgeExplanation(cv, article);
    var actions = _knowledgeActions(cv, article);
    var engine = knowledgeEngine;

    if (explainWithLlm && !cv.isUnknown && !cv.isNotLeaf) {
      if (!_llm.isReady && _ensureLlm != null) {
        try {
          await _ensureLlm();
        } catch (_) {}
      }
      if (_llm.isReady) {
        try {
          final raw = await _llm.complete(
            system: LlmPromptBuilder.scanSystemPrompt,
            turns: [
              LlmTurn.user(_prompts.scan(
                cropName: cv.cropName,
                conditionLabel: label,
                confidence: cv.confidence,
                confidenceBand: cv.band.label,
                article: article,
                farm: farm,
              )),
            ],
            maxTokens: 260,
          );
          final parsed = _parser.parse(raw);
          if (parsed.answer.length > 40) {
            explanation = parsed.answer;
            engine = _llm.displayName;
            if (parsed.recommendedActions.isNotEmpty) {
              actions = _mergeActions(parsed.recommendedActions, actions);
            }
          }
        } catch (e) {
          debugPrint('scan explanation failed, using knowledge: $e');
        }
      }
    }
    yield const ScanStep(AnalysisStepKind.preparingRecommendations);

    final status = _statusFor(cv);
    final analysis = CropAnalysis(
      id: 'scan-${DateTime.now().millisecondsSinceEpoch}',
      crop: (cv.isUnknown || cv.isNotLeaf) ? (matchedCrop?.name ?? 'Unknown crop') : cv.cropName,
      condition: cv.isNotLeaf ? 'unknown' : cv.label,
      conditionLabel: label,
      confidence: cv.confidence,
      confidenceBand: cv.band.label,
      severity: _severity(cv),
      affectedArea: (cv.isUnknown || cv.isNotLeaf)
          ? 'Unclear'
          : cv.isHealthy
              ? 'None detected'
              : 'Seen on the photographed leaf',
      growthStage: matchedCrop?.growthStage ?? 'Not recorded',
      explanation: explanation,
      recommendedActions: actions,
      modelName: cv.modelName,
      inferenceTimeMs: cv.inferenceTimeMs,
      createdAt: DateTime.now(),
      imagePath: imagePath,
      status: status,
      explanationEngine: engine,
      sources: article == null ? const [] : [article.title],
      cropId: matchedCrop?.id,
      margin: cv.margin,
      runnerUp: cv.runnerUp,
    );
    debugPrint('scan: ${cv.label} ${(cv.confidence * 100).round()}% in ${cv.inferenceTimeMs} ms, total ${sw.elapsedMilliseconds} ms');
    yield ScanDone(analysis);
  }

  /// CV class id → knowledge article id.
  static String _articleIdFor(CvResult cv) {
    switch (cv.label) {
      case 'maize_healthy':
      case 'tomato_healthy':
      case 'rice_healthy':
      case 'papaya_healthy':
        return 'healthy_crop';
      case 'tomato_leaf_problem':
        return 'tomato_early_blight';
      case 'rice_blast':
        return 'rice_blast';
      case 'rice_bacterial_blight':
        return 'rice_bacterial_leaf_blight';
      case 'rice_brown_spot':
        return 'rice_brown_spot';
      case 'papaya_leaf_disease':
        return 'papaya_leaf_disease';
      case 'papaya_pest':
        return 'papaya_pest';
      default:
        return cv.label; // maize_leaf_blight / maize_leaf_rust / maize_leaf_spot
    }
  }

  static String _hedgedLabel(CvResult cv) {
    if (cv.isNotLeaf) return 'No leaf detected';
    if (cv.isUnknown) return 'Possible crop issue (unclear photo)';
    if (cv.isHealthy) return 'Healthy';
    final word = cv.band == ConfidenceBand.high ? 'Likely' : 'Possible';
    switch (cv.condition) {
      case 'leaf_blight':
        return '$word Leaf Blight';
      case 'leaf_rust':
        return '$word Leaf Rust';
      case 'leaf_spot':
        return cv.cropName == 'Maize' ? '$word Gray Leaf Spot' : '$word Leaf Spot';
      case 'leaf_problem':
        return '$word Leaf Disease';
      case 'blast':
        return '$word Rice Blast';
      case 'bacterial_blight':
        return '$word Bacterial Leaf Blight';
      case 'brown_spot':
        return '$word Brown Spot';
      case 'leaf_disease':
        // Papaya: leaf curl / mosaic / ring spot are all virus diseases, and
        // the advice is the same, so they are reported together.
        return '$word Papaya Leaf Virus';
      case 'pest':
        return '$word Mealybug or Mite Damage';
      default:
        return '$word ${cv.condition.replaceAll('_', ' ')}';
    }
  }

  static HealthStatus _statusFor(CvResult cv) {
    if (cv.isUnknown || cv.isNotLeaf) return HealthStatus.monitor;
    if (cv.isHealthy) return HealthStatus.healthy;
    return cv.band == ConfidenceBand.high ? HealthStatus.atRisk : HealthStatus.monitor;
  }

  static String _severity(CvResult cv) {
    if (cv.isUnknown || cv.isNotLeaf) return 'Uncertain';
    if (cv.isHealthy) return 'None';
    switch (cv.band) {
      case ConfidenceBand.high:
        return 'Moderate';
      case ConfidenceBand.moderate:
        return 'Mild';
      case ConfidenceBand.low:
        return 'Uncertain';
    }
  }

  static String _knowledgeExplanation(CvResult cv, KnowledgeArticleRow? a) {
    if (cv.isNotLeaf) {
      return 'This photo does not look like a close-up of a leaf, so no crop condition was checked. Point the camera at a single leaf, fill the frame, and try again.';
    }
    if (cv.isUnknown) {
      return 'The image is not clear enough to identify the problem confidently. Try another photo in better lighting, closer to the leaf, with the whole leaf in the frame.';
    }
    if (cv.isHealthy) {
      return 'Your ${cv.cropName.toLowerCase()} leaf looks healthy in this photo. Colour and texture are consistent with a well-watered, well-fed plant.';
    }
    final b = StringBuffer(
        'Signs in this photo may be consistent with ${a?.title.toLowerCase() ?? cv.condition.replaceAll('_', ' ')} (${cv.band.label.toLowerCase()}). ');
    if (a != null) b.write(a.summary);
    b.write(' This is a possible finding, not a confirmed diagnosis — check nearby plants and, if it spreads, ask your local extension officer.');
    return b.toString();
  }

  static List<RecommendedAction> _knowledgeActions(CvResult cv, KnowledgeArticleRow? a) {
    if (cv.isUnknown || cv.isNotLeaf) {
      return const [
        RecommendedAction(title: 'Retake the photo', detail: 'Good light, clear focus, whole leaf in the frame.'),
        RecommendedAction(title: 'Look under the leaf', detail: 'Check for insects, powder or spots.'),
        RecommendedAction(title: 'Ask the AI Assistant', detail: 'Describe what you see for more guidance.'),
      ];
    }
    final src = a?.actions ?? const <String>[];
    if (src.isEmpty) {
      return const [
        RecommendedAction(title: 'Keep monitoring', detail: 'Scan again in 7 days or if anything changes.'),
      ];
    }
    return src.take(4).map((s) => _splitAction(s)).toList();
  }

  static List<RecommendedAction> _mergeActions(List<String> fromLlm, List<RecommendedAction> fromKb) {
    final out = fromLlm.take(4).map(_splitAction).toList();
    for (final k in fromKb) {
      if (out.length >= 4) break;
      if (!out.any((o) => o.title.toLowerCase() == k.title.toLowerCase())) out.add(k);
    }
    return out;
  }

  static RecommendedAction _splitAction(String s) {
    final t = s.trim();
    final i = t.indexOf(RegExp(r'[:—–-]\s|\.\s'));
    if (i > 8 && i < 60) {
      return RecommendedAction(title: t.substring(0, i).trim(), detail: t.substring(i + 1).trim());
    }
    if (t.length <= 48) return RecommendedAction(title: t, detail: '');
    final cut = t.lastIndexOf(' ', 48);
    return RecommendedAction(title: '${t.substring(0, cut)}…', detail: t);
  }

  // ------------------------------------------------------------------
  // Risk
  // ------------------------------------------------------------------

  RiskAssessment assessRisk(RiskInputs inputs) => _risk.assess(inputs);

  /// Optional one-paragraph explanation of a risk from the LLM; returns null
  /// when the model is not loaded (the rule reasons are always available).
  Future<String?> explainRisk(RiskAssessment r, {FarmContext? farm}) async {
    if (!_llm.isReady) return null;
    try {
      final raw = await _llm.complete(
        system: LlmPromptBuilder.scanSystemPrompt,
        turns: [
          LlmTurn.user(_prompts.risk(
            cropName: r.cropName,
            level: r.level.label.toLowerCase(),
            reasons: r.reasons,
            farm: farm,
          )),
        ],
        maxTokens: 160,
      );
      final a = _parser.parse(raw).answer;
      return a.length > 20 ? a : null;
    } catch (_) {
      return null;
    }
  }
}
