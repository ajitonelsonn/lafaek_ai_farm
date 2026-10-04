import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../core/formatters.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../navigation/main_shell.dart';
import '../../repositories/local_scan_repository.dart';
import '../../services/cloud/ai_router.dart';
import '../../services/connectivity_service.dart';
import '../../services/cloud/online_analysis_service.dart';
import '../../state/chat_state.dart';
import '../../state/connectivity_state.dart';
import '../../state/farm_state.dart';
import '../../l10n/strings.dart';
import '../../state/language_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/buttons.dart';
import '../../widgets/scan_image.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/states.dart';

/// Scan Result — what we found, in plain language, with hedged wording.
class ScanResultScreen extends StatefulWidget {
  const ScanResultScreen({super.key, required this.result});

  final ScanResult result;

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  late bool _saved = widget.result.savedToFarm;

  OnlineAnalysis? _online;
  OnlineIdentification? _identified;
  bool _askingOnline = false;

  /// The result as it should now be shown.
  ///
  /// When Claude identified the photo, its reading replaces the on-device
  /// "unknown" everywhere on the screen — not just in the header. Showing
  /// the local model's 46% next to Claude's answer would be stating a
  /// confidence about a different conclusion.
  ScanResult get _effective {
    final id = _identified;
    if (id == null) return widget.result;
    return widget.result.copyWith(
      cropName: id.crop,
      issue: id.condition,
      explanation: id.summary.isEmpty ? widget.result.explanation : id.summary,
      actions: id.actions.isEmpty
          ? widget.result.actions
          : [
              for (final a in id.actions)
                RecommendedAction(title: a, detail: ''),
            ],
      confidenceBand: switch (id.confidence) {
        'high' => 'High confidence',
        'moderate' => 'Moderate confidence',
        _ => 'Low confidence',
      },
      severity: id.askAPerson ? 'Check with an officer' : 'Review',
      affectedArea: 'From the photograph',
      engine: id.model,
      identifiedOnline: true,
    );
  }

  /// True when the on-device model had no answer — the only case where the
  /// photograph itself is sent anywhere.
  bool get _localIsUnclear {
    final id = widget.result.conditionId;
    return id == null || id == 'unknown' || id == 'other';
  }

  @override
  void initState() {
    super.initState();
    // The local result is already on screen and already saved. This only ever
    // adds to it, so it runs after the first frame and failure is silent.
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchOnline());
  }

  Future<void> _fetchOnline({bool force = false}) async {
    final repo = context.read<LocalScanRepository>();

    // A previous identification is already in the database — show it rather
    // than paying for the same request twice.
    final storedId = await repo.onlineIdentificationFor(widget.result.id);
    if (!mounted) return;
    if (storedId != null && !force) {
      setState(() => _identified = storedId);
      return;
    }
    final stored = await repo.onlineAnalysisFor(widget.result.id);
    if (!mounted) return;
    if (stored != null && !force) {
      setState(() => _online = stored);
      return;
    }
    // Route on the measured connection, not on "is there an interface".
    final conn = context.read<ConnectivityState>();
    final route = AiRouter.forScan(
      quality: conn.quality,
      localIsUnclear: _localIsUnclear,
    );
    if (route != AiRoute.cloud && !force) return;
    if (!AiRouter.isFastEnough(conn.quality)) return;

    setState(() => _askingOnline = true);
    final farm = context.read<FarmState>();
    final weather = farm.weather;
    final r = widget.result;
    if (_localIsUnclear) {
      final identified = await _identifyFromPhoto(farm, weather);
      if (identified != null) {
        // Write it to SQLite so it survives leaving the screen and the scan
        // history stops showing "Unknown crop".
        await repo.attachOnlineIdentification(widget.result.id, identified);
        await farm.refresh();
      }
      if (!mounted) return;
      setState(() {
        _identified = identified;
        _askingOnline = false;
      });
      return;
    }

    final result = await const OnlineAnalysisService().reanalyse(
      local: LocalScanSummary(
        label: r.conditionId ?? r.issue,
        confidence: r.confidence,
        margin: r.margin,
        runnerUp: r.runnerUp,
        modelName: r.modelName ?? '',
        crop: r.cropName,
        growthStage: r.growthStage,
      ),
      farm: FarmContext(
        location: farm.farmer?.location ?? '',
        temperatureC: weather?.now.temperatureC.toDouble(),
        humidity: weather?.now.humidity,
        rainChance: weather?.now.rainChance,
        soilMoisture: weather?.now.soilMoistureLabel ?? '',
      ),
      language: context.read<LanguageState>().language.code,
    );
    if (!mounted) return;
    if (result != null) {
      await repo.attachOnlineAnalysis(widget.result.id, result);
    }
    if (!mounted) return;
    setState(() {
      _online = result;
      _askingOnline = false;
    });
  }

  /// Sends the photograph to Claude, which can see images, because the
  /// on-device model could not place it.
  ///
  /// This is the only upload in the app. It is downscaled to 640 px first so
  /// it is a few tens of KB on a weak link, and the farmer is told on screen
  /// that the photo was sent.
  Future<OnlineIdentification?> _identifyFromPhoto(
      FarmState farm, WeatherBundle? weather) async {
    try {
      final file = File(widget.result.imageAsset);
      if (!await file.exists()) return null;
      final bytes = await file.readAsBytes();
      final shrunk = await compute(_downscaleForUpload, bytes);
      if (!mounted) return null;
      return await const OnlineAnalysisService().identify(
        jpegBytes: shrunk,
        localLabel: widget.result.conditionId ?? 'unknown',
        farm: FarmContext(
          crop: widget.result.cropName,
          location: farm.farmer?.location ?? '',
          growthStage: widget.result.growthStage,
          temperatureC: weather?.now.temperatureC.toDouble(),
          humidity: weather?.now.humidity,
          rainChance: weather?.now.rainChance,
          soilMoisture: weather?.now.soilMoistureLabel ?? '',
        ),
        language: context.read<LanguageState>().language.code,
      );
    } catch (e) {
      debugPrint('identify from photo failed: $e');
      return null;
    }
  }

  Future<void> _save() async {
    setState(() => _saved = true);
    await context.read<FarmState>().saveScan(widget.result);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
            SizedBox(width: 10),
            Expanded(child: Text('Saved to My Farm on this device.')),
          ],
        ),
        action: SnackBarAction(
          label: 'View',
          textColor: AppColors.mint,
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.shell,
            (r) => false,
            arguments: MainTab.farm,
          ),
        ),
      ));
  }

  void _scanAnother() {
    Navigator.of(context).popUntil((r) => r.isFirst);
    final scope = MainShellScope.maybeOf(context);
    scope?.goTo(MainTab.scan);
  }

  void _askAi() {
    context.read<ChatState>().startNewConversation();
    context.read<ChatState>().send(
        'My ${widget.result.cropName.toLowerCase()} scan shows ${widget.result.issue.toLowerCase()}. What should I do?');
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.shell,
      (r) => false,
      arguments: MainTab.assistant,
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _effective;
    final visual = StatusVisual.health(r.status);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: AppHeader(
                title: 'Scan Result',
                subtitle: 'Here is what we found',
                showBack: true,
                centered: true,
              ),
            ),
            const SliverToBoxAdapter(child: OfflineBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final narrow = c.maxWidth < 380;
                    final image = _ResultImage(asset: r.imageAsset);
                    final details =
                        _DetailsCard(result: r, visual: visual);
                    if (narrow) {
                      return Column(
                        children: [
                          SizedBox(height: 220, child: image),
                          const SizedBox(height: 12),
                          details,
                        ],
                      );
                    }
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: image),
                          const SizedBox(width: 12),
                          Expanded(child: details),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            if (!r.identifiedOnline &&
                (r.isUnknown || (r.confidenceBand ?? '').startsWith('Low')))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page, 12, AppSpacing.page, 0),
                  child: AppCard(
                    color: AppColors.warningTint,
                    shadow: false,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const IconTile(
                            icon: Icons.help_outline_rounded,
                            color: AppColors.warning,
                            background: AppColors.white),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Possible crop issue', style: AppTextStyles.cardTitle),
                              const SizedBox(height: 4),
                              Text(
                                'The image is not clear enough to identify the problem confidently. Try another photo in better lighting.',
                                style: AppTextStyles.body.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, 12, AppSpacing.page, 0),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: AppCard(
                    color: AppColors.lightGreen,
                    shadow: false,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const IconTile(
                            icon: Icons.medical_services_rounded,
                            background: AppColors.white),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('What does this mean?',
                                  style: AppTextStyles.cardTitle),
                              const SizedBox(height: 4),
                              Text(r.explanation, style: AppTextStyles.body),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, 12, AppSpacing.page, 0),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 180),
                  child: _ActionsCard(result: r),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _OnlineSecondOpinion(
                analysis: _online,
                identification: _identified,
                loading: _askingOnline,
                localIsUnclear: _localIsUnclear,
                onRetry: () => _fetchOnline(force: true),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, 12, AppSpacing.page, 0),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final tiles = [
                      _ShortcutTile(
                        icon: Icons.wb_sunny_rounded,
                        color: AppColors.warning,
                        title: 'Weather Info',
                        subtitle: 'Check risk',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.weather),
                      ),
                      _ShortcutTile(
                        icon: Icons.menu_book_rounded,
                        color: AppColors.waterBlue,
                        title: 'Learn More',
                        subtitle: 'About this disease',
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.diseaseDetails,
                          arguments: r.issue,
                        ),
                      ),
                      _ShortcutTile(
                        icon: Icons.eco_rounded,
                        color: AppColors.primary,
                        title: 'Similar Cases',
                        subtitle: 'View examples',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.scanHistory),
                      ),
                      _ShortcutTile(
                        icon: Icons.chat_bubble_rounded,
                        color: AppColors.lavender,
                        title: 'Ask AI',
                        subtitle: 'Get more advice',
                        onTap: _askAi,
                      ),
                    ];
                    // Two per row on narrow phones so labels stay readable.
                    if (c.maxWidth < 400) {
                      return Column(
                        children: [
                          Row(children: [
                            Expanded(child: tiles[0]),
                            const SizedBox(width: 10),
                            Expanded(child: tiles[1]),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(child: tiles[2]),
                            const SizedBox(width: 10),
                            Expanded(child: tiles[3]),
                          ]),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        for (var i = 0; i < tiles.length; i++) ...[
                          if (i > 0) const SizedBox(width: 10),
                          Expanded(child: tiles[i]),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
            // The farmer's own past scans of this crop. This used to be five
            // copies of the same stock maize photo, which told a papaya
            // grower nothing; now it is real history, and it hides itself
            // when there is none.
            SliverToBoxAdapter(child: _SimilarCases(current: r)),
            SliverPadding(padding: EdgeInsets.only(bottom: 150 + bottom)),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: EdgeInsets.fromLTRB(
            AppSpacing.page, 12, AppSpacing.page, 12 + bottom),
        decoration: const BoxDecoration(
          color: AppColors.cream,
          boxShadow: [
            BoxShadow(
                color: Color(0x1414212B),
                blurRadius: 20,
                offset: Offset(0, -6)),
          ],
        ),
        child: _BottomActions(
          saved: _saved,
          onScanAnother: _scanAnother,
          onSave: _saved ? null : _save,
        ),
      ),
    );
  }
}

/// "Scan Another" + "Save to My Farm". Side by side when there is room,
/// stacked (primary on top) on narrow phones so labels never truncate.
class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.saved,
    required this.onScanAnother,
    required this.onSave,
  });

  final bool saved;
  final VoidCallback onScanAnother;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    final save = PrimaryButton(
      label: saved ? 'Saved to My Farm' : 'Save to My Farm',
      icon: saved ? Icons.check_rounded : Icons.eco_rounded,
      onPressed: onSave,
    );
    final scan = SecondaryButton(
      label: 'Scan Another',
      icon: Icons.photo_camera_rounded,
      onPressed: onScanAnother,
    );
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 400) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              save,
              const SizedBox(height: 10),
              SizedBox(height: 50, child: scan),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: scan),
            const SizedBox(width: 12),
            Expanded(child: save),
          ],
        );
      },
    );
  }
}

class _ResultImage extends StatelessWidget {
  const _ResultImage({required this.asset});
  final String asset;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ScanImage(asset, fit: BoxFit.cover),
          Positioned(
            left: 12,
            bottom: 12,
            child: Material(
              color: const Color(0xAA141A16),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      child: ScanImage(asset, fit: BoxFit.contain),
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.open_in_full_rounded,
                          size: 16, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('View Full Image',
                          style: AppTextStyles.caption
                              .copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.result, required this.visual});
  final ScanResult result;
  final StatusVisual visual;

  @override
  Widget build(BuildContext context) {
    final r = result;
    final cropName = r.cropName;
    final cropLabel =
        r.identifiedOnline ? 'Identified online' : 'Detected crop';
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              cropName.toLowerCase().startsWith('unknown')
                  ? const IconTile(
                      icon: Icons.help_outline_rounded,
                      color: AppColors.textSecondary,
                      background: AppColors.surfaceMuted,
                      size: 56)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(AppAssets.cropImageFor(cropName),
                          width: 56, height: 56, fit: BoxFit.cover),
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cropName,
                        style: AppTextStyles.sectionTitle
                            .copyWith(fontSize: 22),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    Text(cropLabel, style: AppTextStyles.secondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: visual.tint,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              children: [
                IconTile(
                  icon: r.isHealthy
                      ? Icons.check_circle_rounded
                      : Icons.eco_rounded,
                  color: visual.color,
                  background: AppColors.white,
                  size: 40,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.issue,
                          style: AppTextStyles.cardTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      if (r.issue == 'No leaf detected')
                        Text('Point the camera at a single leaf', style: AppTextStyles.secondary)
                      else
                      if (r.identifiedOnline)
                        // Claude does not return a percentage, and the local
                        // model's number was about a different answer.
                        Text(r.confidenceBand ?? 'Moderate confidence',
                            style: AppTextStyles.secondary)
                      else
                      RichText(
                        text: TextSpan(
                          style: AppTextStyles.secondary,
                          children: [
                            const TextSpan(text: 'Confidence: '),
                            TextSpan(
                              text: '${(r.confidence * 100).round()}%',
                              style: AppTextStyles.bodyStrong.copyWith(
                                  color: r.confidence >= 0.8
                                      ? AppColors.success
                                      : r.confidence >= 0.6
                                          ? AppColors.warning
                                          : AppColors.danger,
                                  fontSize: 14),
                            ),
                            if (r.confidenceBand != null)
                              TextSpan(text: ' · ${r.confidenceBand}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _KV('Severity', r.severity,
              badge: !r.isHealthy
                  ? StatusBadge(
                      label: r.severity,
                      visual: StatusVisual.health(r.status),
                      small: true,
                    )
                  : null),
          _KV('Affected area', r.affectedArea),
          _KV('Growth stage', r.growthStage),
          _KV('Date', Formatters.shortDate(r.scannedAt)),
          if (r.modelName != null)
            _KV('Vision model',
                '${r.modelName}${r.inferenceTimeMs != null && r.inferenceTimeMs! > 0 ? ' · ${r.inferenceTimeMs} ms' : ''}'),
          _KV('Explained by', r.engine),
        ],
      ),
    );
  }
}

class _KV extends StatelessWidget {
  const _KV(this.k, this.v, {this.badge});
  final String k;
  final String v;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(k, style: AppTextStyles.secondary)),
          badge ??
              Flexible(
                child: Text(v,
                    textAlign: TextAlign.end,
                    style: AppTextStyles.bodyStrong.copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
        ],
      ),
    );
  }
}

class _ActionsCard extends StatelessWidget {
  const _ActionsCard({required this.result});
  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.lightGreen,
      shadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconTile(
                  icon: Icons.assignment_rounded,
                  color: AppColors.white,
                  background: AppColors.primary,
                  size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Recommended Actions',
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 18)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 16, color: Colors.white),
                    const SizedBox(width: 6),
                    Text('AI Advice',
                        style: AppTextStyles.caption
                            .copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < result.actions.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text('${i + 1}',
                        style: AppTextStyles.bodyStrong
                            .copyWith(color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(result.actions[i].title,
                            style: AppTextStyles.cardTitle),
                        Text(result.actions[i].detail,
                            style: AppTextStyles.secondary),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI advice is informational. For uncertain cases, consider checking with a local agricultural extension officer.',
                    style: AppTextStyles.caption,
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

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyStrong.copyWith(fontSize: 14)),
          Text(subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}


/// Claude Haiku's second opinion, shown beneath the on-device result.
///
/// Deliberately *below* the local analysis and clearly labelled: the phone's
/// answer is the product, this is the enhancement. Offline it is simply
/// absent — there is no error, because nothing failed that the farmer needed.
class _OnlineSecondOpinion extends StatelessWidget {
  const _OnlineSecondOpinion({
    required this.analysis,
    required this.identification,
    required this.loading,
    required this.localIsUnclear,
    required this.onRetry,
  });

  final OnlineAnalysis? analysis;
  final OnlineIdentification? identification;
  final bool loading;

  /// True when the on-device model had no answer, so Claude was shown the
  /// photograph rather than just the label.
  final bool localIsUnclear;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final quality = context.watch<ConnectivityState>().quality;
    final slow = !AiRouter.isFastEnough(quality);
    final a = analysis;
    final id = identification;

    // The on-device model could not place the photo, and Claude looked at it.
    if (id != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.page, 12, AppSpacing.page, 0),
        child: AppCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded,
                      size: 18, color: AppColors.lavender),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Identified online',
                        style: AppTextStyles.cardTitle),
                  ),
                  IconButton(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Ask again',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('${id.crop} — ${id.condition}',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 17)),
              const SizedBox(height: 6),
              Text(id.summary, style: AppTextStyles.body),
              if (id.actions.isNotEmpty) ...[
                const SizedBox(height: 10),
                for (final action in id.actions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  ', style: AppTextStyles.body),
                        Expanded(
                            child: Text(action,
                                style:
                                    AppTextStyles.body.copyWith(fontSize: 14))),
                      ],
                    ),
                  ),
              ],
              if (id.askAPerson) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warningTint,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_search_rounded,
                          size: 18, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Not certain enough — check with an agricultural '
                          'extension officer before acting.',
                          style: AppTextStyles.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (id.caveat.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(id.caveat, style: AppTextStyles.caption),
              ],
              const SizedBox(height: 8),
              // Said plainly: this is the one case where the image is sent.
              Text(
                '${id.model} · the phone could not identify this, so the photo '
                'was sent to be looked at. Every other scan stays on the device.',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      );
    }

    // The phone had no answer and the link was judged too slow. Offer the
    // choice rather than deciding for the farmer.
    if (id == null && a == null && !loading && localIsUnclear &&
        quality != NetworkQuality.none) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.page, 12, AppSpacing.page, 0),
        child: AppCard(
          color: AppColors.lightGreen,
          shadow: false,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('The phone could not identify this photo',
                  style: AppTextStyles.cardTitle),
              const SizedBox(height: 6),
              Text(
                'Claude can look at the picture itself. Your connection '
                'measured slower than 600 ms, so it was not sent automatically '
                '— the photo would take a while to upload.',
                style: AppTextStyles.secondary,
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Send the photo to be identified',
                icon: Icons.auto_awesome_rounded,
                height: 44,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      );
    }

    if (a == null && !loading && slow && localIsUnclear) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.page, 12, AppSpacing.page, 0),
        child: AppCard(
          color: AppColors.surfaceMuted,
          shadow: false,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 20, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  quality == NetworkQuality.none
                      ? 'The phone could not identify this photo. With a signal '
                          'it can be sent to be looked at online. Your result '
                          'above is saved either way.'
                      : 'The connection is too slow to be worth waiting for '
                          '(over 600 ms). Your result above is saved.',
                  style: AppTextStyles.secondary,
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (a == null && !loading) return const SizedBox.shrink();

    return Padding(
      padding:
          const EdgeInsets.fromLTRB(AppSpacing.page, 12, AppSpacing.page, 0),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded,
                    size: 18, color: AppColors.lavender),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Second opinion (online)',
                      style: AppTextStyles.cardTitle),
                ),
                if (loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.lavender),
                  )
                else
                  IconButton(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Ask again',
                  ),
              ],
            ),
            if (a != null) ...[
              const SizedBox(height: 8),
              Text(a.summary, style: AppTextStyles.body),
              if (a.actions.isNotEmpty) ...[
                const SizedBox(height: 10),
                for (final action in a.actions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('•  ', style: AppTextStyles.body),
                        Expanded(
                            child: Text(action,
                                style: AppTextStyles.body.copyWith(fontSize: 14))),
                      ],
                    ),
                  ),
              ],
              if (a.askAPerson) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warningTint,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_search_rounded,
                          size: 18, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Not certain enough — check with an agricultural '
                          'extension officer before acting.',
                          style: AppTextStyles.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (a.caveat.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(a.caveat, style: AppTextStyles.caption),
              ],
              const SizedBox(height: 8),
              Text(
                '${a.model} · the photo was not uploaded, only the on-device '
                'result and your farm conditions.',
                style: AppTextStyles.caption,
              ),
            ],
          ],
        ),
      ),
    );
  }
}


/// Shrinks a scan photo before upload. Runs in an isolate: a full-resolution
/// camera JPEG would be megabytes on a connection that may barely work.
Uint8List _downscaleForUpload(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return bytes;
  final resized = decoded.width > 640 || decoded.height > 640
      ? img.copyResize(decoded,
          width: decoded.width >= decoded.height ? 640 : null,
          height: decoded.height > decoded.width ? 640 : null)
      : decoded;
  return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
}


/// Past scans of the same crop, from the farmer's own history.
///
/// Replaces a row of stock photographs that were the same image whatever had
/// been scanned. Real history is useful — "has this happened before on this
/// crop?" — and when there is none the section simply does not appear, which
/// is more honest than filling it.
class _SimilarCases extends StatelessWidget {
  const _SimilarCases({required this.current});

  final ScanResult current;

  @override
  Widget build(BuildContext context) {
    final all = context.watch<FarmState>().scans;
    final crop = current.cropName.toLowerCase();
    final similar = all
        .where((s) =>
            s.id != current.id && s.cropName.toLowerCase() == crop)
        .take(6)
        .toList();
    if (similar.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Your past ${current.cropName} scans',
          actionLabel: 'See all',
          onAction: () =>
              Navigator.of(context).pushNamed(AppRoutes.scanHistory),
        ),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            itemCount: similar.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final s = similar[i];
              return GestureDetector(
                onTap: () => Navigator.of(context).pushReplacementNamed(
                    AppRoutes.scanResult,
                    arguments: s),
                child: SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        child: ScanImage(s.imageAsset,
                            width: 120, height: 76, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 4),
                      Text(Formatters.shortDate(s.scannedAt),
                          style: AppTextStyles.caption),
                      Text(s.issue,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
