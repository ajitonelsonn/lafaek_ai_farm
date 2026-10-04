import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lafaek_ai_farm/core/app_assets.dart';
import 'package:lafaek_ai_farm/database/app_database.dart';
import 'package:lafaek_ai_farm/models/models.dart';
import 'package:lafaek_ai_farm/navigation/app_router.dart';
import 'package:lafaek_ai_farm/navigation/app_routes.dart';
import 'package:lafaek_ai_farm/repositories/local_chat_repository.dart';
import 'package:lafaek_ai_farm/repositories/local_farm_repository.dart';
import 'package:lafaek_ai_farm/repositories/local_scan_repository.dart';
import 'package:lafaek_ai_farm/repositories/local_sync_queue_service.dart';
import 'package:lafaek_ai_farm/repositories/local_weather_service.dart';
import 'package:lafaek_ai_farm/services/ai_service.dart';
import 'package:lafaek_ai_farm/services/connectivity_service.dart';
import 'package:lafaek_ai_farm/services/local_ai/local_ai_engine.dart';
import 'package:lafaek_ai_farm/services/local_ai/local_knowledge_service.dart';
import 'package:lafaek_ai_farm/state/chat_state.dart';
import 'package:lafaek_ai_farm/state/connectivity_state.dart';
import 'package:lafaek_ai_farm/l10n/strings.dart';
import 'package:lafaek_ai_farm/state/farm_state.dart';
import 'package:lafaek_ai_farm/state/language_state.dart';
import 'package:lafaek_ai_farm/theme/app_theme.dart';
import 'package:provider/provider.dart';

import 'support/fake_bundle.dart';
import 'support/test_farm.dart';

/// Everything the real app wires in main.dart, but on an in-memory SQLite
/// database and a manual connectivity source. Vision runs for real (TFLite
/// on the host); the LLM is not installed so answers come from knowledge.
class TestApp {
  TestApp._(this.db, this.engine, this.farm, this.chat, this.conn, this.widget);

  final AppDatabase db;
  final LocalAiEngine engine;
  final FarmState farm;
  final ChatState chat;
  final ConnectivityState conn;
  final Widget widget;

  /// Must be called through `tester.runAsync` because the vision model spins
  /// up a real isolate, which never completes under the fake-async test zone.
  static Future<TestApp> create(
    WidgetTester tester, {
    required ManualConnectivityService connectivity,
    String initialRoute = AppRoutes.shell,
    Object? arguments,
  }) async {
    final app = await tester.runAsync(() => _create(
          connectivity: connectivity,
          initialRoute: initialRoute,
          arguments: arguments,
        ));
    return app!;
  }

  static Future<TestApp> _create({
    required ManualConnectivityService connectivity,
    required String initialRoute,
    Object? arguments,
  }) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await seedTestFarm(db);
    final sync = LocalSyncQueueService(db);
    final knowledge = LocalKnowledgeService(db, bundle: FakeBundle());
    final farmRepo = LocalFarmRepository(db, sync: sync, knowledge: knowledge);
    final scanRepo = LocalScanRepository(db, sync: sync);
    final chatRepo = LocalChatRepository(db, sync: sync);
    final weather = LocalWeatherService(db);
    final engine = LocalAiEngine(db: db, knowledge: knowledge);
    await engine.initialize();

    final conn = ConnectivityState(
      connectivity: connectivity,
      localAI: LocalAIService(engine: engine, scans: scanRepo),
      cloudAI: CloudAIService(),
      syncQueue: sync,
    );
    final farm = FarmState(
      farm: farmRepo,
      scans: scanRepo,
      weather: weather,
      onDataChanged: conn.refreshPending,
    );
    await farm.load();
    final chat = ChatState(
      connectivity: conn,
      repo: chatRepo,
      farmContext: farm.farmContext,
      onDataChanged: conn.refreshPending,
    );
    await chat.load();
    final language = LanguageState(db);
    await language.load();

    final widget = MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        Provider<LocalSyncQueueService>.value(value: sync),
        Provider<LocalFarmRepository>.value(value: farmRepo),
        Provider<LocalScanRepository>.value(value: scanRepo),
        Provider<LocalChatRepository>.value(value: chatRepo),
        Provider<LocalWeatherService>.value(value: weather),
        ChangeNotifierProvider<LocalAiEngine>.value(value: engine),
        ChangeNotifierProvider<ConnectivityState>.value(value: conn),
        ChangeNotifierProvider<FarmState>.value(value: farm),
        ChangeNotifierProvider<ChatState>.value(value: chat),
        ChangeNotifierProvider<LanguageState>.value(value: language),
      ],
      child: LanguageScope(
        language: language.language,
        child: MaterialApp(
        theme: AppTheme.light(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        onGenerateInitialRoutes: (route) => [
          AppRouter.onGenerateRoute(RouteSettings(name: route, arguments: arguments)),
        ],
        initialRoute: initialRoute,
        ),
      ),
    );
    return TestApp._(db, engine, farm, chat, conn, widget);
  }

  Future<void> dispose() async {
    engine.dispose();
    await db.close();
  }

  /// Disposal also touches the isolate; run it outside fake-async.
  static Future<void> disposeWith(WidgetTester tester, TestApp app) =>
      tester.runAsync(app.dispose);
}

Future<void> settle(WidgetTester tester, {int frames = 20}) async {
  // Bounded pump so repeating animations (spinners) don't hang pumpAndSettle.
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}


/// Route arguments for the navigation test.
///
/// Built here rather than taken from a shared sample-data file: the app no
/// longer ships one, because a new installation starts empty and every record
/// belongs to the farmer who created it.
ScanResult _sampleScan() => ScanResult(
      id: 'scan-test',
      cropName: 'Maize',
      imageAsset: AppAssets.sampleLeaf,
      issue: 'Possible Leaf Blight',
      confidence: 0.86,
      severity: 'Moderate',
      affectedArea: 'Lower leaves',
      growthStage: 'Vegetative',
      scannedAt: DateTime(2026, 10, 1),
      explanation: 'Test fixture.',
      actions: const [
        RecommendedAction(
            title: 'Remove affected leaves',
            detail: 'Take off the worst lower leaves.'),
      ],
      status: HealthStatus.monitor,
      engine: 'test',
    );

Crop _sampleCrop() => Crop(
      id: 'crop-test',
      name: 'Maize',
      areaHa: 1,
      status: HealthStatus.healthy,
      plantedOn: DateTime(2026, 9, 1),
      locationName: 'Home field',
    );

const KnowledgeArticle _sampleArticle = KnowledgeArticle(
  id: 'test-article',
  category: KnowledgeCategory.cropGuides,
  title: 'Test Article',
  summary: 'A fixture for the route test.',
  sections: [MapEntry('Heading', 'Body text.')],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sizes = [Size(360, 800), Size(390, 844), Size(412, 915)];

  for (final size in sizes) {
    testWidgets('bottom navigation reaches all five tabs at ${size.width.toInt()}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final app = await TestApp.create(tester, connectivity: ManualConnectivityService());
      addTearDown(() => TestApp.disposeWith(tester, app));

      await tester.pumpWidget(app.widget);
      await settle(tester);
      expect(find.text('Scan My Crop'), findsOneWidget);

      await tester.tap(find.text('Scan'));
      await settle(tester);
      expect(find.text('Scan Crop'), findsOneWidget);

      await tester.tap(find.text('AI Assistant').last);
      await settle(tester);
      expect(find.text('AI Assistant'), findsWidgets);

      await tester.tap(find.text('My Farm').last);
      await settle(tester);
      expect(find.text('My Farm Overview'), findsOneWidget);

      await tester.tap(find.text('More').last);
      await settle(tester);
      expect(find.text('Knowledge'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('every named route builds without error', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final routes = <String, Object?>{
      AppRoutes.weather: null,
      AppRoutes.scanResult: _sampleScan(),
      AppRoutes.cropDetails: _sampleCrop(),
      AppRoutes.scanHistory: null,
      AppRoutes.aiHistory: null,
      AppRoutes.knowledge: null,
      AppRoutes.knowledgeArticle: _sampleArticle,
      AppRoutes.diseaseDetails: 'Possible Leaf Blight',
      AppRoutes.alerts: null,
      AppRoutes.farmActivity: null,
      AppRoutes.logActivity: null,
      AppRoutes.addCrop: null,
      AppRoutes.addLocation: null,
      AppRoutes.reports: null,
      AppRoutes.settings: null,
      AppRoutes.profile: null,
      AppRoutes.language: null,
      AppRoutes.offlineSync: null,
      AppRoutes.about: null,
    };
    for (final entry in routes.entries) {
      final app = await TestApp.create(
        tester,
        connectivity: ManualConnectivityService(),
        initialRoute: entry.key,
        arguments: entry.value,
      );
      await tester.pumpWidget(app.widget);
      await settle(tester);
      expect(tester.takeException(), isNull, reason: 'route ${entry.key}');
      await tester.pumpWidget(const SizedBox());
      await TestApp.disposeWith(tester, app);
    }
  });

  testWidgets('scan flow: sample photo → real TFLite analysis → result persisted in SQLite', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final app = await TestApp.create(tester, connectivity: ManualConnectivityService(), arguments: MainTab.scan);
    addTearDown(() => TestApp.disposeWith(tester, app));
    expect(app.engine.visionReady, isTrue, reason: app.engine.visionError);

    await tester.pumpWidget(app.widget);
    await settle(tester);

    // No camera in tests → the shutter uses the bundled sample photo.
    await tester.tap(find.bySemanticsLabel('Take photo'));
    await settle(tester);
    expect(find.text('Analyze Crop'), findsOneWidget);

    final before = await app.db.scanDao.count();
    await tester.tap(find.text('Analyze Crop'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Analyzing your crop...'), findsOneWidget);
    expect(find.textContaining('Using Local AI'), findsOneWidget);

    // Real inference runs on a background isolate; give it time.
    for (var i = 0; i < 100 && find.text('Scan Result').evaluate().isEmpty; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Scan Result'), findsOneWidget);
    expect(find.textContaining('MobileNetV3'), findsWidgets);
    expect(await app.db.scanDao.count(), before + 1, reason: 'scan saved to SQLite');

    await tester.tap(find.text('Save to My Farm'));
    await settle(tester);
    expect(find.text('Saved to My Farm'), findsOneWidget);
    final saved = (await app.db.scanDao.recent(limit: 1)).single;
    expect(saved.savedToFarm, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('offline: app keeps working and status pill says Local AI', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final connectivity = ManualConnectivityService();
    final app = await TestApp.create(tester, connectivity: connectivity, arguments: MainTab.scan);
    addTearDown(() => TestApp.disposeWith(tester, app));

    await tester.pumpWidget(app.widget);
    await settle(tester);
    expect(find.textContaining('Local AI'), findsWidgets);

    connectivity.setOverride(NetworkQuality.none);
    await settle(tester);
    expect(find.textContaining("You're offline. Lafaek AI works fully on this phone."), findsOneWidget);
    expect(app.conn.ai, isA<LocalAIService>(), reason: 'local engine is always active');
    expect(tester.takeException(), isNull);
  });

  testWidgets('AI assistant answers from local knowledge and persists the chat', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final app = await TestApp.create(tester, connectivity: ManualConnectivityService(), arguments: MainTab.assistant);
    addTearDown(() => TestApp.disposeWith(tester, app));

    await tester.pumpWidget(app.widget);
    await settle(tester);

    await tester.enterText(find.byType(TextField), 'How can I improve my soil health?');
    await tester.tap(find.bySemanticsLabel('Send'));
    await tester.pump();
    for (var i = 0; i < 40 && app.chat.thinking; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await settle(tester);
    expect(find.textContaining(RegExp('compost', caseSensitive: false)), findsWidgets);
    expect(app.chat.engineLabel, contains('Local knowledge'));

    final convs = await app.db.chatDao.listConversations();
    final latest = convs.first;
    final msgs = await app.db.chatDao.listMessages(latest.id);
    expect(msgs.length, greaterThanOrEqualTo(2));
    expect(msgs.last.role, 'assistant');
    expect(tester.takeException(), isNull);
  });
}
