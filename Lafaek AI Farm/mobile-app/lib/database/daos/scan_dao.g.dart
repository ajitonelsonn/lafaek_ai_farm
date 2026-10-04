// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_dao.dart';

// ignore_for_file: type=lint
mixin _$ScanDaoMixin on DatabaseAccessor<AppDatabase> {
  $CropScansTable get cropScans => attachedDatabase.cropScans;
  ScanDaoManager get managers => ScanDaoManager(this);
}

class ScanDaoManager {
  final _$ScanDaoMixin _db;
  ScanDaoManager(this._db);
  $$CropScansTableTableManager get cropScans =>
      $$CropScansTableTableManager(_db.attachedDatabase, _db.cropScans);
}
