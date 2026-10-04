import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../l10n/strings.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../state/connectivity_state.dart';
import '../../state/farm_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ai_status_pill.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/states.dart';

/// More — grouped list of everything else.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmState>();
    final conn = context.watch<ConnectivityState>();
    final s = S.of(context);
    final mode = conn.mode;
    final visual = AiModeVisual.of(mode);
    final bottomPad = MediaQuery.paddingOf(context).bottom + 16;

    void go(String route) => Navigator.of(context).pushNamed(route);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(bottom: bottomPad),
          children: [
            AppHeader(
              title: s.moreTitle,
              subtitle: s.moreSubtitle,
            ),
            const OfflineBanner(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: AppCard(
                onTap: () => go(AppRoutes.profile),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppColors.lightGreen,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const AppIcon(AppAssets.icProfile, size: 40),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(farm.farmer?.name ?? 'Farmer',
                              style: AppTextStyles.cardTitle),
                          Text(farm.farmer?.location ?? '',
                              style: AppTextStyles.secondary),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: AppCard(
                color: visual.tint,
                shadow: false,
                onTap: () => go(AppRoutes.offlineSync),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    IconTile(
                        icon: visual.icon,
                        color: visual.color,
                        background: AppColors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mode.label, style: AppTextStyles.cardTitle),
                          Text(
                            conn.pendingCount > 0
                                ? '${conn.pendingCount} records waiting to sync'
                                : mode.engineName,
                            style: AppTextStyles.secondary,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: SettingsGroup(
                title: 'Learn & History',
                rows: [
                  SettingsRow(
                    asset: AppAssets.icKnowledge,
                    title: s.knowledge,
                    subtitle: s.knowledgeSub,
                    onTap: () => go(AppRoutes.knowledge),
                  ),
                  SettingsRow(
                    asset: AppAssets.icAlerts,
                    title: s.alerts,
                    subtitle: farm.unreadAlerts > 0
                        ? s.alertsNew(farm.unreadAlerts)
                        : s.alertsSub,
                    color: AppColors.warning,
                    tint: AppColors.warningTint,
                    onTap: () => go(AppRoutes.alerts),
                  ),
                  SettingsRow(
                    asset: AppAssets.icCamera,
                    title: s.scanHistory,
                    subtitle: s.scansCount(farm.scans.length),
                    onTap: () => go(AppRoutes.scanHistory),
                  ),
                  SettingsRow(
                    asset: AppAssets.icAssistant,
                    title: s.aiHistory,
                    subtitle: s.aiHistorySub,
                    color: AppColors.lavender,
                    tint: AppColors.lavenderTint,
                    onTap: () => go(AppRoutes.aiHistory),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: SettingsGroup(
                title: 'App',
                rows: [
                  SettingsRow(
                    asset: AppAssets.icSync,
                    title: s.offlineAndSync,
                    subtitle: conn.pendingCount > 0
                        ? s.syncWaiting(conn.pendingCount)
                        : mode == AiMode.offline
                            ? s.syncSavedHere
                            : s.syncUpToDate,
                    color: AppColors.waterBlue,
                    tint: AppColors.skyTint,
                    onTap: () => go(AppRoutes.offlineSync),
                  ),
                  SettingsRow(
                    asset: AppAssets.icSettings,
                    title: s.settings,
                    subtitle: s.settingsSub,
                    color: AppColors.textSecondary,
                    tint: AppColors.surfaceMuted,
                    onTap: () => go(AppRoutes.settings),
                  ),
                  SettingsRow(
                    asset: AppAssets.icProfile,
                    title: s.profile,
                    subtitle: s.profileSub,
                    onTap: () => go(AppRoutes.profile),
                  ),
                  SettingsRow(
                    icon: Icons.language_rounded,
                    title: s.languageLabel,
                    subtitle: S.of(context).language.nativeName,
                    color: AppColors.skyBlue,
                    tint: AppColors.skyTint,
                    onTap: () => go(AppRoutes.language),
                  ),
                  SettingsRow(
                    asset: AppAssets.icInfo,
                    title: s.about,
                    subtitle: 'Lafaek AI Farm v0.1',
                    color: AppColors.earthBrown,
                    tint: AppColors.earthTint,
                    onTap: () => go(AppRoutes.about),
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
