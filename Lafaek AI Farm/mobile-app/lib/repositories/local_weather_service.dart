import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../models/models.dart';
import '../services/farm_services.dart';
import '../services/local_ai/local_risk_engine.dart';
import '../services/weather/open_meteo_client.dart';

/// Weather, in order of preference: **live forecast → cached → manual entry →
/// bundled demo**.
///
/// The live forecast comes from Open-Meteo and is written to `weather_cache`
/// the moment it arrives, so every read after that is a local database read.
/// A failed fetch is never fatal: the cached forecast stays on screen with an
/// honest "Last updated" line, which is the whole point of the cache.
class LocalWeatherService implements WeatherService {
  LocalWeatherService(
    this._db, {
    LocalRiskEngine risk = const LocalRiskEngine(),
    this.locationKey = 'dili',
    OpenMeteoClient client = const OpenMeteoClient(),
  })  : _risk = risk,
        _client = client;

  final AppDatabase _db;
  final LocalRiskEngine _risk;
  final OpenMeteoClient _client;
  final String locationKey;

  /// Dili, used until the farmer pins a plot on the map.
  static const double defaultLatitude = -8.5569;
  static const double defaultLongitude = 125.5603;
  static const String defaultLocationName = 'Dili, Timor-Leste';

  /// A forecast older than this is worth refetching when there is a network.
  static const Duration staleAfter = Duration(hours: 3);

  @override
  Future<WeatherBundle> current() => bundleFor(crops: const [], scans: const []);

  /// True when the stored forecast is missing, stale, or not from the API.
  Future<bool> needsRefresh() async {
    final row = await _db.getWeather(locationKey);
    if (row == null || row.source != 'live') return true;
    return DateTime.now().difference(row.updatedAt) > staleAfter;
  }

  /// Fetches a live forecast and caches it.
  ///
  /// Returns true when the cache was updated. Never throws: the caller is a
  /// UI refresh, and an unreachable weather service must not break a screen
  /// the farmer is already reading.
  Future<bool> refreshFromNetwork({
    double? latitude,
    double? longitude,
    String? locationName,
    bool force = false,
  }) async {
    if (!force && !await needsRefresh()) return false;
    try {
      final payload = await _client.fetch(
        latitude: latitude ?? defaultLatitude,
        longitude: longitude ?? defaultLongitude,
        locationName: locationName ?? defaultLocationName,
      );
      await _db.putWeather(
        locationKey: locationKey,
        payloadJson: jsonEncode(payload),
        source: 'live',
      );
      return true;
    } catch (e) {
      // Expected whenever the farmer is offline; the cache carries the screen.
      debugPrint('weather refresh failed, keeping cached forecast: $e');
      return false;
    }
  }

  /// Weather + per-crop risk computed locally from the farm's crops and
  /// recent scans.
  Future<WeatherBundle> bundleFor({
    required List<Crop> crops,
    required List<ScanResult> scans,
  }) async {
    var row = await _db.getWeather(locationKey);
    if (row == null) {
      await _db.putWeather(locationKey: locationKey, payloadJson: jsonEncode(_demoPayload()), source: 'demo');
      row = await _db.getWeather(locationKey);
    }
    final payload = jsonDecode(row!.payloadJson) as Map<String, dynamic>;
    final base = _fromPayload(payload, updatedAt: row.updatedAt, source: row.source);
    return _withRisk(base, crops, scans);
  }

  /// Farmer-entered conditions (spec §19 source 3).
  Future<void> setManual({
    required int temperatureC,
    required int humidity,
    required int rainChance,
    required WeatherCondition condition,
    int windKmh = 10,
    String soilMoisture = 'Good',
  }) async {
    final existing = await _db.getWeather(locationKey);
    final payload = existing == null
        ? _demoPayload()
        : jsonDecode(existing.payloadJson) as Map<String, dynamic>;
    payload['now'] = {
      'location': payload['now']?['location'] ?? 'Dili, Timor-Leste',
      'temperatureC': temperatureC,
      'condition': condition.name,
      'humidity': humidity,
      'windKmh': windKmh,
      'rainChance': rainChance,
      'soilMoistureLabel': soilMoisture,
      'soilMoistureDelta': 0,
    };
    await _db.putWeather(locationKey: locationKey, payloadJson: jsonEncode(payload), source: 'manual');
  }

  /// Restores the bundled demonstration data.
  Future<void> resetToDemo() =>
      _db.putWeather(locationKey: locationKey, payloadJson: jsonEncode(_demoPayload()), source: 'demo');

  // ---- Risk ----

  WeatherBundle _withRisk(WeatherBundle w, List<Crop> crops, List<ScanResult> scans) {
    if (crops.isEmpty) return w;
    final now = DateTime.now();
    final assessments = <RiskAssessment>[];
    final risks = <CropRisk>[];
    for (final c in crops) {
      final recent = scans
          .where((s) => s.cropName == c.name && now.difference(s.scannedAt).inDays <= 14)
          .map((s) => s.status)
          .toList();
      final a = _risk.assess(RiskInputs(
        cropName: c.name,
        temperatureC: w.now.temperatureC,
        humidity: w.now.humidity,
        rainChance: w.now.rainChance,
        windKmh: w.now.windKmh,
        plantedOn: c.plantedOn,
        growthStage: c.growthStage,
        recentScans: recent,
        soilMoistureLabel: w.now.soilMoistureLabel,
      ));
      assessments.add(a);
      risks.add(CropRisk(
        cropName: c.name,
        level: a.level,
        reason: a.factors.isEmpty ? 'Good growing conditions' : a.factors.first.reason,
        reasons: a.reasons,
        advice: a.advice,
      ));
    }
    final overall = LocalRiskEngine.overall(assessments);
    return w.copyWith(
      overallRisk: overall,
      overallRiskNote: LocalRiskEngine.overallNote(overall),
      cropRisks: risks,
    );
  }

  // ---- Serialisation ----

  static WeatherBundle _fromPayload(Map<String, dynamic> m, {required DateTime updatedAt, required String source}) {
    final now = m['now'] as Map<String, dynamic>;
    final today = DateTime.now();
    // A live forecast records the hour it starts from, so hours stay truthful
    // when the forecast is read back later. Demo/manual data has no base time
    // and is simply relative to now.
    final stamped = DateTime.tryParse((m['baseTime'] as String?) ?? '');
    final base = stamped ?? DateTime(today.year, today.month, today.day, today.hour);
    final hourly = <HourlyForecast>[];
    for (final h in (m['hourly'] as List)) {
      final x = h as Map<String, dynamic>;
      hourly.add(HourlyForecast(
        time: base.add(Duration(hours: x['offsetHours'] as int)),
        temperatureC: x['temperatureC'] as int,
        condition: WeatherCondition.values.byName(x['condition'] as String),
      ));
    }
    final daily = <DailyForecast>[];
    for (final d in (m['daily'] as List)) {
      final x = d as Map<String, dynamic>;
      daily.add(DailyForecast(
        date: DateTime(base.year, base.month, base.day)
            .add(Duration(days: x['offsetDays'] as int)),
        minC: x['minC'] as int,
        maxC: x['maxC'] as int,
        condition: WeatherCondition.values.byName(x['condition'] as String),
        rainMm: (x['rainMm'] as num?)?.toDouble(),
        rainChance: (x['rainChance'] as num?)?.round(),
      ));
    }
    return WeatherBundle(
      now: WeatherNow(
        location: now['location'] as String,
        temperatureC: now['temperatureC'] as int,
        condition: WeatherCondition.values.byName(now['condition'] as String),
        humidity: now['humidity'] as int,
        windKmh: now['windKmh'] as int,
        rainChance: now['rainChance'] as int,
        soilMoistureLabel: now['soilMoistureLabel'] as String,
        soilMoistureDelta: now['soilMoistureDelta'] as int,
      ),
      hourly: hourly,
      daily: daily,
      overallRisk: RiskLevel.low,
      overallRiskNote: 'Good conditions for most crops',
      cropRisks: const [],
      insight: m['insight'] as String,
      updatedAt: updatedAt,
      source: source,
    );
  }

  /// Bundled demonstration data for Dili in the late dry season.
  static Map<String, dynamic> _demoPayload() => {
        'now': {
          'location': 'Dili, Timor-Leste',
          'temperatureC': 28,
          'condition': 'partlyCloudy',
          'humidity': 78,
          'windKmh': 12,
          'rainChance': 70,
          'soilMoistureLabel': 'Good',
          'soilMoistureDelta': 12,
        },
        'hourly': [
          for (var i = 0; i < 8; i++)
            {
              'offsetHours': i,
              'temperatureC': [28, 29, 30, 30, 29, 28, 27, 27][i],
              'condition': ['sunny', 'sunny', 'partlyCloudy', 'cloudy', 'rain', 'rain', 'rain', 'cloudy'][i],
            },
        ],
        'daily': [
          for (var i = 0; i < 7; i++)
            {
              'offsetDays': i,
              'minC': [24, 24, 23, 23, 24, 24, 25][i],
              'maxC': [30, 31, 30, 29, 31, 32, 32][i],
              'condition': ['rain', 'partlyCloudy', 'cloudy', 'rain', 'partlyCloudy', 'sunny', 'partlyCloudy'][i],
            },
        ],
        'insight': 'Light rain expected in the next 2 days. Good time for planting and soil preparation.',
      };
}
