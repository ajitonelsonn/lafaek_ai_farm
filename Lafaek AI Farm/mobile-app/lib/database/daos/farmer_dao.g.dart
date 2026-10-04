// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farmer_dao.dart';

// ignore_for_file: type=lint
mixin _$FarmerDaoMixin on DatabaseAccessor<AppDatabase> {
  $FarmersTable get farmers => attachedDatabase.farmers;
  FarmerDaoManager get managers => FarmerDaoManager(this);
}

class FarmerDaoManager {
  final _$FarmerDaoMixin _db;
  FarmerDaoManager(this._db);
  $$FarmersTableTableManager get farmers =>
      $$FarmersTableTableManager(_db.attachedDatabase, _db.farmers);
}
