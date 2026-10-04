import 'package:flutter/material.dart';
// latlong2 exports its own Path, which collides with dart:ui's.
import 'package:latlong2/latlong.dart' hide Path;
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../core/formatters.dart';
import '../../l10n/strings.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../repositories/local_weather_service.dart';
import '../../state/farm_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ai_status_pill.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/buttons.dart';
import '../../widgets/farm_map.dart';
import '../../widgets/list_cards.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/states.dart';
import '../../widgets/weather_visuals.dart';

/// Weather & Farm Risk — connects weather to farming decisions.
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmState>();
    final w = farm.weather;
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      body: Stack(
        children: [
          // Scenic header background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: top + 330,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(AppAssets.background, fit: BoxFit.cover,
                    alignment: const Alignment(-0.3, 0.3)),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xB3FFFFFF), Color(0x66FFFFFF), AppColors.cream],
                      stops: [0, 0.5, 1],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            bottom: false,
            child: w == null
                ? Column(
                    children: [
                      AppHeader(
                        title: S.of(context).weatherTitle,
                        subtitle: S.of(context).weatherSubtitle,
                        showBack: true,
                      ),
                      Expanded(child: LoadingState(message: 'Checking the sky…')),
                    ],
                  )
                : RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: farm.refreshWeather,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      slivers: [
                        SliverToBoxAdapter(
                          child: AppHeader(
                            title: S.of(context).weatherTitle,
                            subtitle: S.of(context).weatherSubtitle,
                            showBack: true,
                            showAiStatus: false,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                AppSpacing.page, 0, AppSpacing.page, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: _LocationPill(location: w.now.location),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const AIStatusPill(compact: true),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _UpdatedLine(bundle: w),
                              ],
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: OfflineBanner()),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.page),
                            child: LayoutBuilder(
                              builder: (context, c) {
                                final stack = c.maxWidth < 380;
                                final current = _CurrentCard(now: w.now);
                                final risk = _OverallRiskCard(bundle: w);
                                if (stack) {
                                  return Column(children: [
                                    current,
                                    const SizedBox(height: 12),
                                    SizedBox(width: double.infinity, child: risk),
                                  ]);
                                }
                                return IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(flex: 8, child: current),
                                      const SizedBox(width: 12),
                                      Expanded(flex: 5, child: risk),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                AppSpacing.page, 12, AppSpacing.page, 0),
                            child: _HourlyCard(hourly: w.hourly),
                          ),
                        ),
                        const SliverToBoxAdapter(child: _ForecastLocationCard()),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                AppSpacing.page, 12, AppSpacing.page, 0),
                            child: LayoutBuilder(
                              builder: (context, c) {
                                final stack = c.maxWidth < 400;
                                final daily = _DailyCard(daily: w.daily);
                                final insight =
                                    _InsightCard(insight: w.insight, daily: w.daily);
                                if (stack) {
                                  return Column(children: [
                                    daily,
                                    const SizedBox(height: 12),
                                    insight,
                                  ]);
                                }
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: daily),
                                    const SizedBox(width: 12),
                                    Expanded(child: insight),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                AppSpacing.page, 12, AppSpacing.page, 0),
                            child: _CropRiskCard(risks: w.cropRisks),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                AppSpacing.page, 12, AppSpacing.page, 0),
                            child: AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Text('Alerts & Recommendations',
                                            style: AppTextStyles.sectionTitle),
                                      ),
                                      LinkButton(
                                        label: 'See all',
                                        onPressed: () => Navigator.of(context)
                                            .pushNamed(AppRoutes.alerts),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  for (final a in farm.alerts.take(2))
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: AlertCard(
                                        alert: a,
                                        onTap: () => Navigator.of(context)
                                            .pushNamed(AppRoutes.alerts),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                AppSpacing.page, 12, AppSpacing.page, 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                              child: SizedBox(
                                height: 84,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.asset(AppAssets.background,
                                        fit: BoxFit.cover,
                                        alignment: const Alignment(0, 0.8)),
                                    const DecoratedBox(
                                      decoration: BoxDecoration(
                                          color: Color(0xB3073B20)),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16),
                                      child: Row(
                                        children: [
                                          const LafaekLogo(size: 48),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Better information. Healthier crops. A stronger Timor-Leste.',
                                              style: AppTextStyles.bodyStrong
                                                  .copyWith(color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.paddingOf(context).bottom + 24),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LocationPill extends StatelessWidget {
  const _LocationPill({required this.location});
  final String location;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.addLocation),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_rounded,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyStrong.copyWith(fontSize: 13)),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({required this.now});
  final WeatherNow now;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WeatherIcon(condition: now.condition, size: 56),
                const SizedBox(height: 8),
                Text('${now.temperatureC}°C',
                    style: AppTextStyles.display.copyWith(fontSize: 34)),
                Text(WeatherVisual.of(now.condition).label,
                    style: AppTextStyles.secondary,
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          Container(width: 1, height: 90, color: AppColors.border),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Metric(Icons.water_drop_outlined, 'Humidity', '${now.humidity}%'),
                const SizedBox(height: 10),
                _Metric(Icons.air_rounded, 'Wind', '${now.windKmh} km/h'),
                const SizedBox(height: 10),
                _Metric(Icons.umbrella_rounded, 'Rain', '${now.rainChance}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.waterBlue),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppTextStyles.secondary)),
        Text(value, style: AppTextStyles.bodyStrong.copyWith(fontSize: 14)),
      ],
    );
  }
}

class _OverallRiskCard extends StatelessWidget {
  const _OverallRiskCard({required this.bundle});
  final WeatherBundle bundle;

  @override
  Widget build(BuildContext context) {
    final v = StatusVisual.risk(bundle.overallRisk);
    return AppCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [v.color, Color.lerp(v.color, AppColors.textPrimary, 0.25)!],
      ),
      onTap: () {},
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: Icon(v.icon, color: v.color, size: 24),
          ),
          const SizedBox(height: 10),
          Text('Overall Farm Risk',
              style: AppTextStyles.caption.copyWith(color: Colors.white)),
          Text(bundle.overallRisk.label,
              style: AppTextStyles.display
                  .copyWith(color: Colors.white, fontSize: 30)),
          const SizedBox(height: 4),
          Text(bundle.overallRiskNote,
              style: AppTextStyles.secondary
                  .copyWith(color: const Color(0xE6FFFFFF), fontSize: 13)),
        ],
      ),
    );
  }
}

class _HourlyCard extends StatelessWidget {
  const _HourlyCard({required this.hourly});
  final List<HourlyForecast> hourly;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Text('Hourly Forecast', style: AppTextStyles.sectionTitle),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: hourly.length,
              separatorBuilder: (_, __) => const SizedBox(width: 18),
              itemBuilder: (_, i) {
                final h = hourly[i];
                return Column(
                  children: [
                    Text(i == 0 ? 'Now' : Formatters.hourLabel(h.time),
                        style: AppTextStyles.caption),
                    const SizedBox(height: 8),
                    WeatherIcon(condition: h.condition, size: 30),
                    const SizedBox(height: 8),
                    Text('${h.temperatureC}°',
                        style: AppTextStyles.bodyStrong),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyCard extends StatelessWidget {
  const _DailyCard({required this.daily});
  final List<DailyForecast> daily;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('7-Day Forecast', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 8),
          for (final d in daily)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                children: [
                  Expanded(
                    child: Text(Formatters.weekdayDate(d.date),
                        style: AppTextStyles.body.copyWith(fontSize: 14)),
                  ),
                  WeatherIcon(condition: d.condition, size: 26),
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 74),
                    child: Text('${d.minC}° / ${d.maxC}°',
                        textAlign: TextAlign.end,
                        style: AppTextStyles.bodyStrong.copyWith(fontSize: 14)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Rain expected over the week, in millimetres, from the forecast.
///
/// This replaced a painted gradient that looked like a rainfall map but was
/// decoration — fixed blobs on a hand-drawn island, identical whatever the
/// weather. Millimetres per day is the number a farmer can act on: whether to
/// irrigate, and when the ground will be too wet to work.
class _RainfallCard extends StatelessWidget {
  const _RainfallCard({required this.daily});
  final List<DailyForecast> daily;

  @override
  Widget build(BuildContext context) {
    final days = daily.take(7).toList();
    final withData = days.where((d) => d.hasRainData).toList();

    if (withData.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Rain this week', style: AppTextStyles.cardTitle),
            const SizedBox(height: 8),
            Text(
              'Rainfall figures come with the live forecast. Tap refresh at the '
              'top when you have a signal.',
              style: AppTextStyles.secondary,
            ),
          ],
        ),
      );
    }

    final total = withData.fold<double>(0, (s, d) => s + (d.rainMm ?? 0));
    // Scale to the wettest day, with a 2 mm floor. Any higher and a light
    // week — which Timor-Leste's dry season mostly is — draws as flat lines
    // the farmer cannot compare.
    final peak = days
        .map((d) => d.rainMm ?? 0)
        .fold<double>(2, (a, b) => b > a ? b : a);

    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Rain this week', style: AppTextStyles.cardTitle),
              ),
              Text('${total.toStringAsFixed(total < 10 ? 1 : 0)} mm total',
                  style: AppTextStyles.secondary),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 108,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final d in days)
                  Expanded(
                    child: _RainBar(day: d, peak: peak),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            total < 1
                ? 'Almost no rain forecast. Plan to irrigate.'
                : 'Bar height is millimetres; the number under it is the chance of rain.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

class _RainBar extends StatelessWidget {
  const _RainBar({required this.day, required this.peak});
  final DailyForecast day;
  final double peak;

  @override
  Widget build(BuildContext context) {
    final mm = day.rainMm ?? 0;
    final fraction = (mm / peak).clamp(0.0, 1.0);
    final chance = day.rainChance;
    // Heavier rain reads darker, so a wet day stands out at a glance.
    final color = mm >= 20
        ? AppColors.danger
        : mm >= 5
            ? AppColors.waterBlue
            : AppColors.skyBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              mm >= 0.1 ? mm.toStringAsFixed(mm < 10 ? 1 : 0) : '–',
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: mm >= 0.1 ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: (64 * fraction).clamp(4.0, 64.0),
            decoration: BoxDecoration(
              color: mm >= 0.1 ? color : AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(Formatters.weekdayShort(day.date),
                style: AppTextStyles.caption),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(chance == null ? '' : '$chance%',
                style: AppTextStyles.caption.copyWith(fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight, required this.daily});
  final String insight;
  final List<DailyForecast> daily;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _RainfallCard(daily: daily),
        const SizedBox(height: 12),
        AppCard(
          color: AppColors.lightGreen,
          shadow: false,
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconTile(
                  asset: AppAssets.icTip,
                  background: AppColors.white,
                  size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Insight', style: AppTextStyles.cardTitle),
                    const SizedBox(height: 2),
                    Text(insight, style: AppTextStyles.secondary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Stylised rainfall heat-map of Timor-Leste. Illustrative only.
class _CropRiskCard extends StatelessWidget {
  const _CropRiskCard({required this.risks});
  final List<CropRisk> risks;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Crop Risk Analysis', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, c) {
              final tiles = [
                for (final r in risks) _RiskTile(risk: r),
              ];
              if (c.maxWidth < 360) {
                return Column(
                  children: [
                    for (final t in tiles)
                      Padding(padding: const EdgeInsets.only(bottom: 8), child: t),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: tiles[i]),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RiskTile extends StatelessWidget {
  const _RiskTile({required this.risk});
  final CropRisk risk;

  @override
  Widget build(BuildContext context) {
    final v = StatusVisual.risk(risk.level);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: v.tint,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(AppAssets.cropImageFor(risk.cropName),
                    width: 36, height: 36, fit: BoxFit.cover),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(risk.cropName,
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StatusBadge.risk(risk.level, small: true,
              suffix: risk.level == RiskLevel.medium ? '' : ' Risk'),
          const SizedBox(height: 6),
          if (risk.reasons.isEmpty)
            Text(risk.reason, style: AppTextStyles.caption, maxLines: 2,
                overflow: TextOverflow.ellipsis)
          else ...[
            Text('Why:', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
            for (final r in risk.reasons.take(3))
              Text('• $r', style: AppTextStyles.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          if (risk.advice != null && risk.level != RiskLevel.low) ...[
            const SizedBox(height: 6),
            Text(risk.advice!,
                style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                maxLines: 3, overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }
}

/// "Last updated" line — cached/demo/manual data is never called live.
/// Shows which point the forecast was fetched for.
///
/// Without this the farmer has no way to tell whether "28°C" is their valley
/// or the capital — which matters in Timor-Leste, where the coast and the
/// highlands differ sharply.
class _ForecastLocationCard extends StatelessWidget {
  const _ForecastLocationCard();

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmState>();
    final at = farm.weatherLocation;
    final point = at == null
        ? const LatLng(LocalWeatherService.defaultLatitude,
            LocalWeatherService.defaultLongitude)
        : LatLng(at.latitude!, at.longitude!);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.page, 12, AppSpacing.page, 0),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.place_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    at == null ? 'Forecast point' : 'Forecast for ${at.name}',
                    style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                  ),
                ),
                if (at == null)
                  LinkButton(
                    label: 'Pin my field',
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.addLocation),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            FarmMap(
              center: point,
              marker: point,
              height: 170,
              zoom: at == null ? 11 : 14,
              interactive: false,
            ),
            const SizedBox(height: 8),
            Text(
              at == null
                  ? 'Using ${LocalWeatherService.defaultLocationName}. Pin your field on the map to get the forecast for your own land.'
                  : '${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)} · ${at.district}',
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdatedLine extends StatelessWidget {
  const _UpdatedLine({required this.bundle});
  final WeatherBundle bundle;

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmState>();
    final when = bundle.updatedAt == null ? 'unknown' : Formatters.timeAgo(bundle.updatedAt!);
    return Row(
      children: [
        Icon(
          bundle.isLive && !bundle.isStale
              ? Icons.cloud_done_rounded
              : Icons.schedule_rounded,
          size: 16,
          color: bundle.isLive && !bundle.isStale
              ? AppColors.success
              : AppColors.textSecondary,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text('Updated $when · ${bundle.sourceLabel}',
              style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        // Fetches a new forecast. Offline it fails quietly and the stored one
        // stays on screen, which is the behaviour we want in the field.
        IconButton(
          onPressed: farm.weatherLoading
              ? null
              : () => farm.refreshWeather(fetchLive: true, force: true),
          icon: farm.weatherLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                )
              : const Icon(Icons.refresh_rounded, size: 20),
          tooltip: 'Fetch the latest forecast',
          visualDensity: VisualDensity.compact,
          color: AppColors.primary,
        ),
        LinkButton(
          label: 'Enter',
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            builder: (_) => _ManualWeatherSheet(
                farm: context.read<FarmState>(), initial: bundle.now),
          ),
        ),
      ],
    );
  }
}

/// Farmer-entered conditions (local weather source 3).
class _ManualWeatherSheet extends StatefulWidget {
  const _ManualWeatherSheet({required this.farm, required this.initial});
  final FarmState farm;
  final WeatherNow initial;

  @override
  State<_ManualWeatherSheet> createState() => _ManualWeatherSheetState();
}

class _ManualWeatherSheetState extends State<_ManualWeatherSheet> {
  late double _temp = widget.initial.temperatureC.toDouble();
  late double _humidity = widget.initial.humidity.toDouble();
  late double _rain = widget.initial.rainChance.toDouble();
  late WeatherCondition _cond = widget.initial.condition;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Update today\'s conditions', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 4),
            Text('No internet needed. Risk is recalculated on this phone.', style: AppTextStyles.secondary),
            const SizedBox(height: 16),
            _slider('Temperature', '${_temp.round()}°C', _temp, 15, 40, (v) => setState(() => _temp = v)),
            _slider('Humidity', '${_humidity.round()}%', _humidity, 20, 100, (v) => setState(() => _humidity = v)),
            _slider('Rain chance', '${_rain.round()}%', _rain, 0, 100, (v) => setState(() => _rain = v)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in WeatherCondition.values)
                  ChoiceChip(
                    label: Text(WeatherVisual.of(c).label),
                    avatar: Icon(WeatherVisual.of(c).icon, size: 18, color: WeatherVisual.of(c).color),
                    selected: _cond == c,
                    onSelected: (_) => setState(() => _cond = c),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Save conditions',
              icon: Icons.check_rounded,
              loading: _saving,
              onPressed: () async {
                setState(() => _saving = true);
                await widget.farm.setManualWeather(
                  temperatureC: _temp.round(),
                  humidity: _humidity.round(),
                  rainChance: _rain.round(),
                  condition: _cond,
                );
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 8),
            SecondaryButton(
              label: 'Reset to demo data',
              icon: Icons.restore_rounded,
              height: 46,
              onPressed: () async {
                await widget.farm.resetWeatherToDemo();
                if (context.mounted) Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _slider(String label, String value, double v, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 96, child: Text(label, style: AppTextStyles.secondary)),
        Expanded(
          child: Slider(value: v, min: min, max: max, onChanged: onChanged, activeColor: AppColors.primary),
        ),
        SizedBox(width: 52, child: Text(value, textAlign: TextAlign.end, style: AppTextStyles.bodyStrong)),
      ],
    );
  }
}
