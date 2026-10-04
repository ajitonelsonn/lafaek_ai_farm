import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../state/connectivity_state.dart';
import '../../state/farm_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/buttons.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/list_cards.dart';
import '../../widgets/states.dart';

/// Log Activity — record watering, fertilizer, planting or harvest.
class LogActivityScreen extends StatefulWidget {
  const LogActivityScreen({super.key});

  @override
  State<LogActivityScreen> createState() => _LogActivityScreenState();
}

class _LogActivityScreenState extends State<LogActivityScreen> {
  final _note = TextEditingController();
  ActivityType _type = ActivityType.watered;
  String? _crop;
  bool _saving = false;

  static const _labels = {
    ActivityType.watered: 'Watered',
    ActivityType.fertilized: 'Fertilized',
    ActivityType.planted: 'Planted',
    ActivityType.harvested: 'Harvested',
    ActivityType.other: 'Other',
  };

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_crop == null) return;
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    final conn = context.read<ConnectivityState>();
    final verb = _labels[_type]!;
    context.read<FarmState>().logActivity(FarmActivity(
          id: 'act-${DateTime.now().millisecondsSinceEpoch}',
          type: _type,
          title: '$verb ${_crop!.toLowerCase()}',
          detail: _note.text.trim().isEmpty ? _crop! : _note.text.trim(),
          date: DateTime.now(),
          cropName: _crop,
        ));
    if (!conn.mode.isCloud) conn.queueForSync('farm records');
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity logged.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmState>();
    _crop ??= farm.crops.isEmpty ? null : farm.crops.first.name;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Log Activity',
              subtitle: 'Keep a simple record of your work',
              showBack: true,
              showAiStatus: false,
            ),
            const OfflineBanner(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, 0, AppSpacing.page, 24),
                children: [
                  ChoiceRow<ActivityType>(
                    label: 'Activity',
                    options: _labels.keys.toList(),
                    selected: _type,
                    labelOf: (t) => _labels[t]!,
                    iconOf: ActivityRow.iconFor,
                    onSelected: (t) => setState(() => _type = t),
                  ),
                  const SizedBox(height: 16),
                  ChoiceRow<String>(
                    label: 'Crop',
                    options: [for (final c in farm.crops) c.name],
                    selected: _crop,
                    labelOf: (s) => s,
                    onSelected: (s) => setState(() => _crop = s),
                  ),
                  const SizedBox(height: 16),
                  LabeledField(
                    label: 'Note (optional)',
                    controller: _note,
                    hint: 'e.g. 0.5 ha, organic compost',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: 'Save Activity',
                    icon: Icons.check_rounded,
                    loading: _saving,
                    onPressed: _crop == null ? null : _save,
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
