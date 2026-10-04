import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import '../models/models.dart';
import '../services/cloud/online_analysis_service.dart';
import '../services/farm_services.dart';
import 'local_sync_queue_service.dart';

/// Scan history in SQLite + photos on disk (spec §16, §20).
class LocalScanRepository implements CropScanService {
  LocalScanRepository(this._db, {required LocalSyncQueueService sync}) : _sync = sync;

  final AppDatabase _db;
  final LocalSyncQueueService _sync;

  /// `app_documents/lafaek/scans/` — photos are files, only paths go in SQLite.
  Future<Directory> scansDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'lafaek', 'scans'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  /// Copies a captured photo into app storage and returns its path.
  Future<String> storePhoto(List<int> bytes, {String ext = 'jpg'}) async {
    final dir = await scansDirectory();
    final f = File(p.join(dir.path, 'scan-${DateTime.now().millisecondsSinceEpoch}.$ext'));
    await f.writeAsBytes(bytes, flush: true);
    return f.path;
  }

  @override
  Future<List<ScanResult>> history() async =>
      (await _db.scanDao.recent(limit: 100)).map(fromRow).toList();

  Future<List<ScanResult>> forCrop(String cropName) async =>
      (await _db.scanDao.forCrop(cropName)).map(fromRow).toList();

  Future<ScanResult?> byId(String id) async {
    final r = await _db.scanDao.byId(id);
    return r == null ? null : fromRow(r);
  }

  /// Persists a completed analysis (always, whether or not the farmer taps
  /// "Save to My Farm" — the spec says every completed scan is stored).
  Future<ScanResult> saveAnalysis(CropAnalysis a, {bool savedToFarm = false}) async {
    final row = CropScansCompanion(
      id: Value(a.id),
      cropId: Value(a.cropId),
      cropName: Value(a.crop),
      imagePath: Value(a.imagePath),
      condition: Value(a.condition),
      issueLabel: Value(a.conditionLabel),
      confidence: Value(a.confidence),
      margin: Value(a.margin),
      runnerUp: Value(a.runnerUp),
      severity: Value(a.severity),
      affectedArea: Value(a.affectedArea),
      growthStage: Value(a.growthStage),
      explanation: Value(a.explanation),
      actionsJson: Value(jsonEncode([
        for (final x in a.recommendedActions) {'title': x.title, 'detail': x.detail}
      ])),
      status: Value(a.status.name),
      modelName: Value(a.modelName),
      inferenceTimeMs: Value(a.inferenceTimeMs),
      engine: Value(a.explanationEngine),
      savedToFarm: Value(savedToFarm),
      pendingSync: const Value(true),
      createdAt: Value(a.createdAt),
    );
    await _db.scanDao.upsert(row);
    await _sync.enqueue(entityType: 'scan', entityId: a.id, operation: 'create', payload: {
      'crop': a.crop,
      'condition': a.condition,
      'confidence': a.confidence,
      'model': a.modelName,
      'createdAt': a.createdAt.toIso8601String(),
      'imagePath': a.imagePath,
    });
    return a.toScanResult(savedToFarm: savedToFarm, pendingSync: true);
  }

  /// Stores Claude's second opinion next to the local result.
  ///
  /// The local analysis is never overwritten: a farmer who scanned offline
  /// keeps exactly what the phone decided, and the online view is added
  /// beside it when a signal appears.
  Future<void> attachOnlineAnalysis(String scanId, OnlineAnalysis a) async {
    await (_db.update(_db.cropScans)..where((t) => t.id.equals(scanId)))
        .write(CropScansCompanion(
      onlineSummary: Value(a.summary),
      onlineActionsJson: Value(jsonEncode(a.actions)),
      onlineModel: Value(a.model),
      onlineConfirms: Value(a.confirmsLocal),
      onlineAskAPerson: Value(a.askAPerson),
      onlineCaveat: Value(a.caveat),
      onlineAt: Value(DateTime.now()),
    ));
  }

  /// Stores Claude's reading of a photograph the on-device model could not
  /// place, and promotes it onto the scan itself so the history stops saying
  /// "Unknown crop".
  Future<void> attachOnlineIdentification(
      String scanId, OnlineIdentification id) async {
    await (_db.update(_db.cropScans)..where((t) => t.id.equals(scanId)))
        .write(CropScansCompanion(
      onlineCrop: Value(id.crop),
      onlineCondition: Value(id.condition),
      onlineConfidence: Value(id.confidence),
      onlineSummary: Value(id.summary),
      onlineActionsJson: Value(jsonEncode(id.actions)),
      onlineModel: Value(id.model),
      onlineAskAPerson: Value(id.askAPerson),
      onlineCaveat: Value(id.caveat),
      onlineAt: Value(DateTime.now()),
    ));
    await _sync.enqueue(
      entityType: 'scan',
      entityId: scanId,
      operation: 'update',
      payload: {'onlineCrop': id.crop, 'onlineCondition': id.condition},
    );
  }

  /// The stored identification for a scan, or null if there is none.
  Future<OnlineIdentification?> onlineIdentificationFor(String scanId) async {
    final row = await (_db.select(_db.cropScans)
          ..where((t) => t.id.equals(scanId)))
        .getSingleOrNull();
    if (row == null || row.onlineCrop == null) return null;
    return OnlineIdentification(
      model: row.onlineModel ?? 'claude',
      crop: row.onlineCrop!,
      condition: row.onlineCondition ?? '',
      summary: row.onlineSummary ?? '',
      actions: ((jsonDecode(row.onlineActionsJson ?? '[]') as List?) ?? [])
          .cast<String>(),
      confidence: row.onlineConfidence ?? 'low',
      askAPerson: row.onlineAskAPerson ?? true,
      caveat: row.onlineCaveat ?? '',
      elapsedMs: 0,
    );
  }

  /// The stored online analysis for a scan, or null if there is none yet.
  Future<OnlineAnalysis?> onlineAnalysisFor(String scanId) async {
    final row = await (_db.select(_db.cropScans)
          ..where((t) => t.id.equals(scanId)))
        .getSingleOrNull();
    if (row == null || row.onlineSummary == null) return null;
    return OnlineAnalysis(
      model: row.onlineModel ?? 'claude',
      summary: row.onlineSummary!,
      confirmsLocal: row.onlineConfirms ?? false,
      actions: ((jsonDecode(row.onlineActionsJson ?? '[]') as List?) ?? [])
          .cast<String>(),
      askAPerson: row.onlineAskAPerson ?? false,
      caveat: row.onlineCaveat ?? '',
      elapsedMs: 0,
    );
  }

  Future<void> markSavedToFarm(String id) async {
    await _db.scanDao.markSaved(id, pendingSync: true);
    await _sync.enqueue(entityType: 'scan', entityId: id, operation: 'update', payload: {
      'savedToFarm': true,
    });
  }

  Future<int> count() => _db.scanDao.count();

  static ScanResult fromRow(CropScanRow r) {
    List<RecommendedAction> actions;
    try {
      actions = (jsonDecode(r.actionsJson) as List)
          .map((e) => RecommendedAction(
                title: (e as Map)['title'].toString(),
                detail: (e['detail'] ?? '').toString(),
              ))
          .toList();
    } catch (_) {
      actions = const [];
    }
    // Prefer Claude's identification when the on-device model could not place
    // the photo, so the history does not keep saying "Unknown crop".
    final unknownLocally = r.cropName.toLowerCase().startsWith('unknown');
    return ScanResult(
      id: r.id,
      cropName: unknownLocally && r.onlineCrop != null
          ? r.onlineCrop!
          : r.cropName,
      imageAsset: r.imagePath,
      issue: unknownLocally && r.onlineCondition != null
          ? r.onlineCondition!
          : r.issueLabel,
      confidence: r.confidence,
      severity: r.severity,
      affectedArea: r.affectedArea,
      growthStage: r.growthStage,
      scannedAt: r.createdAt,
      explanation: r.explanation,
      actions: actions,
      status: HealthStatus.values.byName(r.status),
      engine: r.engine,
      savedToFarm: r.savedToFarm,
      pendingSync: r.pendingSync,
      modelName: r.modelName,
      inferenceTimeMs: r.inferenceTimeMs,
      conditionId: r.condition,
      margin: r.margin,
      runnerUp: r.runnerUp,
    );
  }
}
