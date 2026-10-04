import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart' as llama;

import 'local_model_manager.dart';

/// A chat turn passed to the model.
class LlmTurn {
  const LlmTurn.user(this.content) : role = 'user';
  const LlmTurn.assistant(this.content) : role = 'assistant';
  final String role;
  final String content;
}

/// Thin wrapper over llama.cpp (via `llama_cpp_dart`). One engine, one
/// active generation at a time, running in a worker isolate so the UI
/// never blocks.
///
/// Lifecycle: [load] → [generate]* → [dispose]. Readiness is exposed through
/// [state] and [stateChanges] so the status pill can show
/// "Local AI Loading / Ready / Unavailable".
class LocalLlmService {
  LocalLlmService({this.libraryPath});

  /// Absolute path to libllama for desktop/tests; null on Android where the
  /// package bundles the library.
  final String? libraryPath;

  llama.LlamaEngine? _engine;
  InstalledModel? _model;
  ModelState _state = ModelState.notInitialized;
  String? _error;
  Future<void>? _loading;
  StreamSubscription<llama.GenerationEvent>? _active;
  final _stateCtrl = StreamController<ModelState>.broadcast();

  ModelState get state => _state;
  Stream<ModelState> get stateChanges => _stateCtrl.stream;
  String? get errorMessage => _error;
  InstalledModel? get model => _model;
  bool get isReady => _state == ModelState.ready && _engine != null;
  bool get isGenerating => _active != null;
  String get displayName => _model?.spec.displayName ?? 'Local AI';

  void _set(ModelState s, [String? err]) {
    _state = s;
    _error = err;
    _stateCtrl.add(s);
  }

  /// Loads [model] into memory. Idempotent while loading; a second call with
  /// a different model reloads.
  Future<void> load(InstalledModel model, {int threads = 4, int contextTokens = 2048}) {
    if (_loading != null && _model?.spec.id == model.spec.id) return _loading!;
    _loading = _load(model, threads: threads, contextTokens: contextTokens);
    return _loading!;
  }

  Future<void> _load(InstalledModel model,
      {required int threads, required int contextTokens}) async {
    await dispose(keepState: true);
    _set(ModelState.initializing);
    final sw = Stopwatch()..start();
    try {
      if (!await LocalModelManager.verify(model.file, model.spec)) {
        throw const FileSystemException('Model file failed verification');
      }
      _engine = await llama.LlamaEngine.spawn(
        libraryPath: libraryPath,
        modelParams: llama.ModelParams(
          path: model.file.path,
          gpuLayers: 0,
          useMmap: true,
        ),
        contextParams: llama.ContextParams(
          nCtx: contextTokens,
          nBatch: 512,
          nUbatch: 256,
          nThreads: threads,
          nThreadsBatch: threads,
        ),
      );
      _model = model;
      _set(ModelState.ready);
      debugPrint('LocalLlm: loaded ${model.spec.displayName} in ${sw.elapsedMilliseconds} ms');
    } catch (e, st) {
      debugPrint('LocalLlm: load failed: $e\n$st');
      _engine = null;
      _model = null;
      _set(ModelState.error, _friendlyError(e));
    } finally {
      _loading = null;
    }
  }

  /// Streams the assistant's reply text for a chat. Cancelling the returned
  /// stream's subscription stops generation.
  Stream<String> generate({
    required String system,
    required List<LlmTurn> turns,
    int maxTokens = 320,
    double temperature = 0.4,
  }) {
    final engine = _engine;
    if (engine == null || !isReady) {
      return Stream.error(StateError('Local AI is not loaded'));
    }
    if (_active != null) {
      return Stream.error(StateError('Local AI is busy'));
    }
    final ctrl = StreamController<String>();
    final sw = Stopwatch()..start();
    llama.EngineChat? chat;
    late StreamSubscription<llama.GenerationEvent> sub;

    Future<void> run() async {
      try {
        chat = await engine.createChat();
        chat!.addSystem(system);
        for (final t in turns) {
          if (t.role == 'user') {
            chat!.addUser(t.content);
          } else {
            chat!.addAssistant(t.content);
          }
        }
        sub = chat!
            .generate(
              sampler: llama.SamplerParams(
                temperature: temperature,
                topP: 0.9,
                topK: 40,
                minP: 0.05,
                repeatPenalty: 1.1,
              ),
              maxTokens: maxTokens,
            )
            .listen(
          (ev) {
            if (ev is llama.TokenEvent) {
              if (!ctrl.isClosed) ctrl.add(ev.text);
            } else if (ev is llama.DoneEvent) {
              if (ev.trailingText.isNotEmpty && !ctrl.isClosed) {
                ctrl.add(ev.trailingText);
              }
              debugPrint('LocalLlm: generated ${ev.generatedCount} tokens in ${sw.elapsedMilliseconds} ms '
                  '(${(ev.generatedCount * 1000 / (sw.elapsedMilliseconds + 1)).toStringAsFixed(1)} tok/s, ${ev.reason})');
            }
          },
          onError: (Object e, StackTrace st) {
            if (!ctrl.isClosed) ctrl.addError(e, st);
          },
          onDone: () async {
            _active = null;
            await chat?.dispose();
            if (!ctrl.isClosed) await ctrl.close();
          },
          cancelOnError: true,
        );
        _active = sub;
      } catch (e, st) {
        _active = null;
        await chat?.dispose();
        if (!ctrl.isClosed) {
          ctrl.addError(e, st);
          await ctrl.close();
        }
      }
    }

    ctrl.onListen = run;
    ctrl.onCancel = () async {
      final a = _active;
      _active = null;
      await a?.cancel();
      await chat?.dispose();
      if (!ctrl.isClosed) await ctrl.close();
    };
    return ctrl.stream;
  }

  /// Convenience: collect the whole reply.
  Future<String> complete({
    required String system,
    required List<LlmTurn> turns,
    int maxTokens = 320,
  }) async {
    final buf = StringBuffer();
    await for (final t in generate(system: system, turns: turns, maxTokens: maxTokens)) {
      buf.write(t);
    }
    return buf.toString();
  }

  Future<void> cancel() async {
    final a = _active;
    _active = null;
    await a?.cancel();
  }

  Future<void> dispose({bool keepState = false}) async {
    await cancel();
    final e = _engine;
    _engine = null;
    _model = null;
    try {
      await e?.dispose();
    } catch (err) {
      debugPrint('LocalLlm: dispose error $err');
    }
    if (!keepState) _set(ModelState.notInitialized);
  }

  static String _friendlyError(Object e) {
    if (e is llama.LlamaLibraryException) {
      return 'The local AI library is not available on this device.';
    }
    if (e is llama.LlamaModelLoadException) {
      return 'The model could not be loaded (not enough memory or a damaged file).';
    }
    if (e is FileSystemException) return e.message;
    return 'Local AI could not start: $e';
  }
}
