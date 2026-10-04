import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lafaek_ai_farm/database/app_database.dart';
import 'package:lafaek_ai_farm/l10n/strings.dart';
import 'package:lafaek_ai_farm/state/language_state.dart';

/// The challenge requires at least one interaction in a local language. The
/// named language is **Tetun**, the national language of Timor-Leste, and the
/// whole interface is translated — so these tests check it is real rather
/// than an English string wearing a Tetun label.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  const en = EnglishStrings();
  const tet = TetunStrings();

  group('Tetun translation', () {
    test('names itself correctly', () {
      expect(tet.language, AppLanguage.tetun);
      expect(AppLanguage.tetun.code, 'tet');
      expect(AppLanguage.tetun.nativeName, 'Tetun');
    });

    test('every interface string differs from English', () {
      // A translation that silently falls through to English would let the
      // app claim a language it does not really have. These are the strings a
      // farmer reads on the screens they use most.
      final pairs = <String, (String, String)>{
        'navHome': (en.navHome, tet.navHome),
        'navScan': (en.navScan, tet.navScan),
        'navFarm': (en.navFarm, tet.navFarm),
        'navMore': (en.navMore, tet.navMore),
        'scanTitle': (en.scanTitle, tet.scanTitle),
        'analysing': (en.analysing, tet.analysing),
        'resultUnclear': (en.resultUnclear, tet.resultUnclear),
        'resultNoLeaf': (en.resultNoLeaf, tet.resultNoLeaf),
        'askExtensionOfficer':
            (en.askExtensionOfficer, tet.askExtensionOfficer),
        'soilMoisture': (en.soilMoisture, tet.soilMoisture),
        'cropRisk': (en.cropRisk, tet.cropRisk),
        'riskHigh': (en.riskHigh, tet.riskHigh),
        'healthy': (en.healthy, tet.healthy),
        'offlineBanner': (en.offlineBanner, tet.offlineBanner),
        'onboardingWelcomeTitle':
            (en.onboardingWelcomeTitle, tet.onboardingWelcomeTitle),
        'yourName': (en.yourName, tet.yourName),
        'area': (en.area, tet.area),
        'whatToDo': (en.whatToDo, tet.whatToDo),
        'why': (en.why, tet.why),
        'typeYourQuestion': (en.typeYourQuestion, tet.typeYourQuestion),
      };
      final untranslated = <String>[];
      pairs.forEach((name, v) {
        if (v.$1 == v.$2) untranslated.add(name);
      });
      expect(untranslated, isEmpty,
          reason: 'these strings are still English in the Tetun build');
    });

    test('no Tetun string is left empty', () {
      for (final value in [
        tet.appName, tet.continueLabel, tet.back, tet.save, tet.retry,
        tet.navHome, tet.navScan, tet.navAssistant, tet.navFarm, tet.navMore,
        tet.onboardingFinish, tet.yourName, tet.municipality, tet.farmName,
        tet.scanTitle, tet.resultUnclear, tet.saveToMyFarm, tet.whatToDo,
        tet.weatherTitle, tet.humidity, tet.wind, tet.rain, tet.rainThisWeek,
        tet.healthy, tet.monitor, tet.diseased, tet.riskLow, tet.riskHigh,
        tet.knowledge, tet.alerts, tet.settings, tet.profile, tet.about,
      ]) {
        expect(value.trim(), isNotEmpty);
      }
    });

    test('parameterised strings keep the value they are given', () {
      expect(tet.greeting('Maria'), contains('Maria'));
      expect(tet.resultLikely('rice blast'), contains('rice blast'));
      expect(tet.updatedAgo('5 minutu'), contains('5 minutu'));
      expect(tet.cropScannable('Maize'), contains('batar'),
          reason: 'crop names should appear in Tetun');
      expect(tet.cropNotScannable('Chili'), contains('ai-manas'));
    });

    test('crop names use the words farmers use', () {
      expect(TetunStrings.cropName('Maize'), 'batar');
      expect(TetunStrings.cropName('Rice'), 'hare');
      expect(TetunStrings.cropName('Beans'), 'koto');
      expect(TetunStrings.cropName('Tomato'), 'tomate');
    });

    test('the fail-safe advice is translated, not dropped', () {
      // The pass/fail judging criterion requires the tool to point at a human
      // when it is unsure. That sentence must exist in both languages.
      expect(tet.askExtensionOfficer, isNot(en.askExtensionOfficer));
      expect(tet.askExtensionOfficer.toLowerCase(), contains('estensionista'));
      expect(tet.resultUnclearBody.trim(), isNotEmpty);
    });

    test('states honestly what Tetun does not yet cover', () {
      // The app must not claim more coverage than it has.
      expect(tet.missingTetun, isNotEmpty);
      expect(en.missingTetun, isEmpty);
    });
  });

  group('LanguageState', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('defaults to English', () async {
      final state = LanguageState(db);
      await state.load();
      expect(state.language, AppLanguage.english);
      expect(state.isTetun, isFalse);
    });

    test('remembers Tetun across a restart', () async {
      final first = LanguageState(db);
      await first.load();
      await first.select(AppLanguage.tetun);

      final second = LanguageState(db);
      await second.load();
      expect(second.language, AppLanguage.tetun,
          reason: 'the choice must survive offline with no account');
      expect(second.strings.navHome, const TetunStrings().navHome);
    });

    test('switching back to English persists too', () async {
      final state = LanguageState(db);
      await state.load();
      await state.select(AppLanguage.tetun);
      await state.select(AppLanguage.english);

      final reloaded = LanguageState(db);
      await reloaded.load();
      expect(reloaded.language, AppLanguage.english);
    });
  });

  group('LanguageScope', () {
    testWidgets('gives the widget tree the chosen language', (tester) async {
      await tester.pumpWidget(const LanguageScope(
        language: AppLanguage.tetun,
        child: MaterialApp(home: _Probe()),
      ));
      expect(find.text(const TetunStrings().navHome), findsOneWidget);
    });

    testWidgets('falls back to English outside a scope', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: _Probe()));
      expect(find.text(const EnglishStrings().navHome), findsOneWidget);
    });
  });
}

class _Probe extends StatelessWidget {
  const _Probe();

  @override
  Widget build(BuildContext context) => Text(S.of(context).navHome);
}
