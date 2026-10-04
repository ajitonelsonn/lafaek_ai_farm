import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import '../models/models.dart';
import '../repositories/local_scan_repository.dart';
import 'local_ai/llm_prompt_builder.dart';
import 'local_ai/local_ai_engine.dart';
import 'local_ai/local_ai_orchestrator.dart';
import 'local_ai/local_llm_service.dart';

export 'local_ai/local_ai_orchestrator.dart'
    show AssistantEvent, AssistantStatus, AssistantPartial, AssistantDone;

/// Progress steps reported while a crop photo is analysed.
enum AnalysisStep {
  identifyingCrop,
  checkingLeafHealth,
  detectingDiseases,
  preparingRecommendations;

  String get label {
    switch (this) {
      case AnalysisStep.identifyingCrop:
        return 'Identifying crop';
      case AnalysisStep.checkingLeafHealth:
        return 'Checking leaf health';
      case AnalysisStep.detectingDiseases:
        return 'Detecting possible diseases';
      case AnalysisStep.preparingRecommendations:
        return 'Preparing recommendations';
    }
  }
}

/// Thrown by [CloudAIService] until the AWS phase is implemented.
class CloudNotConfiguredException implements Exception {
  const CloudNotConfiguredException();
  @override
  String toString() => 'Cloud AI is not configured in the local-first phase';
}

/// The one interface the UI talks to. Implementations may be cloud or local;
/// the UI does not care which is active.
abstract class AIService {
  String get engineName;

  /// Streams assistant events (status → partial text → done).
  Stream<AssistantEvent> answer(
    String question, {
    List<ChatMessage> history = const [],
    FarmContext? farm,
  });

  /// One-shot convenience.
  Future<String> ask(String question, {List<ChatMessage> history = const []}) async {
    String last = '';
    await for (final e in answer(question, history: history)) {
      if (e is AssistantDone) last = e.answer.answer;
    }
    return last;
  }

  /// Analyses a crop photo, emitting completed steps as it goes; the result
  /// is available from [analysisResult] once the stream completes.
  Stream<AnalysisStep> analyzeCrop({
    String? imagePath,
    Uint8List? imageBytes,
    FarmContext? farm,
    Crop? matchedCrop,
  });

  Future<ScanResult> analysisResult();
}

/// Real on-device AI: TFLite vision + Llama via llama.cpp + SQLite
/// knowledge, orchestrated by [LocalAIOrchestrator]. Every completed scan is
/// stored in SQLite.
class LocalAIService implements AIService {
  LocalAIService({
    required LocalAiEngine engine,
    required LocalScanRepository scans,
  })  : _engine = engine,
        _scans = scans;

  final LocalAiEngine _engine;
  final LocalScanRepository _scans;
  ScanResult? _last;

  @override
  String get engineName => _engine.llmReady ? _engine.llmDisplayName : 'Local AI';

  LocalAiEngine get engine => _engine;

  @override
  Stream<AssistantEvent> answer(
    String question, {
    List<ChatMessage> history = const [],
    FarmContext? farm,
  }) {
    final turns = [
      for (final m in history)
        m.isUser ? LlmTurn.user(m.text) : LlmTurn.assistant(m.text),
    ];
    return _engine.orchestrator.answer(question, farm: farm, history: turns);
  }

  @override
  Future<String> ask(String question, {List<ChatMessage> history = const []}) async {
    String last = '';
    await for (final e in answer(question, history: history)) {
      if (e is AssistantDone) last = e.answer.answer;
    }
    return last;
  }

  @override
  Stream<AnalysisStep> analyzeCrop({
    String? imagePath,
    Uint8List? imageBytes,
    FarmContext? farm,
    Crop? matchedCrop,
  }) async* {
    // Resolve bytes: explicit bytes, a file on disk, or a bundled asset.
    Uint8List bytes;
    String storedPath;
    if (imageBytes != null) {
      bytes = imageBytes;
      storedPath = imagePath != null && imagePath.startsWith('/')
          ? imagePath
          : await _scans.storePhoto(bytes);
    } else if (imagePath != null && imagePath.startsWith('/')) {
      bytes = await File(imagePath).readAsBytes();
      storedPath = imagePath;
    } else if (imagePath != null) {
      bytes = (await rootBundle.load(imagePath)).buffer.asUint8List();
      storedPath = imagePath; // demo asset; keep the asset path
    } else {
      throw ArgumentError('analyzeCrop needs imageBytes or imagePath');
    }

    CropAnalysis? analysis;
    await for (final ev in _engine.orchestrator.analyzeImage(
      bytes,
      imagePath: storedPath,
      farm: farm,
      matchedCrop: null,
    )) {
      if (ev is ScanStep) {
        yield AnalysisStep.values[ev.step.index];
      } else if (ev is ScanDone) {
        analysis = ev.analysis;
      }
    }
    if (analysis == null) throw StateError('Analysis produced no result');

    // Attach the farm crop's growth stage when the detected crop matches.
    final a = analysis;
    final stage = matchedCrop != null && matchedCrop.name.toLowerCase() == a.crop.toLowerCase()
        ? matchedCrop.growthStage
        : a.growthStage;
    final withStage = CropAnalysis(
      id: a.id,
      crop: a.crop,
      condition: a.condition,
      conditionLabel: a.conditionLabel,
      confidence: a.confidence,
      confidenceBand: a.confidenceBand,
      severity: a.severity,
      affectedArea: a.affectedArea,
      growthStage: stage,
      explanation: a.explanation,
      recommendedActions: a.recommendedActions,
      modelName: a.modelName,
      inferenceTimeMs: a.inferenceTimeMs,
      createdAt: a.createdAt,
      imagePath: a.imagePath,
      status: a.status,
      explanationEngine: a.explanationEngine,
      sources: a.sources,
      cropId: matchedCrop?.id,
    );
    _last = await _scans.saveAnalysis(withStage);
  }

  @override
  Future<ScanResult> analysisResult() async {
    final r = _last;
    if (r == null) throw StateError('No analysis has completed');
    return r;
  }
}

/// Amazon Bedrock–backed engine — **future phase**. Kept so the UI and state
/// keep compiling against the same interface; every call reports that the
/// cloud is not configured rather than pretending.
class CloudAIService implements AIService {
  @override
  String get engineName => 'Amazon Bedrock (not configured)';

  @override
  Stream<AssistantEvent> answer(String question,
      {List<ChatMessage> history = const [], FarmContext? farm}) =>
      Stream.error(const CloudNotConfiguredException());

  @override
  Future<String> ask(String question, {List<ChatMessage> history = const []}) =>
      Future.error(const CloudNotConfiguredException());

  @override
  Stream<AnalysisStep> analyzeCrop(
          {String? imagePath, Uint8List? imageBytes, FarmContext? farm, Crop? matchedCrop}) =>
      Stream.error(const CloudNotConfiguredException());

  @override
  Future<ScanResult> analysisResult() => Future.error(const CloudNotConfiguredException());
}
