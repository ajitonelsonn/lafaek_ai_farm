import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lafaek_ai_farm/services/connectivity_service.dart';
import 'package:lafaek_ai_farm/services/network_probe.dart';

/// Drives `onConnectivityChanged` by hand.
class _FakeConnectivity implements Connectivity {
  final _controller = Stream<List<ConnectivityResult>>.empty();
  List<ConnectivityResult> value = [ConnectivityResult.wifi];

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => value;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => _controller;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ProbeResult fast() => const ProbeResult.reachable(Duration(milliseconds: 120));
ProbeResult slow() => const ProbeResult.reachable(Duration(milliseconds: 900));
ProbeResult dead() => const ProbeResult.unreachable('SocketException');

void main() {
  group('NetworkProbe verdicts', () {
    test('a quick reply is good, a sluggish one is weak', () {
      expect(NetworkProbe.verdictFor(fast()), NetworkQualityVerdict.fast);
      expect(NetworkProbe.verdictFor(slow()), NetworkQualityVerdict.slow);
    });

    test('no reply is unreachable, whatever the phone is attached to', () {
      expect(NetworkProbe.verdictFor(dead()), NetworkQualityVerdict.unreachable);
    });

    test('the slow threshold is the routing decision, at 600 ms', () {
      // Above this the app stops reaching for the cloud and answers locally:
      // a round trip plus a model call would make the farmer wait for
      // something the phone has already computed.
      expect(NetworkProbe.slowThreshold.inMilliseconds, 600);
    });
  });

  group('DeviceConnectivityService', () {
    late _FakeConnectivity connectivity;

    setUp(() => connectivity = _FakeConnectivity());

    Future<DeviceConnectivityService> serviceWith(
        List<ProbeResult> results, List<ConnectivityResult> transport) async {
      connectivity.value = transport;
      final s = DeviceConnectivityService(
        connectivity: connectivity,
        probe: FakeNetworkProbe(results),
      );
      await s.check(force: true);
      return s;
    }

    test('Wi-Fi that carries traffic is good, and reports the latency',
        () async {
      final s = await serviceWith([fast()], [ConnectivityResult.wifi]);
      expect(s.current, NetworkQuality.good);
      expect(s.transport, NetworkTransport.wifi);
      expect(s.latencyMs, 120);
      await s.dispose();
    });

    test('Wi-Fi with a dead router is offline, not "good"', () async {
      // The bug this whole probe exists for: the phone says Wi-Fi, the type
      // check said "good", and every request failed.
      final s = await serviceWith([dead()], [ConnectivityResult.wifi]);
      expect(s.transport, NetworkTransport.wifi);
      expect(s.current, NetworkQuality.none);
      await s.dispose();
    });

    test('ordinary mobile data is good, not "limited"', () async {
      // Mobile data is the normal way to be online in Timor-Leste. Calling it
      // weak by default told farmers their connection was bad when it was fine.
      final s = await serviceWith([fast()], [ConnectivityResult.mobile]);
      expect(s.transport, NetworkTransport.mobile);
      expect(s.current, NetworkQuality.good);
      await s.dispose();
    });

    test('a genuinely slow link is limited', () async {
      final s = await serviceWith([slow()], [ConnectivityResult.mobile]);
      expect(s.current, NetworkQuality.limited);
      expect(s.latencyMs, 900);
      await s.dispose();
    });

    test('no network at all never probes', () async {
      final probe = FakeNetworkProbe([fast()]);
      connectivity.value = [ConnectivityResult.none];
      final s = DeviceConnectivityService(
          connectivity: connectivity, probe: probe);
      await s.check(force: true);
      expect(s.current, NetworkQuality.none);
      expect(s.latencyMs, isNull);
      expect(probe.calls, 0, reason: 'offline must cost no battery or data');
      await s.dispose();
    });

    test('checks are throttled so the probe cannot run on every rebuild',
        () async {
      final probe = FakeNetworkProbe([fast()]);
      connectivity.value = [ConnectivityResult.wifi];
      final s = DeviceConnectivityService(
          connectivity: connectivity, probe: probe);
      await s.check(force: true);
      final after = probe.calls;
      await s.check();
      await s.check();
      expect(probe.calls, after, reason: 'within the throttle window');
      await s.dispose();
    });

    test('the demo override still wins over the measurement', () async {
      final s = await serviceWith([fast()], [ConnectivityResult.wifi]);
      expect(s.current, NetworkQuality.good);
      s.setOverride(NetworkQuality.none);
      expect(s.current, NetworkQuality.none);
      s.setOverride(null);
      expect(s.current, NetworkQuality.good);
      await s.dispose();
    });

    test('transport labels are farmer-readable', () {
      expect(NetworkTransport.wifi.label, 'Wi-Fi');
      expect(NetworkTransport.mobile.label, 'Mobile data');
      expect(NetworkTransport.none.label, 'No network');
    });
  });
}
