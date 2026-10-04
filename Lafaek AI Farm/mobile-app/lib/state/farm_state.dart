import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../repositories/local_farm_repository.dart';
import '../repositories/local_scan_repository.dart';
import '../repositories/local_weather_service.dart';
import '../services/local_ai/llm_prompt_builder.dart';

/// Farm, scan history, alerts, weather and knowledge — everything the
/// dashboard needs, read from SQLite and refreshed after every write.
class FarmState extends ChangeNotifier {
  FarmState({
    required LocalFarmRepository farm,
    required LocalScanRepository scans,
    required LocalWeatherService weather,
    this.onDataChanged,
  })  : _farm = farm,
        _scans = scans,
        _weather = weather;

  final LocalFarmRepository _farm;
  final LocalScanRepository _scans;
  final LocalWeatherService _weather;

  /// Called after any write so other state (sync counts) can refresh.
  final VoidCallback? onDataChanged;

  bool _loaded = false;
  Farmer? _farmer;
  List<Crop> _crops = [];
  List<FarmLocation> _locations = [];
  List<FarmActivity> _activities = [];
  List<Recommendation> _recommendations = [];
  List<FarmAlert> _alerts = [];
  List<ScanResult> _scanList = [];
  List<KnowledgeArticle> _knowledge = [];
  WeatherBundle? _weatherBundle;
  bool _weatherLoading = false;
  String? _loadError;

  bool get loaded => _loaded;
  String? get loadError => _loadError;
  Farmer? get farmer => _farmer;
  List<Crop> get crops => List.unmodifiable(_crops);
  List<FarmLocation> get locations => List.unmodifiable(_locations);
  List<FarmActivity> get activities => List.unmodifiable(_activities);
  List<Recommendation> get recommendations => List.unmodifiable(_recommendations);
  List<FarmAlert> get alerts => List.unmodifiable(_alerts);
  List<ScanResult> get scans => List.unmodifiable(_scanList);
  List<KnowledgeArticle> get knowledge => List.unmodifiable(_knowledge);
  WeatherBundle? get weather => _weatherBundle;
  bool get weatherLoading => _weatherLoading;

  double get totalAreaHa => _locations.fold(0, (s, l) => s + l.areaHa);
  int get unreadAlerts => _alerts.where((a) => !a.read).length;

  /// Context handed to the local LLM so answers mention the farmer's crops.
  FarmContext farmContext() => FarmContext(
        location: _farmer?.location ?? 'Timor-Leste',
        crops: [
          for (final c in _crops)
            '${c.name} ${c.areaHa.toStringAsFixed(1)} ha (${c.growthStage.toLowerCase()})',
        ],
        weatherSummary: _weatherBundle == null
            ? null
            : '${_weatherBundle!.now.temperatureC}°C, humidity ${_weatherBundle!.now.humidity}%, rain chance ${_weatherBundle!.now.rainChance}%',
      );

  Future<void> load() async {
    try {
      await _reload();
      _loaded = true;
      _loadError = null;
      notifyListeners();
      // Show the stored forecast straight away, then try for a fresh one. The
      // screen is never waiting on the network.
      await refreshWeather();
      await refreshWeather(fetchLive: true);
    } catch (e, st) {
      debugPrint('FarmState.load failed: $e\n$st');
      _loadError = 'Could not open the local database.';
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _reload() async {
    final results = await Future.wait<dynamic>([
      _farm.farmer(),
      _farm.crops(),
      _farm.locations(),
      _farm.activities(),
      _farm.recommendations(),
      _farm.alerts(),
      _scans.history(),
      _farm.knowledge(),
    ]);
    _farmer = results[0] as Farmer;
    _crops = results[1] as List<Crop>;
    _locations = results[2] as List<FarmLocation>;
    _activities = results[3] as List<FarmActivity>;
    _recommendations = results[4] as List<Recommendation>;
    _alerts = results[5] as List<FarmAlert>;
    _scanList = results[6] as List<ScanResult>;
    _knowledge = results[7] as List<KnowledgeArticle>;
  }

  Future<void> refresh() async {
    await _reload();
    notifyListeners();
    onDataChanged?.call();
  }

  /// The plot the forecast is fetched for: the first location the farmer has
  /// pinned on the map. Without one, the service falls back to Dili.
  FarmLocation? get weatherLocation {
    for (final l in _locations) {
      if (l.hasCoordinates) return l;
    }
    return null;
  }

  /// Reads the stored forecast and recomputes per-crop risk.
  ///
  /// [fetchLive] asks Open-Meteo for a new forecast first; it is skipped when
  /// the stored one is still fresh unless [force] is set. A failed fetch is
  /// not an error — the cached forecast is shown with its real age.
  Future<void> refreshWeather({bool fetchLive = false, bool force = false}) async {
    _weatherLoading = true;
    notifyListeners();
    try {
      if (fetchLive) {
        final at = weatherLocation;
        await _weather.refreshFromNetwork(
          latitude: at?.latitude,
          longitude: at?.longitude,
          locationName: at == null
              ? null
              : '${at.name}, ${at.district}',
          force: force,
        );
      }
      _weatherBundle = await _weather.bundleFor(crops: _crops, scans: _scanList);
      await _refreshRecommendations();
    } catch (e) {
      debugPrint('refreshWeather: $e');
    } finally {
      _weatherLoading = false;
      notifyListeners();
    }
  }

  /// Dashboard recommendations are derived locally from risk + scans.
  Future<void> _refreshRecommendations() async {
    final w = _weatherBundle;
    if (w == null) return;
    final recs = <Recommendation>[];
    final worst = w.cropRisks.isEmpty
        ? null
        : w.cropRisks.reduce((a, b) => a.level.index >= b.level.index ? a : b);
    if (worst != null && worst.level != RiskLevel.low) {
      recs.add(Recommendation(
        id: 'rec-risk',
        kind: RecommendationKind.crop,
        title: '${worst.cropName}: ${worst.level.label.toLowerCase()} risk this week',
        detail: worst.advice ?? worst.reason,
      ));
    } else if (_crops.isNotEmpty) {
      recs.add(Recommendation(
        id: 'rec-risk',
        kind: RecommendationKind.crop,
        title: 'Your crops are in good condition',
        detail: 'Keep monitoring and scan a leaf if you notice changes.',
      ));
    }
    recs.add(Recommendation(
      id: 'rec-weather',
      kind: RecommendationKind.weather,
      title: w.insight,
      detail: 'Weather: ${w.sourceLabel.toLowerCase()}.',
    ));
    final latest = _scanList.isEmpty ? null : _scanList.first;
    if (latest != null && !latest.isHealthy) {
      recs.add(Recommendation(
        id: 'rec-scan',
        kind: RecommendationKind.tip,
        title: 'Follow up on your ${latest.cropName.toLowerCase()} scan',
        detail: latest.actions.isEmpty ? latest.issue : latest.actions.first.title,
      ));
    } else {
      recs.add(const Recommendation(
        id: 'rec-tip',
        kind: RecommendationKind.tip,
        title: 'Tip: Use organic compost to improve soil health',
        detail: 'Healthier soil = stronger crops.',
      ));
    }
    await _farm.replaceRecommendations(recs);
    _recommendations = recs;
  }

  Crop? cropById(String id) {
    for (final c in _crops) {
      if (c.id == id) return c;
    }
    return null;
  }

  Crop? cropByName(String name) {
    for (final c in _crops) {
      if (c.name.toLowerCase() == name.toLowerCase()) return c;
    }
    return null;
  }

  Future<void> addCrop(Crop crop) async {
    await _farm.addCrop(crop);
    await _farm.logActivity(FarmActivity(
      id: 'act-${DateTime.now().millisecondsSinceEpoch}',
      type: ActivityType.planted,
      title: 'Planted ${crop.name.toLowerCase()}',
      detail: '${crop.areaHa.toStringAsFixed(1)} ha',
      date: DateTime.now(),
      cropName: crop.name,
    ));
    await refresh();
    await refreshWeather();
  }

  Future<void> addLocation(FarmLocation location) async {
    await _farm.addLocation(location);
    await refresh();
    // A pinned plot changes where the forecast comes from, so refetch for it.
    if (location.hasCoordinates) {
      await refreshWeather(fetchLive: true, force: true);
    }
  }

  Future<void> logActivity(FarmActivity activity) async {
    await _farm.logActivity(activity);
    await refresh();
  }

  /// Marks a completed scan as saved to the farm, updates the crop's health
  /// status and records the activity.
  Future<void> saveScan(ScanResult result, {bool pendingSync = true}) async {
    await _scans.markSavedToFarm(result.id);
    await _farm.logActivity(FarmActivity(
      id: 'act-${DateTime.now().millisecondsSinceEpoch}',
      type: ActivityType.scanned,
      title: 'Scanned crop',
      detail: '${result.cropName} • ${result.issue}',
      date: result.scannedAt,
      cropName: result.cropName,
    ));
    if (cropByName(result.cropName) != null && !result.isUnknown) {
      await _farm.updateCropStatus(result.cropName, result.status);
    }
    await refresh();
    await refreshWeather();
  }

  Future<void> updateProfile({String? name, String? location, String? phone, double? farmingYears}) async {
    await _farm.updateProfile(name: name, location: location, phone: phone, farmingYears: farmingYears);
    await refresh();
  }

  Future<void> markAlertRead(String id) async {
    await _farm.markAlertRead(id);
    _alerts = _alerts.map((a) => a.id == id ? a.copyWith(read: true) : a).toList();
    notifyListeners();
  }

  Future<void> markAllAlertsRead() async {
    await _farm.markAllAlertsRead();
    _alerts = _alerts.map((a) => a.copyWith(read: true)).toList();
    notifyListeners();
  }

  /// Farmer-entered weather conditions (Weather screen).
  Future<void> setManualWeather({
    required int temperatureC,
    required int humidity,
    required int rainChance,
    required WeatherCondition condition,
  }) async {
    await _weather.setManual(
      temperatureC: temperatureC,
      humidity: humidity,
      rainChance: rainChance,
      condition: condition,
    );
    await refreshWeather();
  }

  Future<void> resetWeatherToDemo() async {
    await _weather.resetToDemo();
    await refreshWeather();
  }
}
