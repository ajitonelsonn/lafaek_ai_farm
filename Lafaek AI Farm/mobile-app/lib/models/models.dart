/// Domain models for Lafaek AI Farm.
///
/// Kept plain and immutable so they can be serialized to/from a local store
/// and the cloud backend later without changing the UI.
library;

export 'ai_mode.dart';

/// Health / risk level shared by crops, scans and weather.
enum HealthStatus {
  healthy,
  monitor,
  atRisk;

  String get label {
    switch (this) {
      case HealthStatus.healthy:
        return 'Healthy';
      case HealthStatus.monitor:
        return 'Monitor';
      case HealthStatus.atRisk:
        return 'At risk';
    }
  }
}

enum RiskLevel {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High';
    }
  }
}

class Farmer {
  const Farmer({
    required this.name,
    required this.location,
    required this.farmingYears,
    this.phone,
  });

  final String name;
  final String location;
  final double farmingYears;
  final String? phone;
}

class Crop {
  const Crop({
    required this.id,
    required this.name,
    required this.areaHa,
    required this.status,
    required this.plantedOn,
    required this.locationName,
    this.variety,
    this.growthStage = 'Vegetative',
    this.note,
  });

  final String id;
  final String name;
  final double areaHa;
  final HealthStatus status;
  final DateTime plantedOn;
  final String locationName;
  final String? variety;
  final String growthStage;
  final String? note;

  Crop copyWith({HealthStatus? status, String? note}) => Crop(
        id: id,
        name: name,
        areaHa: areaHa,
        status: status ?? this.status,
        plantedOn: plantedOn,
        locationName: locationName,
        variety: variety,
        growthStage: growthStage,
        note: note ?? this.note,
      );
}

class FarmLocation {
  const FarmLocation({
    required this.id,
    required this.name,
    required this.areaHa,
    required this.district,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String name;
  final double areaHa;
  final String district;

  /// Set when the farmer pins the plot on the map. The weather forecast is
  /// fetched for the first plot that has coordinates.
  final double? latitude;
  final double? longitude;

  bool get hasCoordinates => latitude != null && longitude != null;
}

enum ActivityType { planted, watered, fertilized, scanned, harvested, other }

class FarmActivity {
  const FarmActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.detail,
    required this.date,
    this.cropName,
  });

  final String id;
  final ActivityType type;
  final String title;
  final String detail;
  final DateTime date;
  final String? cropName;
}

class RecommendedAction {
  const RecommendedAction({required this.title, required this.detail});
  final String title;
  final String detail;
}

class ScanResult {
  const ScanResult({
    required this.id,
    required this.cropName,
    required this.imageAsset,
    required this.issue,
    required this.confidence,
    required this.severity,
    required this.affectedArea,
    required this.growthStage,
    required this.scannedAt,
    required this.explanation,
    required this.actions,
    required this.status,
    required this.engine,
    this.savedToFarm = false,
    this.pendingSync = false,
    this.modelName,
    this.inferenceTimeMs,
    this.confidenceBand,
    this.conditionId,
    this.margin = 1.0,
    this.runnerUp,
    this.identifiedOnline = false,
  });

  final String id;
  final String cropName;

  /// Bundled asset path *or* an absolute file path on the device.
  final String imageAsset;

  /// Short, hedged label — e.g. "Possible Leaf Blight" or "Healthy".
  final String issue;
  final double confidence; // 0..1
  final String severity;
  final String affectedArea;
  final String growthStage;
  final DateTime scannedAt;
  final String explanation;
  final List<RecommendedAction> actions;
  final HealthStatus status;

  /// Which engine produced the result ("Amazon Bedrock" / "Local AI").
  final String engine;
  final bool savedToFarm;
  final bool pendingSync;

  /// Local CV model that produced the classification, if any.
  final String? modelName;
  final int? inferenceTimeMs;
  final String? confidenceBand;
  final String? conditionId;

  /// Gap between the top two classes, and the runner-up. Carried so the
  /// fail-safe survives a reopen from history.
  final double margin;
  final String? runnerUp;

  /// True when the crop and condition came from Claude looking at the photo,
  /// because the on-device model could not place it. The UI then stops
  /// showing the local model's confidence, which is about a different answer.
  final bool identifiedOnline;
  bool get isHealthy => status == HealthStatus.healthy;
  bool get isFile => imageAsset.startsWith('/');
  bool get isUnknown => conditionId == 'unknown';

  ScanResult copyWith({
    bool? savedToFarm,
    bool? pendingSync,
    String? cropName,
    String? issue,
    double? confidence,
    String? severity,
    String? affectedArea,
    String? explanation,
    List<RecommendedAction>? actions,
    HealthStatus? status,
    String? engine,
    String? confidenceBand,
    bool? identifiedOnline,
  }) => ScanResult(
        id: id,
        cropName: cropName ?? this.cropName,
        imageAsset: imageAsset,
        issue: issue ?? this.issue,
        confidence: confidence ?? this.confidence,
        severity: severity ?? this.severity,
        affectedArea: affectedArea ?? this.affectedArea,
        growthStage: growthStage,
        scannedAt: scannedAt,
        explanation: explanation ?? this.explanation,
        actions: actions ?? this.actions,
        status: status ?? this.status,
        engine: engine ?? this.engine,
        savedToFarm: savedToFarm ?? this.savedToFarm,
        pendingSync: pendingSync ?? this.pendingSync,
        modelName: modelName,
        inferenceTimeMs: inferenceTimeMs,
        confidenceBand: confidenceBand ?? this.confidenceBand,
        conditionId: conditionId,
        margin: margin,
        runnerUp: runnerUp,
        identifiedOnline: identifiedOnline ?? this.identifiedOnline,
      );
}

enum ChatRole { user, assistant }

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.sentAt,
    this.engine,
    this.pendingSync = false,
  });

  final String id;
  final ChatRole role;
  final String text;
  final DateTime sentAt;
  final String? engine;
  final bool pendingSync;

  bool get isUser => role == ChatRole.user;
}

class Conversation {
  const Conversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.startedAt,
  });

  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime startedAt;

  String get preview => messages.isEmpty ? '' : messages.last.text;
}

enum RecommendationKind { crop, weather, tip }

class Recommendation {
  const Recommendation({
    required this.id,
    required this.kind,
    required this.title,
    required this.detail,
  });

  final String id;
  final RecommendationKind kind;
  final String title;
  final String detail;
}

enum WeatherCondition { sunny, partlyCloudy, cloudy, rain, heavyRain, storm }

class WeatherNow {
  const WeatherNow({
    required this.location,
    required this.temperatureC,
    required this.condition,
    required this.humidity,
    required this.windKmh,
    required this.rainChance,
    required this.soilMoistureLabel,
    required this.soilMoistureDelta,
  });

  final String location;
  final int temperatureC;
  final WeatherCondition condition;
  final int humidity;
  final int windKmh;
  final int rainChance;
  final String soilMoistureLabel;
  final int soilMoistureDelta;
}

class HourlyForecast {
  const HourlyForecast({
    required this.time,
    required this.temperatureC,
    required this.condition,
  });
  final DateTime time;
  final int temperatureC;
  final WeatherCondition condition;
}

class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.minC,
    required this.maxC,
    required this.condition,
    this.rainMm,
    this.rainChance,
  });
  final DateTime date;
  final int minC;
  final int maxC;
  final WeatherCondition condition;

  /// Total rainfall in millimetres. Null for demo and manually entered data,
  /// where there is no real figure to show.
  final double? rainMm;

  /// Chance of rain, 0-100. Null when unknown.
  final int? rainChance;

  bool get hasRainData => rainMm != null || rainChance != null;
}

class CropRisk {
  const CropRisk({
    required this.cropName,
    required this.level,
    required this.reason,
    this.reasons = const [],
    this.advice,
  });
  final String cropName;
  final RiskLevel level;

  /// One-line summary.
  final String reason;

  /// Every rule that fired (shown as "Why" bullets).
  final List<String> reasons;
  final String? advice;
}

enum AlertKind { warning, opportunity, info }

class FarmAlert {
  const FarmAlert({
    required this.id,
    required this.kind,
    required this.title,
    required this.detail,
    required this.action,
    required this.date,
    this.read = false,
  });

  final String id;
  final AlertKind kind;
  final String title;
  final String detail;

  /// Every alert explains the recommended action.
  final String action;
  final DateTime date;
  final bool read;

  FarmAlert copyWith({bool? read}) => FarmAlert(
        id: id,
        kind: kind,
        title: title,
        detail: detail,
        action: action,
        date: date,
        read: read ?? this.read,
      );
}

class WeatherBundle {
  const WeatherBundle({
    required this.now,
    required this.hourly,
    required this.daily,
    required this.overallRisk,
    required this.overallRiskNote,
    required this.cropRisks,
    required this.insight,
    this.updatedAt,
    this.source = 'demo',
  });

  final WeatherNow now;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final RiskLevel overallRisk;
  final String overallRiskNote;
  final List<CropRisk> cropRisks;
  final String insight;

  /// When this data was last written; null for static mock data.
  final DateTime? updatedAt;

  /// `live` | `cached` | `manual` | `demo`.
  ///
  /// `live` is a forecast fetched from Open-Meteo and stored locally. Once it
  /// is older than [WeatherBundle.freshFor] the UI calls it cached, because
  /// the farmer is reading yesterday's numbers.
  final String source;

  /// How long a fetched forecast is described as current.
  static const Duration freshFor = Duration(hours: 3);

  /// True when this came from the weather service rather than demo data.
  bool get isLive => source == 'live';

  /// True when a live forecast has aged past [freshFor].
  bool get isStale {
    if (!isLive || updatedAt == null) return false;
    return DateTime.now().difference(updatedAt!) > freshFor;
  }

  String get sourceLabel {
    switch (source) {
      case 'live':
        // Kept short: this sits after "Updated 5 min ago ·" on a 360 dp
        // screen, where the longer wording was being truncated.
        return isStale ? 'Saved · Open-Meteo' : 'Live · Open-Meteo';
      case 'manual':
        return 'Entered by you';
      case 'cached':
        return 'Cached forecast';
      default:
        return 'Demo data (offline)';
    }
  }

  WeatherBundle copyWith({
    RiskLevel? overallRisk,
    String? overallRiskNote,
    List<CropRisk>? cropRisks,
    String? insight,
  }) =>
      WeatherBundle(
        now: now,
        hourly: hourly,
        daily: daily,
        overallRisk: overallRisk ?? this.overallRisk,
        overallRiskNote: overallRiskNote ?? this.overallRiskNote,
        cropRisks: cropRisks ?? this.cropRisks,
        insight: insight ?? this.insight,
        updatedAt: updatedAt,
        source: source,
      );
}

enum KnowledgeCategory {
  cropGuides,
  diseaseLibrary,
  pestLibrary,
  farmingTips,
  soilHealth,
  waterManagement;

  String get label {
    switch (this) {
      case KnowledgeCategory.cropGuides:
        return 'Crop Guides';
      case KnowledgeCategory.diseaseLibrary:
        return 'Disease Library';
      case KnowledgeCategory.pestLibrary:
        return 'Pest Library';
      case KnowledgeCategory.farmingTips:
        return 'Farming Tips';
      case KnowledgeCategory.soilHealth:
        return 'Soil Health';
      case KnowledgeCategory.waterManagement:
        return 'Water Management';
    }
  }
}

class KnowledgeArticle {
  const KnowledgeArticle({
    required this.id,
    required this.category,
    required this.title,
    required this.summary,
    required this.sections,
    this.readMinutes = 3,
    this.cachedOffline = true,
  });

  final String id;
  final KnowledgeCategory category;
  final String title;
  final String summary;

  /// Heading → paragraph pairs.
  final List<MapEntry<String, String>> sections;
  final int readMinutes;
  final bool cachedOffline;
}

class SyncItem {
  const SyncItem({required this.label, required this.count});
  final String label;
  final int count;
}

/// Full result of a local crop scan (spec §16). Persisted to SQLite and
/// converted to [ScanResult] for the existing screens.
class CropAnalysis {
  const CropAnalysis({
    required this.id,
    required this.crop,
    required this.condition,
    required this.conditionLabel,
    required this.confidence,
    required this.confidenceBand,
    required this.severity,
    required this.affectedArea,
    required this.growthStage,
    required this.explanation,
    required this.recommendedActions,
    required this.modelName,
    required this.inferenceTimeMs,
    required this.createdAt,
    required this.imagePath,
    required this.status,
    required this.explanationEngine,
    this.sources = const [],
    this.cropId,
    this.margin = 1.0,
    this.runnerUp,
  });

  final String id;
  final String crop;

  /// CV class id (e.g. `maize_leaf_blight`, `unknown`).
  final String condition;

  /// Hedged farmer-facing label ("Possible Leaf Blight").
  final String conditionLabel;
  final double confidence;
  final String confidenceBand;
  final String severity;
  final String affectedArea;
  final String growthStage;
  final String explanation;
  final List<RecommendedAction> recommendedActions;
  final String modelName;
  final int inferenceTimeMs;
  final DateTime createdAt;
  final String imagePath;
  final HealthStatus status;

  /// Who wrote the explanation: the local LLM or the knowledge base.
  final String explanationEngine;

  /// Knowledge article titles used.
  final List<String> sources;
  final String? cropId;

  /// How far the winning class beat the runner-up. Carried through so the
  /// online service can apply the same fail-safe as the on-device guard.
  final double margin;
  final String? runnerUp;

  bool get isUnknown => condition == 'unknown';

  ScanResult toScanResult({bool savedToFarm = false, bool pendingSync = true}) =>
      ScanResult(
        id: id,
        cropName: crop,
        imageAsset: imagePath,
        issue: conditionLabel,
        confidence: confidence,
        severity: severity,
        affectedArea: affectedArea,
        growthStage: growthStage,
        scannedAt: createdAt,
        explanation: explanation,
        actions: recommendedActions,
        status: status,
        engine: explanationEngine,
        savedToFarm: savedToFarm,
        pendingSync: pendingSync,
        modelName: modelName,
        inferenceTimeMs: inferenceTimeMs,
        confidenceBand: confidenceBand,
        conditionId: condition,
        margin: margin,
        runnerUp: runnerUp,
      );
}
