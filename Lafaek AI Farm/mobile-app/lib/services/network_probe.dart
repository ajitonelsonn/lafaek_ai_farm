import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// What a reachability check actually found.
class ProbeResult {
  const ProbeResult.reachable(this.latency)
      : reachable = true,
        error = null;
  const ProbeResult.unreachable(this.error)
      : reachable = false,
        latency = null;

  final bool reachable;

  /// Round-trip time to the probe endpoint.
  final Duration? latency;
  final String? error;

  int? get latencyMs => latency?.inMilliseconds;
}

/// Measures whether the internet is actually reachable, and how fast.
///
/// The interface type a phone reports — Wi-Fi, mobile — says what it is
/// *attached* to, not whether anything is on the other end. Two cases matter
/// for a farmer in Timor-Leste:
///
/// * Wi-Fi connected to a router with no upstream, or a captive portal. The
///   phone says "Wi-Fi"; nothing works.
/// * Perfectly good 4G, which the type check calls "limited" even though it is
///   the normal way to be online here.
///
/// So the app asks the network a real question and times the answer.
class NetworkProbe {
  const NetworkProbe({
    this.endpoint = defaultEndpoint,
    this.timeout = const Duration(seconds: 5),
  });

  /// Android's own connectivity check: HTTP 204, empty body. A few hundred
  /// bytes of headers per probe and nothing else — it exists for this.
  static const String defaultEndpoint =
      'https://connectivitycheck.gstatic.com/generate_204';

  /// Above this round-trip the connection is reported as weak, and the app
  /// stops reaching for the cloud and answers locally instead.
  ///
  /// 600 ms is the point where a round trip to the backend plus a model call
  /// stops feeling like an enhancement and starts making the farmer wait. The
  /// on-device answer is already there, so waiting buys nothing.
  static const Duration slowThreshold = Duration(milliseconds: 600);

  final String endpoint;
  final Duration timeout;

  Future<ProbeResult> measure({HttpClient? client}) async {
    final http = client ?? HttpClient();
    http.connectionTimeout = timeout;
    final watch = Stopwatch()..start();
    try {
      final request = await http.getUrl(Uri.parse(endpoint)).timeout(timeout);
      request.headers.set(HttpHeaders.userAgentHeader, 'LafaekAIFarm/0.1');
      request.followRedirects = false;
      final response = await request.close().timeout(timeout);
      await response.drain<void>();
      watch.stop();
      // A captive portal answers 200 with a login page instead of 204; that is
      // not working internet, so only the expected empty reply counts.
      if (response.statusCode != 204 && response.statusCode != 200) {
        return ProbeResult.unreachable('HTTP ${response.statusCode}');
      }
      return ProbeResult.reachable(watch.elapsed);
    } catch (e) {
      watch.stop();
      return ProbeResult.unreachable('$e');
    } finally {
      if (client == null) http.close(force: true);
    }
  }

  /// Turns a measurement into the three states the UI shows.
  static NetworkQualityVerdict verdictFor(ProbeResult result) {
    if (!result.reachable) return NetworkQualityVerdict.unreachable;
    return (result.latency ?? Duration.zero) > slowThreshold
        ? NetworkQualityVerdict.slow
        : NetworkQualityVerdict.fast;
  }
}

enum NetworkQualityVerdict { fast, slow, unreachable }

/// A probe that answers from a script, for tests.
@visibleForTesting
class FakeNetworkProbe implements NetworkProbe {
  FakeNetworkProbe(this.results);

  /// Returned in order; the last one repeats once the list runs out.
  final List<ProbeResult> results;
  int calls = 0;

  @override
  String get endpoint => 'fake';
  @override
  Duration get timeout => const Duration(seconds: 1);

  @override
  Future<ProbeResult> measure({HttpClient? client}) async {
    final r = results[calls.clamp(0, results.length - 1)];
    calls++;
    return r;
  }
}
