import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/farm_tables.dart';

part 'farmer_dao.g.dart';

@DriftAccessor(tables: [Farmers])
class FarmerDao extends DatabaseAccessor<AppDatabase> with _$FarmerDaoMixin {
  FarmerDao(super.db);

  Future<FarmerRow?> getFarmer() =>
      (select(farmers)..limit(1)).getSingleOrNull();

  Stream<FarmerRow?> watchFarmer() =>
      (select(farmers)..limit(1)).watchSingleOrNull();

  Future<void> upsert(FarmersCompanion row) =>
      into(farmers).insertOnConflictUpdate(row);

  Future<int> updateProfile({
    required String id,
    String? name,
    String? location,
    String? phone,
    double? farmingYears,
  }) {
    return (update(farmers)..where((f) => f.id.equals(id))).write(
      FarmersCompanion(
        name: name == null ? const Value.absent() : Value(name),
        location: location == null ? const Value.absent() : Value(location),
        phone: phone == null ? const Value.absent() : Value(phone),
        farmingYears:
            farmingYears == null ? const Value.absent() : Value(farmingYears),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
