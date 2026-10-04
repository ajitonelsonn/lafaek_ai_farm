import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../core/formatters.dart';
import '../../navigation/app_routes.dart';
import '../../state/farm_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/scan_image.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/states.dart';

/// Scan History — every scan, newest first.
class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scans = context.watch<FarmState>().scans;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Scan History',
              subtitle: 'All your crop scans',
              showBack: true,
            ),
            const OfflineBanner(),
            Expanded(
              child: scans.isEmpty
                  ? EmptyState(
                      asset: AppAssets.icCamera,
                      title: 'No scans yet',
                      message: 'Scan a crop to check its health with AI.',
                      actionLabel: 'Scan Crop',
                      onAction: () => Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.shell,
                        (r) => false,
                        arguments: MainTab.scan,
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.page, 0, AppSpacing.page, 32),
                      itemCount: scans.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final s = scans[i];
                        return FadeSlideIn(
                          delay: Duration(milliseconds: 40 * i),
                          child: AppCard(
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.scanResult, arguments: s),
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                  child: ScanImage(s.imageAsset,
                                      width: 84, height: 70, fit: BoxFit.cover),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(s.cropName,
                                                style: AppTextStyles.cardTitle),
                                          ),
                                          StatusBadge.health(s.status, small: true),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(s.issue,
                                          style: AppTextStyles.body.copyWith(fontSize: 14),
                                          maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 6,
                                        runSpacing: 2,
                                        children: [
                                          Text(Formatters.timeAgo(s.scannedAt),
                                              style: AppTextStyles.caption),
                                          Icon(
                                            s.engine.contains('Bedrock')
                                                ? Icons.cloud_rounded
                                                : Icons.psychology_rounded,
                                            size: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                          Text(s.modelName ?? s.engine, style: AppTextStyles.caption),
                                          if (s.pendingSync) ...[
                                            const Icon(Icons.schedule_rounded,
                                                size: 13, color: AppColors.waterBlue),
                                            Text('To sync',
                                                style: AppTextStyles.caption
                                                    .copyWith(color: AppColors.waterBlue)),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded,
                                    color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
