// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crop_dao.dart';

// ignore_for_file: type=lint
mixin _$CropDaoMixin on DatabaseAccessor<AppDatabase> {
  $FarmersTable get farmers => attachedDatabase.farmers;
  $FarmsTable get farms => attachedDatabase.farms;
  $CropsTable get crops => attachedDatabase.crops;
  CropDaoManager get managers => CropDaoManager(this);
}

class CropDaoManager {
  final _$CropDaoMixin _db;
  CropDaoManager(this._db);
  $$FarmersTableTableManager get farmers =>
      $$FarmersTableTableManager(_db.attachedDatabase, _db.farmers);
  $$FarmsTableTableManager get farms =>
      $$FarmsTableTableManager(_db.attachedDatabase, _db.farms);
  $$CropsTableTableManager get crops =>
      $$CropsTableTableManager(_db.attachedDatabase, _db.crops);
}
