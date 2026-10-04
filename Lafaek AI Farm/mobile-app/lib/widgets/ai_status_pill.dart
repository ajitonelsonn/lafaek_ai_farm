import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../navigation/app_routes.dart';
import '../services/connectivity_service.dart';
import '../services/local_ai/local_ai_engine.dart';
import '../services/local_ai/local_model_manager.dart';
import '../state/connectivity_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'buttons.dart';

/// Visual identity of each connectivity mode — colour + icon + label, so
/// status is never communicated by colour alone.
class AiModeVisual {
  const AiModeVisual({
    required this.color,
    required this.tint,
    required this.icon,
  });

  final Color color;
  final Color tint;
  final IconData icon;

  static AiModeVisual of(AiMode mode) {
    switch (mode) {
      case AiMode.online:
        return const AiModeVisual(
          color: AppColors.success,
          tint: AppColors.lightGreen,
          icon: Icons.wifi_rounded,
        );
      case AiMode.limited:
        return const AiModeVisual(
          color: AppColors.warning,
          tint: AppColors.warningTint,
          icon: Icons.network_cell_rounded,
        );
      case AiMode.offline:
        return const AiModeVisual(
          color: AppColors.waterBlue,
          tint: AppColors.skyTint,
          icon: Icons.wifi_off_rounded,
        );
      case AiMode.syncing:
        return const AiModeVisual(
          color: AppColors.primary,
          tint: AppColors.lightGreen,
          icon: Icons.sync_rounded,
        );
    }
  }
}

/// Visual for the local AI readiness (spec §25).
class LocalAiVisual {
  const LocalAiVisual(this.color, this.tint, this.icon);
  final Color color;
  final Color tint;
  final IconData icon;

  static LocalAiVisual of(LocalAiReadiness r) {
    switch (r) {
      case LocalAiReadiness.ready:
        return const LocalAiVisual(AppColors.success, AppColors.lightGreen, Icons.psychology_rounded);
      case LocalAiReadiness.partial:
        return const LocalAiVisual(AppColors.primary, AppColors.lightGreen, Icons.psychology_rounded);
      case LocalAiReadiness.loading:
        return const LocalAiVisual(AppColors.warning, AppColors.warningTint, Icons.psychology_rounded);
      case LocalAiReadiness.unavailable:
        return const LocalAiVisual(AppColors.danger, AppColors.dangerTint, Icons.psychology_alt_rounded);
    }
  }
}

/// The one reusable AI status component. Shows local AI readiness with a
/// connectivity dot; tapping opens a sheet with every local component, the
/// model installer and the demo connectivity switch.
class AIStatusPill extends StatelessWidget {
  const AIStatusPill({super.key, this.dark = false, this.compact = false});

  /// Render for placement over dark/photo backgrounds.
  final bool dark;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<LocalAiEngine>();
    final mode = context.select<ConnectivityState, AiMode>((s) => s.mode);
    final readiness = engine.readiness;
    final visual = LocalAiVisual.of(readiness);
    final net = AiModeVisual.of(mode);
    final label = compact ? _shortLabel(engine) : engine.statusLabel;

    return Semantics(
      button: true,
      label: '${engine.statusLabel}. Connection: ${mode.label}',
      child: Material(
        color: dark ? const Color(0x33000000) : AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: () => showAiStatusSheet(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 14,
              vertical: compact ? 8 : 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: dark
                  ? Border.all(color: const Color(0x55FFFFFF))
                  : Border.all(color: AppColors.border),
              boxShadow: dark ? null : AppShadows.soft,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: readiness == LocalAiReadiness.loading || mode == AiMode.syncing
                      ? _SpinningIcon(
                          key: const ValueKey('spin'),
                          icon: mode == AiMode.syncing ? Icons.sync_rounded : Icons.autorenew_rounded,
                          color: dark ? Colors.white : visual.color,
                        )
                      : Icon(
                          visual.icon,
                          key: ValueKey(readiness),
                          size: 20,
                          color: dark ? Colors.white : visual.color,
                        ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      label,
                      key: ValueKey(label),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyStrong.copyWith(
                        fontSize: compact ? 14 : 15,
                        color: dark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: 'Connection: ${mode.label}',
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: net.color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: net.color.withValues(alpha: 0.5), blurRadius: 6),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _shortLabel(LocalAiEngine e) {
    switch (e.readiness) {
      case LocalAiReadiness.ready:
        return 'Local AI';
      case LocalAiReadiness.partial:
        return e.llmInstalled ? 'Local AI' : 'Local AI';
      case LocalAiReadiness.loading:
        return 'Loading AI';
      case LocalAiReadiness.unavailable:
        return 'AI Unavailable';
    }
  }
}

class _SpinningIcon extends StatefulWidget {
  const _SpinningIcon({super.key, required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RotationTransition(turns: _c, child: Icon(widget.icon, size: 20, color: widget.color));
}

/// Bottom sheet: local AI components, model installer, connectivity and the
/// demo switch.
Future<void> showAiStatusSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _AiStatusSheet(),
  );
}

class _AiStatusSheet extends StatelessWidget {
  const _AiStatusSheet();

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<LocalAiEngine>();
    final conn = context.watch<ConnectivityState>();
    final mode = conn.mode;
    final visual = LocalAiVisual.of(engine.readiness);
    final net = AiModeVisual.of(mode);
    final maxH = MediaQuery.sizeOf(context).height * 0.88;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: visual.tint, borderRadius: BorderRadius.circular(16)),
                    child: Icon(visual.icon, color: visual.color, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(engine.statusLabel, style: AppTextStyles.sectionTitle),
                        Text(
                          engine.llmReady
                              ? '${engine.llmDisplayName} · runs on this phone'
                              : 'Everything runs on this phone',
                          style: AppTextStyles.secondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ComponentRow(
                icon: Icons.visibility_rounded,
                title: 'Local Vision',
                subtitle: engine.visionReady
                    ? '${engine.visionInfo?.displayName} v${engine.visionInfo?.version} · on-device'
                    : (engine.visionError ?? 'Loading…'),
                state: engine.visionState,
              ),
              _ComponentRow(
                icon: Icons.psychology_rounded,
                title: 'Local Language Model',
                subtitle: engine.llmReady
                    ? '${engine.selectedModel?.spec.displayName} · ${engine.selectedModel?.spec.parameters}'
                    : engine.llmInstalled
                        ? (engine.llmState == ModelState.initializing
                            ? 'Loading ${engine.llmDisplayName}…'
                            : engine.llmError ?? '${engine.llmDisplayName} installed · loads on first question')
                        : 'Not installed — answers use the local knowledge library',
                state: engine.llmInstalled ? engine.llmState : ModelState.error,
                softError: !engine.llmInstalled,
              ),
              _ComponentRow(
                icon: Icons.storage_rounded,
                title: 'Local Data',
                subtitle: engine.dataReady
                    ? 'SQLite ready · ${engine.knowledgeCount} knowledge articles'
                    : 'Opening database…',
                state: engine.dataReady ? ModelState.ready : ModelState.initializing,
              ),
              _ComponentRow(
                icon: net.icon,
                title: 'Internet',
                // The detail line is what was measured — transport plus the
                // real round-trip — not what the phone claims it is attached
                // to. "Wi-Fi · no internet" is a case the type check missed.
                subtitle: mode == AiMode.offline
                    ? '${conn.connectionDetail} — nothing changes, Lafaek keeps working'
                    : mode == AiMode.limited
                        ? '${conn.connectionDetail} — slow, and not needed for AI'
                        : '${conn.connectionDetail} — cloud sync comes in the next phase',
                state: ModelState.ready,
                color: net.color,
              ),
              if (conn.pendingCount > 0) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.save_rounded, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${conn.pendingCount} records saved on this device, queued for the cloud phase.',
                        style: AppTextStyles.secondary,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              const _ModelInstaller(),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 14),
              const Text('Simulate connection (demo)', style: AppTextStyles.cardTitle),
              const SizedBox(height: 4),
              Text(
                'Switch off the internet: the app keeps working because AI runs locally.',
                style: AppTextStyles.secondary,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SimChip(
                    label: 'Good',
                    icon: Icons.wifi_rounded,
                    selected: conn.manualOverride && conn.quality == NetworkQuality.good,
                    onTap: () => conn.simulate(NetworkQuality.good),
                  ),
                  _SimChip(
                    label: 'Weak',
                    icon: Icons.network_cell_rounded,
                    selected: conn.manualOverride && conn.quality == NetworkQuality.limited,
                    onTap: () => conn.simulate(NetworkQuality.limited),
                  ),
                  _SimChip(
                    label: 'Offline',
                    icon: Icons.wifi_off_rounded,
                    selected: conn.manualOverride && conn.quality == NetworkQuality.none,
                    onTap: () => conn.simulate(NetworkQuality.none),
                  ),
                  _SimChip(
                    label: 'Auto',
                    icon: Icons.autorenew_rounded,
                    selected: !conn.manualOverride,
                    onTap: () => conn.simulate(null),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SecondaryButton(
                label: 'Offline & Sync status',
                icon: Icons.sync_rounded,
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(AppRoutes.offlineSync);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComponentRow extends StatelessWidget {
  const _ComponentRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.state,
    this.color,
    this.softError = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final ModelState state;
  final Color? color;

  /// Treat error as "not installed" (blue info) rather than red.
  final bool softError;

  @override
  Widget build(BuildContext context) {
    final (IconData sIcon, Color sColor) = switch (state) {
      ModelState.ready => (Icons.check_circle_rounded, AppColors.success),
      ModelState.initializing => (Icons.hourglass_top_rounded, AppColors.warning),
      ModelState.error => softError
          ? (Icons.download_for_offline_rounded, AppColors.waterBlue)
          : (Icons.error_rounded, AppColors.danger),
      ModelState.notInitialized => (Icons.radio_button_unchecked_rounded, AppColors.textSecondary),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: color ?? AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyStrong.copyWith(fontSize: 15)),
                Text(subtitle, style: AppTextStyles.secondary),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(sIcon, size: 20, color: sColor),
        ],
      ),
    );
  }
}

/// Model picker: one card per known model with download / use / delete.
class _ModelInstaller extends StatelessWidget {
  const _ModelInstaller();

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<LocalAiEngine>();
    final conn = context.watch<ConnectivityState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Language model', style: AppTextStyles.cardTitle),
        const SizedBox(height: 4),
        Text(
          'Choose the model that answers your questions. Each is a one-time download; afterwards no internet is needed.',
          style: AppTextStyles.secondary,
        ),
        if (engine.downloadError != null) ...[
          const SizedBox(height: 6),
          Text(engine.downloadError!, style: AppTextStyles.caption.copyWith(color: AppColors.danger)),
        ],
        const SizedBox(height: 10),
        for (final spec in kKnownLlmModels)
          if (spec.minRamMb < 7000 || engine.fits(spec) || engine.isInstalled(spec))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ModelCard(spec: spec, engine: engine, online: conn.isOnline),
            ),
      ],
    );
  }
}

class _ModelCard extends StatelessWidget {
  const _ModelCard({required this.spec, required this.engine, required this.online});
  final LlmModelSpec spec;
  final LocalAiEngine engine;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final installed = engine.isInstalled(spec);
    final active = engine.isActive(spec);
    final preferred = engine.preferredModelId == spec.id ||
        (engine.preferredModelId == null && spec.recommended);
    final downloading = engine.downloadingSpec?.id == spec.id && engine.downloadProgress != null;
    final loading = engine.llmState == ModelState.initializing && engine.selectedModel?.spec.id == spec.id;
    final fits = engine.fits(spec);

    final String status;
    final Color statusColor;
    if (active) {
      status = 'Active · running on this phone';
      statusColor = AppColors.success;
    } else if (loading) {
      status = 'Loading…';
      statusColor = AppColors.warning;
    } else if (installed) {
      status = 'Installed · ${spec.sizeLabel}';
      statusColor = AppColors.primary;
    } else if (!fits) {
      status = 'Needs more memory than this phone has';
      statusColor = AppColors.textSecondary;
    } else {
      status = 'Not installed · ${spec.sizeLabel} download';
      statusColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? AppColors.lightGreen : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: active ? AppColors.primary : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(active ? Icons.check_circle_rounded : Icons.psychology_rounded,
                  size: 22, color: active ? AppColors.success : AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(spec.displayName,
                              style: AppTextStyles.bodyStrong, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        if (spec.recommended) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.mint,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text('Recommended',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.primaryDark, fontSize: 10)),
                          ),
                        ],
                      ],
                    ),
                    Text('${spec.vendor} · ${spec.parameters} · ${spec.description}',
                        style: AppTextStyles.caption),
                    Text(status, style: AppTextStyles.caption.copyWith(color: statusColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          if (downloading) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                  value: engine.downloadProgress!.fraction, minHeight: 8, color: AppColors.primary),
            ),
            const SizedBox(height: 4),
            Text(
              '${(engine.downloadProgress!.received / 1048576).round()} of ${(engine.downloadProgress!.total / 1048576).round()} MB',
              style: AppTextStyles.caption,
            ),
          ] else ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (installed && !active)
                  Expanded(
                    child: PrimaryButton(
                      label: loading ? 'Loading…' : 'Use ${spec.displayName}',
                      icon: Icons.memory_rounded,
                      height: 42,
                      loading: loading,
                      onPressed: () => engine.selectModel(spec),
                    ),
                  ),
                if (!installed && fits)
                  Expanded(
                    child: PrimaryButton(
                      label: online ? 'Download' : 'Wi‑Fi needed',
                      icon: Icons.download_rounded,
                      height: 42,
                      onPressed: online && engine.downloadingSpec == null ? () => engine.downloadModel(spec) : null,
                    ),
                  ),
                if (active && !preferred)
                  Expanded(
                    child: SecondaryButton(
                      label: 'Keep as default',
                      icon: Icons.push_pin_outlined,
                      height: 42,
                      onPressed: () => engine.selectModel(spec),
                    ),
                  ),
                if (installed) ...[
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Delete download',
                    child: Material(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        onTap: () => _confirmDelete(context, engine, spec),
                        child: const SizedBox(
                          width: 42,
                          height: 42,
                          child: Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, LocalAiEngine engine, LlmModelSpec spec) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete model?'),
        content: Text('${spec.displayName} (${spec.sizeLabel}) will be removed from this phone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) await engine.deleteModel(spec);
  }
}

class _SimChip extends StatelessWidget {
  const _SimChip({required this.label, required this.icon, required this.selected, required this.onTap});

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: selected ? Colors.white : AppColors.textPrimary),
              const SizedBox(width: 6),
              Text(label,
                  style: AppTextStyles.bodyStrong.copyWith(
                    fontSize: 14,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
