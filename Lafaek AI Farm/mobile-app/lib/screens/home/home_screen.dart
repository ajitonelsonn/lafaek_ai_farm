import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../core/formatters.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../navigation/main_shell.dart';
import '../../state/farm_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ai_status_pill.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';
import '../../widgets/list_cards.dart';
import '../../widgets/stat_cards.dart';
import '../../widgets/states.dart';

/// Central dashboard — the first thing the farmer sees.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmState>();
    // Inside the shell the bottom padding already equals the nav bar height.
    final bottomPad = MediaQuery.paddingOf(context).bottom + 16;

    if (!farm.loaded) {
      return const Scaffold(
        body: LoadingState(message: 'Preparing your farm…'),
      );
    }

    final weather = farm.weather;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _HomeHero(farm: farm)),
          const SliverToBoxAdapter(child: OfflineBanner()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final twoRows = constraints.maxWidth < 380;
                  final cards = [
                    WeatherCard(
                      weather: weather?.now,
                      onTap: () => _openWeather(context),
                    ),
                    SoilCard(
                      weather: weather?.now,
                      onTap: () => _openWeather(context),
                    ),
                    RiskCard(
                      level: weather?.overallRisk,
                      onTap: () => _openWeather(context),
                    ),
                    FarmSummaryCard(
                      cropCount: farm.crops.length,
                      areaHa: farm.totalAreaHa,
                      onTap: () =>
                          MainShellScope.of(context).goTo(MainTab.farm),
                    ),
                  ];
                  if (twoRows) {
                    return Column(
                      children: [
                        Row(children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: 10),
                          Expanded(child: cards[1]),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: cards[2]),
                          const SizedBox(width: 10),
                          Expanded(child: cards[3]),
                        ]),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        if (i > 0) const SizedBox(width: 10),
                        Expanded(
                          child: FadeSlideIn(
                            delay: Duration(milliseconds: 60 * i),
                            child: cards[i],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page, AppSpacing.lg, AppSpacing.page, 0),
              child: LayoutBuilder(
                builder: (context, c) {
                  final scan = HeroActionCard(
                    icon: Icons.photo_camera_rounded,
                    title: 'Scan My Crop',
                    subtitle: 'Detect problems with AI',
                    compact: c.maxWidth < 380,
                    onTap: () =>
                        MainShellScope.of(context).goTo(MainTab.scan),
                  );
                  final ask = HeroActionCard(
                    icon: Icons.chat_bubble_rounded,
                    title: 'Ask AI Assistant',
                    subtitle: 'Get farming advice',
                    compact: c.maxWidth < 380,
                    onTap: () =>
                        MainShellScope.of(context).goTo(MainTab.assistant),
                  );
                  // On narrow phones the two cards stack as full-width rows
                  // so titles never wrap or truncate.
                  if (c.maxWidth < 380) {
                    return Column(
                      children: [
                        FadeSlideIn(
                            delay: const Duration(milliseconds: 200),
                            child: scan),
                        const SizedBox(height: 12),
                        FadeSlideIn(
                            delay: const Duration(milliseconds: 260),
                            child: ask),
                      ],
                    );
                  }
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: FadeSlideIn(
                              delay: const Duration(milliseconds: 200),
                              child: scan),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FadeSlideIn(
                              delay: const Duration(milliseconds: 260),
                              child: ask),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: "Today's Recommendations",
              actionLabel: 'See all',
              onAction: () => Navigator.of(context).pushNamed(AppRoutes.alerts),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            sliver: SliverList.separated(
              itemCount: farm.recommendations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => FadeSlideIn(
                delay: Duration(milliseconds: 300 + 60 * i),
                child: RecommendationCard(
                  recommendation: farm.recommendations[i],
                  onTap: () => _openRecommendation(
                      context, farm.recommendations[i]),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Recent Scans',
              actionLabel: 'See all',
              onAction: () =>
                  Navigator.of(context).pushNamed(AppRoutes.scanHistory),
            ),
          ),
          SliverToBoxAdapter(
            child: farm.scans.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
                    child: EmptyState(
                      asset: AppAssets.mascotScan,
                      title: 'No scans yet',
                      message: 'Scan a crop to see its health here.',
                    ),
                  )
                : SizedBox(
                    height: MediaQuery.textScalerOf(context).scale(204),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.page),
                      itemCount: farm.scans.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) => ScanCard(
                        scan: farm.scans[i],
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.scanResult,
                          arguments: farm.scans[i],
                        ),
                      ),
                    ),
                  ),
          ),
          SliverPadding(padding: EdgeInsets.only(bottom: bottomPad)),
        ],
      ),
    );
  }

  void _openWeather(BuildContext context) =>
      Navigator.of(context).pushNamed(AppRoutes.weather);

  void _openRecommendation(BuildContext context, Recommendation r) {
    switch (r.kind) {
      case RecommendationKind.crop:
        MainShellScope.of(context).goTo(MainTab.farm);
        break;
      case RecommendationKind.weather:
        _openWeather(context);
        break;
      case RecommendationKind.tip:
        Navigator.of(context).pushNamed(
          AppRoutes.knowledge,
          arguments: KnowledgeCategory.soilHealth,
        );
        break;
    }
  }
}

/// Scenic hero with logo, greeting and AI status over the landscape.
class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.farm});

  final FarmState farm;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final firstName = (farm.farmer?.name ?? 'Farmer').split(' ').last;

    return SizedBox(
      height: top + 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.background,
            fit: BoxFit.cover,
            alignment: const Alignment(0.2, 0),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.heroOverlay),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                AppSpacing.page, top + 8, AppSpacing.page, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const LafaekLogo(size: 64),
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: AIStatusPill(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    RoundIconButton(
                      icon: Icons.notifications_none_rounded,
                      tooltip: 'Alerts',
                      badge: farm.unreadAlerts > 0,
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.alerts),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(Formatters.greeting(),
                    style: AppTextStyles.sectionTitle.copyWith(
                        fontSize: 22, fontWeight: FontWeight.w600)),
                Text('$firstName! 👋', style: AppTextStyles.display),
                const SizedBox(height: 6),
                Text(
                  'Healthy crops, brighter tomorrow.',
                  style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          // Sits below the greeting text, not over it: the hero is 260 tall
          // and the subtitle ends around 190.
          Positioned(
            right: AppSpacing.page,
            bottom: 4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const AppIcon(AppAssets.mascotWave, size: 72),
                const SizedBox(width: 6),
                Transform.rotate(
                  angle: -0.12,
                  child: Text(
                    'Stronger Farmers\nGreener Timor-Leste',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                      fontSize: 15,
                      shadows: const [
                        Shadow(color: Color(0x66000000), blurRadius: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
