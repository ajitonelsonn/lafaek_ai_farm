import 'package:flutter/widgets.dart';

/// The languages the interface is available in.
///
/// Tetun is the national language of Timor-Leste and the one most farmers
/// actually speak at home; English is kept because agricultural extension
/// material and the knowledge library are written in it.
enum AppLanguage { english, tetun }

extension AppLanguageInfo on AppLanguage {
  /// The language's own name, as its speakers write it.
  String get nativeName => this == AppLanguage.tetun ? 'Tetun' : 'English';
  String get englishName => this == AppLanguage.tetun ? 'Tetun' : 'English';
  String get code => this == AppLanguage.tetun ? 'tet' : 'en';
  String get flag => this == AppLanguage.tetun ? '🇹🇱' : '🇬🇧';

  static AppLanguage fromCode(String? code) =>
      code == 'tet' ? AppLanguage.tetun : AppLanguage.english;
}

/// Interface strings.
///
/// Hand-written rather than generated: the app ships two languages and a
/// plain Dart map keeps Tetun reviewable by a native speaker in one file,
/// which matters more here than tooling. Every Tetun string below is a real
/// translation — nothing falls through to English silently, and
/// [S.missingTetun] lists anything still untranslated so the gap is visible
/// instead of hidden.
abstract class S {
  const S();

  static S of(BuildContext context) => _LanguageScope.of(context);

  /// Used by the About screen to state coverage honestly.
  static const int totalStrings = 96;

  AppLanguage get language;

  // ---- General ----
  String get appName;
  String get continueLabel;
  String get back;
  String get cancel;
  String get save;
  String get retry;
  String get loading;
  String get close;

  // ---- Navigation ----
  String get navHome;
  String get navScan;
  String get navAssistant;
  String get navFarm;
  String get navMore;

  // ---- Onboarding ----
  String get onboardingWelcomeTitle;
  String get onboardingWelcomeSubtitle;
  String get onboardingFarmTitle;
  String get onboardingFarmSubtitle;
  String get onboardingCropTitle;
  String get onboardingCropSubtitle;
  String get onboardingFinish;
  String get onboardingNoInternet;
  String get onboardingPinLater;
  String get onboardingSaveFailed;
  String get yourName;
  String get yourNameHint;
  String get yourNameRequired;
  String get phoneOptional;
  String get municipality;
  String get farmName;
  String get fieldName;
  String get fieldNameRequired;
  String get area;
  String get areaRequired;
  String cropScannable(String crop);
  String cropNotScannable(String crop);
  String get cropsWorkOffline;
  String get cropsNeedInternet;
  String cropOnlineOnly(String crop);
  String get cropOnlineOnlyOffline;
  String get worksOfflineBadge;
  String get needsInternetBadge;

  // ---- Home ----
  String greeting(String name);
  String get homeTagline;
  String get soilMoisture;
  String get cropRisk;
  String get cropsCount;
  String get next7Days;
  String get scanMyCrop;
  String get scanMyCropSub;
  String get askAssistant;
  String get askAssistantSub;
  String get todaysRecommendations;
  String get recentScans;
  String get noScansYet;
  String get noScansYetBody;

  // ---- Scan ----
  String get scanTitle;
  String get scanSubtitle;
  String get analysing;
  String get analysingLocal;
  String get photoStaysOnPhone;
  String resultLikely(String condition);
  String resultPossible(String condition);
  String get resultUnclear;
  String get resultUnclearBody;
  String get resultNoLeaf;
  String get resultNoLeafBody;
  String get askExtensionOfficer;
  String get confidenceHigh;
  String get confidenceModerate;
  String get confidenceLow;
  String get saveToMyFarm;
  String get whatToDo;

  // ---- Assistant ----
  String get assistantTitle;
  String get assistantSubtitle;
  String get assistantHello;
  String get assistantHelloBody;
  String get typeYourQuestion;
  String get suggestedQuestions;
  String get thinking;
  String get fromOfflineLibrary;
  String get modelNotLoaded;

  // ---- Farm ----
  String get myFarmTitle;
  String get myFarmSubtitle;
  String get totalArea;
  String get myCrops;
  String get addCrop;
  String get locations;
  String get activities;
  String get noCropsYet;
  String get noCropsYetBody;
  String get planted;

  // ---- Weather ----
  String get weatherTitle;
  String get weatherSubtitle;
  String get humidity;
  String get wind;
  String get rain;
  String get overallFarmRisk;
  String get rainThisWeek;
  String get forecastPoint;
  String updatedAgo(String ago);
  String get why;

  // ---- Status ----
  String get healthy;
  String get monitor;
  String get diseased;
  String get riskLow;
  String get riskMedium;
  String get riskHigh;
  String get offlineBanner;
  String get weakConnectionBanner;
  String get localAiReady;

  // ---- More ----
  String get moreTitle;
  String get knowledge;
  String get alerts;
  String get scanHistory;
  String get aiHistory;
  String get offlineAndSync;
  String get settings;
  String get profile;
  String get languageLabel;
  String get about;
  String get moreSubtitle;
  String get knowledgeSub;
  String get alertsSub;
  String alertsNew(int n);
  String scansCount(int n);
  String get aiHistorySub;
  String get settingsSub;
  String get profileSub;
  String get syncUpToDate;
  String get syncSavedHere;
  String syncWaiting(int n);

  /// Strings that have no Tetun translation yet, so the UI can say so rather
  /// than quietly showing English.
  List<String> get missingTetun => const [];
}

// ---------------------------------------------------------------------------

class EnglishStrings extends S {
  const EnglishStrings();

  @override
  AppLanguage get language => AppLanguage.english;

  @override
  String get appName => 'Lafaek AI Farm';
  @override
  String get continueLabel => 'Continue';
  @override
  String get back => 'Back';
  @override
  String get cancel => 'Cancel';
  @override
  String get save => 'Save';
  @override
  String get retry => 'Try again';
  @override
  String get loading => 'Loading…';
  @override
  String get close => 'Close';

  @override
  String get navHome => 'Home';
  @override
  String get navScan => 'Scan';
  @override
  String get navAssistant => 'AI Assistant';
  @override
  String get navFarm => 'My Farm';
  @override
  String get navMore => 'More';

  @override
  String get onboardingWelcomeTitle => 'Welcome';
  @override
  String get onboardingWelcomeSubtitle =>
      'Let\'s set up your farm. This takes a minute and works without internet.';
  @override
  String get onboardingFarmTitle => 'Your farm';
  @override
  String get onboardingFarmSubtitle =>
      'Name your farm and your first field, and say how big it is.';
  @override
  String get onboardingCropTitle => 'Your first crop';
  @override
  String get onboardingCropSubtitle =>
      'Choose what is growing. You can add more crops later.';
  @override
  String get onboardingFinish => 'Finish setup';
  @override
  String get onboardingNoInternet =>
      'Everything is saved on this phone. No internet needed.';
  @override
  String get onboardingPinLater =>
      'You can pin this field on the map later, to get the weather for your own land.';
  @override
  String get onboardingSaveFailed =>
      'Could not save your farm. Please try again.';
  @override
  String get yourName => 'Your name';
  @override
  String get yourNameHint => 'e.g. Maria da Costa';
  @override
  String get yourNameRequired => 'Please enter your name';
  @override
  String get phoneOptional => 'Phone (optional)';
  @override
  String get municipality => 'Municipality';
  @override
  String get farmName => 'Farm name';
  @override
  String get fieldName => 'Field name';
  @override
  String get fieldNameRequired => 'Give this field a name';
  @override
  String get area => 'Area';
  @override
  String get areaRequired => 'Enter the area in hectares';
  @override
  String cropScannable(String crop) =>
      'The camera can check $crop leaves for disease.';
  @override
  String cropNotScannable(String crop) =>
      'For $crop the app gives advice and risk warnings. Leaf scanning covers maize, rice and tomato.';

  @override
  String greeting(String name) => 'Hello, $name!';
  @override
  String get homeTagline => 'Healthy crops, brighter tomorrow.';
  @override
  String get soilMoisture => 'Soil moisture';
  @override
  String get cropRisk => 'Crop risk';
  @override
  String get cropsCount => 'In your farm';
  @override
  String get next7Days => 'Next 7 days';
  @override
  String get scanMyCrop => 'Scan My Crop';
  @override
  String get scanMyCropSub => 'Detect problems with AI';
  @override
  String get askAssistant => 'Ask AI Assistant';
  @override
  String get askAssistantSub => 'Get farming advice';
  @override
  String get todaysRecommendations => 'Today\'s Recommendations';
  @override
  String get recentScans => 'Recent Scans';
  @override
  String get noScansYet => 'No scans yet';
  @override
  String get noScansYetBody => 'Scan a crop to see its health here.';

  @override
  String get scanTitle => 'Scan Crop';
  @override
  String get scanSubtitle => 'Point at a leaf and take a photo';
  @override
  String get analysing => 'Analyzing your crop…';
  @override
  String get analysingLocal => 'Using Local AI';
  @override
  String get photoStaysOnPhone =>
      'No internet needed — the photo never leaves this phone.';
  @override
  String resultLikely(String condition) => 'Likely $condition';
  @override
  String resultPossible(String condition) => 'Possible $condition';
  @override
  String get resultUnclear => 'Possible crop issue';
  @override
  String get resultUnclearBody =>
      'The image is not clear enough to identify the problem confidently. Try another photo in better light.';
  @override
  String get resultNoLeaf => 'No leaf detected';
  @override
  String get resultNoLeafBody =>
      'Point the camera at a single leaf, filling most of the frame.';
  @override
  String get askExtensionOfficer =>
      'If you are not sure, ask your agricultural extension officer. This app informs your decision; it does not replace it.';
  @override
  String get confidenceHigh => 'High confidence';
  @override
  String get confidenceModerate => 'Moderate confidence';
  @override
  String get confidenceLow => 'Low confidence';
  @override
  String get saveToMyFarm => 'Save to My Farm';
  @override
  String get whatToDo => 'What to do';

  @override
  String get assistantTitle => 'AI Assistant';
  @override
  String get assistantSubtitle => 'Your farming companion, always here to help.';
  @override
  String get assistantHello => 'Hello!';
  @override
  String get assistantHelloBody =>
      'Ask me anything about your crops, soil, weather, pests, or farming practices.';
  @override
  String get typeYourQuestion => 'Type your question here…';
  @override
  String get suggestedQuestions => 'Suggested questions';
  @override
  String get thinking => 'Thinking…';
  @override
  String get fromOfflineLibrary => 'Answering from the offline library';
  @override
  String get modelNotLoaded => 'Local knowledge (model not loaded)';

  @override
  String get myFarmTitle => 'My Farm';
  @override
  String get myFarmSubtitle => 'Manage your land, crops, and activities';
  @override
  String get totalArea => 'Total Area';
  @override
  String get myCrops => 'My Crops';
  @override
  String get addCrop => 'Add Crop';
  @override
  String get locations => 'Locations';
  @override
  String get activities => 'Activities';
  @override
  String get noCropsYet => 'No crops yet';
  @override
  String get noCropsYetBody => 'Add your first crop to start tracking it.';
  @override
  String get planted => 'Planted';

  @override
  String get weatherTitle => 'Weather & Farm Risk';
  @override
  String get weatherSubtitle => 'Plan ahead for a better harvest';
  @override
  String get humidity => 'Humidity';
  @override
  String get wind => 'Wind';
  @override
  String get rain => 'Rain';
  @override
  String get overallFarmRisk => 'Overall Farm Risk';
  @override
  String get rainThisWeek => 'Rain this week';
  @override
  String get forecastPoint => 'Forecast point';
  @override
  String updatedAgo(String ago) => 'Updated $ago';
  @override
  String get why => 'Why';

  @override
  String get healthy => 'Healthy';
  @override
  String get monitor => 'Monitor';
  @override
  String get diseased => 'Diseased';
  @override
  String get riskLow => 'Low Risk';
  @override
  String get riskMedium => 'Medium Risk';
  @override
  String get riskHigh => 'High Risk';
  @override
  String get offlineBanner =>
      'You\'re offline. Lafaek AI works fully on this phone.';
  @override
  String get weakConnectionBanner =>
      'Weak connection. Nothing changes — AI runs on this phone.';
  @override
  String get localAiReady => 'Local AI Ready';

  @override
  String get moreTitle => 'More';
  @override
  String get knowledge => 'Knowledge';
  @override
  String get alerts => 'Alerts';
  @override
  String get scanHistory => 'Scan History';
  @override
  String get aiHistory => 'AI History';
  @override
  String get offlineAndSync => 'Offline & Sync';
  @override
  String get settings => 'Settings';
  @override
  String get profile => 'Profile';
  @override
  String get languageLabel => 'Language';
  @override
  String get about => 'About';
  @override
  String get moreSubtitle => 'Knowledge, history and settings';
  @override
  String get knowledgeSub => 'Crop guides, diseases, pests, tips';
  @override
  String get alertsSub => 'Weather and crop alerts';
  @override
  String alertsNew(int n) => '$n new';
  @override
  String scansCount(int n) => '$n scans';
  @override
  String get aiHistorySub => 'Past conversations';
  @override
  String get settingsSub => 'Notifications, units, data';
  @override
  String get profileSub => 'Your farm details';
  @override
  String get syncUpToDate => 'Everything up to date';
  @override
  String get syncSavedHere => 'Data saved on this device';
  @override
  String syncWaiting(int n) => '$n records waiting to sync';
  @override
  String get cropsWorkOffline => 'Works without internet';
  @override
  String get cropsNeedInternet => 'Needs internet';
  @override
  String cropOnlineOnly(String crop) =>
      'The app has no local data for $crop yet. You can still record it, and ask for advice while you have a connection.';
  @override
  String get cropOnlineOnlyOffline =>
      'You are offline, so these crops cannot be analysed right now. They will work when you have a signal.';
  @override
  String get worksOfflineBadge => 'Offline';
  @override
  String get needsInternetBadge => 'Online';
}

// ---------------------------------------------------------------------------

/// Tetun Dili — the lingua franca of Timor-Leste.
///
/// Agricultural vocabulary follows the terms used in Ministry of Agriculture
/// extension material: *to'os* (field/garden), *batar* (maize), *hare* (rice),
/// *ai-han* (food/crop), *moras* (disease/sickness), *rai* (soil/land).
/// Loanwords that farmers actually use are kept rather than invented
/// equivalents — *umidade*, *risku*, *hektare* — because an unfamiliar coined
/// word helps nobody.
class TetunStrings extends S {
  const TetunStrings();

  @override
  AppLanguage get language => AppLanguage.tetun;

  @override
  String get appName => 'Lafaek AI Farm';
  @override
  String get continueLabel => 'Kontinua';
  @override
  String get back => 'Fila';
  @override
  String get cancel => 'Kansela';
  @override
  String get save => 'Rai';
  @override
  String get retry => 'Koko fali';
  @override
  String get loading => 'Karega hela…';
  @override
  String get close => 'Taka';

  @override
  String get navHome => 'Uma';
  @override
  String get navScan => 'Hare';
  @override
  String get navAssistant => 'Asistente AI';
  @override
  String get navFarm => 'Ha\'u-nia To\'os';
  @override
  String get navMore => 'Seluk';

  @override
  String get onboardingWelcomeTitle => 'Bemvindu';
  @override
  String get onboardingWelcomeSubtitle =>
      'Mai ita hari\'i ita-nia to\'os. Ne\'e lori minutu ida de\'it, no la presiza internet.';
  @override
  String get onboardingFarmTitle => 'Ita-nia to\'os';
  @override
  String get onboardingFarmSubtitle =>
      'Fó naran ba ita-nia to\'os no ba ita-nia natar primeiru, no hatete nia luan.';
  @override
  String get onboardingCropTitle => 'Ita-nia ai-han primeiru';
  @override
  String get onboardingCropSubtitle =>
      'Hili saida mak ita kuda ona. Ita bele aumenta tan ikus mai.';
  @override
  String get onboardingFinish => 'Remata';
  @override
  String get onboardingNoInternet =>
      'Buat hotu rai iha telefone ne\'e. La presiza internet.';
  @override
  String get onboardingPinLater =>
      'Ikus mai ita bele marka natar ne\'e iha mapa, atu hetan tempu nian ba ita-nia rai rasik.';
  @override
  String get onboardingSaveFailed =>
      'La konsege rai ita-nia to\'os. Favór koko fali.';
  @override
  String get yourName => 'Ita-nia naran';
  @override
  String get yourNameHint => 'por ezemplu Maria da Costa';
  @override
  String get yourNameRequired => 'Favór hakerek ita-nia naran';
  @override
  String get phoneOptional => 'Telefone (opsionál)';
  @override
  String get municipality => 'Munisípiu';
  @override
  String get farmName => 'Naran to\'os';
  @override
  String get fieldName => 'Naran natar';
  @override
  String get fieldNameRequired => 'Fó naran ba natar ne\'e';
  @override
  String get area => 'Luan';
  @override
  String get areaRequired => 'Hakerek luan iha hektare';
  @override
  String cropScannable(String crop) =>
      'Kamera bele hare ${_crop(crop)} nia tahan atu buka moras.';
  @override
  String cropNotScannable(String crop) =>
      'Ba ${_crop(crop)}, aplikasaun ne\'e fó konsellu no avizu risku. Hare tahan serve ba batar, hare no tomate.';

  @override
  String greeting(String name) => 'Olá, $name!';
  @override
  String get homeTagline => 'Ai-han di\'ak, aban-bainrua naroman.';
  @override
  String get soilMoisture => 'Rai nia been';
  @override
  String get cropRisk => 'Risku ba ai-han';
  @override
  String get cropsCount => 'Iha ita-nia to\'os';
  @override
  String get next7Days => 'Loron 7 tuirmai';
  @override
  String get scanMyCrop => 'Hare Ha\'u-nia Ai-han';
  @override
  String get scanMyCropSub => 'Buka problema ho AI';
  @override
  String get askAssistant => 'Husu Asistente AI';
  @override
  String get askAssistantSub => 'Hetan konsellu to\'os nian';
  @override
  String get todaysRecommendations => 'Rekomendasaun Ohin';
  @override
  String get recentScans => 'Hare Foin Lalais';
  @override
  String get noScansYet => 'Seidauk iha hare ida';
  @override
  String get noScansYetBody =>
      'Hare ai-han ida atu haree nia saúde iha ne\'e.';

  @override
  String get scanTitle => 'Hare Ai-han';
  @override
  String get scanSubtitle => 'Hatudu ba tahan ida no foti foto';
  @override
  String get analysing => 'Analiza hela ita-nia ai-han…';
  @override
  String get analysingLocal => 'Uza AI lokál';
  @override
  String get photoStaysOnPhone =>
      'La presiza internet — foto ne\'e nunka sai husi telefone ne\'e.';
  @override
  String resultLikely(String condition) => 'Karik $condition';
  @override
  String resultPossible(String condition) => 'Bele dede $condition';
  @override
  String get resultUnclear => 'Bele dede iha problema';
  @override
  String get resultUnclearBody =>
      'Foto ne\'e la klaru atu hatene problema ho serteza. Koko foti foto seluk iha naroman di\'ak liu.';
  @override
  String get resultNoLeaf => 'La hetan tahan';
  @override
  String get resultNoLeafBody =>
      'Hatudu kamera ba tahan ida de\'it, atu nia nakonu iha foto laran.';
  @override
  String get askExtensionOfficer =>
      'Se ita la serteza, husu ita-nia estensionista agrikultura nian. Aplikasaun ne\'e ajuda ita deside; nia la troka ita-nia desizaun.';
  @override
  String get confidenceHigh => 'Serteza aas';
  @override
  String get confidenceModerate => 'Serteza klaran';
  @override
  String get confidenceLow => 'Serteza ki\'ik';
  @override
  String get saveToMyFarm => 'Rai ba Ha\'u-nia To\'os';
  @override
  String get whatToDo => 'Halo saida';

  @override
  String get assistantTitle => 'Asistente AI';
  @override
  String get assistantSubtitle =>
      'Ita-nia kompañeiru to\'os nian, sempre prontu atu ajuda.';
  @override
  String get assistantHello => 'Olá!';
  @override
  String get assistantHelloBody =>
      'Husu ha\'u kona-ba ita-nia ai-han, rai, tempu, insetu, ka maneira kuda.';
  @override
  String get typeYourQuestion => 'Hakerek ita-nia pergunta iha ne\'e…';
  @override
  String get suggestedQuestions => 'Pergunta sujestaun';
  @override
  String get thinking => 'Hanoin hela…';
  @override
  String get fromOfflineLibrary => 'Hatán husi biblioteka ofline';
  @override
  String get modelNotLoaded => 'Koñesimentu lokál (modelu seidauk karega)';

  @override
  String get myFarmTitle => 'Ha\'u-nia To\'os';
  @override
  String get myFarmSubtitle => 'Jere ita-nia rai, ai-han, no serbisu';
  @override
  String get totalArea => 'Luan Totál';
  @override
  String get myCrops => 'Ha\'u-nia Ai-han';
  @override
  String get addCrop => 'Aumenta Ai-han';
  @override
  String get locations => 'Fatin';
  @override
  String get activities => 'Serbisu';
  @override
  String get noCropsYet => 'Seidauk iha ai-han';
  @override
  String get noCropsYetBody =>
      'Aumenta ita-nia ai-han primeiru atu komesa akompaña.';
  @override
  String get planted => 'Kuda iha';

  @override
  String get weatherTitle => 'Tempu no Risku To\'os';
  @override
  String get weatherSubtitle => 'Prepara uluk ba kolleita di\'ak liu';
  @override
  String get humidity => 'Umidade';
  @override
  String get wind => 'Anin';
  @override
  String get rain => 'Udan';
  @override
  String get overallFarmRisk => 'Risku Totál To\'os Nian';
  @override
  String get rainThisWeek => 'Udan semana ne\'e';
  @override
  String get forecastPoint => 'Fatin previzaun';
  @override
  String updatedAgo(String ago) => 'Atualiza $ago';
  @override
  String get why => 'Tanbasá';

  @override
  String get healthy => 'Saudavel';
  @override
  String get monitor => 'Haree nafatin';
  @override
  String get diseased => 'Moras';
  @override
  String get riskLow => 'Risku Ki\'ik';
  @override
  String get riskMedium => 'Risku Klaran';
  @override
  String get riskHigh => 'Risku Aas';
  @override
  String get offlineBanner =>
      'Ita ofline. Lafaek AI serbisu nafatin iha telefone ne\'e.';
  @override
  String get weakConnectionBanner =>
      'Koneksaun fraku. La iha mudansa — AI serbisu iha telefone ne\'e.';
  @override
  String get localAiReady => 'AI Lokál Prontu';

  @override
  String get moreTitle => 'Seluk';
  @override
  String get knowledge => 'Koñesimentu';
  @override
  String get alerts => 'Avizu';
  @override
  String get scanHistory => 'Istória Hare';
  @override
  String get aiHistory => 'Istória AI';
  @override
  String get offlineAndSync => 'Ofline no Sinkroniza';
  @override
  String get settings => 'Konfigurasaun';
  @override
  String get profile => 'Perfil';
  @override
  String get languageLabel => 'Lian';
  @override
  String get about => 'Kona-ba';
  @override
  String get moreSubtitle => 'Koñesimentu, istória no konfigurasaun';
  @override
  String get knowledgeSub => 'Matadalan ai-han, moras, insetu, dica';
  @override
  String get alertsSub => 'Avizu tempu no ai-han nian';
  @override
  String alertsNew(int n) => '$n foun';
  @override
  String scansCount(int n) => 'hare $n';
  @override
  String get aiHistorySub => 'Konversa uluk nian';
  @override
  String get settingsSub => 'Notifikasaun, unidade, dadus';
  @override
  String get profileSub => 'Ita-nia detallu to\'os nian';
  @override
  String get syncUpToDate => 'Buat hotu atualiza ona';
  @override
  String get syncSavedHere => 'Dadus rai iha aparellu ne\'e';
  @override
  String syncWaiting(int n) => 'Rejistu $n hein atu sinkroniza';
  @override
  String get cropsWorkOffline => 'Serbisu la presiza internet';
  @override
  String get cropsNeedInternet => 'Presiza internet';
  @override
  String cropOnlineOnly(String crop) =>
      'Aplikasaun seidauk iha dadus lokál ba ${_crop(crop)}. Ita bele rejista nafatin, no husu konsellu bainhira iha koneksaun.';
  @override
  String get cropOnlineOnlyOffline =>
      'Ita ofline, tanba ne\'e ai-han sira-ne\'e la bele analiza agora. Sira sei serbisu bainhira iha sinál.';
  @override
  String get worksOfflineBadge => 'Ofline';
  @override
  String get needsInternetBadge => 'Online';


  /// Tetun covers the whole interface. The knowledge library and the language
  /// model still answer in English, which the Language screen states plainly.
  @override
  List<String> get missingTetun => const [
        'Knowledge library articles',
        'AI assistant answers',
      ];

  /// Crop names farmers use in Tetun.
  static String _crop(String english) {
    switch (english.trim().toLowerCase()) {
      case 'maize':
        return 'batar';
      case 'rice':
        return 'hare';
      case 'tomato':
        return 'tomate';
      case 'chili':
        return 'ai-manas';
      case 'beans':
        return 'koto';
      default:
        return english.toLowerCase();
    }
  }

  /// Public lookup for crop names elsewhere in the UI.
  static String cropName(String english) => _crop(english);
}

// ---------------------------------------------------------------------------

/// Provides the active [S] to the widget tree.
class LanguageScope extends StatelessWidget {
  const LanguageScope({super.key, required this.language, required this.child});

  final AppLanguage language;
  final Widget child;

  @override
  Widget build(BuildContext context) => _LanguageScope(
        strings: language == AppLanguage.tetun
            ? const TetunStrings()
            : const EnglishStrings(),
        child: child,
      );
}

class _LanguageScope extends InheritedWidget {
  const _LanguageScope({required this.strings, required super.child});

  final S strings;

  static S of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_LanguageScope>();
    return scope?.strings ?? const EnglishStrings();
  }

  @override
  bool updateShouldNotify(_LanguageScope old) => old.strings != strings;
}
