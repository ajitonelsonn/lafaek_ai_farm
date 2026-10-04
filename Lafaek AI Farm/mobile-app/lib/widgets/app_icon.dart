import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// An illustrated PNG icon from `assets/images/icons/`.
///
/// The artwork is a fixed-colour illustration, so it is used where an icon
/// carries meaning on its own (navigation, menu rows, feature tiles, empty
/// states). Small inline glyphs and icons drawn on coloured buttons stay as
/// Material icons, which can be tinted to match their background.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.asset, {
    super.key,
    this.size = 24,
    this.opacity = 1,
    this.semanticLabel,
  });

  final String asset;
  final double size;
  final double opacity;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      // The source art is ~80 px, so it is usually scaled; `medium` keeps the
      // edges smooth instead of aliased.
      filterQuality: FilterQuality.medium,
      semanticLabel: semanticLabel,
      // Never let a missing asset take down a screen.
      errorBuilder: (_, __, ___) =>
          Icon(Icons.image_not_supported_rounded, size: size),
    );
    return opacity >= 1 ? image : Opacity(opacity: opacity, child: image);
  }
}

/// An [AppIcon] inside a soft tinted square — the shape used for menu rows,
/// quick actions and list leading slots.
class AppIconTile extends StatelessWidget {
  const AppIconTile(
    this.asset, {
    super.key,
    this.box = 44,
    this.icon = 28,
    this.tint = AppColors.lightGreen,
    this.radius = 12,
  });

  final String asset;
  final double box;
  final double icon;
  final Color tint;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: box,
      height: box,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(radius),
      ),
      alignment: Alignment.center,
      child: AppIcon(asset, size: icon),
    );
  }
}
