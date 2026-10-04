import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_colors.dart';

/// Icon + colour + label for a weather condition.
class WeatherVisual {
  const WeatherVisual(this.icon, this.color, this.label);
  final IconData icon;
  final Color color;
  final String label;

  static WeatherVisual of(WeatherCondition c) {
    switch (c) {
      case WeatherCondition.sunny:
        return const WeatherVisual(
            Icons.wb_sunny_rounded, AppColors.warning, 'Sunny');
      case WeatherCondition.partlyCloudy:
        return const WeatherVisual(
            Icons.wb_cloudy_rounded, AppColors.skyBlue, 'Partly cloudy');
      case WeatherCondition.cloudy:
        return const WeatherVisual(
            Icons.cloud_rounded, AppColors.textSecondary, 'Cloudy');
      case WeatherCondition.rain:
        return const WeatherVisual(
            Icons.water_drop_rounded, AppColors.waterBlue, 'Rain');
      case WeatherCondition.heavyRain:
        return const WeatherVisual(
            Icons.thunderstorm_rounded, AppColors.waterBlue, 'Heavy rain');
      case WeatherCondition.storm:
        return const WeatherVisual(
            Icons.flash_on_rounded, AppColors.danger, 'Storm');
    }
  }
}

/// Sun-behind-cloud composite icon used on weather cards.
class WeatherIcon extends StatelessWidget {
  const WeatherIcon({super.key, required this.condition, this.size = 40});

  final WeatherCondition condition;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (condition == WeatherCondition.partlyCloudy) {
      return SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Icon(Icons.wb_sunny_rounded,
                  size: size * 0.62, color: AppColors.warning),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Icon(Icons.cloud_rounded,
                  size: size * 0.66, color: AppColors.skyBlue),
            ),
          ],
        ),
      );
    }
    final v = WeatherVisual.of(condition);
    return Icon(v.icon, size: size, color: v.color);
  }
}
