import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'device_capability_service.dart';

/// Readiness of a local model component.
enum ModelState { notInitialized, initializing, ready, error }

/// A GGUF language model we know how to run.
class LlmModelSpec {
  const LlmModelSpec({
    required this.id,
    required this.displayName,
    required this.fileName,
    required this.sizeBytes,
    required this.minRamMb,
    required this.downloadUrl,
    required this.license,
    required this.parameters,
    required this.vendor,
    required this.description,
    this.recommended = false,
  });

  final String id;
  final String displayName;
  final String fileName;
  final int sizeBytes;

  /// "Meta" / "Google".
  final String vendor;

  /// One line for the picker.
  final String description;

  /// Default choice when the user has not picked one.
  final bool recommended;

  /// Minimum device RAM (MB) before we will even try to load this model.
  final int minRamMb;
  final String downloadUrl;
  final String license;
  final String parameters;

  String get sizeLabel => '${(sizeBytes / (1024 * 1024)).round()} MB';
}

/// Models this build knows about. The farmer picks one in the status sheet;
/// each is a one-time download. Licences: see docs/MODELS.md.
const List<LlmModelSpec> kKnownLlmModels = [
  LlmModelSpec(
    id: 'llama-3.2-1b-instruct-q4_k_m',
    displayName: 'Llama 3.2 1B',
    fileName: 'Llama-3.2-1B-Instruct-Q4_K_M.gguf',
    sizeBytes: 807694464,
    minRamMb: 3000,
    downloadUrl:
        'https://huggingface.co/bartowski/Llama-3.2-1B-Instruct-GGUF/resolve/main/Llama-3.2-1B-Instruct-Q4_K_M.gguf',
    license: 'Llama 3.2 Community License',
    parameters: '1.24B · Q4_K_M',
    vendor: 'Meta',
    description: 'Best answers for farming questions in our tests.',
    recommended: true,
  ),
  LlmModelSpec(
    id: 'gemma-3-1b-it-q4_k_m',
    displayName: 'Gemma 3 1B',
    fileName: 'gemma-3-1b-it-Q4_K_M.gguf',
    sizeBytes: 806058240,
    minRamMb: 3000,
    downloadUrl:
        'https://huggingface.co/ggml-org/gemma-3-1b-it-GGUF/resolve/main/gemma-3-1b-it-Q4_K_M.gguf',
    license: 'Gemma Terms of Use',
    parameters: '1.0B · Q4_K_M',
    vendor: 'Google',
    description: 'Alternative small model; 32k context.',
  ),
];

/// The smallest model, always the last-resort fallback.
LlmModelSpec get kFallbackLlmModel =>
    kKnownLlmModels.firstWhere((m) => m.id == 'llama-3.2-1b-instruct-q4_k_m');

/// A model file found on disk together with its spec.
class InstalledModel {
  const InstalledModel({required this.spec, required this.file});
  final LlmModelSpec spec;
  final File file;
}

class ModelDownloadProgress {
  const ModelDownloadProgress(this.received, this.total);
  final int received;
  final int total;
  double get fraction => total == 0 ? 0 : received / total;
}

/// Locates, verifies, selects and downloads GGUF models. Loading into memory
/// is done by `LocalLlmService`; this class only deals with files.
class LocalModelManager {
  LocalModelManager({DeviceCapabilityService? capability})
      : _capability = capability ?? DeviceCapabilityService();

  final DeviceCapabilityService _capability;

  static const String modelsDirName = 'models';

  /// Directories searched for model files, in priority order:
  /// 1. app support dir (private, survives app updates)
  /// 2. app-private external dir on Android — `adb push`-able for demos:
  ///    `/sdcard/Android/data/<package>/files/models/`
  Future<List<Directory>> modelDirectories() async {
    final dirs = <Directory>[];
    final support = await getApplicationSupportDirectory();
    dirs.add(Directory(p.join(support.path, modelsDirName)));
    if (Platform.isAndroid) {
      try {
        final ext = await getExternalStorageDirectory();
        if (ext != null) dirs.add(Directory(p.join(ext.path, modelsDirName)));
      } catch (_) {}
    }
    return dirs;
  }

  /// Directory used for new downloads.
  Future<Directory> downloadDirectory() async {
    final dirs = await modelDirectories();
    final d = dirs.first;
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  /// All known models present on disk with a matching size and GGUF header.
  Future<List<InstalledModel>> installed() async {
    final found = <InstalledModel>[];
    for (final dir in await modelDirectories()) {
      if (!await dir.exists()) continue;
      for (final spec in kKnownLlmModels) {
        if (found.any((m) => m.spec.id == spec.id)) continue;
        final f = File(p.join(dir.path, spec.fileName));
        if (await verify(f, spec)) found.add(InstalledModel(spec: spec, file: f));
      }
    }
    return found;
  }

  /// A file is valid when it has the exact expected size and starts with the
  /// GGUF magic bytes — enough to catch truncated downloads and wrong files.
  static Future<bool> verify(File f, LlmModelSpec spec) async {
    try {
      if (!await f.exists()) return false;
      if (await f.length() != spec.sizeBytes) return false;
      final raf = await f.open();
      try {
        final head = await raf.read(4);
        return String.fromCharCodes(head) == 'GGUF';
      } finally {
        await raf.close();
      }
    } catch (_) {
      return false;
    }
  }

  /// Picks the model to run: the farmer's [preferredId] if installed,
  /// otherwise the recommended one, otherwise the largest that fits RAM.
  /// Returns null when nothing is installed.
  Future<InstalledModel?> selectBest({DeviceCapability? capability, String? preferredId}) async {
    final models = await installed();
    if (models.isEmpty) return null;
    if (preferredId != null) {
      final p = models.where((m) => m.spec.id == preferredId).firstOrNull;
      if (p != null) return p;
    }
    final rec = models.where((m) => m.spec.recommended).firstOrNull;
    if (rec != null) return rec;
    final cap = capability ?? await _capability.detect();
    final ram = cap.totalRamMb ?? 0;
    // Sort largest first, pick first whose RAM requirement is satisfied.
    models.sort((a, b) => b.spec.sizeBytes.compareTo(a.spec.sizeBytes));
    for (final m in models) {
      if (ram == 0 || ram >= m.spec.minRamMb) return m;
    }
    // Nothing satisfied the RAM rule; still return the smallest so the
    // caller can try (and handle a load error gracefully).
    return models.last;
  }

  /// Recommended model for this device when nothing is installed yet.
  Future<LlmModelSpec> recommendedSpec({DeviceCapability? capability}) async {
    return kKnownLlmModels.firstWhere((m) => m.recommended, orElse: () => kFallbackLlmModel);
  }

  /// Whether this device has enough RAM for [spec].
  static bool fits(LlmModelSpec spec, DeviceCapability? cap) {
    final ram = cap?.totalRamMb ?? 0;
    return ram == 0 || ram >= spec.minRamMb;
  }

  /// Downloads [spec] into the app's model directory with resume support.
  /// This is model *installation*, not a runtime dependency: once the file is
  /// on the phone the app never needs the network again.
  Stream<ModelDownloadProgress> download(LlmModelSpec spec,
      {HttpClient? client}) async* {
    final dir = await downloadDirectory();
    final target = File(p.join(dir.path, spec.fileName));
    final part = File('${target.path}.part');
    var received = await part.exists() ? await part.length() : 0;
    if (received >= spec.sizeBytes) {
      await part.delete();
      received = 0;
    }

    final http = client ?? HttpClient();
    http.connectionTimeout = const Duration(seconds: 30);
    try {
      final req = await http.getUrl(Uri.parse(spec.downloadUrl));
      if (received > 0) req.headers.set('Range', 'bytes=$received-');
      final res = await req.close();
      if (res.statusCode != 200 && res.statusCode != 206) {
        throw HttpException('HTTP ${res.statusCode} downloading ${spec.fileName}');
      }
      if (res.statusCode == 200) received = 0; // server ignored Range
      final sink = part.openWrite(
          mode: received > 0 ? FileMode.append : FileMode.write);
      try {
        yield ModelDownloadProgress(received, spec.sizeBytes);
        var lastEmit = DateTime.now();
        await for (final chunk in res) {
          sink.add(chunk);
          received += chunk.length;
          final now = DateTime.now();
          if (now.difference(lastEmit).inMilliseconds > 250) {
            lastEmit = now;
            yield ModelDownloadProgress(received, spec.sizeBytes);
          }
        }
      } finally {
        await sink.close();
      }
      await part.rename(target.path);
      if (!await verify(target, spec)) {
        await target.delete();
        throw const FileSystemException('Downloaded model failed verification');
      }
      yield ModelDownloadProgress(spec.sizeBytes, spec.sizeBytes);
    } finally {
      if (client == null) http.close(force: true);
    }
  }

  Future<void> deleteModel(InstalledModel m) async {
    try {
      await m.file.delete();
    } catch (e) {
      debugPrint('deleteModel: $e');
    }
  }
}
