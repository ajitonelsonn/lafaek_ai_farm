
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../navigation/app_routes.dart';
import '../../navigation/main_shell.dart';
import '../../services/local_ai/local_ai_engine.dart';
import '../../core/crop_catalogue.dart';
import 'scan_request.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/buttons.dart';
import '../../widgets/states.dart';

/// Scan Crop — camera view with alignment frame, guidance and supported crops.
///
/// The preview is a bundled photo for the UI build; swap `_CameraPreview`
/// for a real camera plugin later without changing the rest of the screen.
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // Camera
  CameraController? _cam;
  List<CameraDescription> _cameras = const [];
  int _cameraIndex = 0;
  bool _cameraStarting = false;
  String? _cameraError;
  bool _wasActive = false;

  // Capture
  Uint8List? _capturedBytes;
  String? _capturedLabel;
  bool _flash = false;
  bool _autoDetect = true;
  bool _guidanceOpen = true;
  double _zoom = 1;
  late final AnimationController _flashAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );

  bool get _captured => _capturedBytes != null || _capturedLabel == 'Sample photo';
  bool get _cameraReady => _cam?.value.isInitialized == true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _flashAnim.dispose();
    _cam?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _stopCamera();
    } else if (state == AppLifecycleState.resumed && _wasActive) {
      _startCamera();
    }
  }

  /// The camera only runs while the Scan tab is visible.
  void _syncWithTab(bool active) {
    if (active == _wasActive) return;
    _wasActive = active;
    if (active) {
      _startCamera();
    } else {
      _stopCamera();
    }
  }

  Future<void> _startCamera() async {
    if (_cameraStarting || _cameraReady) return;
    _cameraStarting = true;
    try {
      if (_cameras.isEmpty) _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() => _cameraError = 'No camera on this device');
        return;
      }
      final desc = _cameras[_cameraIndex % _cameras.length];
      final ctrl = CameraController(desc, ResolutionPreset.high, enableAudio: false);
      await ctrl.initialize();
      if (!mounted) {
        await ctrl.dispose();
        return;
      }
      await ctrl.setFlashMode(_flash ? FlashMode.torch : FlashMode.off);
      setState(() {
        _cam = ctrl;
        _cameraError = null;
      });
    } on CameraException catch (e) {
      setState(() => _cameraError = e.code == 'CameraAccessDenied'
          ? 'Camera permission denied — using a sample photo'
          : 'Camera unavailable — using a sample photo');
    } catch (e) {
      setState(() => _cameraError = 'Camera unavailable — using a sample photo');
    } finally {
      _cameraStarting = false;
    }
  }

  Future<void> _stopCamera() async {
    final c = _cam;
    _cam = null;
    if (mounted) setState(() {});
    await c?.dispose();
  }

  Future<void> _capture() async {
    HapticFeedback.mediumImpact();
    await _flashAnim.forward(from: 0);
    await _flashAnim.reverse();
    if (!mounted) return;
    if (_cameraReady) {
      try {
        final file = await _cam!.takePicture();
        final bytes = await file.readAsBytes();
        setState(() {
          _capturedBytes = bytes;
          _capturedLabel = 'Camera';
        });
        return;
      } catch (e) {
        _toast('Could not take the photo. Try again.');
        return;
      }
    }
    // No camera: use the bundled sample leaf so the flow still works.
    setState(() {
      _capturedBytes = null;
      _capturedLabel = 'Sample photo';
    });
  }

  Future<void> _pickFromGallery() async {
    try {
      final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600);
      if (x == null) return;
      final bytes = await x.readAsBytes();
      if (!mounted) return;
      setState(() {
        _capturedBytes = bytes;
        _capturedLabel = 'Gallery';
      });
    } catch (e) {
      _toast('Could not open the gallery.');
    }
  }

  void _retake() => setState(() {
        _capturedBytes = null;
        _capturedLabel = null;
      });

  Future<void> _toggleFlash() async {
    setState(() => _flash = !_flash);
    try {
      await _cam?.setFlashMode(_flash ? FlashMode.torch : FlashMode.off);
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) {
      _toast('Only one camera on this device.');
      return;
    }
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _stopCamera();
    await _startCamera();
  }

  Future<void> _cycleZoom() async {
    final next = _zoom >= 3 ? 1.0 : _zoom + 1;
    setState(() => _zoom = next);
    try {
      if (_cameraReady) {
        final max = await _cam!.getMaxZoomLevel();
        await _cam!.setZoomLevel(next.clamp(1.0, max));
      }
    } catch (_) {}
  }

  void _analyze() {
    final req = _capturedBytes != null
        ? ScanRequest(bytes: _capturedBytes, sourceLabel: _capturedLabel ?? 'Camera')
        : const ScanRequest(assetPath: AppAssets.sampleLeaf, sourceLabel: 'Sample photo');
    Navigator.of(context).pushNamed(AppRoutes.scanAnalysis, arguments: req);
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom + 16;
    final active = MainShellScope.maybeOf(context)?.currentIndex == MainTab.scan;
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncWithTab(active));
    final engine = context.watch<LocalAiEngine>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(
              child: AppHeader(
                title: 'Scan Crop',
                subtitle: 'Take a photo to detect problems with AI',
              ),
            ),
            const SliverToBoxAdapter(child: OfflineBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: _CameraPreview(
                  controller: _cameraReady ? _cam : null,
                  cameraError: _cameraError,
                  capturedBytes: _capturedBytes,
                  captured: _captured,
                  flash: _flash,
                  autoDetect: _autoDetect,
                  zoom: _zoom,
                  flashAnim: _flashAnim,
                  visionLabel: engine.visionReady
                      ? '${engine.visionDisplayName} · on-device'
                      : 'Loading vision model…',
                  onCapture: _capture,
                  onRetake: _retake,
                  onAnalyze: _analyze,
                  onToggleFlash: _toggleFlash,
                  onToggleAuto: () => setState(() => _autoDetect = !_autoDetect),
                  onZoom: _cycleZoom,
                  onGallery: _pickFromGallery,
                  onSwitch: _switchCamera,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, AppSpacing.lg, AppSpacing.page, 0),
                child: _GuidanceCard(
                  open: _guidanceOpen,
                  onToggle: () =>
                      setState(() => _guidanceOpen = !_guidanceOpen),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Supported Crops',
                actionLabel: 'View all',
                onAction: () =>
                    Navigator.of(context).pushNamed(AppRoutes.knowledge),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                  itemCount: CropCatalogue.localScanCrops.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final name = CropCatalogue.localScanCrops[i];
                    return _SupportedCropTile(
                      name: name,
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.knowledge,
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverPadding(padding: EdgeInsets.only(bottom: bottomPad)),
          ],
        ),
      ),
    );
  }
}

class _CameraPreview extends StatelessWidget {
  const _CameraPreview({
    required this.controller,
    required this.cameraError,
    required this.capturedBytes,
    required this.visionLabel,
    required this.captured,
    required this.flash,
    required this.autoDetect,
    required this.zoom,
    required this.flashAnim,
    required this.onCapture,
    required this.onRetake,
    required this.onAnalyze,
    required this.onToggleFlash,
    required this.onToggleAuto,
    required this.onZoom,
    required this.onGallery,
    required this.onSwitch,
  });

  final CameraController? controller;
  final String? cameraError;
  final Uint8List? capturedBytes;
  final String visionLabel;
  final bool captured;
  final bool flash;
  final bool autoDetect;
  final double zoom;
  final Animation<double> flashAnim;
  final VoidCallback onCapture;
  final VoidCallback onRetake;
  final VoidCallback onAnalyze;
  final VoidCallback onToggleFlash;
  final VoidCallback onToggleAuto;
  final VoidCallback onZoom;
  final VoidCallback onGallery;
  final VoidCallback onSwitch;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        color: AppColors.darkSurface,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 0.82,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _PreviewSurface(
                    controller: controller,
                    capturedBytes: capturedBytes,
                    zoom: zoom,
                    cameraError: cameraError,
                  ),
                  if (!captured) const _AlignmentFrame(),
                  if (captured)
                    const DecoratedBox(
                      decoration: BoxDecoration(color: Color(0x22000000)),
                    ),
                  // Detects panel
                  Positioned(
                    top: 14,
                    right: 14,
                    child: AnimatedOpacity(
                      opacity: autoDetect && !captured ? 1 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: _DetectsPanel(modelLabel: visionLabel),
                    ),
                  ),
                  // Left rail (sits above the hint line)
                  Positioned(
                    left: 14,
                    bottom: 76,
                    child: _SideRail(
                      autoDetect: autoDetect,
                      flash: flash,
                      onToggleAuto: onToggleAuto,
                      onToggleFlash: onToggleFlash,
                      onGallery: onGallery,
                    ),
                  ),
                  // Hint
                  Positioned(
                    left: 14,
                    right: 100,
                    bottom: 20,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Container(
                          key: ValueKey(captured),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xAA141A16),
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                captured
                                    ? Icons.check_circle_rounded
                                    : Icons.center_focus_weak_rounded,
                                size: 18,
                                color: captured
                                    ? AppColors.success
                                    : Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  captured
                                      ? 'Photo captured'
                                      : 'Align the leaf in the frame',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.caption.copyWith(
                                      color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Zoom
                  Positioned(
                    right: 14,
                    bottom: 20,
                    child: Material(
                      color: const Color(0xAA141A16),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      child: InkWell(
                        onTap: onZoom,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text('${zoom.toInt()}×',
                                    style: AppTextStyles.caption.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 10),
                              Text('3',
                                  style: AppTextStyles.caption
                                      .copyWith(color: Colors.white)),
                              const SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Shutter flash
                  IgnorePointer(
                    child: FadeTransition(
                      opacity: flashAnim,
                      child: const ColoredBox(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // Controls bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: captured
                    ? Row(
                        key: const ValueKey('captured'),
                        children: [
                          Semantics(
                            button: true,
                            label: 'Retake',
                            child: Tooltip(
                              message: 'Retake',
                              child: Material(
                                color: const Color(0x22FFFFFF),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.md),
                                child: InkWell(
                                  onTap: onRetake,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                  child: const SizedBox(
                                    width: 64,
                                    height: 56,
                                    child: Icon(Icons.refresh_rounded,
                                        color: Colors.white, size: 26),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PrimaryButton(
                              label: 'Analyze Crop',
                              icon: Icons.auto_awesome_rounded,
                              onPressed: onAnalyze,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        key: const ValueKey('live'),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _DarkControl(
                            icon: Icons.image_rounded,
                            label: 'Upload',
                            onTap: onGallery,
                          ),
                          _Shutter(onTap: onCapture),
                          _DarkControl(
                            icon: Icons.cameraswitch_rounded,
                            label: 'Switch',
                            onTap: onSwitch,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlignmentFrame extends StatefulWidget {
  const _AlignmentFrame();

  @override
  State<_AlignmentFrame> createState() => _AlignmentFrameState();
}

class _AlignmentFrameState extends State<_AlignmentFrame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0.18, 0.12),
      child: FractionallySizedBox(
        widthFactor: 0.46,
        heightFactor: 0.42,
        child: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: _CornerPainter(),
            ),
            Center(
              child: FadeTransition(
                opacity: Tween(begin: 0.5, end: 1.0).animate(_c),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0x3316A34A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.eco_outlined,
                      color: Colors.white, size: 30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const len = 28.0;
    const r = 16.0;
    final w = size.width;
    final h = size.height;

    void corner(Offset o, int sx, int sy) {
      final p = Path()
        ..moveTo(o.dx, o.dy + sy * len)
        ..lineTo(o.dx, o.dy + sy * r)
        ..quadraticBezierTo(o.dx, o.dy, o.dx + sx * r, o.dy)
        ..lineTo(o.dx + sx * len, o.dy);
      canvas.drawPath(p, paint);
    }

    corner(const Offset(0, 0), 1, 1);
    corner(Offset(w, 0), -1, 1);
    corner(Offset(0, h), 1, -1);
    corner(Offset(w, h), -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DetectsPanel extends StatelessWidget {
  const _DetectsPanel({required this.modelLabel});
  final String modelLabel;

  @override
  Widget build(BuildContext context) {
    // The crops the bundled model actually has classes for. Anything else
    // is handled by the knowledge library, or online.
    const items = [
      'Maize: blight, rust, leaf spot',
      'Rice: blast, bacterial blight, brown spot',
      'Tomato: leaf disease',
      'Papaya: leaf virus, mealybug & mite',
      'Healthy leaves',
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0x99141A16),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.eco_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text('Detects',
                  style: AppTextStyles.bodyStrong
                      .copyWith(color: Colors.white, fontSize: 13)),
            ],
          ),
          Text(modelLabel,
              style: AppTextStyles.caption
                  .copyWith(color: const Color(0xCCFFFFFF), fontSize: 10)),
          const SizedBox(height: 6),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 13, color: AppColors.success),
                  const SizedBox(width: 6),
                  Text(it,
                      style: AppTextStyles.caption
                          .copyWith(color: Colors.white, fontSize: 11)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({
    required this.autoDetect,
    required this.flash,
    required this.onToggleAuto,
    required this.onToggleFlash,
    required this.onGallery,
  });

  final bool autoDetect;
  final bool flash;
  final VoidCallback onToggleAuto;
  final VoidCallback onToggleFlash;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0x99141A16),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RailButton(
            icon: Icons.eco_rounded,
            label: 'Auto',
            active: autoDetect,
            onTap: onToggleAuto,
          ),
          _RailButton(
            icon: Icons.image_rounded,
            label: 'Gallery',
            onTap: onGallery,
          ),
          _RailButton(
            icon: flash ? Icons.flash_on_rounded : Icons.flash_off_rounded,
            label: 'Flash',
            active: flash,
            onTap: onToggleFlash,
          ),
        ],
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 56,
          height: 54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 3),
              Text(label,
                  style: AppTextStyles.caption
                      .copyWith(color: Colors.white, fontSize: 10.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkControl extends StatelessWidget {
  const _DarkControl({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x22FFFFFF),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          width: 84,
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 26),
              const SizedBox(height: 4),
              Text(label,
                  style: AppTextStyles.caption.copyWith(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Shutter extends StatelessWidget {
  const _Shutter({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Take photo',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.success, width: 4),
          ),
          padding: const EdgeInsets.all(6),
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard({required this.open, required this.onToggle});

  final bool open;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    const tips = [
      (Icons.wb_sunny_rounded, AppColors.warning, 'Good lighting', 'Use natural light'),
      (Icons.eco_rounded, AppColors.primary, 'Clear focus', 'Keep it steady'),
      (Icons.crop_free_rounded, AppColors.primary, 'Full leaf/plant', 'Capture the whole leaf'),
      (Icons.grain_rounded, AppColors.primary, 'Multiple angles', 'Try different sides'),
    ];
    return AppCard(
      color: AppColors.lightGreen,
      shadow: false,
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Row(
              children: [
                const IconTile(
                    icon: Icons.eco_rounded,
                    background: AppColors.white,
                    size: 40),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Get better results',
                      style: AppTextStyles.sectionTitle),
                ),
                AnimatedRotation(
                  turns: open ? 0 : 0.5,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_up_rounded,
                      size: 28, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState:
                open ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final t in tips)
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(t.$1, color: t.$2, size: 22),
                          ),
                          const SizedBox(height: 8),
                          Text(t.$3,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(t.$4,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption
                                  .copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _SupportedCropTile extends StatelessWidget {
  const _SupportedCropTile({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(6),
        clip: true,
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.asset(
                AppAssets.cropImageFor(name),
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(name, style: AppTextStyles.cardTitle.copyWith(fontSize: 15)),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}


/// Live camera preview, captured still, or the bundled sample leaf.
class _PreviewSurface extends StatelessWidget {
  const _PreviewSurface({
    required this.controller,
    required this.capturedBytes,
    required this.zoom,
    required this.cameraError,
  });

  final CameraController? controller;
  final Uint8List? capturedBytes;
  final double zoom;
  final String? cameraError;

  @override
  Widget build(BuildContext context) {
    if (capturedBytes != null) {
      return Image.memory(capturedBytes!, fit: BoxFit.cover, gaplessPlayback: true);
    }
    final c = controller;
    if (c != null && c.value.isInitialized) {
      return ClipRect(
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: c.value.previewSize?.height ?? 720,
              height: c.value.previewSize?.width ?? 960,
              child: CameraPreview(c),
            ),
          ),
        ),
      );
    }
    // Fallback: sample photo with an explanatory chip.
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedScale(
          scale: zoom * 0.5 + 0.5,
          duration: const Duration(milliseconds: 300),
          child: Image.asset(AppAssets.sampleLeaf, fit: BoxFit.cover),
        ),
        Positioned(
          top: 14,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xAA141A16),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: cameraError == null
                      ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      : const Icon(Icons.photo_rounded, size: 12, color: Colors.white),
                ),
                const SizedBox(width: 6),
                Text(cameraError ?? 'Starting camera…',
                    style: AppTextStyles.caption.copyWith(color: Colors.white, fontSize: 11)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
