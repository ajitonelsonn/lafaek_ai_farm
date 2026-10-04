import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../navigation/app_routes.dart';
import '../../services/local_ai/local_ai_engine.dart';
import '../../widgets/ai_status_pill.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/form_widgets.dart';

/// Settings — a small set of useful toggles. Values are local to this
/// screen for the UI build; wire to a preferences store later.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _weatherAlerts = true;
  bool _cropAlerts = true;
  bool _autoSync = true;
  bool _saveScans = true;
  bool _metric = true;

  @override
  Widget build(BuildContext context) {
    void go(String r) => Navigator.of(context).pushNamed(r);
    final engine = context.watch<LocalAiEngine>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Settings',
              showBack: true,
              showAiStatus: false,
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, 0, AppSpacing.page, 32),
                children: [
                  SettingsGroup(
                    title: 'Notifications',
                    rows: [
                      SettingsRow(
                        asset: AppAssets.icWeather,
                        color: AppColors.skyBlue,
                        tint: AppColors.skyTint,
                        title: 'Weather alerts',
                        subtitle: 'Heavy rain, dry spells, planting windows',
                        trailing: Switch(
                          value: _weatherAlerts,
                          onChanged: (v) => setState(() => _weatherAlerts = v),
                        ),
                      ),
                      SettingsRow(
                        asset: AppAssets.icPlanting,
                        title: 'Crop alerts',
                        subtitle: 'Disease and pest risk',
                        trailing: Switch(
                          value: _cropAlerts,
                          onChanged: (v) => setState(() => _cropAlerts = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SettingsGroup(
                    title: 'Local AI',
                    rows: [
                      SettingsRow(
                        asset: AppAssets.icProtect,
                        title: 'Language model',
                        subtitle: engine.llmReady
                            ? '${engine.llmDisplayName} · loaded'
                            : engine.llmInstalled
                                ? '${engine.llmDisplayName} · installed'
                                : 'Not installed · tap to download',
                        onTap: () => showAiStatusSheet(context),
                      ),
                      SettingsRow(
                        asset: AppAssets.icScan,
                        color: AppColors.waterBlue,
                        tint: AppColors.skyTint,
                        title: 'Vision model',
                        subtitle: engine.visionReady
                            ? '${engine.visionInfo?.displayName} v${engine.visionInfo?.version} · ${(engine.visionInfo!.valAccuracy * 100).round()}% validation accuracy'
                            : (engine.visionError ?? 'Loading…'),
                        onTap: () => go(AppRoutes.about),
                      ),
                      if (engine.llmReady)
                        SettingsRow(
                          asset: AppAssets.icAssistant,
                          color: AppColors.warning,
                          tint: AppColors.warningTint,
                          title: 'Free model memory',
                          subtitle: 'Unload the language model; it reloads on the next question',
                          onTap: () => engine.unloadLlm(),
                        ),
                      SettingsRow(
                        asset: AppAssets.icSync,
                        color: AppColors.lavender,
                        tint: AppColors.lavenderTint,
                        title: 'Choose or delete models',
                        subtitle: '${engine.installedModels.length} installed · Llama 3.2 1B/3B, Gemma 3 1B',
                        onTap: () => showAiStatusSheet(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SettingsGroup(
                    title: 'Data',
                    rows: [
                      SettingsRow(
                        asset: AppAssets.icUpload,
                        title: 'Auto-sync when cloud is enabled',
                        trailing: Switch(
                          value: _autoSync,
                          onChanged: (v) => setState(() => _autoSync = v),
                        ),
                      ),
                      SettingsRow(
                        asset: AppAssets.icGallery,
                        color: AppColors.lavender,
                        tint: AppColors.lavenderTint,
                        title: 'Keep scan photos on device',
                        trailing: Switch(
                          value: _saveScans,
                          onChanged: (v) => setState(() => _saveScans = v),
                        ),
                      ),
                      SettingsRow(
                        asset: AppAssets.icKnowledge,
                        title: 'Offline & Sync status',
                        onTap: () => go(AppRoutes.offlineSync),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SettingsGroup(
                    title: 'General',
                    rows: [
                      SettingsRow(
                        icon: Icons.straighten_rounded,
                        color: AppColors.earthBrown,
                        tint: AppColors.earthTint,
                        title: 'Units',
                        subtitle: _metric ? 'Hectares, °C, km/h' : 'Acres, °F, mph',
                        trailing: Switch(
                          value: _metric,
                          onChanged: (v) => setState(() => _metric = v),
                        ),
                      ),
                      SettingsRow(
                        icon: Icons.language_rounded,
                        color: AppColors.skyBlue,
                        tint: AppColors.skyTint,
                        title: 'Language',
                        subtitle: 'English',
                        onTap: () => go(AppRoutes.language),
                      ),
                      SettingsRow(
                        asset: AppAssets.icProfile,
                        title: 'Profile',
                        onTap: () => go(AppRoutes.profile),
                      ),
                      SettingsRow(
                        asset: AppAssets.icInfo,
                        color: AppColors.textSecondary,
                        tint: AppColors.surfaceMuted,
                        title: 'About Lafaek AI Farm',
                        onTap: () => go(AppRoutes.about),
                      ),
                    ],
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
