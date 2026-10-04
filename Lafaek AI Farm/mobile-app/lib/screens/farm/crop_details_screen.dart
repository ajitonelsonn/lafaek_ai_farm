import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../core/formatters.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../state/farm_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/buttons.dart';
import '../../widgets/list_cards.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/states.dart';

/// Crop Details — one crop's health, history and related scans.
class CropDetailsScreen extends StatelessWidget {
  const CropDetailsScreen({super.key, required this.crop});

  final Crop crop;

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmState>();
    final live = farm.cropById(crop.id) ?? crop;
    final scans = farm.scans.where((s) => s.cropName == live.name).toList();
    final activities =
        farm.activities.where((a) => a.cropName == live.name).toList();
    final risk = farm.weather?.cropRisks
        .where((r) => r.cropName == live.name)
        .firstOrNull;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AppHeader(
                title: live.name,
                subtitle: '${live.areaHa.toStringAsFixed(1)} ha • ${live.locationName}',
                showBack: true,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: AspectRatio(
                    aspectRatio: 1.9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(AppAssets.fieldImageFor(live.name),
                            fit: BoxFit.cover),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: StatusBadge.health(live.status, solid: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, 12, AppSpacing.page, 0),
                child: AppCard(
                  child: Column(
                    children: [
                      _Row('Variety', live.variety ?? '—'),
                      _Row('Growth stage', live.growthStage),
                      _Row('Planted', Formatters.longDate(live.plantedOn)),
                      _Row('Location', live.locationName),
                      if (risk != null)
                        _Row('7-day risk', '${risk.level.label} — ${risk.reason}'),
                    ],
                  ),
                ),
              ),
            ),
            if (live.note != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page, 12, AppSpacing.page, 0),
                  child: AppCard(
                    color: AppColors.warningTint,
                    shadow: false,
                    child: Row(
                      children: [
                        const Icon(Icons.error_rounded, color: AppColors.warning),
                        const SizedBox(width: 10),
                        Expanded(child: Text(live.note!, style: AppTextStyles.body)),
                      ],
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Scans',
                actionLabel: 'See all',
                onAction: () => Navigator.of(context).pushNamed(AppRoutes.scanHistory),
              ),
            ),
            SliverToBoxAdapter(
              child: scans.isEmpty
                  ? const EmptyState(
                      asset: AppAssets.mascotScan,
                      title: 'No scans for this crop yet',
                      message: 'Scan a leaf to check its health.',
                    )
                  : SizedBox(
                      height: MediaQuery.textScalerOf(context).scale(204),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                        itemCount: scans.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => ScanCard(
                          scan: scans[i],
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.scanResult, arguments: scans[i]),
                        ),
                      ),
                    ),
            ),
            const SliverToBoxAdapter(child: SectionHeader(title: 'Activity')),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              sliver: activities.isEmpty
                  ? const SliverToBoxAdapter(
                      child: EmptyState(
                        asset: AppAssets.icHistory,
                        title: 'No activity yet',
                        message: 'Log watering, fertilizer or harvest for this crop.',
                      ),
                    )
                  : SliverList.separated(
                      itemCount: activities.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => ActivityRow(activity: activities[i]),
                    ),
            ),
            SliverPadding(padding: EdgeInsets.only(bottom: 150 + bottom)),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.fromLTRB(AppSpacing.page, 12, AppSpacing.page, 12 + bottom),
        color: AppColors.cream,
        child: LayoutBuilder(
          builder: (context, c) {
            final log = SecondaryButton(
              label: 'Log Activity',
              icon: Icons.calendar_month_rounded,
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.logActivity),
            );
            final scan = PrimaryButton(
              label: 'Scan Crop',
              icon: Icons.photo_camera_rounded,
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.shell,
                (r) => false,
                arguments: MainTab.scan,
              ),
            );
            if (c.maxWidth < 400) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [scan, const SizedBox(height: 10), SizedBox(height: 50, child: log)],
              );
            }
            return Row(
              children: [
                Expanded(child: log),
                const SizedBox(width: 12),
                Expanded(child: scan),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.k, this.v);
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(k, style: AppTextStyles.secondary)),
          Expanded(child: Text(v, style: AppTextStyles.bodyStrong.copyWith(fontSize: 14))),
        ],
      ),
    );
  }
}
