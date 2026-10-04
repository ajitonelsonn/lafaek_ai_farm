import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../core/crop_catalogue.dart';
import '../../l10n/strings.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../repositories/local_farm_repository.dart';
import '../../state/farm_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/buttons.dart';
import '../../widgets/form_widgets.dart';

/// First-run setup: the farmer's own name, their farm, and one crop.
///
/// This replaced a seeded demo farm. A new installation now starts empty and
/// every record in the app belongs to the person using it — which is what the
/// challenge means by real-world data, and what makes the saved history on the
/// Home screen worth anything.
///
/// Nothing here needs the internet.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _page = PageController();
  final _nameKey = GlobalKey<FormState>();
  final _farmKey = GlobalKey<FormState>();
  final _cropKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _farmName = TextEditingController(text: 'My Farm');
  final _fieldName = TextEditingController(text: 'Home field');
  final _area = TextEditingController(text: '0.5');

  String _district = 'Dili';
  String _crop = CropCatalogue.supported.first;
  int _step = 0;
  bool _saving = false;

  static const _districts = [
    'Dili', 'Liquiçá', 'Aileu', 'Manatuto', 'Baucau', 'Ermera', 'Viqueque',
    'Bobonaro', 'Covalima', 'Ainaro', 'Lautém', 'Manufahi', 'Oecusse',
  ];

  @override
  void dispose() {
    _page.dispose();
    _name.dispose();
    _phone.dispose();
    _farmName.dispose();
    _fieldName.dispose();
    _area.dispose();
    super.dispose();
  }

  void _next() {
    final forms = [_nameKey, _farmKey, _cropKey];
    if (!(forms[_step].currentState?.validate() ?? true)) return;
    if (_step < 2) {
      setState(() => _step++);
      _page.animateToPage(_step,
          duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step--);
    _page.animateToPage(_step,
        duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    final repo = context.read<LocalFarmRepository>();
    final farm = context.read<FarmState>();
    final now = DateTime.now();
    try {
      await repo.createFarmer(
        name: _name.text.trim(),
        location: _district,
        phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        farmName: _farmName.text.trim().isEmpty ? 'My Farm' : _farmName.text.trim(),
      );
      await repo.addLocation(FarmLocation(
        id: 'loc-${now.millisecondsSinceEpoch}',
        name: _fieldName.text.trim().isEmpty ? 'Home field' : _fieldName.text.trim(),
        areaHa: double.tryParse(_area.text) ?? 0.5,
        district: _district,
      ));
      await repo.addCrop(Crop(
        id: 'crop-${now.millisecondsSinceEpoch}',
        name: _crop,
        locationName: _fieldName.text.trim().isEmpty ? 'Home field' : _fieldName.text.trim(),
        areaHa: double.tryParse(_area.text) ?? 0.5,
        plantedOn: now,
        status: HealthStatus.healthy,
        growthStage: 'Seedling',
      ));
      await farm.load();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).onboardingSaveFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page, 12, AppSpacing.page, 0),
              child: Row(
                children: [
                  if (_step > 0)
                    IconButton(
                      onPressed: _saving ? null : _back,
                      icon: const Icon(Icons.arrow_back_rounded),
                      tooltip: s.back,
                    ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < 3; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: i == _step ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: i <= _step
                                  ? AppColors.primary
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_step > 0) const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _StepFarmer(
                    formKey: _nameKey,
                    name: _name,
                    phone: _phone,
                    district: _district,
                    districts: _districts,
                    onDistrict: (d) => setState(() => _district = d),
                  ),
                  _StepFarm(
                    formKey: _farmKey,
                    farmName: _farmName,
                    fieldName: _fieldName,
                    area: _area,
                  ),
                  _StepCrop(
                    formKey: _cropKey,
                    crop: _crop,
                    onCrop: (c) => setState(() => _crop = c),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: Column(
                children: [
                  PrimaryButton(
                    label: _step < 2 ? s.continueLabel : s.onboardingFinish,
                    icon: _step < 2
                        ? Icons.arrow_forward_rounded
                        : Icons.check_rounded,
                    loading: _saving,
                    onPressed: _saving ? null : _next,
                  ),
                  const SizedBox(height: 8),
                  Text(s.onboardingNoInternet,
                      textAlign: TextAlign.center, style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepShell extends StatelessWidget {
  const _StepShell({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String asset;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.page, 8, AppSpacing.page, 24),
      children: [
        Center(child: AppIcon(asset, size: 132)),
        const SizedBox(height: 12),
        Text(title, style: AppTextStyles.display, textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(subtitle,
            style: AppTextStyles.secondary.copyWith(fontSize: 15),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        child,
      ],
    );
  }
}

class _StepFarmer extends StatelessWidget {
  const _StepFarmer({
    required this.formKey,
    required this.name,
    required this.phone,
    required this.district,
    required this.districts,
    required this.onDistrict,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController phone;
  final String district;
  final List<String> districts;
  final ValueChanged<String> onDistrict;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Form(
      key: formKey,
      child: _StepShell(
        asset: AppAssets.farmerWave,
        title: s.onboardingWelcomeTitle,
        subtitle: s.onboardingWelcomeSubtitle,
        child: Column(
          children: [
            LabeledField(
              label: s.yourName,
              controller: name,
              hint: s.yourNameHint,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? s.yourNameRequired : null,
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: s.phoneOptional,
              controller: phone,
              hint: '+670 …',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            ChoiceRow<String>(
              label: s.municipality,
              options: districts,
              selected: district,
              labelOf: (d) => d,
              onSelected: onDistrict,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepFarm extends StatelessWidget {
  const _StepFarm({
    required this.formKey,
    required this.farmName,
    required this.fieldName,
    required this.area,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController farmName;
  final TextEditingController fieldName;
  final TextEditingController area;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Form(
      key: formKey,
      child: _StepShell(
        asset: AppAssets.farmerPlanting,
        title: s.onboardingFarmTitle,
        subtitle: s.onboardingFarmSubtitle,
        child: Column(
          children: [
            LabeledField(
              label: s.farmName,
              controller: farmName,
              hint: 'e.g. My Farm',
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: s.fieldName,
              controller: fieldName,
              hint: 'e.g. Home field',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? s.fieldNameRequired : null,
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: s.area,
              controller: area,
              suffix: 'ha',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                return (n == null || n <= 0) ? s.areaRequired : null;
              },
            ),
            const SizedBox(height: 10),
            Text(s.onboardingPinLater, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _StepCrop extends StatelessWidget {
  const _StepCrop({
    required this.formKey,
    required this.crop,
    required this.onCrop,
  });

  final GlobalKey<FormState> formKey;
  final String crop;
  final ValueChanged<String> onCrop;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Form(
      key: formKey,
      child: _StepShell(
        asset: AppAssets.farmerHarvest,
        title: s.onboardingCropTitle,
        subtitle: s.onboardingCropSubtitle,
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                for (final c in CropCatalogue.supported)
                  _CropChoice(
                    crop: c,
                    selected: c == crop,
                    onTap: () => onCrop(c),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Row(
                children: [
                  const AppIcon(AppAssets.icCamera, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      CropCatalogue.isScannable(crop)
                          ? s.cropScannable(crop)
                          : s.cropNotScannable(crop),
                      style: AppTextStyles.secondary,
                    ),
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

class _CropChoice extends StatelessWidget {
  const _CropChoice({
    required this.crop,
    required this.selected,
    required this.onTap,
  });

  final String crop;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightGreen : AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            AppIcon(AppAssets.cropImageFor(crop), size: 48),
            const SizedBox(height: 6),
            Text(crop,
                style: AppTextStyles.bodyStrong.copyWith(
                  fontSize: 14,
                  color: selected ? AppColors.primaryDark : AppColors.textPrimary,
                )),
          ],
        ),
      ),
    );
  }
}
