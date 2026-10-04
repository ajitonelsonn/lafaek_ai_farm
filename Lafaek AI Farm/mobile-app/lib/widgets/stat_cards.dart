import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';
import 'status_badge.dart';
import 'weather_visuals.dart';

/// Compact tinted stat card used on the Home dashboard grid.
class FarmStatCard extends StatelessWidget {
  const FarmStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.tint,
    this.iconColor = AppColors.primary,
    this.footer,
    this.onTap,
    this.iconWidget,
  });

  final IconData icon;
  final Widget? iconWidget;
  final String value;
  final String label;
  final Color tint;
  final Color iconColor;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: tint,
      shadow: false,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 40,
            child: iconWidget ?? Icon(icon, size: 36, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTextStyles.statValue, maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.secondary, maxLines: 1,
              overflow: TextOverflow.ellipsis),
          if (footer != null) ...[
            const SizedBox(height: 10),
            footer!,
          ],
        ],
      ),
    );
  }
}

/// Weather stat card (28°C · Partly cloudy · Dili).
class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key, required this.weather, this.onTap});

  final WeatherNow? weather;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final w = weather;
    return FarmStatCard(
      icon: Icons.wb_cloudy_rounded,
      iconWidget: WeatherIcon(
        condition: w?.condition ?? WeatherCondition.partlyCloudy,
        size: 40,
      ),
      value: w == null ? '--°C' : '${w.temperatureC}°C',
      label: w == null ? 'Loading…' : WeatherVisual.of(w.condition).label,
      tint: AppColors.skyTint,
      onTap: onTap,
      footer: _FooterRow(
        icon: Icons.location_on_rounded,
        text: w?.location.split(',').first ?? '—',
        color: AppColors.textPrimary,
      ),
    );
  }
}

/// Soil moisture card.
class SoilCard extends StatelessWidget {
  const SoilCard({super.key, required this.weather, this.onTap});

  final WeatherNow? weather;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final w = weather;
    return FarmStatCard(
      icon: Icons.grass_rounded,
      iconColor: AppColors.primary,
      value: w?.soilMoistureLabel ?? '—',
      label: 'Soil moisture',
      tint: AppColors.lightGreen,
      onTap: onTap,
      footer: _FooterRow(
        icon: Icons.arrow_upward_rounded,
        text: w == null ? '' : '${w.soilMoistureDelta}%',
        color: AppColors.success,
      ),
    );
  }
}

/// Crop risk card (Low / Medium / High for next 7 days).
class RiskCard extends StatelessWidget {
  const RiskCard({super.key, required this.level, this.onTap});

  final RiskLevel? level;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = level ?? RiskLevel.low;
    final v = StatusVisual.risk(l);
    return FarmStatCard(
      icon: v.icon,
      iconColor: v.color,
      value: l.label,
      label: 'Crop risk',
      tint: v.tint,
      onTap: onTap,
      footer: const Text('Next 7 days', style: AppTextStyles.caption),
    );
  }
}

/// Farm summary card (3 crops · 2.5 ha).
class FarmSummaryCard extends StatelessWidget {
  const FarmSummaryCard({
    super.key,
    required this.cropCount,
    required this.areaHa,
    this.onTap,
  });

  final int cropCount;
  final double areaHa;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FarmStatCard(
      icon: Icons.eco_rounded,
      value: '$cropCount Crop${cropCount == 1 ? '' : 's'}',
      label: 'In your farm',
      tint: AppColors.mint,
      onTap: onTap,
      footer: _FooterRow(
        icon: Icons.landscape_rounded,
        text: '${areaHa.toStringAsFixed(1)} ha',
        color: AppColors.success,
      ),
    );
  }
}

class _FooterRow extends StatelessWidget {
  const _FooterRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

/// Large gradient action card (Scan My Crop / Ask AI Assistant).
class HeroActionCard extends StatelessWidget {
  const HeroActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Horizontal full-width layout for narrow screens.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return AppCard(
        gradient: AppColors.primaryGradient,
        radius: AppRadius.xl,
        onTap: onTap,
        clip: true,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0x33FFFFFF),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.sectionTitle
                          .copyWith(color: Colors.white, fontSize: 19),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppTextStyles.secondary
                          .copyWith(color: const Color(0xE6FFFFFF)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const ChevronCircle(),
          ],
        ),
      );
    }
    return AppCard(
      gradient: AppColors.primaryGradient,
      radius: AppRadius.xl,
      onTap: onTap,
      clip: true,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0x33FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const ChevronCircle(),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(
              color: Colors.white,
              fontSize: 19,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.secondary.copyWith(
              color: const Color(0xE6FFFFFF),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
