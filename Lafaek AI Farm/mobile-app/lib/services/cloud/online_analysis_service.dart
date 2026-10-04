import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Claude's reading of a photograph the on-device model could not place.
class OnlineIdentification {
  const OnlineIdentification({
    required this.model,
    required this.crop,
    required this.condition,
    required this.summary,
    required this.actions,
    required this.confidence,
    required this.askAPerson,
    required this.caveat,
    required this.elapsedMs,
  });

  final String model;
  final String crop;
  final String condition;
  final String summary;
  final List<String> actions;

  /// 'high' | 'moderate' | 'low'
  final String confidence;
  final bool askAPerson;
  final String caveat;
  final int elapsedMs;

  factory OnlineIdentification.fromJson(Map<String, dynamic> j) =>
      OnlineIdentification(
        model: j['model'] as String? ?? 'claude',
        crop: j['crop'] as String? ?? 'Unknown',
        condition: j['condition'] as String? ?? 'Unclear',
        summary: j['summary'] as String? ?? '',
        actions: (j['actions'] as List?)?.cast<String>() ?? const [],
        confidence: j['confidence'] as String? ?? 'low',
        askAPerson: j['ask_a_person'] as bool? ?? true,
        caveat: j['caveat'] as String? ?? '',
        elapsedMs: (j['elapsed_ms'] as num?)?.toInt() ?? 0,
      );
}

/// Claude's answer to a question the offline library could not handle.
class OnlineAnswer {
  const OnlineAnswer({
    required this.model,
    required this.answer,
    required this.actions,
    required this.askAPerson,
    required this.elapsedMs,
  });

  final String model;
  final String answer;
  final List<String> actions;
  final bool askAPerson;
  final int elapsedMs;

  factory OnlineAnswer.fromJson(Map<String, dynamic> j) => OnlineAnswer(
        model: j['model'] as String? ?? 'claude',
        answer: j['answer'] as String? ?? '',
        actions: (j['actions'] as List?)?.cast<String>() ?? const [],
        askAPerson: j['ask_a_person'] as bool? ?? false,
        elapsedMs: (j['elapsed_ms'] as num?)?.toInt() ?? 0,
      );
}

/// The parts of a local scan the backend needs. The photograph is not one of
/// them — only the label the on-device model chose and its confidence.
class LocalScanSummary {
  const LocalScanSummary({
    required this.label,
    required this.confidence,
    required this.crop,
    this.margin = 1.0,
    this.runnerUp,
    this.modelName = '',
    this.growthStage = '',
  });

  final String label;
  final double confidence;
  final String crop;
  final double margin;
  final String? runnerUp;
  final String modelName;
  final String growthStage;
}

/// A second opinion from Claude Haiku, fetched through the project's own
/// FastAPI service.
class OnlineAnalysis {
  const OnlineAnalysis({
    required this.model,
    required this.summary,
    required this.confirmsLocal,
    required this.actions,
    required this.askAPerson,
    required this.caveat,
    required this.elapsedMs,
  });

  final String model;
  final String summary;
  final bool confirmsLocal;
  final List<String> actions;

  /// True when the evidence is not strong enough to decide without a human.
  final bool askAPerson;
  final String caveat;
  final int elapsedMs;

  factory OnlineAnalysis.fromJson(Map<String, dynamic> j) => OnlineAnalysis(
        model: j['model'] as String? ?? 'claude',
        summary: j['summary'] as String? ?? '',
        confirmsLocal: j['confirms_local'] as bool? ?? false,
        actions: (j['actions'] as List?)?.cast<String>() ?? const [],
        askAPerson: j['ask_a_person'] as bool? ?? false,
        caveat: j['caveat'] as String? ?? '',
        elapsedMs: (j['elapsed_ms'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'model': model,
        'summary': summary,
        'confirms_local': confirmsLocal,
        'actions': actions,
        'ask_a_person': askAPerson,
        'caveat': caveat,
        'elapsed_ms': elapsedMs,
      };
}

/// Sends a *local* analysis to the backend for a richer second opinion.
///
/// This is the enhancement, never the path. The farmer already has a saved
/// result from the on-device model before this is called, and every failure
/// here is swallowed: the local result simply stands.
///
/// **The photograph is never uploaded.** Only the label the on-device model
/// chose, its confidence and margin, and the farm context are sent. That keeps
/// the request tiny on a weak connection and means a farmer's images never
/// leave their phone.
///
/// The Anthropic API key lives only on the server.
class OnlineAnalysisService {
  const OnlineAnalysisService({
    this.baseUrl = defaultBaseUrl,
    this.appToken = '',
    this.timeout = const Duration(seconds: 20),
  });

  /// Overridable at build time:
  /// `flutter build apk --dart-define=LAFAEK_API=https://…`
  static const String defaultBaseUrl =
      String.fromEnvironment('LAFAEK_API', defaultValue: 'http://100.58.102.39:8000');

  final String baseUrl;
  final String appToken;
  final Duration timeout;

  bool get isConfigured => baseUrl.isNotEmpty;

  Future<bool> health({HttpClient? client}) async {
    final http = client ?? HttpClient();
    try {
      final req = await http
          .getUrl(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 6));
      final res = await req.close().timeout(const Duration(seconds: 6));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    } finally {
      if (client == null) http.close(force: true);
    }
  }

  /// Returns null when the service cannot be reached or replies with an error.
  /// The caller keeps the local result either way.
  Future<OnlineAnalysis?> reanalyse({
    required LocalScanSummary local,
    required FarmContext farm,
    String language = 'en',
    String knowledge = '',
    HttpClient? client,
  }) async {
    if (!isConfigured) return null;
    final http = client ?? HttpClient();
    http.connectionTimeout = timeout;
    try {
      final req = await http
          .postUrl(Uri.parse('$baseUrl/api/v1/analyze'))
          .timeout(timeout);
      req.headers.contentType = ContentType.json;
      req.headers.set(HttpHeaders.userAgentHeader, 'LafaekAIFarm/0.1');
      if (appToken.isNotEmpty) req.headers.set('X-App-Token', appToken);
      req.add(utf8.encode(jsonEncode({
        'local': {
          'label': local.label,
          'confidence': local.confidence,
          'margin': local.margin,
          'runner_up': local.runnerUp,
          'model_name': local.modelName,
        },
        'farm': {
          'crop': local.crop,
          'location': farm.location,
          'growth_stage': local.growthStage,
          'temperature_c': farm.temperatureC,
          'humidity': farm.humidity,
          'rain_chance': farm.rainChance,
          'soil_moisture': farm.soilMoisture,
        },
        'language': language,
        // A short excerpt only; the server caps it anyway.
        'knowledge': knowledge.length > 3500
            ? knowledge.substring(0, 3500)
            : knowledge,
      })));
      final res = await req.close().timeout(timeout);
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode != 200) {
        debugPrint('online analysis ${res.statusCode}: $body');
        return null;
      }
      return OnlineAnalysis.fromJson(
          jsonDecode(body) as Map<String, dynamic>);
    } catch (e) {
      // Expected whenever the farmer is offline or the service is down.
      debugPrint('online analysis unavailable, keeping local result: $e');
      return null;
    } finally {
      if (client == null) http.close(force: true);
    }
  }

  /// Asks Claude to look at the photograph itself.
  ///
  /// **This is the one path where an image leaves the phone.** It runs only
  /// when the on-device model returned `unknown`/`other` *and* the measured
  /// round trip was under 600 ms, and the farmer is told before it happens.
  /// Everywhere else the photo stays on the device.
  Future<OnlineIdentification?> identify({
    required List<int> jpegBytes,
    required FarmContext farm,
    String localLabel = 'unknown',
    String language = 'en',
    HttpClient? client,
  }) async {
    if (!isConfigured) return null;
    final http = client ?? HttpClient();
    http.connectionTimeout = timeout;
    try {
      final req = await http
          .postUrl(Uri.parse('$baseUrl/api/v1/identify'))
          .timeout(timeout);
      req.headers.contentType = ContentType.json;
      req.headers.set(HttpHeaders.userAgentHeader, 'LafaekAIFarm/0.1');
      if (appToken.isNotEmpty) req.headers.set('X-App-Token', appToken);
      req.add(utf8.encode(jsonEncode({
        'image_base64': base64Encode(jpegBytes),
        'mime_type': 'image/jpeg',
        'farm': _farmJson(farm),
        'language': language,
        'local_label': localLabel,
      })));
      final res = await req.close().timeout(timeout);
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode != 200) {
        debugPrint('identify ${res.statusCode}: $body');
        return null;
      }
      return OnlineIdentification.fromJson(
          jsonDecode(body) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('identify unavailable, keeping the local result: $e');
      return null;
    } finally {
      if (client == null) http.close(force: true);
    }
  }

  /// Asks Claude a farming question the offline library could not answer.
  Future<OnlineAnswer?> ask({
    required String question,
    required FarmContext farm,
    String knowledge = '',
    String language = 'en',
    HttpClient? client,
  }) async {
    if (!isConfigured) return null;
    final http = client ?? HttpClient();
    http.connectionTimeout = timeout;
    try {
      final req =
          await http.postUrl(Uri.parse('$baseUrl/api/v1/ask')).timeout(timeout);
      req.headers.contentType = ContentType.json;
      req.headers.set(HttpHeaders.userAgentHeader, 'LafaekAIFarm/0.1');
      if (appToken.isNotEmpty) req.headers.set('X-App-Token', appToken);
      req.add(utf8.encode(jsonEncode({
        'question': question,
        'farm': _farmJson(farm),
        'knowledge': knowledge.length > 3500
            ? knowledge.substring(0, 3500)
            : knowledge,
        'language': language,
      })));
      final res = await req.close().timeout(timeout);
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode != 200) {
        debugPrint('ask ${res.statusCode}: $body');
        return null;
      }
      return OnlineAnswer.fromJson(jsonDecode(body) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('ask unavailable, answering locally: $e');
      return null;
    } finally {
      if (client == null) http.close(force: true);
    }
  }

  static Map<String, dynamic> _farmJson(FarmContext farm) => {
        'crop': farm.crop,
        'location': farm.location,
        'growth_stage': farm.growthStage,
        'temperature_c': farm.temperatureC,
        'humidity': farm.humidity,
        'rain_chance': farm.rainChance,
        'soil_moisture': farm.soilMoisture,
      };
}

/// The farm facts sent alongside a local result.
class FarmContext {
  const FarmContext({
    this.crop = '',
    this.growthStage = '',
    this.location = '',
    this.temperatureC,
    this.humidity,
    this.rainChance,
    this.soilMoisture = '',
  });

  final String crop;
  final String growthStage;
  final String location;
  final double? temperatureC;
  final int? humidity;
  final int? rainChance;
  final String soilMoisture;
}
