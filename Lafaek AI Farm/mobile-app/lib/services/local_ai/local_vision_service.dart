import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

import 'image_preprocessor.dart';
import 'local_model_manager.dart';

/// Confidence bands from the spec (§15).
enum ConfidenceBand {
  high,
  moderate,
  low;

  static ConfidenceBand of(double c) {
    if (c >= 0.80) return ConfidenceBand.high;
    if (c >= 0.60) return ConfidenceBand.moderate;
    return ConfidenceBand.low;
  }

  String get label {
    switch (this) {
      case ConfidenceBand.high:
        return 'High confidence';
      case ConfidenceBand.moderate:
        return 'Moderate confidence';
      case ConfidenceBand.low:
        return 'Low confidence';
    }
  }
}

/// Raw output of the classifier.
class CvResult {
  const CvResult({
    required this.label,
    required this.confidence,
    required this.scores,
    required this.inferenceTimeMs,
    required this.modelName,
    this.margin = 1.0,
    this.runnerUp,
  });

  /// Class id, e.g. `maize_leaf_blight`, or `unknown` when confidence is low.
  final String label;
  final double confidence;

  /// All class probabilities, keyed by class id.
  final Map<String, double> scores;
  final int inferenceTimeMs;
  final String modelName;

  /// Gap between the top and second class — small means a near-tie.
  final double margin;
  final String? runnerUp;

  ConfidenceBand get band => ConfidenceBand.of(confidence);
  bool get isUnknown => label == 'unknown';

  /// The classifier is confident this is not a leaf photo.
  bool get isNotLeaf => label == 'other';

  /// Crop name derived from the class id prefix (`maize_…` → Maize).
  String get cropName {
    final prefix = label.split('_').first;
    if (prefix.isEmpty || label == 'unknown' || label == 'other') return 'Unknown';
    return prefix[0].toUpperCase() + prefix.substring(1);
  }

  /// Condition part of the class id (`maize_leaf_blight` → `leaf_blight`).
  String get condition {
    final i = label.indexOf('_');
    return i < 0 ? label : label.substring(i + 1);
  }

  bool get isHealthy => condition == 'healthy';
}

/// Metadata bundled next to the .tflite file.
class CvModelInfo {
  const CvModelInfo({
    required this.name,
    required this.architecture,
    required this.version,
    required this.classes,
    required this.inputWidth,
    required this.inputHeight,
    required this.valAccuracy,
    required this.status,
    required this.trainingData,
  });

  final String name;
  final String architecture;
  final String version;
  final List<String> classes;
  final int inputWidth;
  final int inputHeight;
  final double valAccuracy;
  final String status;
  final String trainingData;

  String get displayName => 'MobileNetV3-Small';

  static CvModelInfo fromJson(Map<String, dynamic> m) => CvModelInfo(
        name: m['name'] as String,
        architecture: m['architecture'] as String,
        version: m['version'] as String,
        classes: (m['output']['classes'] as List).map((e) => e.toString()).toList(),
        inputWidth: m['input']['width'] as int,
        inputHeight: m['input']['height'] as int,
        valAccuracy: (m['val_accuracy'] as num).toDouble(),
        status: m['status'] as String,
        trainingData: m['training_data'] as String,
      );
}

/// On-device crop condition classifier (TensorFlow Lite).
///
/// The model and its metadata are bundled as assets, so vision works with no
/// network and no download. Inference runs on a dedicated isolate.
class LocalVisionService {
  LocalVisionService({
    this.modelAsset = 'assets/models/crop_condition_mnv3s.tflite',
    this.metaAsset = 'assets/models/model_meta.json',
    this.threads = 4,
  });

  final String modelAsset;
  final String metaAsset;
  final int threads;

  /// Below this the result is reported as `unknown`.
  static const double unknownThreshold = 0.55;

  /// The top class must beat the runner-up by at least this much. With 11
  /// classes a confident-looking score can still hide a near-tie, and a
  /// wrong-but-confident answer is worse for a farmer than "unclear".
  static const double minMargin = 0.20;

  tfl.Interpreter? _interpreter;
  tfl.IsolateInterpreter? _isolate;
  CvModelInfo? _info;
  ImagePreprocessor? _pre;
  ModelState _state = ModelState.notInitialized;
  String? _error;
  Future<void>? _loading;
  final _stateCtrl = StreamController<ModelState>.broadcast();

  ModelState get state => _state;
  Stream<ModelState> get stateChanges => _stateCtrl.stream;
  String? get errorMessage => _error;
  CvModelInfo? get info => _info;
  bool get isReady => _state == ModelState.ready;

  void _set(ModelState s, [String? err]) {
    _state = s;
    _error = err;
    _stateCtrl.add(s);
  }

  Future<void> load() {
    if (isReady) return Future.value();
    return _loading ??= _load();
  }

  Future<void> _load() async {
    _set(ModelState.initializing);
    try {
      final metaRaw = await rootBundle.loadString(metaAsset);
      _info = CvModelInfo.fromJson(jsonDecode(metaRaw) as Map<String, dynamic>);
      _pre = ImagePreprocessor(ImagePreprocessorConfig(
        width: _info!.inputWidth,
        height: _info!.inputHeight,
      ));
      final options = tfl.InterpreterOptions()..threads = threads;
      _interpreter = await tfl.Interpreter.fromAsset(modelAsset, options: options);
      _isolate = await tfl.IsolateInterpreter.create(address: _interpreter!.address);
      _set(ModelState.ready);
    } catch (e, st) {
      debugPrint('LocalVision: load failed: $e\n$st');
      _set(ModelState.error, 'The vision model could not be loaded.');
    } finally {
      _loading = null;
    }
  }

  /// Classifies an image. Throws [FormatException] for undecodable input and
  /// [StateError] when the model is not loaded.
  Future<CvResult> classify(Uint8List imageBytes) async {
    if (!isReady || _isolate == null || _info == null) {
      throw StateError('Vision model is not loaded');
    }
    final info = _info!;
    final sw = Stopwatch()..start();
    final pre = await _pre!.run(imageBytes);
    final input = pre.data.reshape([1, info.inputHeight, info.inputWidth, 3]);
    final output = List.filled(info.classes.length, 0.0).reshape([1, info.classes.length]);
    await _isolate!.run(input, output);
    sw.stop();

    final probs = (output[0] as List).map((e) => (e as num).toDouble()).toList();
    final scores = <String, double>{
      for (var i = 0; i < info.classes.length; i++) info.classes[i]: probs[i],
    };
    final ranked = List<int>.generate(probs.length, (i) => i)
      ..sort((a, b) => probs[b].compareTo(probs[a]));
    final best = ranked.first;
    final conf = probs[best];
    final margin = probs.length > 1 ? conf - probs[ranked[1]] : conf;
    final unclear = conf < unknownThreshold || margin < minMargin;
    return CvResult(
      label: unclear ? 'unknown' : info.classes[best],
      confidence: conf,
      scores: scores,
      inferenceTimeMs: sw.elapsedMilliseconds,
      modelName: '${info.displayName} v${info.version}',
      margin: margin,
      runnerUp: probs.length > 1 ? info.classes[ranked[1]] : null,
    );
  }

  Future<void> dispose() async {
    await _isolate?.close();
    _interpreter?.close();
    _isolate = null;
    _interpreter = null;
    _set(ModelState.notInitialized);
  }
}
