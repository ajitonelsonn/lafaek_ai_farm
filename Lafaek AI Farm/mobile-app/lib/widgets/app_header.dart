import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'ai_status_pill.dart';
import 'buttons.dart';

/// Standard page header.
///
/// Layout: one row with [back] · title · [trailing], then the subtitle on its
/// own full-width line so it never gets squeezed by the trailing controls.
/// The title scales down (never truncates) when a trailing control is wide,
/// which matters on 360dp phones.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.trailing,
    this.showAiStatus = true,
    this.centered = false,
    this.dark = false,
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final Widget? trailing;
  final bool showAiStatus;
  final bool centered;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final titleColor = dark ? Colors.white : AppColors.textPrimary;
    final subColor = dark ? const Color(0xDDFFFFFF) : AppColors.textSecondary;
    final trail = trailing ??
        (showAiStatus ? AIStatusPill(dark: dark, compact: true) : null);
    final hasSideControls = showBack || trail != null;

    final titleText = Text(
      title,
      maxLines: 1,
      textAlign: centered ? TextAlign.center : TextAlign.start,
      style: AppTextStyles.pageTitle.copyWith(
        color: titleColor,
        fontSize: hasSideControls ? 24 : 28,
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.md),
      child: Column(
        crossAxisAlignment:
            centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (showBack) ...[
                RoundIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  tooltip: 'Back',
                  dark: dark,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Align(
                  alignment:
                      centered ? Alignment.center : Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment:
                        centered ? Alignment.center : Alignment.centerLeft,
                    child: titleText,
                  ),
                ),
              ),
              if (trail != null) ...[
                const SizedBox(width: 12),
                trail,
              ] else if (showBack && centered)
                // Keep a centered title truly centered.
                const SizedBox(width: 60),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              style: AppTextStyles.secondary.copyWith(
                color: subColor,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

/// Section heading row with optional "See all" link. The title scales down
/// rather than wrapping so lists stay compact on narrow screens.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.padding = const EdgeInsets.fromLTRB(
        AppSpacing.page, AppSpacing.xxl, AppSpacing.page, AppSpacing.md),
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(title, style: AppTextStyles.sectionTitle,
                    maxLines: 1),
              ),
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 8),
            LinkButton(label: actionLabel!, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
