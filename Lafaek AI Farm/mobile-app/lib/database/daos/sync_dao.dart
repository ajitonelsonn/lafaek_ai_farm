import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/ai_tables.dart';

part 'sync_dao.g.dart';

/// Offline outbox. Upload to the cloud is intentionally not implemented in
/// this phase; the queue only records, retries and reports locally.
@DriftAccessor(tables: [SyncQueue])
class SyncDao extends DatabaseAccessor<AppDatabase> with _$SyncDaoMixin {
  SyncDao(super.db);

  Future<int> enqueue({
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
  }) =>
      into(syncQueue).insert(SyncQueueCompanion.insert(
        entityType: entityType,
        entityId: entityId,
        operation: operation,
        payload: payload,
        createdAt: DateTime.now(),
      ));

  Future<List<SyncQueueRow>> pending({int limit = 100}) => (select(syncQueue)
        ..where((q) => q.status.isIn(['pending', 'failed']))
        ..orderBy([(q) => OrderingTerm.asc(q.createdAt)])
        ..limit(limit))
      .get();

  Future<List<SyncQueueRow>> all() =>
      (select(syncQueue)..orderBy([(q) => OrderingTerm.desc(q.createdAt)]))
          .get();

  /// Pending counts grouped by entity type, for the sync status UI.
  Future<Map<String, int>> pendingCounts() async {
    final c = countAll();
    final q = selectOnly(syncQueue)
      ..addColumns([syncQueue.entityType, c])
      ..where(syncQueue.status.isIn(['pending', 'failed']))
      ..groupBy([syncQueue.entityType]);
    final rows = await q.get();
    return {
      for (final r in rows) r.read(syncQueue.entityType)!: r.read(c) ?? 0,
    };
  }

  Future<int> markSyncing(int id) =>
      (update(syncQueue)..where((q) => q.id.equals(id))).write(
        SyncQueueCompanion(
          status: const Value('syncing'),
          lastAttemptAt: Value(DateTime.now()),
        ),
      );

  Future<int> markSynced(int id) =>
      (update(syncQueue)..where((q) => q.id.equals(id)))
          .write(const SyncQueueCompanion(status: Value('synced')));

  Future<int> markFailed(int id, String error) async {
    final row = await (select(syncQueue)..where((q) => q.id.equals(id)))
        .getSingleOrNull();
    if (row == null) return 0;
    return (update(syncQueue)..where((q) => q.id.equals(id))).write(
      SyncQueueCompanion(
        status: const Value('failed'),
        attemptCount: Value(row.attemptCount + 1),
        lastAttemptAt: Value(DateTime.now()),
        errorMessage: Value(error),
      ),
    );
  }

  Future<int> clearSynced() =>
      (delete(syncQueue)..where((q) => q.status.equals('synced'))).go();
}
