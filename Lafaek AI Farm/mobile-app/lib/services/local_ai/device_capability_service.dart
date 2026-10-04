import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// What this phone can run. Used to pick the LLM size and thread count.
class DeviceCapability {
  const DeviceCapability({
    required this.platform,
    required this.cpuAbi,
    required this.cpuCores,
    required this.osVersion,
    required this.totalRamMb,
    required this.freeStorageMb,
    required this.model,
    required this.isEmulator,
  });

  final String platform;
  final String cpuAbi;
  final int cpuCores;
  final String osVersion;

  /// Total RAM in MB, or null if the platform does not expose it.
  final int? totalRamMb;

  /// Free storage in the app's data partition, or null if unknown.
  final int? freeStorageMb;
  final String model;
  final bool isEmulator;

  bool get isArm64 => cpuAbi.contains('arm64') || cpuAbi.contains('aarch64');

  /// Threads to give llama.cpp: leave headroom for the UI.
  int get recommendedThreads => (cpuCores - 2).clamp(2, 6);

  @override
  String toString() =>
      '$model · $platform $osVersion · $cpuAbi · $cpuCores cores · '
      'RAM ${totalRamMb ?? '?'} MB · free ${freeStorageMb ?? '?'} MB';
}

class DeviceCapabilityService {
  DeviceCapabilityService({DeviceInfoPlugin? plugin})
      : _plugin = plugin ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _plugin;
  DeviceCapability? _cached;

  Future<DeviceCapability> detect() async {
    if (_cached != null) return _cached!;
    var abi = 'unknown';
    var os = Platform.operatingSystemVersion;
    var model = 'unknown';
    var emulator = false;
    int? ram;

    if (Platform.isAndroid) {
      final info = await _plugin.androidInfo;
      abi = info.supportedAbis.isNotEmpty ? info.supportedAbis.first : abi;
      os = 'Android ${info.version.release} (API ${info.version.sdkInt})';
      model = '${info.manufacturer} ${info.model}';
      emulator = !info.isPhysicalDevice;
      ram = _readMemInfoMb();
    } else if (Platform.isIOS) {
      final info = await _plugin.iosInfo;
      abi = 'arm64';
      os = 'iOS ${info.systemVersion}';
      model = info.utsname.machine;
      emulator = !info.isPhysicalDevice;
    } else if (Platform.isMacOS) {
      final info = await _plugin.macOsInfo;
      abi = info.arch;
      model = info.model;
      ram = (info.memorySize / (1024 * 1024)).round();
    }

    int? free;
    try {
      final dir = await getApplicationSupportDirectory();
      free = await _freeSpaceMb(dir.path);
    } catch (_) {}

    return _cached = DeviceCapability(
      platform: Platform.operatingSystem,
      cpuAbi: abi,
      cpuCores: Platform.numberOfProcessors,
      osVersion: os,
      totalRamMb: ram,
      freeStorageMb: free,
      model: model,
      isEmulator: emulator,
    );
  }

  /// Android exposes total memory in /proc/meminfo (readable by apps).
  static int? _readMemInfoMb() {
    try {
      final lines = File('/proc/meminfo').readAsLinesSync();
      for (final l in lines) {
        if (l.startsWith('MemTotal:')) {
          final kb = int.parse(l.replaceAll(RegExp(r'[^0-9]'), ''));
          return kb ~/ 1024;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<int?> _freeSpaceMb(String path) async {
    // `df` is available on Android and macOS; fall back to null elsewhere.
    try {
      final r = await Process.run('df', ['-k', path]);
      if (r.exitCode != 0) return null;
      final lines = (r.stdout as String).trim().split('\n');
      if (lines.length < 2) return null;
      final cols = lines.last.split(RegExp(r'\s+'));
      // Available column is the 4th on both platforms.
      return int.tryParse(cols[3]) != null ? int.parse(cols[3]) ~/ 1024 : null;
    } catch (_) {
      return null;
    }
  }
}
