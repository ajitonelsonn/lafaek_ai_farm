// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farm_dao.dart';

// ignore_for_file: type=lint
mixin _$FarmDaoMixin on DatabaseAccessor<AppDatabase> {
  $FarmersTable get farmers => attachedDatabase.farmers;
  $FarmsTable get farms => attachedDatabase.farms;
  $FarmLocationsTable get farmLocations => attachedDatabase.farmLocations;
  $FarmActivitiesTable get farmActivities => attachedDatabase.farmActivities;
  $RecommendationsTable get recommendations => attachedDatabase.recommendations;
  $AlertsTable get alerts => attachedDatabase.alerts;
  FarmDaoManager get managers => FarmDaoManager(this);
}

class FarmDaoManager {
  final _$FarmDaoMixin _db;
  FarmDaoManager(this._db);
  $$FarmersTableTableManager get farmers =>
      $$FarmersTableTableManager(_db.attachedDatabase, _db.farmers);
  $$FarmsTableTableManager get farms =>
      $$FarmsTableTableManager(_db.attachedDatabase, _db.farms);
  $$FarmLocationsTableTableManager get farmLocations =>
      $$FarmLocationsTableTableManager(_db.attachedDatabase, _db.farmLocations);
  $$FarmActivitiesTableTableManager get farmActivities =>
      $$FarmActivitiesTableTableManager(
          _db.attachedDatabase, _db.farmActivities);
  $$RecommendationsTableTableManager get recommendations =>
      $$RecommendationsTableTableManager(
          _db.attachedDatabase, _db.recommendations);
  $$AlertsTableTableManager get alerts =>
      $$AlertsTableTableManager(_db.attachedDatabase, _db.alerts);
}
