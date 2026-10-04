import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../models/models.dart';
import '../../state/farm_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/states.dart';

/// View Reports — a simple farm summary (no heavy analytics by design).
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmState>();
    final healthy = farm.crops.where((c) => c.status == HealthStatus.healthy).length;
    final monitor = farm.crops.length - healthy;
    final scansThisWeek = farm.scans
        .where((s) => DateTime.now().difference(s.scannedAt).inDays < 7)
        .length;
    final totalCropArea = farm.crops.fold<double>(0, (s, c) => s + c.areaHa);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Farm Report',
              subtitle: 'A simple summary of your farm',
              showBack: true,
              showAiStatus: false,
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, 0, AppSpacing.page, 32),
                children: [
                  IntrinsicHeight(
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _Stat(
                          value: '${farm.crops.length}',
                          label: 'Crops',
                          tint: AppColors.lightGreen,
                          icon: Icons.eco_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Stat(
                          value: '${totalCropArea.toStringAsFixed(1)} ha',
                          label: 'Planted area',
                          tint: AppColors.skyTint,
                          icon: Icons.landscape_rounded,
                          color: AppColors.waterBlue,
                        ),
                      ),
                    ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  IntrinsicHeight(
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _Stat(
                          value: '$healthy',
                          label: 'Healthy crops',
                          tint: AppColors.mint,
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _Stat(
                          value: '$monitor',
                          label: 'Need attention',
                          tint: AppColors.warningTint,
                          icon: Icons.error_rounded,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _Stat(
                    value: '$scansThisWeek',
                    label: 'Scans in the last 7 days',
                    tint: AppColors.lavenderTint,
                    icon: Icons.photo_camera_rounded,
                    color: AppColors.lavender,
                  ),
                  const SizedBox(height: 24),
                  const Text('Crop health', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 12),
                  if (farm.crops.isEmpty)
                    const EmptyState(
                      asset: AppAssets.icReports,
                      title: 'No crops yet',
                      message: 'Add a crop to see it in your report.',
                    )
                  else
                    AppCard(
                      padding: const EdgeInsets.all(8),
                      child: Material(
                        type: MaterialType.transparency,
                        child: Column(
                        children: [
                          for (final c in farm.crops)
                            ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.asset(AppAssets.cropImageFor(c.name),
                                    width: 44, height: 44, fit: BoxFit.cover),
                              ),
                              title: Text(c.name, style: AppTextStyles.cardTitle),
                              subtitle: Text(
                                  '${c.areaHa.toStringAsFixed(1)} ha • ${c.growthStage}',
                                  style: AppTextStyles.secondary),
                              trailing: StatusBadge.health(c.status, small: true),
                            ),
                        ],
                        ),
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

class _Stat extends StatelessWidget {
  const _Stat({
    required this.value,
    required this.label,
    required this.tint,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final Color tint;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: tint,
      shadow: false,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconTile(icon: icon, color: color, background: AppColors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scale the number down rather than wrap "3.5 ha" onto two lines.
                Align(
                  alignment: Alignment.centerLeft,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(value, style: AppTextStyles.statValue, maxLines: 1),
                  ),
                ),
                const SizedBox(height: 2),
                Text(label,
                    style: AppTextStyles.secondary.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
