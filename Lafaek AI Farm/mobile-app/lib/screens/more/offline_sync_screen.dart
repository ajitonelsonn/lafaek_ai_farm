import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../core/formatters.dart';
import '../../database/app_database.dart';
import '../../repositories/local_sync_queue_service.dart';
import '../../services/local_ai/local_ai_engine.dart';
import '../../services/connectivity_service.dart';
import '../../state/connectivity_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ai_status_pill.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/buttons.dart';
import '../../widgets/states.dart';

/// Offline & Sync Status — answers the four questions:
/// Is internet available? Which AI is used? Is my data saved? Anything to sync?
class OfflineSyncScreen extends StatelessWidget {
  const OfflineSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ConnectivityState>();
    final engine = context.watch<LocalAiEngine>();
    final queue = context.read<LocalSyncQueueService>();
    final mode = state.mode;
    final visual = AiModeVisual.of(mode);

    // Measured, not assumed: the label comes from a timed reachability check,
    // and the detail says which transport and how many milliseconds.
    final String netLabel;
    switch (state.quality) {
      case NetworkQuality.good:
        netLabel = 'Good connection';
        break;
      case NetworkQuality.limited:
        netLabel = 'Weak connection';
        break;
      case NetworkQuality.none:
        netLabel = state.transport == NetworkTransport.none
            ? 'No network'
            : 'Connected, but no internet';
        break;
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Offline & Sync',
              subtitle: 'Cloud is the enhancement. Offline is the guarantee.',
              showBack: true,
              showAiStatus: false,
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, 0, AppSpacing.page, 32),
                children: [
                  // Big status
                  AppCard(
                    color: visual.tint,
                    shadow: false,
                    child: Column(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: const BoxDecoration(
                              color: AppColors.white, shape: BoxShape.circle),
                          child: Icon(visual.icon, size: 36, color: visual.color),
                        ),
                        const SizedBox(height: 12),
                        Text(mode.label, style: AppTextStyles.sectionTitle),
                        Text(mode.engineName, style: AppTextStyles.secondary),
                        const SizedBox(height: 10),
                        Text(mode.description,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      children: [
                        _StatusRow(
                          icon: state.isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                          color: state.isOffline ? AppColors.waterBlue : AppColors.success,
                          label: 'Internet',
                          value: netLabel,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(state.connectionDetail,
                                  style: AppTextStyles.caption),
                            ),
                            LinkButton(
                              label: 'Check now',
                              onPressed: state.recheck,
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        _StatusRow(
                          icon: visual.icon,
                          color: visual.color,
                          label: 'AI engine',
                          value: mode.engineName,
                        ),
                        const Divider(height: 20),
                        const _StatusRow(
                          icon: Icons.save_rounded,
                          color: AppColors.success,
                          label: 'Your data',
                          value: 'Saved on this device',
                        ),
                        const Divider(height: 20),
                        _StatusRow(
                          icon: Icons.sync_rounded,
                          color: state.pendingCount > 0
                              ? AppColors.warning
                              : AppColors.success,
                          label: 'Waiting to sync',
                          value: state.pendingCount > 0
                              ? '${state.pendingCount} records'
                              : 'Nothing',
                        ),
                        if (state.lastSyncedAt != null) ...[
                          const Divider(height: 20),
                          _StatusRow(
                            icon: Icons.schedule_rounded,
                            color: AppColors.textSecondary,
                            label: 'Last synced',
                            value: Formatters.timeAgo(state.lastSyncedAt!),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Local AI on this phone', style: AppTextStyles.cardTitle),
                        const SizedBox(height: 8),
                        for (final e in engine.summary().entries)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 120, child: Text(e.key, style: AppTextStyles.secondary)),
                                Expanded(child: Text(e.value, style: AppTextStyles.body.copyWith(fontSize: 14))),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const AppCard(child: SyncStatus()),
                  const SizedBox(height: 12),
                  _OutboxCard(queue: queue),
                  const SizedBox(height: 12),
                  if (state.pendingCount > 0 && !state.isSyncing)
                    PrimaryButton(
                      label: state.quality == NetworkQuality.good
                          ? 'Sync now'
                          : 'Retry sync',
                      icon: Icons.sync_rounded,
                      onPressed: state.retrySync,
                    ),
                  const SizedBox(height: 20),
                  const Text('How it works', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 10),
                  const _FlowCard(),
                  const SizedBox(height: 20),
                  SecondaryButton(
                    label: 'Simulate connection (demo)',
                    icon: Icons.tune_rounded,
                    onPressed: () => showAiStatusSheet(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rows of the offline outbox (sync_queue table).
class _OutboxCard extends StatelessWidget {
  const _OutboxCard({required this.queue});
  final LocalSyncQueueService queue;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SyncQueueRow>>(
      future: queue.all(),
      builder: (context, snap) {
        final rows = snap.data ?? const <SyncQueueRow>[];
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: Text('Offline outbox', style: AppTextStyles.cardTitle)),
                  Text('${rows.length} records', style: AppTextStyles.caption),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Every change is written to SQLite first and listed here for the cloud phase. Nothing is deleted if a sync fails.',
                style: AppTextStyles.secondary,
              ),
              const SizedBox(height: 10),
              if (rows.isEmpty)
                Text('No pending records.', style: AppTextStyles.caption)
              else
                for (final r in rows.take(8))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          r.status == 'synced'
                              ? Icons.check_circle_rounded
                              : r.status == 'failed'
                                  ? Icons.error_outline_rounded
                                  : Icons.schedule_rounded,
                          size: 16,
                          color: r.status == 'synced'
                              ? AppColors.success
                              : r.status == 'failed'
                                  ? AppColors.warning
                                  : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('${r.entityType} · ${r.operation} · ${Formatters.timeAgo(r.createdAt)}',
                              style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        Text(r.status, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
              if (rows.length > 8)
                Text('… and ${rows.length - 8} more', style: AppTextStyles.caption),
            ],
          ),
        );
      },
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyles.secondary)),
        Text(value, style: AppTextStyles.bodyStrong.copyWith(fontSize: 14)),
      ],
    );
  }
}

class _FlowCard extends StatelessWidget {
  const _FlowCard();

  @override
  Widget build(BuildContext context) {
    const steps = [
      (AppAssets.icProtect, AppColors.success, 'Local AI first', 'Vision, language model and knowledge run on this phone'),
      (AppAssets.icOffline, AppColors.waterBlue, 'No internet', 'Everything still works; data is saved in SQLite'),
      (AppAssets.icSync, AppColors.warning, 'Offline outbox', 'Every change is queued locally with retry status'),
      (AppAssets.icUpload, AppColors.primary, 'Next phase', 'When AWS is enabled, the outbox uploads and Bedrock enhances answers'),
    ];
    return AppCard(
      child: Column(
        children: [
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 14),
              child: Row(
                children: [
                  IconTile(
                      asset: steps[i].$1,
                      background: steps[i].$2.withValues(alpha: 0.12),
                      size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(steps[i].$3, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
                        Text(steps[i].$4, style: AppTextStyles.secondary),
                      ],
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
