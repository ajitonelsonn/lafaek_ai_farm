import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/farm_tables.dart';

part 'crop_dao.g.dart';

@DriftAccessor(tables: [Crops])
class CropDao extends DatabaseAccessor<AppDatabase> with _$CropDaoMixin {
  CropDao(super.db);

  Future<List<CropRow>> all(String farmId) => (select(crops)
        ..where((c) => c.farmId.equals(farmId))
        ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
      .get();

  Future<CropRow?> byId(String id) =>
      (select(crops)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<CropRow?> byName(String name) =>
      (select(crops)..where((c) => c.name.equals(name))..limit(1))
          .getSingleOrNull();

  Future<void> insert(CropsCompanion row) => into(crops).insert(row);

  Future<int> updateStatus(String id, String status, {String? note}) =>
      (update(crops)..where((c) => c.id.equals(id))).write(CropsCompanion(
        status: Value(status),
        note: note == null ? const Value.absent() : Value(note),
        updatedAt: Value(DateTime.now()),
      ));

  Future<int> updateStatusByName(String name, String status) =>
      (update(crops)..where((c) => c.name.equals(name))).write(CropsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ));

  Future<int> remove(String id) =>
      (delete(crops)..where((c) => c.id.equals(id))).go();
}
