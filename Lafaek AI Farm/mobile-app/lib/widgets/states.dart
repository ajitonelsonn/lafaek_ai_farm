import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_assets.dart';
import '../models/models.dart';
import '../state/connectivity_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'ai_status_pill.dart';
import 'app_icon.dart';
import 'buttons.dart';

/// Lafaek logo with an optional soft glow — used in splash, loading and
/// empty states.
class LafaekLogo extends StatelessWidget {
  const LafaekLogo({super.key, this.size = 72, this.glow = false});

  final double size;
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: glow
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: size * 0.5,
                  spreadRadius: size * 0.05,
                ),
              ],
            )
          : null,
      child: Image.asset(AppAssets.logo, fit: BoxFit.contain),
    );
  }
}

/// Gentle pulsing logo used as the app-wide loading indicator.
class LoadingState extends StatefulWidget {
  const LoadingState({
    super.key,
    this.message = 'Loading…',
    this.compact = false,
  });

  final String message;
  final bool compact;

  @override
  State<LoadingState> createState() => _LoadingStateState();
}

class _LoadingStateState extends State<LoadingState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.compact ? 44.0 : 80.0;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.06).animate(
              CurvedAnimation(parent: _c, curve: Curves.easeInOut),
            ),
            child: LafaekLogo(size: size, glow: true),
          ),
          SizedBox(height: widget.compact ? 10 : 18),
          Text(widget.message, style: AppTextStyles.secondary),
        ],
      ),
    );
  }
}

/// Friendly empty state with an illustration, message and optional action.
///
/// Pass [asset] for illustrated artwork (preferred), [icon] for a Material
/// glyph in a tinted circle, or neither for the Lafaek logo.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.asset,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData? icon;
  final String? asset;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (asset != null)
              AppIcon(asset!, size: 108)
            else if (icon != null)
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: AppColors.primary),
              )
            else
              const LafaekLogo(size: 88),
            const SizedBox(height: 20),
            Text(title,
                style: AppTextStyles.sectionTitle,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: AppTextStyles.secondary.copyWith(fontSize: 15),
                textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
                height: 50,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Friendly error state (never a raw exception).
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message = 'Please try again in a moment.',
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      asset: AppAssets.mascotQuestion,
      title: title,
      message: message,
      actionLabel: onRetry == null ? null : 'Try again',
      onAction: onRetry,
    );
  }
}

/// Slim banner shown at the top of screens when offline or syncing.
/// Reassures rather than alarms.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.margin = const EdgeInsets.fromLTRB(
      AppSpacing.page, 0, AppSpacing.page, AppSpacing.md)});

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ConnectivityState>();
    final mode = state.mode;
    final show = mode != AiMode.online;
    final visual = AiModeVisual.of(mode);

    final String text;
    switch (mode) {
      case AiMode.offline:
        text = "You're offline. Lafaek AI works fully on this phone.";
        break;
      case AiMode.limited:
        text = 'Weak connection. Nothing changes — AI runs on this phone.';
        break;
      case AiMode.syncing:
        text = 'Checking the offline outbox…';
        break;
      case AiMode.online:
        text = '';
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: show
          ? Padding(
              padding: margin,
              child: Material(
                color: visual.tint,
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  onTap: () => showAiStatusSheet(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Icon(visual.icon, size: 22, color: visual.color),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            text,
                            style: AppTextStyles.body.copyWith(fontSize: 14),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox(width: double.infinity),
    );
  }
}

/// Live sync progress list ("3 records uploaded … ✓ All data synced").
class SyncStatus extends StatelessWidget {
  const SyncStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ConnectivityState>();

    if (state.isSyncing || state.syncedThisRun.isNotEmpty && state.pending.isEmpty) {
      final done = !state.isSyncing;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!done)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.2, color: AppColors.primary),
                )
              else
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 22),
              const SizedBox(width: 10),
              Text(done ? 'All data synced' : 'Syncing…',
                  style: AppTextStyles.cardTitle),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in state.syncedThisRun)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.check_rounded,
                      size: 18, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text('${item.count} ${item.label} uploaded',
                      style: AppTextStyles.body.copyWith(fontSize: 14)),
                ],
              ),
            ),
        ],
      );
    }

    if (state.pending.isEmpty) {
      return Row(
        children: [
          const Icon(Icons.cloud_done_rounded,
              color: AppColors.success, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              state.lastSyncedAt == null
                  ? 'Everything is up to date.'
                  : 'All data synced. Nothing waiting.',
              style: AppTextStyles.body.copyWith(fontSize: 14),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.save_rounded,
                color: AppColors.waterBlue, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                state.lastSyncFailed
                    ? "Couldn't sync yet."
                    : 'Waiting to sync',
                style: AppTextStyles.cardTitle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          state.lastSyncFailed
              ? (state.lastSyncMessage ?? "Your data is safely stored on this device. We'll try again when the connection improves.")
              : 'Your data is saved on this device. It will upload automatically when cloud sync is enabled in the next phase.',
          style: AppTextStyles.secondary,
        ),
        const SizedBox(height: 10),
        for (final item in state.pending)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text('${item.count} ${item.label}',
                    style: AppTextStyles.body.copyWith(fontSize: 14)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Staggered fade + slide entrance for cards.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 420),
    this.offset = 16,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween(
    begin: Offset(0, widget.offset / 100),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
