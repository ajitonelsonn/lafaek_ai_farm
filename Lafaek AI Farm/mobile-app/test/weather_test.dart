import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lafaek_ai_farm/database/app_database.dart';
import 'package:lafaek_ai_farm/models/models.dart';
import 'package:lafaek_ai_farm/repositories/local_weather_service.dart';
import 'package:lafaek_ai_farm/services/weather/open_meteo_client.dart';

/// A real Open-Meteo response for Dili, recorded on 3 Oct 2026.
Map<String, dynamic> _fixture() => jsonDecode(
        File('test/fixtures/open_meteo_dili.json').readAsStringSync())
    as Map<String, dynamic>;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('WMO weather codes', () {
    test('map onto the app\'s six conditions', () {
      const c = OpenMeteoClient.conditionFromWmo;
      expect(c(0), WeatherCondition.sunny);
      expect(c(1), WeatherCondition.partlyCloudy);
      expect(c(2), WeatherCondition.partlyCloudy);
      expect(c(3), WeatherCondition.cloudy);
      expect(c(45), WeatherCondition.cloudy);
      expect(c(51), WeatherCondition.rain);        // light drizzle
      expect(c(61), WeatherCondition.rain);        // slight rain
      expect(c(65), WeatherCondition.heavyRain);   // heavy rain
      expect(c(82), WeatherCondition.heavyRain);   // violent showers
      expect(c(95), WeatherCondition.storm);
      expect(c(99), WeatherCondition.storm);
    });

    test('an unknown code is never reported as sunny', () {
      // Guessing "sunny" from an unrecognised code would be the one wrong
      // answer: it invites a farmer to leave the crop unprotected.
      expect(OpenMeteoClient.conditionFromWmo(7), WeatherCondition.cloudy);
      expect(OpenMeteoClient.conditionFromWmo(-1), WeatherCondition.cloudy);
    });
  });

  group('soil moisture', () {
    test('volumetric water content becomes a farmer-readable label', () {
      expect(OpenMeteoClient.soilMoistureLabel(0.05), 'Dry');
      expect(OpenMeteoClient.soilMoistureLabel(0.15), 'Low');
      expect(OpenMeteoClient.soilMoistureLabel(0.25), 'Good');
      expect(OpenMeteoClient.soilMoistureLabel(0.45), 'Wet');
      expect(OpenMeteoClient.soilMoistureLabel(null), 'Unknown');
    });

    test('the 24-hour change is a percentage, and safe at the edges', () {
      expect(OpenMeteoClient.soilMoistureDelta(0.22, 0.20), 10);
      expect(OpenMeteoClient.soilMoistureDelta(0.18, 0.20), -10);
      expect(OpenMeteoClient.soilMoistureDelta(0.20, 0), 0);
      expect(OpenMeteoClient.soilMoistureDelta(null, 0.2), 0);
    });
  });

  group('parsing a real Open-Meteo response', () {
    late Map<String, dynamic> payload;

    setUp(() {
      payload = OpenMeteoClient.payloadFrom(_fixture(), locationName: 'Dili');
    });

    test('produces the payload shape the cache stores', () {
      expect(payload.keys,
          containsAll(['now', 'hourly', 'daily', 'insight', 'baseTime']));
      final now = payload['now'] as Map<String, dynamic>;
      expect(now['location'], 'Dili');
      expect(now['temperatureC'], isA<int>());
      expect(now['humidity'], inInclusiveRange(0, 100));
      expect(now['rainChance'], inInclusiveRange(0, 100));
      expect(WeatherCondition.values.map((e) => e.name),
          contains(now['condition']));
    });

    test('gives 8 hourly points and 7 daily points', () {
      expect((payload['hourly'] as List), hasLength(8));
      expect((payload['daily'] as List), hasLength(7));
      final d = (payload['daily'] as List).first as Map<String, dynamic>;
      expect(d['minC'], lessThanOrEqualTo(d['maxC'] as int));
    });

    test('each day carries real rainfall in mm and a chance', () {
      // The rainfall chart draws these; without them it says so rather than
      // inventing a shape.
      for (final day in (payload['daily'] as List).cast<Map<String, dynamic>>()) {
        expect(day['rainMm'], isA<num>());
        expect(day['rainMm'], greaterThanOrEqualTo(0));
        expect(day['rainChance'], inInclusiveRange(0, 100));
      }
    });

    test('hourly starts at the hour the reading was taken, not midnight', () {
      final base = payload['baseTime'] as String;
      final current = (_fixture()['current'] as Map)['time'] as String;
      expect(base.substring(0, 13), current.substring(0, 13));
    });

    test('credits Open-Meteo', () {
      expect(payload['attribution'], contains('Open-Meteo'));
      expect(payload['attribution'], contains('CC-BY'));
    });

    test('an incomplete response is rejected, not half-parsed', () {
      expect(
        () => OpenMeteoClient.payloadFrom({'current': {}}, locationName: 'x'),
        throwsA(isA<WeatherFetchException>()),
      );
    });
  });

  group('LocalWeatherService', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('falls back to demo data when nothing is cached', () async {
      final service = LocalWeatherService(db);
      final bundle = await service.current();
      expect(bundle.source, 'demo');
      expect(bundle.sourceLabel, 'Demo data (offline)');
      expect(bundle.isLive, isFalse);
    });

    test('a stored live forecast is read back and labelled live', () async {
      await db.putWeather(
        locationKey: 'dili',
        payloadJson: jsonEncode(
            OpenMeteoClient.payloadFrom(_fixture(), locationName: 'Dili')),
        source: 'live',
      );
      final bundle = await LocalWeatherService(db).current();
      expect(bundle.source, 'live');
      expect(bundle.isLive, isTrue);
      expect(bundle.sourceLabel, contains('Open-Meteo'));
      expect(bundle.now.location, 'Dili');
      expect(bundle.hourly, hasLength(8));
      expect(bundle.daily, hasLength(7));
      expect(bundle.daily.every((d) => d.hasRainData), isTrue);
    });

    test('demo data has no rainfall figures, so the chart stays honest',
        () async {
      final bundle = await LocalWeatherService(db).current();
      expect(bundle.source, 'demo');
      expect(bundle.daily.any((d) => d.hasRainData), isFalse,
          reason: 'demo data must not pretend to carry measured rainfall');
    });

    test('a fresh forecast is not refetched; a stale one is', () async {
      final service = LocalWeatherService(db);
      expect(await service.needsRefresh(), isTrue, reason: 'nothing cached');

      await db.putWeather(
          locationKey: 'dili',
          payloadJson: jsonEncode(
              OpenMeteoClient.payloadFrom(_fixture(), locationName: 'Dili')),
          source: 'live');
      expect(await service.needsRefresh(), isFalse);

      // Age it past the staleness window.
      await db.customStatement(
        'UPDATE weather_cache SET updated_at = ? WHERE id = ?',
        [
          DateTime.now()
                  .subtract(LocalWeatherService.staleAfter * 2)
                  .millisecondsSinceEpoch ~/
              1000,
          'dili',
        ],
      );
      expect(await service.needsRefresh(), isTrue);
    });

    test('a failed fetch keeps the cached forecast instead of blanking it',
        () async {
      await db.putWeather(
          locationKey: 'dili',
          payloadJson: jsonEncode(
              OpenMeteoClient.payloadFrom(_fixture(), locationName: 'Dili')),
          source: 'live');

      // Point the client at a port nothing is listening on.
      final service = LocalWeatherService(db,
          client: const OpenMeteoClient(timeout: Duration(milliseconds: 300)));
      final updated = await service.refreshFromNetwork(
          latitude: 91, longitude: 181, force: true); // out-of-range too

      expect(updated, isFalse, reason: 'fetch failed');
      final bundle = await service.current();
      expect(bundle.now.location, 'Dili', reason: 'cache survived');
      expect(bundle.hourly, hasLength(8));
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('manual entry overrides the forecast and says so', () async {
      final service = LocalWeatherService(db);
      await service.setManual(
        temperatureC: 31,
        humidity: 60,
        rainChance: 10,
        condition: WeatherCondition.sunny,
      );
      final bundle = await service.current();
      expect(bundle.source, 'manual');
      expect(bundle.sourceLabel, 'Entered by you');
      expect(bundle.now.temperatureC, 31);
    });
  });

  group('WeatherBundle freshness', () {
    WeatherBundle bundleWith(String source, DateTime? at) => WeatherBundle(
          now: const WeatherNow(
            location: 'Dili',
            temperatureC: 28,
            condition: WeatherCondition.sunny,
            humidity: 70,
            windKmh: 10,
            rainChance: 20,
            soilMoistureLabel: 'Good',
            soilMoistureDelta: 0,
          ),
          hourly: const [],
          daily: const [],
          overallRisk: RiskLevel.low,
          overallRiskNote: '',
          cropRisks: const [],
          insight: '',
          updatedAt: at,
          source: source,
        );

    test('a recent live forecast reads as live', () {
      final b = bundleWith('live', DateTime.now());
      expect(b.isStale, isFalse);
      expect(b.sourceLabel, startsWith('Live ·'));
    });

    test('an aged live forecast is called saved, not live', () {
      final b = bundleWith(
          'live', DateTime.now().subtract(const Duration(hours: 9)));
      expect(b.isStale, isTrue);
      expect(b.sourceLabel, startsWith('Saved ·'));
    });
  });
}
