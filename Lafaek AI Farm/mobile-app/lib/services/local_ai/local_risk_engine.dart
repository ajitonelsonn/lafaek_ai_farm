import '../../models/models.dart';

/// Inputs to the risk rules. Everything optional so the engine degrades
/// gracefully when a value is unknown.
class RiskInputs {
  const RiskInputs({
    required this.cropName,
    this.temperatureC,
    this.humidity,
    this.rainChance,
    this.recentRainMm,
    this.windKmh,
    this.plantedOn,
    this.growthStage,
    this.recentScans = const [],
    this.soilMoistureLabel,
    DateTime? now,
  }) : _now = now;

  final String cropName;
  final int? temperatureC;
  final int? humidity;
  final int? rainChance;
  final double? recentRainMm;
  final int? windKmh;
  final DateTime? plantedOn;
  final String? growthStage;

  /// Health status of scans of this crop in the last 14 days.
  final List<HealthStatus> recentScans;
  final String? soilMoistureLabel;
  final DateTime? _now;

  DateTime get now => _now ?? DateTime.now();
  int? get daysSincePlanting =>
      plantedOn == null ? null : now.difference(plantedOn!).inDays;
}

/// One rule that fired, shown to the farmer as a "Why" bullet.
class RiskFactor {
  const RiskFactor(this.reason, this.weight);
  final String reason;

  /// Contribution to the score (0–3).
  final int weight;
}

class RiskAssessment {
  const RiskAssessment({
    required this.cropName,
    required this.level,
    required this.score,
    required this.factors,
    required this.headline,
    required this.advice,
  });

  final String cropName;
  final RiskLevel level;
  final int score;
  final List<RiskFactor> factors;

  /// e.g. "Medium fungal risk"
  final String headline;

  /// One practical action.
  final String advice;

  List<String> get reasons => factors.map((f) => f.reason).toList();
}

/// Transparent rule-based crop risk. Every fired rule is returned as a
/// reason so the UI can show *why* a level was assigned (spec §18).
///
/// Scoring: rules add weights; 0–2 → Low, 3–5 → Medium, 6+ → High.
class LocalRiskEngine {
  const LocalRiskEngine();

  RiskAssessment assess(RiskInputs i) {
    final f = <RiskFactor>[];
    final crop = i.cropName.toLowerCase();
    final humid = (i.humidity ?? 0) >= 80;
    final wet = (i.rainChance ?? 0) >= 60 || (i.recentRainMm ?? 0) >= 20;
    final hot = (i.temperatureC ?? 0) >= 32;
    final warm = (i.temperatureC ?? 0) >= 24 && (i.temperatureC ?? 0) <= 30;

    // --- Weather-driven fungal pressure ---
    if (humid) f.add(const RiskFactor('High humidity (≥80%)', 2));
    if (wet) f.add(const RiskFactor('Rain expected or recent heavy rain', 2));
    if (humid && wet && warm) {
      f.add(const RiskFactor('Warm, wet and humid: ideal for fungal disease', 1));
    }

    // --- Crop sensitivity ---
    switch (crop) {
      case 'tomato':
        if (humid || wet) f.add(const RiskFactor('Tomato is very sensitive to leaf wetness (blight)', 2));
        break;
      case 'chili':
        if (wet) f.add(const RiskFactor('Chili fruit rot (anthracnose) spreads in rain', 1));
        break;
      case 'rice':
        if ((i.humidity ?? 0) >= 85 && (i.temperatureC ?? 30) <= 26) {
          f.add(const RiskFactor('Cool humid nights favour rice blast', 2));
        }
        if (wet && (i.windKmh ?? 0) >= 25) {
          f.add(const RiskFactor('Wind and rain spread bacterial leaf blight', 1));
        }
        break;
      case 'maize':
        if (humid && warm) f.add(const RiskFactor('Warm humid days favour maize leaf blight', 1));
        final d = i.daysSincePlanting;
        if (d != null && d >= 7 && d <= 45) {
          f.add(const RiskFactor('Young maize (1–6 weeks) is the fall armyworm window', 1));
        }
        break;
      case 'beans':
        if (humid) f.add(const RiskFactor('Humid weather favours bean rust', 1));
        break;
    }

    // --- Heat / water stress ---
    if (hot && !wet) f.add(const RiskFactor('Hot and dry: water stress likely', 1));
    // Soil moisture now arrives measured from Open-Meteo, which reports "Dry"
    // as well as "Low". Matching only "low" would have scored bone-dry soil
    // *lower* than merely low soil, so both are handled and dry weighs more.
    final soil = (i.soilMoistureLabel ?? '').toLowerCase();
    if (!wet) {
      if (soil == 'dry') {
        f.add(const RiskFactor('Soil is dry in the root zone', 2));
      } else if (soil == 'low') {
        f.add(const RiskFactor('Soil moisture is low', 1));
      }
    }

    // --- Growth stage sensitivity ---
    final stage = (i.growthStage ?? '').toLowerCase();
    if (stage.contains('flower') || stage.contains('tassel') || stage.contains('heading')) {
      f.add(const RiskFactor('Flowering stage is the most sensitive to stress', 1));
    }

    // --- Recent scan history ---
    final bad = i.recentScans.where((s) => s != HealthStatus.healthy).length;
    if (bad >= 2) {
      f.add(RiskFactor('$bad recent scans showed problems', 2));
    } else if (bad == 1) {
      f.add(const RiskFactor('A recent scan showed a possible problem', 1));
    }

    final score = f.fold<int>(0, (s, x) => s + x.weight);
    final level = score >= 6
        ? RiskLevel.high
        : score >= 3
            ? RiskLevel.medium
            : RiskLevel.low;

    return RiskAssessment(
      cropName: i.cropName,
      level: level,
      score: score,
      factors: f,
      headline: _headline(level, crop, humid || wet),
      advice: _advice(level, crop, humid || wet, hot && !wet),
    );
  }

  /// Overall farm level = worst crop, note summarises.
  static RiskLevel overall(Iterable<RiskAssessment> all) {
    var worst = RiskLevel.low;
    for (final a in all) {
      if (a.level.index > worst.index) worst = a.level;
    }
    return worst;
  }

  static String overallNote(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 'Good conditions for most crops';
      case RiskLevel.medium:
        return 'Some crops need attention this week';
      case RiskLevel.high:
        return 'Act now to protect sensitive crops';
    }
  }

  static String _headline(RiskLevel level, String crop, bool fungal) {
    final kind = fungal ? 'fungal' : 'crop';
    return '${level.label} $kind risk';
  }

  static String _advice(RiskLevel level, String crop, bool fungal, bool dry) {
    if (level == RiskLevel.low) return 'Keep monitoring; scan again if you notice changes.';
    if (fungal) {
      switch (crop) {
        case 'tomato':
          return 'Check leaves daily, remove spotted lower leaves, water only at the base and keep air moving.';
        case 'rice':
          return 'Hold off on nitrogen top-dressing and check leaves for spots after the rain.';
        case 'maize':
          return 'Walk the field after the rain and look at lower leaves for long grey lesions.';
        default:
          return 'Improve drainage and airflow, and inspect leaves 2–3 days after rain.';
      }
    }
    if (dry) return 'Water early in the morning and mulch to hold soil moisture.';
    return 'Inspect the crop this week and log what you find.';
  }
}
