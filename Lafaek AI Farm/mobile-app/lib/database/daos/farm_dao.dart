import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/farm_tables.dart';

part 'farm_dao.g.dart';

@DriftAccessor(tables: [Farms, FarmLocations, FarmActivities, Recommendations, Alerts])
class FarmDao extends DatabaseAccessor<AppDatabase> with _$FarmDaoMixin {
  FarmDao(super.db);

  // ---- Farms ----
  Future<FarmRow?> getFarm() => (select(farms)..limit(1)).getSingleOrNull();

  Future<void> insertFarm(FarmsCompanion row) =>
      into(farms).insertOnConflictUpdate(row);

  // ---- Locations ----
  Future<List<FarmLocationRow>> listLocations(String farmId) =>
      (select(farmLocations)
            ..where((l) => l.farmId.equals(farmId))
            ..orderBy([(l) => OrderingTerm.asc(l.createdAt)]))
          .get();

  Future<void> insertLocation(FarmLocationsCompanion row) =>
      into(farmLocations).insert(row);

  // ---- Activities ----
  Future<List<FarmActivityRow>> listActivities(String farmId,
          {int limit = 50, int offset = 0}) =>
      (select(farmActivities)
            ..where((a) => a.farmId.equals(farmId))
            ..orderBy([(a) => OrderingTerm.desc(a.date)])
            ..limit(limit, offset: offset))
          .get();

  Future<List<FarmActivityRow>> activitiesForCrop(String cropName) =>
      (select(farmActivities)
            ..where((a) => a.cropName.equals(cropName))
            ..orderBy([(a) => OrderingTerm.desc(a.date)]))
          .get();

  Future<void> insertActivity(FarmActivitiesCompanion row) =>
      into(farmActivities).insert(row);

  // ---- Recommendations ----
  Future<List<RecommendationRow>> listRecommendations() => (select(recommendations)
        ..where((r) => r.dismissed.equals(false))
        ..orderBy([(r) => OrderingTerm.asc(r.createdAt)]))
      .get();

  Future<void> insertRecommendation(RecommendationsCompanion row) =>
      into(recommendations).insertOnConflictUpdate(row);

  Future<void> replaceRecommendations(List<RecommendationsCompanion> rows) =>
      transaction(() async {
        await delete(recommendations).go();
        for (final r in rows) {
          await into(recommendations).insert(r);
        }
      });

  // ---- Alerts ----
  Future<List<AlertRow>> listAlerts() =>
      (select(alerts)..orderBy([(a) => OrderingTerm.desc(a.date)])).get();

  Future<void> insertAlert(AlertsCompanion row) =>
      into(alerts).insertOnConflictUpdate(row);

  Future<void> markAlertRead(String id) =>
      (update(alerts)..where((a) => a.id.equals(id)))
          .write(const AlertsCompanion(read: Value(true)));

  Future<void> markAllAlertsRead() =>
      update(alerts).write(const AlertsCompanion(read: Value(true)));
}
