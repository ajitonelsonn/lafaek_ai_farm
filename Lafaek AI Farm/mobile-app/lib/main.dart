import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'database/app_database.dart';
import 'navigation/app_router.dart';
import 'navigation/app_routes.dart';
import 'repositories/local_chat_repository.dart';
import 'repositories/local_farm_repository.dart';
import 'repositories/local_scan_repository.dart';
import 'repositories/local_sync_queue_service.dart';
import 'repositories/local_weather_service.dart';
import 'services/ai_service.dart';
import 'services/connectivity_service.dart';
import 'services/local_ai/local_ai_engine.dart';
import 'state/chat_state.dart';
import 'state/connectivity_state.dart';
import 'l10n/strings.dart';
import 'state/farm_state.dart';
import 'state/language_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));
  runApp(const LafaekApp());
}

/// Composition root: database → repositories → local AI → state → UI.
///
/// Everything here runs on the phone. The cloud engine is constructed but
/// disabled (`cloudEnabled: false`) until the AWS phase.
class LafaekApp extends StatelessWidget {
  const LafaekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ---- Local platform ----
        Provider<AppDatabase>(
          create: (_) => AppDatabase(),
          dispose: (_, db) => db.close(),
        ),
        Provider<LocalSyncQueueService>(
          create: (ctx) => LocalSyncQueueService(ctx.read<AppDatabase>()),
        ),
        Provider<LocalFarmRepository>(
          create: (ctx) => LocalFarmRepository(
            ctx.read<AppDatabase>(),
            sync: ctx.read<LocalSyncQueueService>(),
          ),
        ),
        Provider<LocalScanRepository>(
          create: (ctx) => LocalScanRepository(
            ctx.read<AppDatabase>(),
            sync: ctx.read<LocalSyncQueueService>(),
          ),
        ),
        Provider<LocalChatRepository>(
          create: (ctx) => LocalChatRepository(
            ctx.read<AppDatabase>(),
            sync: ctx.read<LocalSyncQueueService>(),
          ),
        ),
        Provider<LocalWeatherService>(
          create: (ctx) => LocalWeatherService(ctx.read<AppDatabase>()),
        ),
        ChangeNotifierProvider<LanguageState>(
          create: (ctx) => LanguageState(ctx.read<AppDatabase>()),
        ),
        ChangeNotifierProvider<LocalAiEngine>(
          create: (ctx) => LocalAiEngine(db: ctx.read<AppDatabase>()),
        ),
        Provider<ConnectivityService>(
          create: (_) => DeviceConnectivityService(),
          dispose: (_, s) => s.dispose(),
        ),

        // ---- State ----
        ChangeNotifierProvider<ConnectivityState>(
          create: (ctx) => ConnectivityState(
            connectivity: ctx.read<ConnectivityService>(),
            localAI: LocalAIService(
              engine: ctx.read<LocalAiEngine>(),
              scans: ctx.read<LocalScanRepository>(),
            ),
            cloudAI: CloudAIService(),
            cloudEnabled: false,
            syncQueue: ctx.read<LocalSyncQueueService>(),
          ),
        ),
        ChangeNotifierProvider<FarmState>(
          create: (ctx) {
            final state = FarmState(
              farm: ctx.read<LocalFarmRepository>(),
              scans: ctx.read<LocalScanRepository>(),
              weather: ctx.read<LocalWeatherService>(),
              onDataChanged: () => ctx.read<ConnectivityState>().refreshPending(),
            );
            _bootstrap(ctx, state);
            return state;
          },
        ),
        ChangeNotifierProvider<ChatState>(
          create: (ctx) => ChatState(
            connectivity: ctx.read<ConnectivityState>(),
            repo: ctx.read<LocalChatRepository>(),
            farmContext: () => ctx.read<FarmState>().farmContext(),
            onDataChanged: () => ctx.read<ConnectivityState>().refreshPending(),
          )..load(),
        ),
      ],
      child: Consumer<LanguageState>(
        builder: (context, lang, _) => LanguageScope(
          language: lang.language,
          child: MaterialApp(
        title: 'Lafaek AI Farm',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
        builder: (context, child) {
          // Clamp system text scaling so layouts stay intact while still
          // honouring larger-text accessibility settings.
          final mq = MediaQuery.of(context);
          final scale = mq.textScaler.clamp(
            minScaleFactor: 0.9,
            maxScaleFactor: 1.25,
          );
          return MediaQuery(
            data: mq.copyWith(textScaler: scale),
            child: child!,
          );
        },
          ),
        ),
      ),
    );
  }

  /// Start-up sequence: language → knowledge + vision → farm data.
  ///
  /// No demo seed. A new installation starts empty and the splash sends the
  /// farmer to onboarding, so every record in the app is one they created.
  /// The LLM is loaded lazily on first use.
  static Future<void> _bootstrap(BuildContext ctx, FarmState farm) async {
    final engine = ctx.read<LocalAiEngine>();
    // Wire the measured connection into the AI router now that every provider
    // exists. Until this runs the engine assumes offline and stays local.
    engine.networkQuality = () => ctx.read<ConnectivityState>().quality;
    await ctx.read<LanguageState>().load();
    await engine.initialize();
    await farm.load();
  }
}
