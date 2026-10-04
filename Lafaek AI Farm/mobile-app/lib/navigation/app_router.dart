import 'package:flutter/material.dart';

import '../models/models.dart';
import '../screens/farm/add_crop_screen.dart';
import '../screens/farm/add_location_screen.dart';
import '../screens/farm/crop_details_screen.dart';
import '../screens/farm/farm_activity_screen.dart';
import '../screens/farm/log_activity_screen.dart';
import '../screens/farm/reports_screen.dart';
import '../screens/more/about_screen.dart';
import '../screens/more/ai_history_screen.dart';
import '../screens/more/alerts_screen.dart';
import '../screens/more/disease_details_screen.dart';
import '../screens/more/knowledge_article_screen.dart';
import '../screens/more/knowledge_screen.dart';
import '../screens/more/language_screen.dart';
import '../screens/more/offline_sync_screen.dart';
import '../screens/more/profile_screen.dart';
import '../screens/more/scan_history_screen.dart';
import '../screens/more/settings_screen.dart';
import '../screens/scan/scan_analysis_screen.dart';
import '../screens/scan/scan_request.dart';
import '../screens/scan/scan_result_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/weather/weather_screen.dart';
import 'app_routes.dart';
import 'main_shell.dart';

/// Single place that maps route names → screens.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case AppRoutes.onboarding:
        return _page(const OnboardingScreen(), settings);
      case AppRoutes.splash:
        return _fade(const SplashScreen(), settings);
      case AppRoutes.shell:
        return _fade(
          MainShell(initialIndex: args is int ? args : MainTab.home),
          settings,
        );

      case AppRoutes.scanAnalysis:
        return _page(
          ScanAnalysisScreen(
            request: args is ScanRequest
                ? args
                : ScanRequest(assetPath: args is String ? args : null, sourceLabel: 'Sample photo'),
          ),
          settings,
        );
      case AppRoutes.scanResult:
        return _page(ScanResultScreen(result: args as ScanResult), settings);

      case AppRoutes.weather:
        return _page(const WeatherScreen(), settings);

      case AppRoutes.cropDetails:
        return _page(CropDetailsScreen(crop: args as Crop), settings);
      case AppRoutes.scanHistory:
        return _page(const ScanHistoryScreen(), settings);
      case AppRoutes.aiHistory:
        return _page(const AiHistoryScreen(), settings);
      case AppRoutes.knowledge:
        return _page(
          KnowledgeScreen(
            initialCategory: args is KnowledgeCategory ? args : null,
          ),
          settings,
        );
      case AppRoutes.knowledgeArticle:
        return _page(
          KnowledgeArticleScreen(article: args as KnowledgeArticle),
          settings,
        );
      case AppRoutes.diseaseDetails:
        return _page(
          DiseaseDetailsScreen(diseaseName: args as String),
          settings,
        );
      case AppRoutes.alerts:
        return _page(const AlertsScreen(), settings);
      case AppRoutes.farmActivity:
        return _page(const FarmActivityScreen(), settings);
      case AppRoutes.logActivity:
        return _page(const LogActivityScreen(), settings);
      case AppRoutes.addCrop:
        return _page(const AddCropScreen(), settings);
      case AppRoutes.addLocation:
        return _page(const AddLocationScreen(), settings);
      case AppRoutes.reports:
        return _page(const ReportsScreen(), settings);
      case AppRoutes.settings:
        return _page(const SettingsScreen(), settings);
      case AppRoutes.profile:
        return _page(const ProfileScreen(), settings);
      case AppRoutes.language:
        return _page(const LanguageScreen(), settings);
      case AppRoutes.offlineSync:
        return _page(const OfflineSyncScreen(), settings);
      case AppRoutes.about:
        return _page(const AboutScreen(), settings);
    }
    return _page(const SplashScreen(), settings);
  }

  static MaterialPageRoute<T> _page<T>(Widget child, RouteSettings settings) =>
      MaterialPageRoute<T>(builder: (_) => child, settings: settings);

  static PageRoute<T> _fade<T>(Widget child, RouteSettings settings) =>
      PageRouteBuilder<T>(
        settings: settings,
        pageBuilder: (_, __, ___) => child,
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      );
}
