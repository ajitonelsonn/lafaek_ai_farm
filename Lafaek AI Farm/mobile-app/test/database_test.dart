import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lafaek_ai_farm/database/app_database.dart';
import 'package:lafaek_ai_farm/models/models.dart';
import 'package:lafaek_ai_farm/repositories/local_chat_repository.dart';
import 'package:lafaek_ai_farm/repositories/local_farm_repository.dart';
import 'package:lafaek_ai_farm/repositories/local_scan_repository.dart';
import 'package:lafaek_ai_farm/services/cloud/online_analysis_service.dart';
import 'package:lafaek_ai_farm/repositories/local_sync_queue_service.dart';
import 'package:lafaek_ai_farm/services/local_ai/local_knowledge_service.dart';

import 'support/fake_bundle.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late LocalSyncQueueService sync;
  late LocalFarmRepository farm;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    sync = LocalSyncQueueService(db);
    farm = LocalFarmRepository(db, sync: sync, knowledge: LocalKnowledgeService(db, bundle: FakeBundle()));
  });

  tearDown(() => db.close());

  group('database', () {
    test('creates schema at version 1 and stores metadata', () async {
      expect(db.schemaVersion, 3);
      await db.setMeta('k', 'v');
      expect(await db.getMeta('k'), 'v');
      expect(await db.getMeta('missing'), isNull);
    });

    test('create farmer + farm, then read back', () async {
      final id = await farm.farmId();
      expect(id, 'farm-local');
      final f = await farm.farmer();
      expect(f.name, 'Farmer');
      await farm.updateProfile(name: 'Maria', location: 'Baucau');
      final f2 = await farm.farmer();
      expect(f2.name, 'Maria');
      expect(f2.location, 'Baucau');
    });

    test('add crop persists and is queued for sync', () async {
      await farm.addCrop(Crop(
        id: 'c1',
        name: 'Maize',
        areaHa: 1.5,
        status: HealthStatus.healthy,
        plantedOn: DateTime(2026, 1, 1),
        locationName: 'Home field',
      ));
      final crops = await farm.crops();
      expect(crops.single.name, 'Maize');
      expect(crops.single.areaHa, 1.5);
      final pending = await sync.pending();
      expect(pending.where((r) => r.entityType == 'crop').length, 1);
      expect(jsonDecode(pending.first.payload)['name'], 'Maize');
    });

    test('add location and activity', () async {
      await farm.addLocation(const FarmLocation(id: 'l1', name: 'River', areaHa: 0.8, district: 'Dili'));
      await farm.logActivity(FarmActivity(
        id: 'a1',
        type: ActivityType.watered,
        title: 'Watered tomatoes',
        detail: '0.5 ha',
        date: DateTime(2026, 2, 2),
        cropName: 'Tomato',
      ));
      expect((await farm.locations()).single.name, 'River');
      expect((await farm.activities()).single.type, ActivityType.watered);
    });

    test('an unknown scan keeps Claude\'s identification', () async {
      // The on-device model could not place the leaf. Claude looked at the
      // photo, and that reading has to survive leaving the screen — otherwise
      // the farmer sees "Unknown crop" in their history forever.
      final scans = LocalScanRepository(db, sync: sync);
      await scans.saveAnalysis(CropAnalysis(
        id: 's-unknown',
        crop: 'Unknown crop',
        condition: 'unknown',
        conditionLabel: 'Possible crop issue (unclear photo)',
        confidence: 0.46,
        confidenceBand: 'Low confidence',
        severity: 'Uncertain',
        affectedArea: 'Unclear',
        growthStage: 'Not recorded',
        explanation: 'The image is not clear enough.',
        recommendedActions: const [],
        modelName: 'MobileNetV3-Small v1.2.0-dev',
        inferenceTimeMs: 1400,
        createdAt: DateTime(2026, 10, 4),
        imagePath: '/tmp/papaya.jpg',
        status: HealthStatus.monitor,
        explanationEngine: 'Local knowledge',
        margin: 0.04,
        runnerUp: 'papaya_leaf_disease',
      ));

      await scans.attachOnlineIdentification(
        's-unknown',
        const OnlineIdentification(
          model: 'claude-haiku-4-5-20251001',
          crop: 'Papaya',
          condition: 'Possible leaf curl virus',
          summary: 'Young leaves curl and thicken.',
          actions: ['Check for whitefly on the leaf underside'],
          confidence: 'moderate',
          askAPerson: true,
          caveat: 'Confirm with an extension officer.',
          elapsedMs: 3200,
        ),
      );

      final stored = await scans.onlineIdentificationFor('s-unknown');
      expect(stored, isNotNull);
      expect(stored!.crop, 'Papaya');
      expect(stored.condition, 'Possible leaf curl virus');
      expect(stored.actions.single, contains('whitefly'));
      expect(stored.askAPerson, isTrue);

      // And the history now shows the real crop instead of "Unknown".
      final history = await scans.history();
      final row = history.firstWhere((r) => r.id == 's-unknown');
      expect(row.cropName, 'Papaya');
      expect(row.issue, 'Possible leaf curl virus');
    });

    test('save scan and mark saved to farm', () async {
      final scans = LocalScanRepository(db, sync: sync);
      final a = CropAnalysis(
        id: 's1',
        crop: 'Maize',
        condition: 'maize_leaf_blight',
        conditionLabel: 'Possible Leaf Blight',
        confidence: 0.87,
        confidenceBand: 'High confidence',
        severity: 'Moderate',
        affectedArea: 'Seen on the photographed leaf',
        growthStage: 'Vegetative',
        explanation: 'Signs may be consistent with leaf blight.',
        recommendedActions: const [RecommendedAction(title: 'Remove leaves', detail: 'Lower ones')],
        modelName: 'MobileNetV3-Small v1.0.0-dev',
        inferenceTimeMs: 120,
        createdAt: DateTime(2026, 3, 3),
        imagePath: '/tmp/scan.jpg',
        status: HealthStatus.atRisk,
        explanationEngine: 'Llama 3.2 1B',
      );
      final saved = await scans.saveAnalysis(a);
      expect(saved.pendingSync, isTrue);
      expect(saved.savedToFarm, isFalse);
      await scans.markSavedToFarm('s1');
      final row = await scans.byId('s1');
      expect(row!.savedToFarm, isTrue);
      expect(row.actions.single.title, 'Remove leaves');
      expect(row.modelName, contains('MobileNetV3'));
      expect(await scans.count(), 1);
    });

    test('save chat and page messages', () async {
      final chat = LocalChatRepository(db, sync: sync);
      final id = await chat.createConversation('Yellow leaves');
      for (var i = 0; i < 5; i++) {
        await chat.addMessage(
          id,
          ChatMessage(
            id: 'm$i',
            role: i.isEven ? ChatRole.user : ChatRole.assistant,
            text: 'message $i',
            sentAt: DateTime(2026, 1, 1, 10, i),
            engine: i.isEven ? null : 'Llama 3.2 1B',
          ),
        );
      }
      final page1 = await chat.messages(id, limit: 2);
      expect(page1.map((m) => m.text), ['message 0', 'message 1']);
      final page2 = await chat.messages(id, limit: 2, offset: 2);
      expect(page2.map((m) => m.text), ['message 2', 'message 3']);
      final convs = await chat.conversations();
      expect(convs.single.preview, 'message 4');
    });

    test('a fresh install is empty and asks for onboarding', () async {
      // The app used to seed a demo farm here. It no longer does: the
      // challenge asks for real farmer data, so a new installation starts
      // with nothing and the splash routes to onboarding.
      expect(await farm.needsOnboarding(), isTrue);
      expect(await farm.crops(), isEmpty);
      expect(await db.scanDao.recent(), isEmpty);
    });

    test('onboarding creates the farmer, farm, field and first crop',
        () async {
      await farm.createFarmer(
          name: 'Maria da Costa', location: 'Ermera', phone: '+670 7723 4567');
      expect(await farm.needsOnboarding(), isFalse);

      await farm.addLocation(const FarmLocation(
          id: 'loc-1', name: 'Hill plot', areaHa: 0.8, district: 'Ermera'));
      await farm.addCrop(Crop(
        id: 'crop-1',
        name: 'Maize',
        areaHa: 0.8,
        status: HealthStatus.healthy,
        plantedOn: DateTime.now(),
        locationName: 'Hill plot',
      ));

      final f = await farm.farmer();
      expect(f.name, 'Maria da Costa');
      expect(f.location, 'Ermera');
      expect((await farm.locations()).single.name, 'Hill plot');
      expect((await farm.crops()).single.name, 'Maize');
    });

    test('data survives close and reopen (restart simulation)', () async {
      // Use a shared in-memory DB via a file-backed temp database instead.
      final file = await _tempFile();
      final db1 = AppDatabase.forTesting(NativeDatabase(file));
      final farm1 = LocalFarmRepository(db1, sync: LocalSyncQueueService(db1),
          knowledge: LocalKnowledgeService(db1, bundle: FakeBundle()));
      await farm1.addCrop(Crop(
        id: 'c-persist',
        name: 'Rice',
        areaHa: 1,
        status: HealthStatus.monitor,
        plantedOn: DateTime(2026, 1, 1),
        locationName: 'Paddy',
      ));
      await db1.close();

      final db2 = AppDatabase.forTesting(NativeDatabase(file));
      final farm2 = LocalFarmRepository(db2, sync: LocalSyncQueueService(db2),
          knowledge: LocalKnowledgeService(db2, bundle: FakeBundle()));
      final crops = await farm2.crops();
      expect(crops.single.id, 'c-persist');
      expect(crops.single.status, HealthStatus.monitor);
      final queue = await LocalSyncQueueService(db2).pending();
      expect(queue.length, 1, reason: 'outbox survives restart');
      await db2.close();
      if (await file.exists()) await file.delete();
    });
  });

  group('sync queue', () {
    test('enqueue, dry-run sync keeps rows and records status', () async {
      await sync.enqueue(entityType: 'scan', entityId: 's1', operation: 'create', payload: {'a': 1});
      await sync.enqueue(entityType: 'chat', entityId: 'm1', operation: 'create', payload: {'b': 2});
      expect(await sync.pendingCount(), 2);
      final items = await sync.pendingItems();
      expect(items.map((i) => i.label), containsAll(['crop scan', 'AI conversation']));

      // Upload is disabled in this phase: rows become `failed` with a reason,
      // attempt counts increase, nothing is deleted.
      final emitted = await sync.sync(items).toList();
      expect(emitted.every((i) => i.count == 0), isTrue);
      final rows = await sync.all();
      expect(rows.length, 2);
      expect(rows.every((r) => r.status == 'failed'), isTrue);
      expect(rows.every((r) => r.attemptCount == 1), isTrue);
      expect(rows.first.errorMessage, contains('not enabled'));
      expect(await sync.pendingCount(), 2, reason: 'failed rows are still pending');
    });

    test('markSynced removes from pending and clearSynced deletes', () async {
      final id = await sync.enqueue(entityType: 'crop', entityId: 'c', operation: 'create', payload: {});
      await db.syncDao.markSynced(id);
      expect(await sync.pendingCount(), 0);
      expect(await sync.clearSynced(), 1);
    });
  });

  group('knowledge', () {
    test('seeds from bundled JSON and searches with TF-IDF', () async {
      final k = LocalKnowledgeService(db, bundle: FakeBundle());
      final n = await k.seedIfNeeded();
      expect(n, greaterThan(30));
      expect(await k.seedIfNeeded(), n, reason: 'idempotent');

      final blight = await k.search('my maize leaves have long grey lesions', limit: 3);
      expect(blight.first.article.id, 'maize_leaf_blight');

      final yellow = await k.search('why are my maize leaves turning yellow');
      expect(yellow.map((h) => h.article.id), contains('maize_nutrient_stress'));

      final water = await k.search('how much water do tomatoes need');
      expect(water.first.article.category, anyOf('irrigation', 'crop'));

      final worm = await k.search('caterpillar holes in leaves', cropHint: 'maize');
      expect(worm.first.article.id, 'fall_armyworm');

      expect(await k.search('   '), isEmpty);
      final byCondition = await k.forCondition('maize_leaf_rust');
      expect(byCondition!.title, 'Maize Leaf Rust');
      expect(byCondition.actions, isNotEmpty);
      expect(byCondition.toModel().sections, isNotEmpty);
    });

    test('tokenizer stems and drops stop words', () {
      expect(LocalKnowledgeService.tokenize('The leaves are yellowing'), ['leaf', 'yellow']);
      expect(LocalKnowledgeService.stem('diseases'), 'disease');
      expect(LocalKnowledgeService.stem('planted'), 'plant');
    });
  });
}

Future<File> _tempFile() async {
  final dir = await Directory.systemTemp.createTemp('lafaek_test');
  return File('${dir.path}/lafaek.sqlite');
}
