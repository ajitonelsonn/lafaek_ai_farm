import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_icon.dart';

/// Rounded surface with a soft shadow. The base building block for every
/// card in the app.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.color = AppColors.white,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppRadius.lg,
    this.onTap,
    this.shadow = true,
    this.border,
    this.gradient,
    this.clip = false,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;
  final bool shadow;
  final BoxBorder? border;
  final Gradient? gradient;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: content,
        ),
      );
    }
    if (clip) {
      content = ClipRRect(borderRadius: borderRadius, child: content);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: gradient == null ? color : null,
        gradient: gradient,
        borderRadius: borderRadius,
        border: border,
        boxShadow: shadow ? AppShadows.soft : null,
      ),
      child: content,
    );
  }
}

/// Rounded square tile holding an icon — used as a leading visual in lists,
/// stat cards and quick actions.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    this.icon,
    this.asset,
    this.color = AppColors.primary,
    this.background = AppColors.lightGreen,
    this.size = 48,
    this.iconSize,
    this.radius = 14,
  }) : assert(icon != null || asset != null, 'give the tile an icon or an asset');

  final IconData? icon;

  /// Illustrated icon from `assets/images/icons/`; wins over [icon].
  final String? asset;
  final Color color;
  final Color background;
  final double size;
  final double? iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      // The artwork carries its own pale rounded square, so it is drawn close
      // to the tile edge; inset further and the two squares read as a frame.
      child: asset != null
          ? AppIcon(asset!, size: iconSize ?? size * 0.88)
          : Icon(icon, color: color, size: iconSize ?? size * 0.5),
    );
  }
}

/// Circular "go" affordance used on the large action cards.
class ChevronCircle extends StatelessWidget {
  const ChevronCircle({
    super.key,
    this.size = 36,
    this.color = Colors.white,
    this.background = const Color(0x33FFFFFF),
  });

  final double size;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(Icons.chevron_right_rounded, color: color, size: size * 0.6),
    );
  }
}
