import 'package:flutter/material.dart';

import '../core/app_assets.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';

/// Colour + icon + label for a status. Never colour alone.
///
/// [glyph] is the illustrated leaf badge; [icon] is the Material fallback used
/// on coloured (solid) backgrounds, where a fixed-colour illustration would
/// disappear.
class StatusVisual {
  const StatusVisual(this.color, this.tint, this.icon, this.glyph);
  final Color color;
  final Color tint;
  final IconData icon;
  final String glyph;

  static StatusVisual health(HealthStatus s) {
    switch (s) {
      case HealthStatus.healthy:
        return const StatusVisual(AppColors.success, AppColors.lightGreen,
            Icons.check_circle_rounded, AppAssets.glyphHealthy);
      case HealthStatus.monitor:
        return const StatusVisual(AppColors.warning, AppColors.warningTint,
            Icons.error_rounded, AppAssets.glyphMonitor);
      case HealthStatus.atRisk:
        return const StatusVisual(AppColors.danger, AppColors.dangerTint,
            Icons.warning_rounded, AppAssets.glyphDiseased);
    }
  }

  static StatusVisual risk(RiskLevel r) {
    switch (r) {
      case RiskLevel.low:
        return const StatusVisual(AppColors.success, AppColors.lightGreen,
            Icons.shield_rounded, AppAssets.glyphRiskLow);
      case RiskLevel.medium:
        return const StatusVisual(AppColors.warning, AppColors.warningTint,
            Icons.error_rounded, AppAssets.glyphRiskMedium);
      case RiskLevel.high:
        return const StatusVisual(AppColors.danger, AppColors.dangerTint,
            Icons.warning_rounded, AppAssets.glyphRiskHigh);
    }
  }
}

/// Pill-shaped badge: "● Healthy", "▲ Monitor", "Low Risk"…
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.visual,
    this.solid = false,
    this.small = false,
  });

  StatusBadge.health(HealthStatus status,
      {super.key, this.solid = false, this.small = false})
      : label = status.label,
        visual = StatusVisual.health(status);

  StatusBadge.risk(RiskLevel level,
      {super.key, this.solid = false, this.small = false, String? suffix})
      : label = '${level.label}${suffix ?? ' Risk'}',
        visual = StatusVisual.risk(level);

  final String label;
  final StatusVisual visual;

  /// Solid = white text on coloured background (for photo overlays).
  final bool solid;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final fg = solid ? Colors.white : visual.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 12,
        vertical: small ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: solid ? visual.color : visual.tint,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // On a solid colour the illustration would not read, so the tinted
          // Material icon is used there and the artwork on the soft badge.
          if (solid)
            Icon(visual.icon, size: small ? 13 : 16, color: fg)
          else
            AppIcon(visual.glyph, size: small ? 15 : 18),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: small ? 12 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
