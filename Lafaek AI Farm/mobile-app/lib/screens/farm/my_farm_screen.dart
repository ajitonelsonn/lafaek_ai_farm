import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../state/farm_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/list_cards.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/states.dart';
import '../../widgets/weather_visuals.dart';

/// My Farm — manage land, crops and activities.
class MyFarmScreen extends StatelessWidget {
  const MyFarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmState>();
    final bottomPad = MediaQuery.paddingOf(context).bottom + 16;

    if (!farm.loaded) {
      return const Scaffold(body: LoadingState(message: 'Loading your farm…'));
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: AppHeader(
                title: 'My Farm',
                subtitle: 'Manage your land, crops, and activities',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: AppColors.primary,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => _showAddSheet(context),
                        child: const SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(Icons.add_rounded,
                              color: Colors.white, size: 28),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: OfflineBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: _OverviewCard(farm: farm),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'My Crops',
                actionLabel: 'Add Crop',
                onAction: () =>
                    Navigator.of(context).pushNamed(AppRoutes.addCrop),
              ),
            ),
            SliverToBoxAdapter(
              child: farm.crops.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.page),
                      child: AppCard(
                        child: EmptyState(
                          asset: AppAssets.icEmptyGrowth,
                          title: 'No crops added yet.',
                          message:
                              'Add your first crop to start tracking your farm.',
                          actionLabel: 'Add Crop',
                          onAction: () => Navigator.of(context)
                              .pushNamed(AppRoutes.addCrop),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: MediaQuery.textScalerOf(context).scale(218),
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.page),
                        itemCount: farm.crops.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, i) => FadeSlideIn(
                          delay: Duration(milliseconds: 60 * i),
                          child: CropCard(
                            crop: farm.crops[i],
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.cropDetails,
                              arguments: farm.crops[i],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Quick Actions'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final actions = [
                      QuickActionCard(
                        icon: Icons.eco_rounded,
                        color: AppColors.primary,
                        tint: AppColors.lightGreen,
                        title: 'Add Crop',
                        subtitle: 'Record new crop',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.addCrop),
                      ),
                      QuickActionCard(
                        icon: Icons.calendar_month_rounded,
                        color: AppColors.waterBlue,
                        tint: AppColors.skyTint,
                        title: 'Log Activity',
                        subtitle: 'Fertilizer, watering, etc.',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.logActivity),
                      ),
                      QuickActionCard(
                        icon: Icons.location_on_rounded,
                        color: AppColors.warning,
                        tint: AppColors.warningTint,
                        title: 'Add Location',
                        subtitle: 'Mark your farm on map',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.addLocation),
                      ),
                      QuickActionCard(
                        icon: Icons.description_rounded,
                        color: AppColors.lavender,
                        tint: AppColors.lavenderTint,
                        title: 'View Reports',
                        subtitle: 'See your farm summary',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.reports),
                      ),
                    ];
                    final twoCols = c.maxWidth < 400;
                    if (twoCols) {
                      return Column(
                        children: [
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: actions[0]),
                                const SizedBox(width: 10),
                                Expanded(child: actions[1]),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: actions[2]),
                                const SizedBox(width: 10),
                                Expanded(child: actions[3]),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0; i < actions.length; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          Expanded(child: actions[i]),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Recent Activities',
                actionLabel: 'See all',
                onAction: () =>
                    Navigator.of(context).pushNamed(AppRoutes.farmActivity),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              sliver: farm.activities.isEmpty
                  ? const SliverToBoxAdapter(
                      child: EmptyState(
                        asset: AppAssets.icHistory,
                        title: 'No activities yet',
                        message: 'Log watering, fertilizer or planting here.',
                      ),
                    )
                  : SliverList.separated(
                      itemCount: farm.activities.length.clamp(0, 4),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => ActivityRow(
                        activity: farm.activities[i],
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.farmActivity),
                      ),
                    ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Weather & Alerts',
                actionLabel: 'View more',
                onAction: () =>
                    Navigator.of(context).pushNamed(AppRoutes.weather),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: _WeatherStrip(weather: farm.weather),
              ),
            ),
            SliverPadding(padding: EdgeInsets.only(bottom: bottomPad)),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('What would you like to add?',
                  style: AppTextStyles.sectionTitle),
              const SizedBox(height: 16),
              _SheetRow(
                icon: Icons.eco_rounded,
                label: 'Add Crop',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushNamed(AppRoutes.addCrop);
                },
              ),
              _SheetRow(
                icon: Icons.calendar_month_rounded,
                label: 'Log Activity',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushNamed(AppRoutes.logActivity);
                },
              ),
              _SheetRow(
                icon: Icons.location_on_rounded,
                label: 'Add Location',
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pushNamed(AppRoutes.addLocation);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: IconTile(icon: icon, size: 44),
      title: Text(label, style: AppTextStyles.cardTitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.farm});
  final FarmState farm;

  @override
  Widget build(BuildContext context) {
    final years = farm.farmer?.farmingYears ?? 0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: SizedBox(
        height: 250,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(AppAssets.background, fit: BoxFit.cover,
                alignment: const Alignment(0.3, 0.2)),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x66000000), Color(0x22000000), Color(0xB3073B20)],
                  stops: [0, 0.4, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('My Farm Overview',
                                style: AppTextStyles.cardTitle
                                    .copyWith(color: Colors.white)),
                            Text(
                              '${farm.totalAreaHa.toStringAsFixed(1)} ha',
                              style: AppTextStyles.display.copyWith(
                                  color: Colors.white, fontSize: 40),
                            ),
                            Text('Total Area',
                                style: AppTextStyles.secondary
                                    .copyWith(color: Colors.white)),
                          ],
                        ),
                      ),
                      Tooltip(
                        message: 'Edit Farm',
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.profile),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_rounded,
                                      size: 16, color: AppColors.textPrimary),
                                  SizedBox(width: 6),
                                  Text('Edit',
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: _OverviewStat(
                          icon: Icons.eco_rounded,
                          value: '${farm.crops.length}',
                          label: 'Crops',
                        ),
                      ),
                      Expanded(
                        child: _OverviewStat(
                          icon: Icons.location_on_rounded,
                          value: '${farm.locations.length}',
                          label: 'Locations',
                        ),
                      ),
                      Expanded(
                        child: _OverviewStat(
                          icon: Icons.calendar_month_rounded,
                          value: '${years.toStringAsFixed(1)} yrs',
                          label: 'Farming',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: 18,
              bottom: 92,
              child: Transform.rotate(
                angle: -0.08,
                child: Text(
                  'Healthy Farms\nStronger Timor-Leste',
                  textAlign: TextAlign.right,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    shadows: const [
                      Shadow(color: Color(0x66000000), blurRadius: 8)
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  const _OverviewStat({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    // Value with a small inline icon, label beneath — fits three across on
    // a 360dp phone without truncating.
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 5),
              Flexible(
                child: Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.cardTitle
                        .copyWith(color: Colors.white, height: 1.1, fontSize: 17)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption
                  .copyWith(color: const Color(0xE6FFFFFF), fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _WeatherStrip extends StatelessWidget {
  const _WeatherStrip({required this.weather});
  final WeatherBundle? weather;

  @override
  Widget build(BuildContext context) {
    final w = weather;
    if (w == null) {
      return const AppCard(child: LoadingState(compact: true, message: 'Loading weather…'));
    }
    final risk = StatusVisual.risk(w.overallRisk);
    return AppCard(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.weather),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: _StripItem(
              icon: WeatherIcon(condition: w.now.condition, size: 36),
              value: '${w.now.temperatureC}°C',
              label: WeatherVisual.of(w.now.condition).label,
            ),
          ),
          const _VDivider(),
          Expanded(
            child: _StripItem(
              icon: const IconTile(
                  icon: Icons.water_drop_rounded,
                  color: AppColors.waterBlue,
                  background: AppColors.skyTint,
                  size: 40),
              value: '${w.now.rainChance}%',
              label: 'Rain chance',
            ),
          ),
          const _VDivider(),
          Expanded(
            child: _StripItem(
              icon: IconTile(
                  icon: risk.icon,
                  color: risk.color,
                  background: risk.tint,
                  size: 40),
              value: w.overallRisk.label,
              label: 'Crop risk',
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 64, color: AppColors.border);
}

class _StripItem extends StatelessWidget {
  const _StripItem({required this.icon, required this.value, required this.label});
  final Widget icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(height: 6),
        Text(value,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 17),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(label,
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
