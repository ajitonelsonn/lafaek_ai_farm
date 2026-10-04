import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/ai_tables.dart';

part 'scan_dao.g.dart';

@DriftAccessor(tables: [CropScans])
class ScanDao extends DatabaseAccessor<AppDatabase> with _$ScanDaoMixin {
  ScanDao(super.db);

  Future<List<CropScanRow>> recent({int limit = 50, int offset = 0}) =>
      (select(cropScans)
            ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
            ..limit(limit, offset: offset))
          .get();

  Future<List<CropScanRow>> forCrop(String cropName) => (select(cropScans)
        ..where((s) => s.cropName.equals(cropName))
        ..orderBy([(s) => OrderingTerm.desc(s.createdAt)]))
      .get();

  Future<CropScanRow?> byId(String id) =>
      (select(cropScans)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<void> upsert(CropScansCompanion row) =>
      into(cropScans).insertOnConflictUpdate(row);

  Future<int> markSaved(String id, {required bool pendingSync}) =>
      (update(cropScans)..where((s) => s.id.equals(id))).write(
        CropScansCompanion(
          savedToFarm: const Value(true),
          pendingSync: Value(pendingSync),
        ),
      );

  Future<int> markSynced(String id) =>
      (update(cropScans)..where((s) => s.id.equals(id)))
          .write(const CropScansCompanion(pendingSync: Value(false)));

  Future<int> count() async {
    final c = countAll();
    final q = selectOnly(cropScans)..addColumns([c]);
    return (await q.getSingle()).read(c) ?? 0;
  }
}
