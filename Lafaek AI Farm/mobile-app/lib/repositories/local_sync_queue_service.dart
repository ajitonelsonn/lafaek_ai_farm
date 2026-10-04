import 'dart:convert';

import '../database/app_database.dart';
import '../models/models.dart';
import '../services/farm_services.dart';

/// Offline outbox backed by the `sync_queue` table (spec §3).
///
/// In this phase nothing is uploaded: [sync] walks the pending rows, marks
/// them `syncing` and then back to `pending` with a note, so the queue, the
/// retry counter and the status UI all work end-to-end without a server.
/// The cloud phase will replace [_upload] with a real API call.
class LocalSyncQueueService implements SyncService {
  LocalSyncQueueService(this._db, {this.uploadEnabled = false});

  final AppDatabase _db;

  /// Stays false until the AWS phase. When false, [sync] performs a dry run.
  final bool uploadEnabled;

  Future<int> enqueue({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) =>
      _db.syncDao.enqueue(
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        payload: jsonEncode(payload),
      );

  Future<List<SyncQueueRow>> pending() => _db.syncDao.pending();
  Future<List<SyncQueueRow>> all() => _db.syncDao.all();

  /// Pending counts as [SyncItem]s for the existing sync UI.
  Future<List<SyncItem>> pendingItems() async {
    final counts = await _db.syncDao.pendingCounts();
    return [
      for (final e in counts.entries) SyncItem(label: _label(e.key, e.value), count: e.value),
    ];
  }

  Future<int> pendingCount() async {
    final counts = await _db.syncDao.pendingCounts();
    return counts.values.fold<int>(0, (a, b) => a + b);
  }

  /// [SyncService] implementation used by ConnectivityState. Streams one
  /// [SyncItem] per entity type as it is processed.
  @override
  Stream<SyncItem> sync(List<SyncItem> _) async* {
    final rows = await _db.syncDao.pending();
    final byType = <String, List<SyncQueueRow>>{};
    for (final r in rows) {
      byType.putIfAbsent(r.entityType, () => []).add(r);
    }
    for (final e in byType.entries) {
      var ok = 0;
      for (final r in e.value) {
        await _db.syncDao.markSyncing(r.id);
        final result = await _upload(r);
        if (result == null) {
          await _db.syncDao.markSynced(r.id);
          ok++;
        } else {
          await _db.syncDao.markFailed(r.id, result);
        }
      }
      yield SyncItem(label: _label(e.key, ok), count: ok);
    }
  }

  /// Returns null on success or an error message. No network in this phase.
  Future<String?> _upload(SyncQueueRow r) async {
    if (!uploadEnabled) {
      return 'Cloud upload not enabled in the local-first phase';
    }
    return 'Cloud API not configured';
  }

  Future<int> clearSynced() => _db.syncDao.clearSynced();

  static String _label(String type, int n) {
    switch (type) {
      case 'scan':
        return n == 1 ? 'crop scan' : 'crop scans';
      case 'chat':
        return n == 1 ? 'AI conversation' : 'AI conversations';
      case 'crop':
        return n == 1 ? 'crop record' : 'crop records';
      case 'activity':
        return n == 1 ? 'activity' : 'activities';
      case 'location':
        return n == 1 ? 'location' : 'locations';
      default:
        return n == 1 ? 'farm record' : 'farm records';
    }
  }
}
