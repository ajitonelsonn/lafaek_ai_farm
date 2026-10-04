import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../navigation/app_routes.dart';
import '../../services/ai_service.dart';
import '../../services/local_ai/local_ai_engine.dart';
import '../../state/connectivity_state.dart';
import '../../state/farm_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ai_status_pill.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/states.dart';
import 'scan_request.dart';

/// "Analyzing your crop…" — runs the on-device pipeline
/// (TFLite vision → knowledge → local LLM) and names each component.
class ScanAnalysisScreen extends StatefulWidget {
  const ScanAnalysisScreen({super.key, required this.request});

  final ScanRequest request;

  @override
  State<ScanAnalysisScreen> createState() => _ScanAnalysisScreenState();
}

class _ScanAnalysisScreenState extends State<ScanAnalysisScreen>
    with SingleTickerProviderStateMixin {
  final Set<AnalysisStep> _done = {};
  AnalysisStep? _current;
  StreamSubscription<AnalysisStep>? _sub;
  String? _error;
  late final AnimationController _scanLine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    final ai = context.read<ConnectivityState>().ai;
    final farm = context.read<FarmState>();
    setState(() {
      _done.clear();
      _error = null;
      _current = AnalysisStep.identifyingCrop;
    });
    _sub?.cancel();
    _sub = ai
        .analyzeCrop(
          imageBytes: widget.request.bytes,
          imagePath: widget.request.assetPath,
          farm: farm.farmContext(),
        )
        .listen(
      (step) {
        if (!mounted) return;
        setState(() {
          _done.add(step);
          final idx = AnalysisStep.values.indexOf(step);
          _current = idx + 1 < AnalysisStep.values.length ? AnalysisStep.values[idx + 1] : null;
        });
      },
      onError: (Object e, StackTrace st) {
        debugPrint('analysis failed: $e\n$st');
        if (mounted) {
          setState(() => _error = e is FormatException
              ? 'That image could not be read. Try another photo.'
              : 'The local analysis could not finish. Your photo is kept on this device.');
        }
      },
      onDone: () async {
        if (!mounted || _error != null) return;
        try {
          final result = await ai.analysisResult();
          if (!mounted) return;
          await farm.refresh();
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(AppRoutes.scanResult, arguments: result);
        } catch (e) {
          if (mounted) setState(() => _error = 'No result was produced. Please try again.');
        }
      },
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    _scanLine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<LocalAiEngine>();
    final visual = LocalAiVisual.of(engine.readiness);
    final engineLine = engine.llmReady
        ? '${engine.visionDisplayName} + ${engine.llmDisplayName}'
        : engine.llmInstalled
            ? '${engine.visionDisplayName} + ${engine.llmDisplayName} (loading)'
            : '${engine.visionDisplayName} + local knowledge';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppIcon(AppAssets.mascotScan, size: 52),
                  AIStatusPill(compact: true),
                ],
              ),
              const SizedBox(height: 28),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        widget.request.bytes != null
                            ? Image.memory(widget.request.bytes!, fit: BoxFit.cover)
                            : Image.asset(widget.request.assetPath ?? AppAssets.sampleLeaf, fit: BoxFit.cover),
                        const DecoratedBox(decoration: BoxDecoration(color: Color(0x2214212B))),
                        if (_error == null)
                          AnimatedBuilder(
                            animation: _scanLine,
                            builder: (_, __) => Align(
                              alignment: Alignment(0, _scanLine.value * 2 - 1),
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.success.withValues(alpha: 0.7),
                                      blurRadius: 14,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                _error != null ? 'Analysis paused' : 'Analyzing your crop...',
                textAlign: TextAlign.center,
                style: AppTextStyles.pageTitle,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(visual.icon, size: 18, color: visual.color),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text('Using Local AI · $engineLine',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.secondary.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              AppCard(
                child: Column(
                  children: [
                    for (final step in AnalysisStep.values)
                      _StepRow(
                        label: step.label,
                        done: _done.contains(step),
                        active: _current == step && _error == null,
                      ),
                  ],
                ),
              ),
              const Spacer(),
              if (_error != null)
                ErrorState(
                  title: "Couldn't finish the analysis",
                  message: _error!,
                  onRetry: _start,
                )
              else
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'No internet needed — the photo never leaves this phone.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.label, required this.done, required this.active});

  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: done
                ? const Icon(Icons.check_circle_rounded,
                    key: ValueKey('done'), color: AppColors.success, size: 26)
                : active
                    ? const SizedBox(
                        key: ValueKey('active'),
                        width: 26,
                        height: 26,
                        child: Padding(
                          padding: EdgeInsets.all(3),
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
                        ),
                      )
                    : const Icon(Icons.radio_button_unchecked_rounded,
                        key: ValueKey('todo'), color: AppColors.border, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: done || active ? FontWeight.w600 : FontWeight.w400,
                color: done || active ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
