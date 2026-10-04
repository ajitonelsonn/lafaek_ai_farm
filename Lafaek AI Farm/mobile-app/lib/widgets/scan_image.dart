import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Renders a scan photo from either a bundled asset path or an absolute
/// file path on the device.
class ScanImage extends StatelessWidget {
  const ScanImage(
    this.path, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.alignment = Alignment.center,
  });

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;

  bool get isFile => path.startsWith('/');

  @override
  Widget build(BuildContext context) {
    Widget fallback(_, __, ___) => Container(
          width: width,
          height: height,
          color: AppColors.surfaceMuted,
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary),
        );
    if (isFile) {
      return Image.file(
        File(path),
        fit: fit,
        width: width,
        height: height,
        alignment: alignment,
        errorBuilder: fallback,
      );
    }
    return Image.asset(
      path,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      errorBuilder: fallback,
    );
  }

  /// ImageProvider for places that need one (e.g. DecorationImage).
  static ImageProvider provider(String path) =>
      path.startsWith('/') ? FileImage(File(path)) : AssetImage(path);
}
