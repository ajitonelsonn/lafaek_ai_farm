import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../l10n/strings.dart';

/// Holds the interface language and remembers it between launches.
///
/// English is the default because the knowledge library and the language
/// model answer in English; Tetun is a deliberate choice the farmer makes and
/// it persists in `app_meta`, like every other preference, so the setting
/// survives offline with no account.
class LanguageState extends ChangeNotifier {
  LanguageState(this._db);

  final AppDatabase _db;
  static const String _key = 'language';

  AppLanguage _language = AppLanguage.english;
  AppLanguage get language => _language;

  bool get isTetun => _language == AppLanguage.tetun;

  /// The strings for the active language, for code outside the widget tree.
  S get strings =>
      _language == AppLanguage.tetun ? const TetunStrings() : const EnglishStrings();

  Future<void> load() async {
    try {
      _language = AppLanguageInfo.fromCode(await _db.getMeta(_key));
    } catch (e) {
      debugPrint('language load failed, staying on English: $e');
    }
    notifyListeners();
  }

  Future<void> select(AppLanguage language) async {
    if (language == _language) return;
    _language = language;
    notifyListeners();
    try {
      await _db.setMeta(_key, language.code);
    } catch (e) {
      debugPrint('language save failed: $e');
    }
  }
}
