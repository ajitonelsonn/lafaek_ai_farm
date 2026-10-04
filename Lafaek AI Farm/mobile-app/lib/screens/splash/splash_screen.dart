import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../navigation/app_routes.dart';
import '../../repositories/local_farm_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/states.dart';

/// Branded splash: logo over the Timor-Leste landscape, then into the app.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1900), _go);
  }

  /// A fresh install has no farmer record, so it goes to onboarding rather
  /// than to a dashboard full of data that is not the farmer's.
  Future<void> _go() async {
    if (!mounted) return;
    var first = false;
    try {
      first = await context.read<LocalFarmRepository>().needsOnboarding();
    } catch (e) {
      debugPrint('onboarding check failed, going to the app: $e');
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(
        first ? AppRoutes.onboarding : AppRoutes.shell);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    final scale = Tween(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));

    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(AppAssets.background, fit: BoxFit.cover),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x99FFFFFF), Color(0xE6FAFCF8), AppColors.cream],
                stops: [0, 0.6, 1],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),
                FadeTransition(
                  opacity: fade,
                  child: ScaleTransition(
                    scale: scale,
                    child: const LafaekLogo(size: 160, glow: true),
                  ),
                ),
                const SizedBox(height: 28),
                FadeTransition(
                  opacity: fade,
                  child: Column(
                    children: [
                      Text('Lafaek AI Farm', style: AppTextStyles.display),
                      const SizedBox(height: 8),
                      Text(
                        'A trusted farming companion that works anywhere.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 4),
                FadeTransition(
                  opacity: fade,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.offline_bolt_rounded,
                            size: 18, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text('Works online and offline',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.primaryDark)),
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
