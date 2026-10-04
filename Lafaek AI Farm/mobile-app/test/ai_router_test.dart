import 'package:flutter_test/flutter_test.dart';
import 'package:lafaek_ai_farm/services/cloud/ai_router.dart';
import 'package:lafaek_ai_farm/services/connectivity_service.dart';
import 'package:lafaek_ai_farm/services/network_probe.dart';

/// The router decides, before any work is done, whether an answer comes from
/// the phone or from Claude. Getting this wrong either wastes a farmer's data
/// or makes them wait for a connection that was never going to deliver.
void main() {
  group('the 600 ms rule', () {
    test('600 ms is the threshold, and the probe agrees', () {
      expect(NetworkProbe.slowThreshold.inMilliseconds, 600);
    });

    test('only a fast link counts as usable', () {
      expect(AiRouter.isFastEnough(NetworkQuality.good), isTrue);
      expect(AiRouter.isFastEnough(NetworkQuality.limited), isFalse);
      expect(AiRouter.isFastEnough(NetworkQuality.none), isFalse);
    });
  });

  group('scan routing', () {
    test('the phone could not identify it, and the link is fast → Claude', () {
      expect(
        AiRouter.forScan(
            quality: NetworkQuality.good, localIsUnclear: true),
        AiRoute.cloud,
      );
    });

    test('the phone answered confidently → stay local even on a fast link', () {
      // Spending a farmer's data to confirm an answer we already trust is
      // rude, and the margin guard already rejected the uncertain cases.
      expect(
        AiRouter.forScan(
            quality: NetworkQuality.good, localIsUnclear: false),
        AiRoute.local,
      );
    });

    test('a slow link keeps everything local, even when unclear', () {
      expect(
        AiRouter.forScan(
            quality: NetworkQuality.limited, localIsUnclear: true),
        AiRoute.local,
      );
    });

    test('offline keeps everything local', () {
      for (final unclear in [true, false]) {
        expect(
          AiRouter.forScan(
              quality: NetworkQuality.none, localIsUnclear: unclear),
          AiRoute.local,
        );
      }
    });
  });

  group('question routing', () {
    AiRoute route(NetworkQuality q, double score, {bool llm = true}) =>
        AiRouter.forQuestion(
            quality: q, knowledgeScore: score, localModelReady: llm);

    test('the offline library answered it → stay local, even online', () {
      expect(route(NetworkQuality.good, 0.9), AiRoute.local);
      expect(route(NetworkQuality.good, AiRouter.goodEnoughScore), AiRoute.local);
    });

    test('the library missed and the link is fast → Claude', () {
      expect(route(NetworkQuality.good, 0.05), AiRoute.cloud);
      expect(route(NetworkQuality.good, 0.0), AiRoute.cloud);
    });

    test('the library missed but the link is slow → local model', () {
      expect(route(NetworkQuality.limited, 0.0), AiRoute.local);
      expect(route(NetworkQuality.none, 0.0), AiRoute.local);
    });

    test('a weak keyword match does not count as an answer', () {
      // A TF-IDF score just above zero means a word matched, not the question.
      expect(AiRouter.goodEnoughScore, greaterThan(0.1));
      expect(route(NetworkQuality.good, 0.05), AiRoute.cloud);
    });

    test('with no local model and no signal it still routes local', () {
      // There is nowhere else to go; the orchestrator then returns the honest
      // "I could not find this in the local farming library" answer.
      expect(route(NetworkQuality.none, 0.0, llm: false), AiRoute.local);
    });
  });
}
