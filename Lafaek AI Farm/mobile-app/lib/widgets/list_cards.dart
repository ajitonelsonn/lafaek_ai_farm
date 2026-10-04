import 'package:flutter/material.dart';

import '../core/app_assets.dart';
import '../core/formatters.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';
import 'scan_image.dart';
import 'status_badge.dart';

/// Recommendation row (icon tile · title · detail · chevron).
class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  final Recommendation recommendation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final asset = switch (recommendation.kind) {
      RecommendationKind.crop => AppAssets.icPlanting,
      RecommendationKind.weather => AppAssets.icWeather,
      RecommendationKind.tip => AppAssets.icTip,
    };
    return AppCard(
      color: AppColors.lightGreen,
      shadow: false,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          IconTile(asset: asset, background: AppColors.white),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recommendation.title,
                    style: AppTextStyles.cardTitle, maxLines: 3,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(recommendation.detail,
                    style: AppTextStyles.secondary, maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

/// Recent-scan tile for horizontal lists (image · crop · status · time).
class ScanCard extends StatelessWidget {
  const ScanCard({
    super.key,
    required this.scan,
    this.onTap,
    this.width = 150,
  });

  final ScanResult scan;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final visual = StatusVisual.health(scan.status);
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
      width: width,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: AspectRatio(
                aspectRatio: 1.45,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ScanImage(scan.imageAsset, fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: visual.color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(visual.icon, size: 11, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scan.cropName, style: AppTextStyles.cardTitle
                      .copyWith(fontSize: 16)),
                  Text(scan.issue,
                      style: AppTextStyles.secondary.copyWith(
                          color: AppColors.textPrimary, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(Formatters.timeAgo(scan.scannedAt),
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
      ),
    );
  }
}

/// Crop card for My Farm (field photo · status badge · name · area · planted).
class CropCard extends StatelessWidget {
  const CropCard({super.key, required this.crop, this.onTap, this.width = 170});

  final Crop crop;
  final VoidCallback? onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
      width: width,
      child: AppCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        clip: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(AppAssets.fieldImageFor(crop.name),
                      fit: BoxFit.cover),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: StatusBadge.health(crop.status, solid: true,
                        small: true),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      AppAssets.cropImageFor(crop.name),
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(crop.name, style: AppTextStyles.cardTitle,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${crop.areaHa.toStringAsFixed(1)} ha',
                            style: AppTextStyles.secondary,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textSecondary),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                'Planted: ${Formatters.shortDate(crop.plantedOn)}',
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

/// Activity row (icon tile · title · detail).
class ActivityRow extends StatelessWidget {
  const ActivityRow({super.key, required this.activity, this.onTap});

  final FarmActivity activity;
  final VoidCallback? onTap;

  /// Material glyph for an activity type, for places that tint the icon —
  /// selectable chips turn solid green and need a white icon, which a
  /// fixed-colour illustration cannot provide.
  static IconData iconFor(ActivityType t) {
    switch (t) {
      case ActivityType.planted:
        return Icons.eco_rounded;
      case ActivityType.watered:
        return Icons.water_drop_rounded;
      case ActivityType.fertilized:
        return Icons.inventory_2_rounded;
      case ActivityType.scanned:
        return Icons.photo_camera_rounded;
      case ActivityType.harvested:
        return Icons.agriculture_rounded;
      case ActivityType.other:
        return Icons.edit_note_rounded;
    }
  }

  /// Illustrated icon, accent colour and tint for an activity type.
  static (String, Color, Color) visualFor(ActivityType t) {
    switch (t) {
      case ActivityType.planted:
        return (AppAssets.icPlanting, AppColors.primary, AppColors.lightGreen);
      case ActivityType.watered:
        return (AppAssets.icWater, AppColors.waterBlue, AppColors.skyTint);
      case ActivityType.fertilized:
        return (AppAssets.icFertilizer, AppColors.primaryDark, AppColors.mint);
      case ActivityType.scanned:
        return (AppAssets.icCamera, AppColors.primaryDark, AppColors.lightGreen);
      case ActivityType.harvested:
        return (AppAssets.icCropField, AppColors.earthBrown, AppColors.earthTint);
      case ActivityType.other:
        return (AppAssets.icEdit, AppColors.textSecondary, AppColors.surfaceMuted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (asset, color, tint) = visualFor(activity.type);
    return AppCard(
      color: AppColors.lightGreen,
      shadow: false,
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          IconTile(asset: asset, background: AppColors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title, style: AppTextStyles.cardTitle),
                Text(
                  '${activity.detail} • ${Formatters.longDate(activity.date)}',
                  style: AppTextStyles.secondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

/// Quick-action tile (tinted, icon, title, subtitle, chevron).
class QuickActionCard extends StatelessWidget {
  const QuickActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: tint,
      shadow: false,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 30, color: color),
              const ChevronCircle(
                size: 28,
                color: AppColors.textPrimary,
                background: AppColors.white,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(title, style: AppTextStyles.cardTitle, maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(subtitle, style: AppTextStyles.secondary, maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// Alert row with an explicit recommended action.
class AlertCard extends StatelessWidget {
  const AlertCard({super.key, required this.alert, this.onTap,
      this.showAction = false});

  final FarmAlert alert;
  final VoidCallback? onTap;
  final bool showAction;

  /// Illustrated icon, accent colour and card tint for an alert kind.
  static (String, Color, Color) visualFor(AlertKind k) {
    switch (k) {
      case AlertKind.warning:
        return (AppAssets.icWarning, AppColors.warning, AppColors.warningTint);
      case AlertKind.opportunity:
        return (AppAssets.icPlanting, AppColors.primary, AppColors.lightGreen);
      case AlertKind.info:
        return (AppAssets.icInfo, AppColors.waterBlue, AppColors.skyTint);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (asset, color, tint) = visualFor(alert.kind);
    return AppCard(
      color: tint,
      shadow: false,
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(asset: asset, background: AppColors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(alert.title,
                              style: AppTextStyles.cardTitle),
                        ),
                        if (!alert.read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(alert.detail, style: AppTextStyles.secondary),
                  ],
                ),
              ),
              if (!showAction) ...[
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textSecondary),
              ],
            ],
          ),
          if (showAction) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.task_alt_rounded,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(alert.action, style: AppTextStyles.body
                        .copyWith(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
