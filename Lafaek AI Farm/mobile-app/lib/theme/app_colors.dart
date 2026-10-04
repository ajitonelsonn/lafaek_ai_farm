import 'package:flutter/material.dart';

/// Nature-inspired color tokens for Lafaek AI Farm.
///
/// Screens must reference these tokens (or the [ThemeData] built from them)
/// rather than hardcoding hex values.
class AppColors {
  AppColors._();

  // Brand greens
  static const Color primary = Color(0xFF168A4A);
  static const Color primaryDark = Color(0xFF0B5D32);
  static const Color lightGreen = Color(0xFFEAF7EE);
  static const Color mint = Color(0xFFDDF4E4);

  // Surfaces
  static const Color cream = Color(0xFFFAFCF8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF3F6F2);
  static const Color border = Color(0xFFE3EAE4);

  // Text
  static const Color textPrimary = Color(0xFF14212B);
  static const Color textSecondary = Color(0xFF66737D);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Semantic
  static const Color success = Color(0xFF1E9B55);
  static const Color warning = Color(0xFFF2A900);
  static const Color danger = Color(0xFFE85B4A);

  // Accents
  static const Color skyBlue = Color(0xFF5BB7E8);
  static const Color waterBlue = Color(0xFF3D9FE8);
  static const Color earthBrown = Color(0xFF8A5A35);
  static const Color lavender = Color(0xFF7C6BE8);

  // Soft tints used for stat cards and icon tiles
  static const Color skyTint = Color(0xFFE3F2FB);
  static const Color warningTint = Color(0xFFFFF4D6);
  static const Color dangerTint = Color(0xFFFDE9E6);
  static const Color earthTint = Color(0xFFF4EBE2);
  static const Color lavenderTint = Color(0xFFEDEAFB);

  // Camera / dark surfaces
  static const Color darkSurface = Color(0xFF1B231D);
  static const Color darkOverlay = Color(0x99141A16);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  static const LinearGradient heroOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xCCFFFFFF), Color(0x66FFFFFF), cream],
    stops: [0.0, 0.55, 1.0],
  );
}
