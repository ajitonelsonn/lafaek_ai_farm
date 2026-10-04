import 'dart:convert';
import 'dart:io';

import '../../models/models.dart';

/// Raised when a forecast cannot be fetched. The caller falls back to the
/// cached forecast; weather never blocks the app.
class WeatherFetchException implements Exception {
  const WeatherFetchException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Live forecast from **Open-Meteo** (https://open-meteo.com).
///
/// Chosen because it needs no API key and no account: there is no secret to
/// ship in the APK, and a farmer never has to register for anything. The free
/// tier is for non-commercial use and the data is CC-BY 4.0, which the About
/// screen credits.
///
/// This is the only outbound call in the app besides the one-time language
/// model download. The response is written straight into `weather_cache`, so
/// every later read is local.
class OpenMeteoClient {
  const OpenMeteoClient({this.timeout = const Duration(seconds: 12)});

  final Duration timeout;

  static const String host = 'api.open-meteo.com';
  static const String path = '/v1/forecast';
  static const String attribution = 'Open-Meteo · CC-BY 4.0';

  /// Fetches current conditions, 8 hours of hourly and 7 days of daily
  /// forecast, plus root-zone soil moisture.
  ///
  /// Returns the payload in the same shape `LocalWeatherService` stores, so
  /// the cached and live paths parse identically.
  Future<Map<String, dynamic>> fetch({
    required double latitude,
    required double longitude,
    required String locationName,
    HttpClient? client,
  }) async {
    final uri = Uri.https(host, path, {
      'latitude': latitude.toStringAsFixed(4),
      'longitude': longitude.toStringAsFixed(4),
      'current':
          'temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m',
      'hourly':
          'temperature_2m,weather_code,precipitation_probability,soil_moisture_3_to_9cm',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max,precipitation_sum',
      'timezone': 'auto',
      'forecast_days': '7',
    });

    final http = client ?? HttpClient();
    http.connectionTimeout = timeout;
    Map<String, dynamic> json;
    try {
      final request = await http.getUrl(uri).timeout(timeout);
      // Open-Meteo asks clients to identify themselves.
      request.headers.set(HttpHeaders.userAgentHeader, 'LafaekAIFarm/0.1');
      final response = await request.close().timeout(timeout);
      if (response.statusCode != 200) {
        throw WeatherFetchException(
            'The weather service replied ${response.statusCode}.');
      }
      final body = await response.transform(utf8.decoder).join();
      json = jsonDecode(body) as Map<String, dynamic>;
    } on WeatherFetchException {
      rethrow;
    } catch (e) {
      throw WeatherFetchException('Could not reach the weather service. $e');
    } finally {
      if (client == null) http.close(force: true);
    }

    return payloadFrom(json, locationName: locationName);
  }

  /// Converts an Open-Meteo response into the app's stored payload.
  ///
  /// Kept separate from the network call so it can be tested against a
  /// recorded response.
  static Map<String, dynamic> payloadFrom(
    Map<String, dynamic> json, {
    required String locationName,
  }) {
    final current = _map(json['current']);
    final hourly = _map(json['hourly']);
    final daily = _map(json['daily']);
    if (current.isEmpty || hourly.isEmpty || daily.isEmpty) {
      throw const WeatherFetchException('The forecast response was incomplete.');
    }

    final times = (hourly['time'] as List).cast<String>();
    final nowIso = current['time'] as String?;
    final startIdx = _indexForHour(times, nowIso);

    final temps = _nums(hourly['temperature_2m']);
    final codes = _nums(hourly['weather_code']);
    final rainChance = _nums(hourly['precipitation_probability']);
    final soil = _nums(hourly['soil_moisture_3_to_9cm']);

    final hourlyOut = <Map<String, dynamic>>[];
    for (var i = 0; i < 8; i++) {
      final idx = startIdx + i;
      if (idx >= times.length) break;
      hourlyOut.add({
        'offsetHours': i,
        'temperatureC': _round(temps[idx]),
        'condition': conditionFromWmo(_round(codes[idx])).name,
      });
    }

    final dailyCodes = _nums(daily['weather_code']);
    final dailyMax = _nums(daily['temperature_2m_max']);
    final dailyMin = _nums(daily['temperature_2m_min']);
    final dailyRain = _nums(daily['precipitation_probability_max']);
    final dailyMm = _nums(daily['precipitation_sum']);
    final dailyOut = <Map<String, dynamic>>[];
    for (var i = 0; i < dailyCodes.length && i < 7; i++) {
      dailyOut.add({
        'offsetDays': i,
        'minC': _round(dailyMin[i]),
        'maxC': _round(dailyMax[i]),
        'condition': conditionFromWmo(_round(dailyCodes[i])).name,
        'rainChance': i < dailyRain.length ? _round(dailyRain[i]) : null,
        // Millimetres is what a farmer can act on; a percentage alone does
        // not say whether to irrigate.
        'rainMm': i < dailyMm.length && dailyMm[i] != null
            ? (dailyMm[i]! * 10).round() / 10
            : null,
      });
    }

    final soilNow = startIdx < soil.length ? soil[startIdx] : null;
    // 24 h back, to say whether the soil is drying out or wetting up.
    final soilBeforeIdx = startIdx - 24;
    final soilBefore =
        soilBeforeIdx >= 0 && soilBeforeIdx < soil.length ? soil[soilBeforeIdx] : null;

    final todayRain =
        dailyRain.isNotEmpty ? _round(dailyRain.first) : _round(rainChance.elementAtOrNull(startIdx));

    return {
      'now': {
        'location': locationName,
        'temperatureC': _round(current['temperature_2m']),
        'condition': conditionFromWmo(_round(current['weather_code'])).name,
        'humidity': _round(current['relative_humidity_2m']),
        'windKmh': _round(current['wind_speed_10m']),
        'rainChance': todayRain,
        'soilMoistureLabel': soilMoistureLabel(soilNow),
        'soilMoistureDelta': soilMoistureDelta(soilNow, soilBefore),
      },
      'hourly': hourlyOut,
      'daily': dailyOut,
      'insight': insightFrom(dailyOut, dailyRain),
      // The hour this forecast starts from, so a forecast read later still
      // labels its hours correctly instead of sliding to "now".
      'baseTime': times.isNotEmpty ? times[startIdx] : null,
      'latitude': json['latitude'],
      'longitude': json['longitude'],
      'attribution': attribution,
    };
  }

  // ---- WMO weather interpretation codes ----
  // https://open-meteo.com/en/docs — the app has six conditions, so bands of
  // codes collapse onto the nearest one.
  static WeatherCondition conditionFromWmo(int code) {
    if (code == 0) return WeatherCondition.sunny;
    if (code == 1 || code == 2) return WeatherCondition.partlyCloudy;
    if (code == 3 || code == 45 || code == 48) return WeatherCondition.cloudy;
    if (code >= 95) return WeatherCondition.storm;           // thunderstorm
    if (code == 65 || code == 67 || code == 82) {
      return WeatherCondition.heavyRain;                      // heavy / violent
    }
    if (code == 75 || code == 86) return WeatherCondition.heavyRain; // heavy snow
    if (code >= 51) return WeatherCondition.rain;             // drizzle→showers
    return WeatherCondition.cloudy;
  }

  /// Volumetric soil water content (m³/m³) at 3–9 cm, where most seedling
  /// roots sit, described in words a farmer uses.
  static String soilMoistureLabel(num? value) {
    if (value == null) return 'Unknown';
    if (value < 0.10) return 'Dry';
    if (value < 0.20) return 'Low';
    if (value <= 0.38) return 'Good';
    return 'Wet';
  }

  /// Change in soil moisture over the last 24 hours, as a percentage.
  static int soilMoistureDelta(num? now, num? before) {
    if (now == null || before == null || before == 0) return 0;
    return (((now - before) / before) * 100).round().clamp(-99, 99);
  }

  /// One plain sentence about the week ahead, from the daily rain chances.
  static String insightFrom(
      List<Map<String, dynamic>> daily, List<num?> rainChance) {
    final wet = <int>[];
    for (var i = 0; i < rainChance.length && i < 7; i++) {
      final p = rainChance[i];
      if (p != null && p >= 50) wet.add(i);
    }
    if (wet.isEmpty) {
      return 'No significant rain expected this week. Plan irrigation and '
          'watch soil moisture.';
    }
    if (wet.first <= 1) {
      return 'Rain is likely in the next day or two. Check drainage before it '
          'arrives and hold off on spraying.';
    }
    return 'Rain is likely in about ${wet.first} days. A good window for '
        'planting and soil preparation before then.';
  }

  // ---- parsing helpers ----

  static Map<String, dynamic> _map(Object? v) =>
      v is Map<String, dynamic> ? v : const {};

  static List<num?> _nums(Object? v) =>
      v is List ? v.map((e) => e is num ? e : null).toList() : const [];

  static int _round(Object? v) => v is num ? v.round() : 0;

  /// Index of the hourly slot covering `isoHour`; falls back to the first
  /// slot so a malformed timestamp cannot break the parse.
  static int _indexForHour(List<String> times, String? isoHour) {
    if (isoHour == null) return 0;
    final hour = isoHour.length >= 13 ? isoHour.substring(0, 13) : isoHour;
    final i = times.indexWhere((t) => t.startsWith(hour));
    return i >= 0 ? i : 0;
  }
}
