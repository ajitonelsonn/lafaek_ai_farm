import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../l10n/strings.dart';
import '../../models/models.dart';
import '../../core/crop_catalogue.dart';
import '../../state/connectivity_state.dart';
import '../../state/farm_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/states.dart';

/// Add Crop — a short, friendly form.
class AddCropScreen extends StatefulWidget {
  const AddCropScreen({super.key});

  @override
  State<AddCropScreen> createState() => _AddCropScreenState();
}

class _AddCropScreenState extends State<AddCropScreen> {
  final _form = GlobalKey<FormState>();
  final _area = TextEditingController(text: '0.5');
  final _variety = TextEditingController();
  String? _crop = 'Maize';
  String? _location;
  bool _saving = false;

  @override
  void dispose() {
    _area.dispose();
    _variety.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _crop == null) return;
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    final farm = context.read<FarmState>();
    final conn = context.read<ConnectivityState>();
    farm.addCrop(Crop(
      id: 'crop-${DateTime.now().millisecondsSinceEpoch}',
      name: _crop!,
      areaHa: double.tryParse(_area.text) ?? 0.5,
      status: HealthStatus.healthy,
      plantedOn: DateTime.now(),
      locationName: _location ?? farm.locations.first.name,
      variety: _variety.text.isEmpty ? null : _variety.text,
      growthStage: 'Seedling',
    ));
    if (!conn.mode.isCloud) conn.queueForSync('farm records');
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(conn.mode.isCloud
            ? '$_crop added to your farm.'
            : '$_crop saved on this device. Will sync when online.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmState>();
    final s = S.of(context);
    // Online-only crops need a working connection, not merely an interface.
    final online = !context.watch<ConnectivityState>().isOffline;
    _location ??= farm.locations.isEmpty ? null : farm.locations.first.name;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: s.addCrop,
              subtitle: 'Record a new crop on your farm',
              showBack: true,
              showAiStatus: false,
            ),
            const OfflineBanner(),
            Expanded(
              child: Form(
                key: _form,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page, 0, AppSpacing.page, 24),
                  children: [
                    // Crops are grouped by what the app can actually do for
                    // them. The offline set is backed by the on-device model
                    // and the local knowledge library; the rest depend on the
                    // online service, and saying so here is kinder than
                    // letting a farmer find out in a field with no signal.
                    ChoiceRow<String>(
                      label: '${s.addCrop} · ${s.cropsWorkOffline}',
                      options: CropCatalogue.offlineCrops,
                      selected: _crop,
                      labelOf: (c) => c,
                      onSelected: (c) => setState(() => _crop = c),
                    ),
                    const SizedBox(height: 16),
                    ChoiceRow<String>(
                      label: '${s.cropsNeedInternet}'
                          '${online ? '' : ' — ${s.needsInternetBadge}'}',
                      options: CropCatalogue.onlineOnlyCrops,
                      selected: _crop,
                      labelOf: (c) => c,
                      enabledOf: (_) => online,
                      onSelected: (c) => setState(() => _crop = c),
                    ),
                    if (!online) ...[
                      const SizedBox(height: 6),
                      Text(s.cropOnlineOnlyOffline,
                          style: AppTextStyles.caption),
                    ],
                    const SizedBox(height: 16),
                    // Confirms the crop that is selected. A landscape photo
                    // was wrong here: crops without their own scene fell back
                    // to a village, which told the farmer nothing.
                    if (_crop != null)
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                            AppIcon(AppAssets.cropImageFor(_crop!), size: 76),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_crop!, style: AppTextStyles.sectionTitle),
                                  const SizedBox(height: 4),
                                  Text(
                                    switch (CropCatalogue.supportFor(_crop!)) {
                                      CropSupport.localScan =>
                                        s.cropScannable(_crop!),
                                      CropSupport.localAdvice =>
                                        s.cropNotScannable(_crop!),
                                      CropSupport.onlineOnly =>
                                        s.cropOnlineOnly(_crop!),
                                    },
                                    style: AppTextStyles.secondary,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    LabeledField(
                      label: 'Area',
                      controller: _area,
                      hint: '0.5',
                      suffix: 'ha',
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        if (n == null || n <= 0) return 'Enter the area in hectares';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    LabeledField(
                      label: 'Variety (optional)',
                      controller: _variety,
                      hint: 'e.g. Sele',
                    ),
                    const SizedBox(height: 16),
                    ChoiceRow<String>(
                      label: 'Location',
                      options: [for (final l in farm.locations) l.name],
                      selected: _location,
                      labelOf: (s) => s,
                      iconOf: (_) => Icons.location_on_rounded,
                      onSelected: (s) => setState(() => _location = s),
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'Save Crop',
                      icon: Icons.check_rounded,
                      loading: _saving,
                      onPressed: _save,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Saved on this device. Cloud sync arrives in the next phase.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
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
