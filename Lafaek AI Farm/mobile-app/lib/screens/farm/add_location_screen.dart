import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../models/models.dart';
import '../../repositories/local_weather_service.dart';
import '../../services/map/device_location_service.dart';
import '../../state/connectivity_state.dart';
import '../../state/farm_state.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/buttons.dart';
import '../../widgets/farm_map.dart';
import '../../widgets/form_widgets.dart';
import '../../widgets/states.dart';

/// Add Farm Location — name, district, area, and the plot's position on an
/// OpenStreetMap. The coordinates are what the weather forecast is fetched
/// for, so pinning the field makes the forecast local to it.
class AddLocationScreen extends StatefulWidget {
  const AddLocationScreen({super.key});

  @override
  State<AddLocationScreen> createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _area = TextEditingController(text: '1.0');
  final _mapKey = GlobalKey<FarmMapState>();
  final _location = const DeviceLocationService();

  String _district = 'Dili';
  LatLng? _pin;
  bool _saving = false;
  bool _locating = false;

  /// Municipality centres, so choosing one moves the map somewhere useful.
  static const Map<String, LatLng> _districts = {
    'Dili': LatLng(-8.5569, 125.5603),
    'Liquiçá': LatLng(-8.5883, 125.3253),
    'Aileu': LatLng(-8.7281, 125.5664),
    'Manatuto': LatLng(-8.5097, 126.0144),
    'Baucau': LatLng(-8.4717, 126.4583),
    'Ermera': LatLng(-8.7525, 125.3975),
    'Viqueque': LatLng(-8.8592, 126.3661),
  };

  @override
  void dispose() {
    _name.dispose();
    _area.dispose();
    super.dispose();
  }

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    final result = await _location.current();
    if (!mounted) return;
    setState(() => _locating = false);
    if (!result.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.failure!.message)),
      );
      return;
    }
    final point = LatLng(result.latitude!, result.longitude!);
    setState(() => _pin = point);
    _mapKey.currentState?.moveTo(point, zoom: 16);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final conn = context.read<ConnectivityState>();
    final farm = context.read<FarmState>();
    final name = _name.text.trim();
    await farm.addLocation(FarmLocation(
      id: 'loc-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      areaHa: double.tryParse(_area.text) ?? 1,
      district: _district,
      latitude: _pin?.latitude,
      longitude: _pin?.longitude,
    ));
    if (!mounted) return;
    if (!conn.mode.isCloud) conn.queueForSync('farm records');
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_pin == null
            ? '$name added to your farm.'
            : '$name added. Weather will now use this field\'s position.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Add Location',
              subtitle: 'Mark your farm on the map',
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
                    FarmMap(
                      key: _mapKey,
                      center: _pin ?? _districts[_district]!,
                      marker: _pin,
                      height: 230,
                      zoom: _pin == null ? 12 : 16,
                      onTap: (point) => setState(() => _pin = point),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: SecondaryButton(
                            label: _locating
                                ? 'Finding your location…'
                                : 'Use my current location',
                            icon: Icons.my_location_rounded,
                            height: 44,
                            onPressed: _locating ? null : _useMyLocation,
                          ),
                        ),
                        if (_pin != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () => setState(() => _pin = null),
                            icon: const Icon(Icons.close_rounded),
                            tooltip: 'Clear pin',
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _pin == null
                          ? 'Tap the map to mark your field, or use your current location. '
                              'Optional — without it, weather uses ${LocalWeatherService.defaultLocationName}.'
                          : 'Pinned at ${_pin!.latitude.toStringAsFixed(4)}, '
                              '${_pin!.longitude.toStringAsFixed(4)}. '
                              'Weather will be fetched for this point.',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 20),
                    LabeledField(
                      label: 'Field name',
                      controller: _name,
                      hint: 'e.g. Hill plot',
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Give this field a name' : null,
                    ),
                    const SizedBox(height: 16),
                    ChoiceRow<String>(
                      label: 'Municipality',
                      options: _districts.keys.toList(),
                      selected: _district,
                      labelOf: (s) => s,
                      onSelected: (s) {
                        setState(() => _district = s);
                        // Move the map there so the farmer is not hunting for
                        // their municipality.
                        if (_pin == null) {
                          _mapKey.currentState?.moveTo(_districts[s]!, zoom: 12);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    LabeledField(
                      label: 'Area',
                      controller: _area,
                      suffix: 'ha',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        final n = double.tryParse(v ?? '');
                        return (n == null || n <= 0) ? 'Enter the area in hectares' : null;
                      },
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      label: 'Save Location',
                      icon: Icons.check_rounded,
                      loading: _saving,
                      onPressed: _save,
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
