import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../database/app_database.dart';
import 'device_capability_service.dart';
import '../connectivity_service.dart';
import 'local_ai_orchestrator.dart';
import 'local_knowledge_service.dart';
import 'local_llm_service.dart';
import 'local_model_manager.dart';
import 'local_vision_service.dart';

/// Overall readiness of the local AI platform for the status pill.
enum LocalAiReadiness { loading, ready, partial, unavailable }

/// The local AI platform: database, knowledge, vision model and language
/// model. Owns start-up (spec §7) and exposes readiness for the UI (§25).
///
/// Start-up sequence:
///   check database → seed knowledge → load CV model → (LLM lazily) → ready
///
/// The LLM is loaded on first use (AI Assistant or scan explanation) so the
/// splash never waits for an 800 MB model.
class LocalAiEngine extends ChangeNotifier {
  LocalAiEngine({
    required AppDatabase db,
    LocalModelManager? models,
    LocalLlmService? llm,
    LocalVisionService? vision,
    LocalKnowledgeService? knowledge,
    DeviceCapabilityService? capability,
  })  : _db = db,
        _capability = capability ?? DeviceCapabilityService(),
        _models = models ?? LocalModelManager(capability: capability),
        _llm = llm ?? LocalLlmService(),
        _vision = vision ?? LocalVisionService(),
        _knowledge = knowledge ?? LocalKnowledgeService(db) {
    orchestrator = LocalAIOrchestrator(
      llm: _llm,
      vision: _vision,
      knowledge: _knowledge,
      ensureLlm: ensureLlm,
      // Read through a field, not a captured value: ConnectivityState is
      // created after this engine, so the wiring happens at bootstrap.
      networkQuality: () => networkQuality?.call() ?? NetworkQuality.none,
    );
    _subs.add(_llm.stateChanges.listen((_) => notifyListeners()));
    _subs.add(_vision.stateChanges.listen((_) => notifyListeners()));
  }

  /// Reads the measured connection quality. Set during bootstrap, once
  /// ConnectivityState exists. Null means "assume offline", so the cloud is
  /// never reached by accident.
  NetworkQuality Function()? networkQuality;

  final AppDatabase _db;
  final DeviceCapabilityService _capability;
  final LocalModelManager _models;
  final LocalLlmService _llm;
  final LocalVisionService _vision;
  final LocalKnowledgeService _knowledge;
  late final LocalAIOrchestrator orchestrator;
  final List<StreamSubscription> _subs = [];

  bool _dataReady = false;
  int _knowledgeCount = 0;
  DeviceCapability? _device;
  InstalledModel? _selected;
  LlmModelSpec? _recommended;
  Future<void>? _llmLoad;
  ModelDownloadProgress? _download;
  LlmModelSpec? _downloading;
  String? _downloadError;
  Future<void>? _init;
  String? _preferredId;
  List<InstalledModel> _installed = const [];
  static const String _prefKey = 'preferred_llm_id';

  // ---- Readiness ----

  bool get dataReady => _dataReady;
  int get knowledgeCount => _knowledgeCount;
  ModelState get llmState => _llm.state;
  ModelState get visionState => _vision.state;
  String? get llmError => _llm.errorMessage;
  String? get visionError => _vision.errorMessage;
  bool get llmReady => _llm.isReady;
  bool get visionReady => _vision.isReady;
  bool get llmInstalled => _selected != null;
  InstalledModel? get selectedModel => _selected;
  LlmModelSpec? get recommendedModel => _recommended;
  DeviceCapability? get device => _device;
  CvModelInfo? get visionInfo => _vision.info;
  ModelDownloadProgress? get downloadProgress => _download;
  LlmModelSpec? get downloadingSpec => _downloading;
  String? get downloadError => _downloadError;
  List<InstalledModel> get installedModels => _installed;
  String? get preferredModelId => _preferredId;
  bool isInstalled(LlmModelSpec s) => _installed.any((m) => m.spec.id == s.id);
  bool isActive(LlmModelSpec s) => _llm.isReady && _llm.model?.spec.id == s.id;
  bool fits(LlmModelSpec s) => LocalModelManager.fits(s, _device);
  bool get isDownloading => _download != null && _download!.received < _download!.total;
  LocalKnowledgeService get knowledge => _knowledge;
  LocalModelManager get models => _models;
  LocalLlmService get llm => _llm;
  LocalVisionService get vision => _vision;

  String get llmDisplayName => _selected?.spec.displayName ?? 'Llama 3.2';
  String get visionDisplayName => _vision.info?.displayName ?? 'MobileNetV3';

  LocalAiReadiness get readiness {
    if (!_dataReady) return LocalAiReadiness.loading;
    if (_llm.state == ModelState.initializing || _vision.state == ModelState.initializing) {
      return LocalAiReadiness.loading;
    }
    if (_llm.isReady && _vision.isReady) return LocalAiReadiness.ready;
    if (_vision.isReady || _llm.isReady) return LocalAiReadiness.partial;
    return LocalAiReadiness.unavailable;
  }

  /// Short label for the status pill.
  String get statusLabel {
    switch (readiness) {
      case LocalAiReadiness.loading:
        return 'Local AI Loading';
      case LocalAiReadiness.ready:
        return 'Local AI Ready';
      case LocalAiReadiness.partial:
        return llmInstalled ? 'Local AI Ready' : 'Local AI Limited';
      case LocalAiReadiness.unavailable:
        return 'Local AI Unavailable';
    }
  }

  // ---- Start-up ----

  /// Idempotent. Seeds knowledge, loads the vision model, locates the LLM
  /// file (without loading it) and detects device capability.
  Future<void> initialize() => _init ??= _initialize();

  Future<void> _initialize() async {
    final sw = Stopwatch()..start();
    try {
      _knowledgeCount = await _knowledge.seedIfNeeded();
      _dataReady = true;
      notifyListeners();
    } catch (e, st) {
      debugPrint('knowledge seed failed: $e\n$st');
    }
    try {
      _device = await _capability.detect();
    } catch (e) {
      debugPrint('capability detect failed: $e');
    }
    // Vision is small (2 MB) — load eagerly so Scan is instant.
    await _vision.load();
    await refreshModels();
    debugPrint('LocalAiEngine ready in ${sw.elapsedMilliseconds} ms: ${_device ?? ''}');
    notifyListeners();
  }

  /// Re-scan model directories (after a download or adb push).
  Future<void> refreshModels() async {
    try {
      _preferredId ??= await _db.getMeta(_prefKey);
      _installed = await _models.installed();
      _selected = await _models.selectBest(capability: _device, preferredId: _preferredId);
      _recommended = await _models.recommendedSpec(capability: _device);
    } catch (e) {
      // No file system access (e.g. tests) — treat as "not installed".
      debugPrint('refreshModels: $e');
      _selected = null;
      _recommended ??= kKnownLlmModels.first;
    }
    notifyListeners();
  }

  /// Loads the selected LLM if it is installed and not yet loaded.
  Future<void> ensureLlm() {
    if (_llm.isReady) return Future.value();
    return _llmLoad ??= _loadLlm().whenComplete(() => _llmLoad = null);
  }

  Future<void> _loadLlm() async {
    if (_selected == null) await refreshModels();
    final m = _selected;
    if (m == null) return; // not installed; callers fall back to knowledge
    final threads = _device?.recommendedThreads ?? 4;
    await _llm.load(m, threads: threads, contextTokens: 2048);
    // If the chosen model failed to load, fall back to the smallest installed.
    if (_llm.state == ModelState.error) {
      final all = await _models.installed()
        ..sort((a, b) => a.spec.sizeBytes.compareTo(b.spec.sizeBytes));
      final other = all.where((x) => x.spec.id != m.spec.id).firstOrNull;
      if (other != null) {
        _selected = other;
        await _llm.load(other, threads: threads, contextTokens: 2048);
      }
    }
    notifyListeners();
  }

  /// Frees the LLM memory (e.g. on memory pressure). Vision stays loaded.
  Future<void> unloadLlm() async {
    await _llm.dispose();
    notifyListeners();
  }

  /// The farmer picked a model. Persists the choice and (re)loads it if it
  /// is installed; otherwise it becomes the download target.
  Future<void> selectModel(LlmModelSpec spec) async {
    _preferredId = spec.id;
    await _db.setMeta(_prefKey, spec.id);
    await refreshModels();
    if (isInstalled(spec)) {
      if (_llm.model?.spec.id != spec.id) {
        await _llm.dispose();
        _llmLoad = null;
        await ensureLlm();
      }
    }
    notifyListeners();
  }

  /// Removes a downloaded model file (unloading it first if active).
  Future<void> deleteModel(LlmModelSpec spec) async {
    final m = _installed.where((x) => x.spec.id == spec.id).firstOrNull;
    if (m == null) return;
    if (isActive(spec)) await unloadLlm();
    await _models.deleteModel(m);
    await refreshModels();
  }

  // ---- Model installation ----

  /// Downloads [spec] (defaults to the recommended model). Installation only;
  /// nothing at runtime depends on the network once the file is on disk.
  Future<void> downloadModel([LlmModelSpec? spec]) async {
    final s = spec ?? _recommended ?? kKnownLlmModels.first;
    if (_download != null) return; // one download at a time
    _downloadError = null;
    _downloading = s;
    _download = ModelDownloadProgress(0, s.sizeBytes);
    notifyListeners();
    try {
      await for (final p in _models.download(s)) {
        _download = p;
        notifyListeners();
      }
      _download = null;
      _downloading = null;
      notifyListeners();
      await selectModel(s);
    } catch (e) {
      _download = null;
      _downloading = null;
      _downloadError = 'Download failed: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    _llm.dispose();
    _vision.dispose();
    super.dispose();
  }

  /// Human-readable summary for the Offline & Sync / About screens.
  Map<String, String> summary() => {
        'Database': _dataReady ? 'Ready ($_knowledgeCount knowledge articles)' : 'Loading',
        'Vision model': _vision.isReady
            ? '${_vision.info?.displayName} v${_vision.info?.version}'
            : (_vision.errorMessage ?? 'Loading'),
        'Language model': _llm.isReady
            ? '${_selected?.spec.displayName} (${_selected?.spec.parameters})'
            : _selected == null
                ? 'Not installed'
                : (_llm.state == ModelState.initializing
                    ? 'Loading…'
                    : (_llm.errorMessage ?? 'Installed, not loaded')),
        'Device': _device?.toString() ?? 'Unknown',
      };

  AppDatabase get db => _db;
}
