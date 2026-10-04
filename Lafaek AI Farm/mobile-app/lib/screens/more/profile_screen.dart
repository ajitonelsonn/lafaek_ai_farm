import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../navigation/app_routes.dart';
import '../../state/farm_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_header.dart';
import '../../widgets/buttons.dart';
import '../../widgets/form_widgets.dart';

/// Profile — farmer and farm details.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmState>();
    final f = farm.farmer;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Profile',
              showBack: true,
              showAiStatus: false,
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, 0, AppSpacing.page, 32),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    child: SizedBox(
                      height: 190,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(AppAssets.sceneFarmer,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.medium),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0x11000000), Color(0xB3073B20)],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 3),
                                  ),
                                  alignment: Alignment.center,
                                  child: const AppIcon(AppAssets.icProfile,
                                      size: 44),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(f?.name ?? 'Farmer',
                                          style: AppTextStyles.sectionTitle
                                              .copyWith(color: Colors.white)),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on_rounded,
                                              size: 16, color: Colors.white),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(f?.location ?? '',
                                                style: AppTextStyles.secondary
                                                    .copyWith(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      children: [
                        _Info('Phone', f?.phone ?? '—'),
                        _Info('Farming since',
                            '${f?.farmingYears.toStringAsFixed(1) ?? '—'} years'),
                        _Info('Total area', '${farm.totalAreaHa.toStringAsFixed(1)} ha'),
                        _Info('Crops', farm.crops.map((c) => c.name).join(', ')),
                        _Info('Locations', farm.locations.map((l) => l.name).join(', ')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SettingsGroup(
                    title: 'Farm',
                    rows: [
                      SettingsRow(
                        asset: AppAssets.icPlanting,
                        title: 'Add Crop',
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.addCrop),
                      ),
                      SettingsRow(
                        asset: AppAssets.icLocation,
                        color: AppColors.warning,
                        tint: AppColors.warningTint,
                        title: 'Add Location',
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.addLocation),
                      ),
                      SettingsRow(
                        asset: AppAssets.icReports,
                        color: AppColors.lavender,
                        tint: AppColors.lavenderTint,
                        title: 'Farm Report',
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.reports),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SecondaryButton(
                    label: 'Edit profile',
                    icon: Icons.edit_rounded,
                    onPressed: () => _editProfile(context, farm),
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

Future<void> _editProfile(BuildContext context, FarmState farm) async {
  final f = farm.farmer;
  final name = TextEditingController(text: f?.name ?? '');
  final location = TextEditingController(text: f?.location ?? '');
  final phone = TextEditingController(text: f?.phone ?? '');
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Edit profile'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: name, decoration: const InputDecoration(hintText: 'Name')),
          const SizedBox(height: 10),
          TextField(controller: location, decoration: const InputDecoration(hintText: 'Location')),
          const SizedBox(height: 10),
          TextField(controller: phone, decoration: const InputDecoration(hintText: 'Phone'), keyboardType: TextInputType.phone),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
      ],
    ),
  );
  if (ok == true) {
    await farm.updateProfile(
      name: name.text.trim().isEmpty ? null : name.text.trim(),
      location: location.text.trim().isEmpty ? null : location.text.trim(),
      phone: phone.text.trim().isEmpty ? null : phone.text.trim(),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved on this device.')));
    }
  }
  name.dispose();
  location.dispose();
  phone.dispose();
}

class _Info extends StatelessWidget {
  const _Info(this.k, this.v);
  final String k;
  final String v;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(k, style: AppTextStyles.secondary)),
          Expanded(child: Text(v, style: AppTextStyles.bodyStrong.copyWith(fontSize: 14))),
        ],
      ),
    );
  }
}
