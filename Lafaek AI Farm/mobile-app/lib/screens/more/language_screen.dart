import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/strings.dart';
import '../../state/language_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';

/// Language — English and Tetun, both working. Others are named as not yet
/// available rather than shown as if they were.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  /// Languages that are not built yet. Listed so a farmer can see the plan,
  /// disabled so the app never claims a language it does not have.
  static const _planned = [
    ('Português', 'Portuguese'),
    ('Bahasa Indonesia', 'Indonesian'),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageState>();
    final s = S.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: s.languageLabel,
              subtitle: lang.isTetun
                  ? 'Hili lian ba aplikasaun'
                  : 'Choose the language for the app',
              showBack: true,
              showAiStatus: false,
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, 0, AppSpacing.page, 32),
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(6),
                    child: Material(
                      type: MaterialType.transparency,
                      child: Column(
                        children: [
                          for (final l in AppLanguage.values)
                            _LanguageTile(
                              flag: l.flag,
                              native: l.nativeName,
                              english: l.englishName,
                              selected: lang.language == l,
                              onTap: () => lang.select(l),
                            ),
                          for (final p in _planned)
                            _LanguageTile(
                              flag: '🏳️',
                              native: p.$1,
                              english: p.$2,
                              selected: false,
                              onTap: null,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    color: AppColors.lightGreen,
                    shadow: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.isTetun
                              ? 'Saida mak Tetun kobre'
                              : 'What Tetun covers',
                          style: AppTextStyles.cardTitle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          lang.isTetun
                              ? 'Interfase tomak iha Tetun: menu, formuláriu, rezultadu hare no avizu risku. '
                                  'Maibé artigu koñesimentu no resposta husi modelu AI sei iha Inglés hela, '
                                  'tanba sira mak material orijinál. Ami la bele hatete katak sira iha Tetun ona.'
                              : 'The whole interface is in Tetun: menus, forms, scan results and risk warnings. '
                                  'The knowledge articles and the AI model\'s answers are still in English, because that '
                                  'is the source material. The app does not pretend otherwise.',
                          style: AppTextStyles.secondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.flag,
    required this.native,
    required this.english,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String native;
  final String english;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return ListTile(
      enabled: enabled,
      onTap: onTap,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm)),
      leading: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.lightGreen : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(flag, style: const TextStyle(fontSize: 22)),
      ),
      title: Text(native,
          style: AppTextStyles.cardTitle.copyWith(
            fontSize: 16,
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
          )),
      subtitle: Text(
        enabled ? english : '$english — not available yet',
        style: AppTextStyles.secondary,
      ),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
          : null,
    );
  }
}
