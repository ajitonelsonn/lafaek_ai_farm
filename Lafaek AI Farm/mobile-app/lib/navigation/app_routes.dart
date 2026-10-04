/// Named routes. Keep every navigation target here so routes can be verified
/// in one place.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String shell = '/shell';

  // Scan flow
  static const String scanAnalysis = '/scan/analysis';
  static const String scanResult = '/scan/result';

  // Primary (non-tab)
  static const String weather = '/weather';

  // Supporting
  static const String cropDetails = '/crop';
  static const String scanHistory = '/scan-history';
  static const String aiHistory = '/ai-history';
  static const String knowledge = '/knowledge';
  static const String knowledgeArticle = '/knowledge/article';
  static const String diseaseDetails = '/disease';
  static const String alerts = '/alerts';
  static const String farmActivity = '/activity';
  static const String logActivity = '/activity/log';
  static const String addCrop = '/add-crop';
  static const String addLocation = '/add-location';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String language = '/language';
  static const String offlineSync = '/sync';
  static const String about = '/about';
  static const String reports = '/reports';
}

/// Bottom navigation tab indices.
class MainTab {
  MainTab._();
  static const int home = 0;
  static const int scan = 1;
  static const int assistant = 2;
  static const int farm = 3;
  static const int more = 4;
}
