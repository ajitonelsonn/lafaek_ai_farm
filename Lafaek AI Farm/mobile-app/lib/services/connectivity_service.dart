import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'network_probe.dart';

/// Coarse network quality as seen by the app.
enum NetworkQuality { good, limited, none }

/// How the carrier is attached, independent of whether it works.
enum NetworkTransport { wifi, mobile, ethernet, other, none }

extension NetworkTransportLabel on NetworkTransport {
  String get label {
    switch (this) {
      case NetworkTransport.wifi:
        return 'Wi-Fi';
      case NetworkTransport.mobile:
        return 'Mobile data';
      case NetworkTransport.ethernet:
        return 'Ethernet';
      case NetworkTransport.other:
        return 'Network';
      case NetworkTransport.none:
        return 'No network';
    }
  }
}

/// Abstract connectivity source. The UI never talks to a platform plugin
/// directly — it listens to this.
abstract class ConnectivityService {
  Stream<NetworkQuality> get onChanged;
  NetworkQuality get current;

  /// What the phone is attached to, for display next to the measured quality.
  NetworkTransport get transport;

  /// Round-trip time of the last successful reachability check, or null when
  /// nothing has been measured yet.
  int? get latencyMs;

  /// When the last check ran.
  DateTime? get lastCheckedAt;

  /// Re-measures now. Returns the resulting quality.
  Future<NetworkQuality> check({bool force = false});

  /// Lets a demo/debug control override the detected quality. Passing null
  /// returns to automatic detection.
  void setOverride(NetworkQuality? quality);

  Future<void> dispose();
}

/// Real implementation: `connectivity_plus` says *what* is attached, a probe
/// says whether it actually works and how fast.
///
/// The interface type alone was wrong in both directions. Wi-Fi joined to a
/// router with no upstream reported "good" while every request failed; and
/// ordinary 4G — the normal way to be online in Timor-Leste — reported
/// "limited" when it was perfectly usable. So the type change is only a
/// trigger; the verdict comes from a measured round-trip.
class DeviceConnectivityService implements ConnectivityService {
  DeviceConnectivityService({
    Connectivity? connectivity,
    NetworkProbe probe = const NetworkProbe(),
  })  : _connectivity = connectivity ?? Connectivity(),
        _probe = probe {
    _sub = _connectivity.onConnectivityChanged.listen(_handleTransport);
    // Remembered so `check()` can wait for the first platform answer instead
    // of assuming "none" — otherwise the app reports offline for a moment on
    // every launch, before anything has actually been measured.
    _firstTransport = _connectivity.checkConnectivity().then((r) {
      _handleTransport(r);
      return r;
    });
  }

  final Connectivity _connectivity;
  final NetworkProbe _probe;
  final _controller = StreamController<NetworkQuality>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  /// Probing more often than this wastes battery and the farmer's data.
  static const Duration minInterval = Duration(seconds: 20);

  NetworkQuality _detected = NetworkQuality.none;
  NetworkQuality? _override;
  NetworkTransport _transport = NetworkTransport.none;
  int? _latencyMs;
  DateTime? _lastCheckedAt;
  Future<NetworkQuality>? _inFlight;
  Future<List<ConnectivityResult>>? _firstTransport;
  bool _transportKnown = false;

  @override
  NetworkQuality get current => _override ?? _detected;

  @override
  NetworkTransport get transport => _transport;

  @override
  int? get latencyMs => _latencyMs;

  @override
  DateTime? get lastCheckedAt => _lastCheckedAt;

  @override
  Stream<NetworkQuality> get onChanged => _controller.stream;

  void _handleTransport(List<ConnectivityResult> results) {
    _transportKnown = true;
    _transport = _transportOf(results);
    if (_transport == NetworkTransport.none) {
      // Nothing attached: no probe, no battery, no data. This one case the
      // platform does know for certain.
      _latencyMs = null;
      _lastCheckedAt = DateTime.now();
      _emit(NetworkQuality.none);
      return;
    }
    // Attached to something — find out whether it carries traffic.
    unawaited(check(force: true));
  }

  static NetworkTransport _transportOf(List<ConnectivityResult> results) {
    if (results.isEmpty || results.every((r) => r == ConnectivityResult.none)) {
      return NetworkTransport.none;
    }
    if (results.contains(ConnectivityResult.wifi)) return NetworkTransport.wifi;
    if (results.contains(ConnectivityResult.ethernet)) {
      return NetworkTransport.ethernet;
    }
    if (results.contains(ConnectivityResult.mobile)) {
      return NetworkTransport.mobile;
    }
    return NetworkTransport.other;
  }

  @override
  Future<NetworkQuality> check({bool force = false}) {
    // Coalesce concurrent callers onto one probe.
    final running = _inFlight;
    if (running != null) return running;

    final future = _check(force: force);
    _inFlight = future;
    return future.whenComplete(() => _inFlight = null);
  }

  Future<NetworkQuality> _check({required bool force}) async {
    // On the very first call the platform may not have answered yet. Waiting
    // is better than reporting offline and flickering a moment later.
    if (!_transportKnown) {
      try {
        await _firstTransport;
      } catch (_) {
        _transportKnown = true;
      }
    }

    final last = _lastCheckedAt;
    if (!force &&
        last != null &&
        DateTime.now().difference(last) < minInterval) {
      return current;
    }
    if (_transport == NetworkTransport.none) {
      _emit(NetworkQuality.none);
      return NetworkQuality.none;
    }
    return _runProbe();
  }

  Future<NetworkQuality> _runProbe() async {
    final result = await _probe.measure();
    _lastCheckedAt = DateTime.now();
    _latencyMs = result.latencyMs;

    final NetworkQuality next;
    switch (NetworkProbe.verdictFor(result)) {
      case NetworkQualityVerdict.fast:
        next = NetworkQuality.good;
        break;
      case NetworkQualityVerdict.slow:
        next = NetworkQuality.limited;
        break;
      case NetworkQualityVerdict.unreachable:
        // Attached but nothing gets through: a dead router, a captive portal,
        // an exhausted data bundle. For the farmer that is simply offline, and
        // saying so is more useful than claiming a connection that fails.
        next = NetworkQuality.none;
        break;
    }
    debugPrint('network: ${_transport.label} · ${result.reachable ? '${result.latencyMs} ms' : result.error} → ${next.name}');
    _emit(next);
    return next;
  }

  void _emit(NetworkQuality next) {
    if (next == _detected) return;
    _detected = next;
    if (_override == null) _controller.add(next);
  }

  @override
  void setOverride(NetworkQuality? quality) {
    _override = quality;
    _controller.add(current);
  }

  @override
  Future<void> dispose() async {
    await _sub?.cancel();
    await _controller.close();
  }
}

/// Fully manual implementation for tests and widget previews.
class ManualConnectivityService implements ConnectivityService {
  ManualConnectivityService([
    this._current = NetworkQuality.good,
    this._transport = NetworkTransport.wifi,
  ]);

  NetworkQuality _current;
  final NetworkTransport _transport;
  final _controller = StreamController<NetworkQuality>.broadcast();

  @override
  NetworkQuality get current => _current;

  @override
  NetworkTransport get transport =>
      _current == NetworkQuality.none ? NetworkTransport.none : _transport;

  @override
  int? get latencyMs => _current == NetworkQuality.none ? null : 42;

  @override
  DateTime? get lastCheckedAt => DateTime.now();

  @override
  Future<NetworkQuality> check({bool force = false}) async => _current;

  @override
  Stream<NetworkQuality> get onChanged => _controller.stream;

  @override
  void setOverride(NetworkQuality? quality) {
    _current = quality ?? NetworkQuality.good;
    _controller.add(_current);
  }

  @override
  Future<void> dispose() => _controller.close();
}
