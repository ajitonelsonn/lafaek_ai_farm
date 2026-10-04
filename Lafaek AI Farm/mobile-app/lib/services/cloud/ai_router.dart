import '../connectivity_service.dart';

/// Where an answer should come from, decided before any work is done.
enum AiRoute {
  /// Answer on the phone. No signal, a slow link, or the local answer is
  /// already good enough.
  local,

  /// Reach for Claude. The connection measured fast and the local path
  /// cannot answer well.
  cloud,
}

/// Chooses between the phone and the cloud.
///
/// The rule is deliberately simple and measured rather than assumed:
///
/// * **No internet** → local. Obviously.
/// * **Round trip ≥ 600 ms** → local. A slow request plus a model call makes
///   the farmer wait for something the phone could already answer.
/// * **Fast link, and the phone cannot answer well** → cloud.
/// * **Fast link, and the phone answered well** → still local. Spending a
///   farmer's data to confirm an answer we already trust is rude.
///
/// The threshold lives in [NetworkProbe.slowThreshold] so the probe, the
/// status line and this router can never disagree.
class AiRouter {
  const AiRouter();

  /// True when the measured connection is good enough to be worth using.
  static bool isFastEnough(NetworkQuality quality) =>
      quality == NetworkQuality.good;

  /// Scan routing. The on-device model always runs first and its result is
  /// always saved; this only decides whether Claude is *also* asked.
  ///
  /// [localIsUnclear] is true when the margin guard rejected the result or the
  /// photo was not a leaf — the case where the phone genuinely has no answer.
  static AiRoute forScan({
    required NetworkQuality quality,
    required bool localIsUnclear,
  }) {
    if (!isFastEnough(quality)) return AiRoute.local;
    return localIsUnclear ? AiRoute.cloud : AiRoute.local;
  }

  /// Chat routing.
  ///
  /// [knowledgeScore] is the best TF-IDF score from the offline library. Below
  /// [goodEnoughScore] the library did not really answer the question.
  static AiRoute forQuestion({
    required NetworkQuality quality,
    required double knowledgeScore,
    required bool localModelReady,
  }) {
    final libraryAnswered = knowledgeScore >= goodEnoughScore;
    if (libraryAnswered) return AiRoute.local;
    // The library missed. Prefer Claude on a fast link; otherwise fall back to
    // the on-device model, and to an honest "I don't know" after that.
    if (isFastEnough(quality)) return AiRoute.cloud;
    return AiRoute.local;
  }

  /// A TF-IDF cosine score below this means the library did not really have
  /// the answer — it matched a word or two, not the question.
  static const double goodEnoughScore = 0.18;
}
