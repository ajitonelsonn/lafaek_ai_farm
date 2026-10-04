// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FarmersTable extends Farmers with TableInfo<$FarmersTable, FarmerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmingYearsMeta =
      const VerificationMeta('farmingYears');
  @override
  late final GeneratedColumn<double> farmingYears = GeneratedColumn<double>(
      'farming_years', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, location, farmingYears, phone, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farmers';
  @override
  VerificationContext validateIntegrity(Insertable<FarmerRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('farming_years')) {
      context.handle(
          _farmingYearsMeta,
          farmingYears.isAcceptableOrUnknown(
              data['farming_years']!, _farmingYearsMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmerRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location'])!,
      farmingYears: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}farming_years'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FarmersTable createAlias(String alias) {
    return $FarmersTable(attachedDatabase, alias);
  }
}

class FarmerRow extends DataClass implements Insertable<FarmerRow> {
  final String id;
  final String name;
  final String location;
  final double farmingYears;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FarmerRow(
      {required this.id,
      required this.name,
      required this.location,
      required this.farmingYears,
      this.phone,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['location'] = Variable<String>(location);
    map['farming_years'] = Variable<double>(farmingYears);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FarmersCompanion toCompanion(bool nullToAbsent) {
    return FarmersCompanion(
      id: Value(id),
      name: Value(name),
      location: Value(location),
      farmingYears: Value(farmingYears),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FarmerRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmerRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String>(json['location']),
      farmingYears: serializer.fromJson<double>(json['farmingYears']),
      phone: serializer.fromJson<String?>(json['phone']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String>(location),
      'farmingYears': serializer.toJson<double>(farmingYears),
      'phone': serializer.toJson<String?>(phone),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FarmerRow copyWith(
          {String? id,
          String? name,
          String? location,
          double? farmingYears,
          Value<String?> phone = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      FarmerRow(
        id: id ?? this.id,
        name: name ?? this.name,
        location: location ?? this.location,
        farmingYears: farmingYears ?? this.farmingYears,
        phone: phone.present ? phone.value : this.phone,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FarmerRow copyWithCompanion(FarmersCompanion data) {
    return FarmerRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      farmingYears: data.farmingYears.present
          ? data.farmingYears.value
          : this.farmingYears,
      phone: data.phone.present ? data.phone.value : this.phone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmerRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('farmingYears: $farmingYears, ')
          ..write('phone: $phone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, location, farmingYears, phone, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmerRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.location == this.location &&
          other.farmingYears == this.farmingYears &&
          other.phone == this.phone &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FarmersCompanion extends UpdateCompanion<FarmerRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> location;
  final Value<double> farmingYears;
  final Value<String?> phone;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FarmersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.farmingYears = const Value.absent(),
    this.phone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmersCompanion.insert({
    required String id,
    required String name,
    required String location,
    this.farmingYears = const Value.absent(),
    this.phone = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        location = Value(location),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<FarmerRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? location,
    Expression<double>? farmingYears,
    Expression<String>? phone,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (farmingYears != null) 'farming_years': farmingYears,
      if (phone != null) 'phone': phone,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? location,
      Value<double>? farmingYears,
      Value<String?>? phone,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return FarmersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      farmingYears: farmingYears ?? this.farmingYears,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (farmingYears.present) {
      map['farming_years'] = Variable<double>(farmingYears.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('farmingYears: $farmingYears, ')
          ..write('phone: $phone, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FarmsTable extends Farms with TableInfo<$FarmsTable, FarmRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmerIdMeta =
      const VerificationMeta('farmerId');
  @override
  late final GeneratedColumn<String> farmerId = GeneratedColumn<String>(
      'farmer_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES farmers (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, farmerId, name, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farms';
  @override
  VerificationContext validateIntegrity(Insertable<FarmRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farmer_id')) {
      context.handle(_farmerIdMeta,
          farmerId.isAcceptableOrUnknown(data['farmer_id']!, _farmerIdMeta));
    } else if (isInserting) {
      context.missing(_farmerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farmer_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FarmsTable createAlias(String alias) {
    return $FarmsTable(attachedDatabase, alias);
  }
}

class FarmRow extends DataClass implements Insertable<FarmRow> {
  final String id;
  final String farmerId;
  final String name;
  final DateTime createdAt;
  const FarmRow(
      {required this.id,
      required this.farmerId,
      required this.name,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farmer_id'] = Variable<String>(farmerId);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FarmsCompanion toCompanion(bool nullToAbsent) {
    return FarmsCompanion(
      id: Value(id),
      farmerId: Value(farmerId),
      name: Value(name),
      createdAt: Value(createdAt),
    );
  }

  factory FarmRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmRow(
      id: serializer.fromJson<String>(json['id']),
      farmerId: serializer.fromJson<String>(json['farmerId']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmerId': serializer.toJson<String>(farmerId),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FarmRow copyWith(
          {String? id, String? farmerId, String? name, DateTime? createdAt}) =>
      FarmRow(
        id: id ?? this.id,
        farmerId: farmerId ?? this.farmerId,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
      );
  FarmRow copyWithCompanion(FarmsCompanion data) {
    return FarmRow(
      id: data.id.present ? data.id.value : this.id,
      farmerId: data.farmerId.present ? data.farmerId.value : this.farmerId,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmRow(')
          ..write('id: $id, ')
          ..write('farmerId: $farmerId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, farmerId, name, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmRow &&
          other.id == this.id &&
          other.farmerId == this.farmerId &&
          other.name == this.name &&
          other.createdAt == this.createdAt);
}

class FarmsCompanion extends UpdateCompanion<FarmRow> {
  final Value<String> id;
  final Value<String> farmerId;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FarmsCompanion({
    this.id = const Value.absent(),
    this.farmerId = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmsCompanion.insert({
    required String id,
    required String farmerId,
    required String name,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        farmerId = Value(farmerId),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<FarmRow> custom({
    Expression<String>? id,
    Expression<String>? farmerId,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmerId != null) 'farmer_id': farmerId,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmsCompanion copyWith(
      {Value<String>? id,
      Value<String>? farmerId,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return FarmsCompanion(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmerId.present) {
      map['farmer_id'] = Variable<String>(farmerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmsCompanion(')
          ..write('id: $id, ')
          ..write('farmerId: $farmerId, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FarmLocationsTable extends FarmLocations
    with TableInfo<$FarmLocationsTable, FarmLocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES farms (id)'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _areaHaMeta = const VerificationMeta('areaHa');
  @override
  late final GeneratedColumn<double> areaHa = GeneratedColumn<double>(
      'area_ha', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _districtMeta =
      const VerificationMeta('district');
  @override
  late final GeneratedColumn<String> district = GeneratedColumn<String>(
      'district', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _latitudeMeta =
      const VerificationMeta('latitude');
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
      'latitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _longitudeMeta =
      const VerificationMeta('longitude');
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
      'longitude', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, farmId, name, areaHa, district, latitude, longitude, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farm_locations';
  @override
  VerificationContext validateIntegrity(Insertable<FarmLocationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('area_ha')) {
      context.handle(_areaHaMeta,
          areaHa.isAcceptableOrUnknown(data['area_ha']!, _areaHaMeta));
    } else if (isInserting) {
      context.missing(_areaHaMeta);
    }
    if (data.containsKey('district')) {
      context.handle(_districtMeta,
          district.isAcceptableOrUnknown(data['district']!, _districtMeta));
    } else if (isInserting) {
      context.missing(_districtMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(_latitudeMeta,
          latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta));
    }
    if (data.containsKey('longitude')) {
      context.handle(_longitudeMeta,
          longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmLocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmLocationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      areaHa: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}area_ha'])!,
      district: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}district'])!,
      latitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}latitude']),
      longitude: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}longitude']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FarmLocationsTable createAlias(String alias) {
    return $FarmLocationsTable(attachedDatabase, alias);
  }
}

class FarmLocationRow extends DataClass implements Insertable<FarmLocationRow> {
  final String id;
  final String farmId;
  final String name;
  final double areaHa;
  final String district;
  final double? latitude;
  final double? longitude;
  final DateTime createdAt;
  const FarmLocationRow(
      {required this.id,
      required this.farmId,
      required this.name,
      required this.areaHa,
      required this.district,
      this.latitude,
      this.longitude,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    map['name'] = Variable<String>(name);
    map['area_ha'] = Variable<double>(areaHa);
    map['district'] = Variable<String>(district);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FarmLocationsCompanion toCompanion(bool nullToAbsent) {
    return FarmLocationsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      name: Value(name),
      areaHa: Value(areaHa),
      district: Value(district),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      createdAt: Value(createdAt),
    );
  }

  factory FarmLocationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmLocationRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      name: serializer.fromJson<String>(json['name']),
      areaHa: serializer.fromJson<double>(json['areaHa']),
      district: serializer.fromJson<String>(json['district']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'name': serializer.toJson<String>(name),
      'areaHa': serializer.toJson<double>(areaHa),
      'district': serializer.toJson<String>(district),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FarmLocationRow copyWith(
          {String? id,
          String? farmId,
          String? name,
          double? areaHa,
          String? district,
          Value<double?> latitude = const Value.absent(),
          Value<double?> longitude = const Value.absent(),
          DateTime? createdAt}) =>
      FarmLocationRow(
        id: id ?? this.id,
        farmId: farmId ?? this.farmId,
        name: name ?? this.name,
        areaHa: areaHa ?? this.areaHa,
        district: district ?? this.district,
        latitude: latitude.present ? latitude.value : this.latitude,
        longitude: longitude.present ? longitude.value : this.longitude,
        createdAt: createdAt ?? this.createdAt,
      );
  FarmLocationRow copyWithCompanion(FarmLocationsCompanion data) {
    return FarmLocationRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      name: data.name.present ? data.name.value : this.name,
      areaHa: data.areaHa.present ? data.areaHa.value : this.areaHa,
      district: data.district.present ? data.district.value : this.district,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmLocationRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('areaHa: $areaHa, ')
          ..write('district: $district, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, farmId, name, areaHa, district, latitude, longitude, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmLocationRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.name == this.name &&
          other.areaHa == this.areaHa &&
          other.district == this.district &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.createdAt == this.createdAt);
}

class FarmLocationsCompanion extends UpdateCompanion<FarmLocationRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String> name;
  final Value<double> areaHa;
  final Value<String> district;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FarmLocationsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.name = const Value.absent(),
    this.areaHa = const Value.absent(),
    this.district = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmLocationsCompanion.insert({
    required String id,
    required String farmId,
    required String name,
    required double areaHa,
    required String district,
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        farmId = Value(farmId),
        name = Value(name),
        areaHa = Value(areaHa),
        district = Value(district),
        createdAt = Value(createdAt);
  static Insertable<FarmLocationRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? name,
    Expression<double>? areaHa,
    Expression<String>? district,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (name != null) 'name': name,
      if (areaHa != null) 'area_ha': areaHa,
      if (district != null) 'district': district,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmLocationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? farmId,
      Value<String>? name,
      Value<double>? areaHa,
      Value<String>? district,
      Value<double?>? latitude,
      Value<double?>? longitude,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return FarmLocationsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      areaHa: areaHa ?? this.areaHa,
      district: district ?? this.district,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (areaHa.present) {
      map['area_ha'] = Variable<double>(areaHa.value);
    }
    if (district.present) {
      map['district'] = Variable<String>(district.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmLocationsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('name: $name, ')
          ..write('areaHa: $areaHa, ')
          ..write('district: $district, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CropsTable extends Crops with TableInfo<$CropsTable, CropRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CropsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES farms (id)'));
  static const VerificationMeta _locationIdMeta =
      const VerificationMeta('locationId');
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
      'location_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationNameMeta =
      const VerificationMeta('locationName');
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
      'location_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _varietyMeta =
      const VerificationMeta('variety');
  @override
  late final GeneratedColumn<String> variety = GeneratedColumn<String>(
      'variety', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _areaHaMeta = const VerificationMeta('areaHa');
  @override
  late final GeneratedColumn<double> areaHa = GeneratedColumn<double>(
      'area_ha', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('healthy'));
  static const VerificationMeta _growthStageMeta =
      const VerificationMeta('growthStage');
  @override
  late final GeneratedColumn<String> growthStage = GeneratedColumn<String>(
      'growth_stage', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Vegetative'));
  static const VerificationMeta _plantedOnMeta =
      const VerificationMeta('plantedOn');
  @override
  late final GeneratedColumn<DateTime> plantedOn = GeneratedColumn<DateTime>(
      'planted_on', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        farmId,
        locationId,
        locationName,
        name,
        variety,
        areaHa,
        status,
        growthStage,
        plantedOn,
        note,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crops';
  @override
  VerificationContext validateIntegrity(Insertable<CropRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('location_id')) {
      context.handle(
          _locationIdMeta,
          locationId.isAcceptableOrUnknown(
              data['location_id']!, _locationIdMeta));
    }
    if (data.containsKey('location_name')) {
      context.handle(
          _locationNameMeta,
          locationName.isAcceptableOrUnknown(
              data['location_name']!, _locationNameMeta));
    } else if (isInserting) {
      context.missing(_locationNameMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('variety')) {
      context.handle(_varietyMeta,
          variety.isAcceptableOrUnknown(data['variety']!, _varietyMeta));
    }
    if (data.containsKey('area_ha')) {
      context.handle(_areaHaMeta,
          areaHa.isAcceptableOrUnknown(data['area_ha']!, _areaHaMeta));
    } else if (isInserting) {
      context.missing(_areaHaMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('growth_stage')) {
      context.handle(
          _growthStageMeta,
          growthStage.isAcceptableOrUnknown(
              data['growth_stage']!, _growthStageMeta));
    }
    if (data.containsKey('planted_on')) {
      context.handle(_plantedOnMeta,
          plantedOn.isAcceptableOrUnknown(data['planted_on']!, _plantedOnMeta));
    } else if (isInserting) {
      context.missing(_plantedOnMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CropRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CropRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id'])!,
      locationId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_id']),
      locationName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_name'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      variety: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}variety']),
      areaHa: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}area_ha'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      growthStage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}growth_stage'])!,
      plantedOn: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}planted_on'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CropsTable createAlias(String alias) {
    return $CropsTable(attachedDatabase, alias);
  }
}

class CropRow extends DataClass implements Insertable<CropRow> {
  final String id;
  final String farmId;
  final String? locationId;
  final String locationName;
  final String name;
  final String? variety;
  final double areaHa;

  /// `healthy` | `monitor` | `atRisk` — matches [HealthStatus.name].
  final String status;
  final String growthStage;
  final DateTime plantedOn;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CropRow(
      {required this.id,
      required this.farmId,
      this.locationId,
      required this.locationName,
      required this.name,
      this.variety,
      required this.areaHa,
      required this.status,
      required this.growthStage,
      required this.plantedOn,
      this.note,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<String>(locationId);
    }
    map['location_name'] = Variable<String>(locationName);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || variety != null) {
      map['variety'] = Variable<String>(variety);
    }
    map['area_ha'] = Variable<double>(areaHa);
    map['status'] = Variable<String>(status);
    map['growth_stage'] = Variable<String>(growthStage);
    map['planted_on'] = Variable<DateTime>(plantedOn);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CropsCompanion toCompanion(bool nullToAbsent) {
    return CropsCompanion(
      id: Value(id),
      farmId: Value(farmId),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      locationName: Value(locationName),
      name: Value(name),
      variety: variety == null && nullToAbsent
          ? const Value.absent()
          : Value(variety),
      areaHa: Value(areaHa),
      status: Value(status),
      growthStage: Value(growthStage),
      plantedOn: Value(plantedOn),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CropRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CropRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      locationId: serializer.fromJson<String?>(json['locationId']),
      locationName: serializer.fromJson<String>(json['locationName']),
      name: serializer.fromJson<String>(json['name']),
      variety: serializer.fromJson<String?>(json['variety']),
      areaHa: serializer.fromJson<double>(json['areaHa']),
      status: serializer.fromJson<String>(json['status']),
      growthStage: serializer.fromJson<String>(json['growthStage']),
      plantedOn: serializer.fromJson<DateTime>(json['plantedOn']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'locationId': serializer.toJson<String?>(locationId),
      'locationName': serializer.toJson<String>(locationName),
      'name': serializer.toJson<String>(name),
      'variety': serializer.toJson<String?>(variety),
      'areaHa': serializer.toJson<double>(areaHa),
      'status': serializer.toJson<String>(status),
      'growthStage': serializer.toJson<String>(growthStage),
      'plantedOn': serializer.toJson<DateTime>(plantedOn),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CropRow copyWith(
          {String? id,
          String? farmId,
          Value<String?> locationId = const Value.absent(),
          String? locationName,
          String? name,
          Value<String?> variety = const Value.absent(),
          double? areaHa,
          String? status,
          String? growthStage,
          DateTime? plantedOn,
          Value<String?> note = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CropRow(
        id: id ?? this.id,
        farmId: farmId ?? this.farmId,
        locationId: locationId.present ? locationId.value : this.locationId,
        locationName: locationName ?? this.locationName,
        name: name ?? this.name,
        variety: variety.present ? variety.value : this.variety,
        areaHa: areaHa ?? this.areaHa,
        status: status ?? this.status,
        growthStage: growthStage ?? this.growthStage,
        plantedOn: plantedOn ?? this.plantedOn,
        note: note.present ? note.value : this.note,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CropRow copyWithCompanion(CropsCompanion data) {
    return CropRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      locationId:
          data.locationId.present ? data.locationId.value : this.locationId,
      locationName: data.locationName.present
          ? data.locationName.value
          : this.locationName,
      name: data.name.present ? data.name.value : this.name,
      variety: data.variety.present ? data.variety.value : this.variety,
      areaHa: data.areaHa.present ? data.areaHa.value : this.areaHa,
      status: data.status.present ? data.status.value : this.status,
      growthStage:
          data.growthStage.present ? data.growthStage.value : this.growthStage,
      plantedOn: data.plantedOn.present ? data.plantedOn.value : this.plantedOn,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CropRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('locationId: $locationId, ')
          ..write('locationName: $locationName, ')
          ..write('name: $name, ')
          ..write('variety: $variety, ')
          ..write('areaHa: $areaHa, ')
          ..write('status: $status, ')
          ..write('growthStage: $growthStage, ')
          ..write('plantedOn: $plantedOn, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      farmId,
      locationId,
      locationName,
      name,
      variety,
      areaHa,
      status,
      growthStage,
      plantedOn,
      note,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CropRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.locationId == this.locationId &&
          other.locationName == this.locationName &&
          other.name == this.name &&
          other.variety == this.variety &&
          other.areaHa == this.areaHa &&
          other.status == this.status &&
          other.growthStage == this.growthStage &&
          other.plantedOn == this.plantedOn &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CropsCompanion extends UpdateCompanion<CropRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String?> locationId;
  final Value<String> locationName;
  final Value<String> name;
  final Value<String?> variety;
  final Value<double> areaHa;
  final Value<String> status;
  final Value<String> growthStage;
  final Value<DateTime> plantedOn;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CropsCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.locationId = const Value.absent(),
    this.locationName = const Value.absent(),
    this.name = const Value.absent(),
    this.variety = const Value.absent(),
    this.areaHa = const Value.absent(),
    this.status = const Value.absent(),
    this.growthStage = const Value.absent(),
    this.plantedOn = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CropsCompanion.insert({
    required String id,
    required String farmId,
    this.locationId = const Value.absent(),
    required String locationName,
    required String name,
    this.variety = const Value.absent(),
    required double areaHa,
    this.status = const Value.absent(),
    this.growthStage = const Value.absent(),
    required DateTime plantedOn,
    this.note = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        farmId = Value(farmId),
        locationName = Value(locationName),
        name = Value(name),
        areaHa = Value(areaHa),
        plantedOn = Value(plantedOn),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CropRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? locationId,
    Expression<String>? locationName,
    Expression<String>? name,
    Expression<String>? variety,
    Expression<double>? areaHa,
    Expression<String>? status,
    Expression<String>? growthStage,
    Expression<DateTime>? plantedOn,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (locationId != null) 'location_id': locationId,
      if (locationName != null) 'location_name': locationName,
      if (name != null) 'name': name,
      if (variety != null) 'variety': variety,
      if (areaHa != null) 'area_ha': areaHa,
      if (status != null) 'status': status,
      if (growthStage != null) 'growth_stage': growthStage,
      if (plantedOn != null) 'planted_on': plantedOn,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CropsCompanion copyWith(
      {Value<String>? id,
      Value<String>? farmId,
      Value<String?>? locationId,
      Value<String>? locationName,
      Value<String>? name,
      Value<String?>? variety,
      Value<double>? areaHa,
      Value<String>? status,
      Value<String>? growthStage,
      Value<DateTime>? plantedOn,
      Value<String?>? note,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CropsCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      name: name ?? this.name,
      variety: variety ?? this.variety,
      areaHa: areaHa ?? this.areaHa,
      status: status ?? this.status,
      growthStage: growthStage ?? this.growthStage,
      plantedOn: plantedOn ?? this.plantedOn,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (variety.present) {
      map['variety'] = Variable<String>(variety.value);
    }
    if (areaHa.present) {
      map['area_ha'] = Variable<double>(areaHa.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (growthStage.present) {
      map['growth_stage'] = Variable<String>(growthStage.value);
    }
    if (plantedOn.present) {
      map['planted_on'] = Variable<DateTime>(plantedOn.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CropsCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('locationId: $locationId, ')
          ..write('locationName: $locationName, ')
          ..write('name: $name, ')
          ..write('variety: $variety, ')
          ..write('areaHa: $areaHa, ')
          ..write('status: $status, ')
          ..write('growthStage: $growthStage, ')
          ..write('plantedOn: $plantedOn, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FarmActivitiesTable extends FarmActivities
    with TableInfo<$FarmActivitiesTable, FarmActivityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FarmActivitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _farmIdMeta = const VerificationMeta('farmId');
  @override
  late final GeneratedColumn<String> farmId = GeneratedColumn<String>(
      'farm_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES farms (id)'));
  static const VerificationMeta _cropIdMeta = const VerificationMeta('cropId');
  @override
  late final GeneratedColumn<String> cropId = GeneratedColumn<String>(
      'crop_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cropNameMeta =
      const VerificationMeta('cropName');
  @override
  late final GeneratedColumn<String> cropName = GeneratedColumn<String>(
      'crop_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
      'detail', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, farmId, cropId, cropName, type, title, detail, date, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'farm_activities';
  @override
  VerificationContext validateIntegrity(Insertable<FarmActivityRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('farm_id')) {
      context.handle(_farmIdMeta,
          farmId.isAcceptableOrUnknown(data['farm_id']!, _farmIdMeta));
    } else if (isInserting) {
      context.missing(_farmIdMeta);
    }
    if (data.containsKey('crop_id')) {
      context.handle(_cropIdMeta,
          cropId.isAcceptableOrUnknown(data['crop_id']!, _cropIdMeta));
    }
    if (data.containsKey('crop_name')) {
      context.handle(_cropNameMeta,
          cropName.isAcceptableOrUnknown(data['crop_name']!, _cropNameMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(_detailMeta,
          detail.isAcceptableOrUnknown(data['detail']!, _detailMeta));
    } else if (isInserting) {
      context.missing(_detailMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FarmActivityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FarmActivityRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      farmId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}farm_id'])!,
      cropId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crop_id']),
      cropName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crop_name']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      detail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detail'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FarmActivitiesTable createAlias(String alias) {
    return $FarmActivitiesTable(attachedDatabase, alias);
  }
}

class FarmActivityRow extends DataClass implements Insertable<FarmActivityRow> {
  final String id;
  final String farmId;
  final String? cropId;
  final String? cropName;

  /// Matches [ActivityType.name].
  final String type;
  final String title;
  final String detail;
  final DateTime date;
  final DateTime createdAt;
  const FarmActivityRow(
      {required this.id,
      required this.farmId,
      this.cropId,
      this.cropName,
      required this.type,
      required this.title,
      required this.detail,
      required this.date,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['farm_id'] = Variable<String>(farmId);
    if (!nullToAbsent || cropId != null) {
      map['crop_id'] = Variable<String>(cropId);
    }
    if (!nullToAbsent || cropName != null) {
      map['crop_name'] = Variable<String>(cropName);
    }
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['detail'] = Variable<String>(detail);
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FarmActivitiesCompanion toCompanion(bool nullToAbsent) {
    return FarmActivitiesCompanion(
      id: Value(id),
      farmId: Value(farmId),
      cropId:
          cropId == null && nullToAbsent ? const Value.absent() : Value(cropId),
      cropName: cropName == null && nullToAbsent
          ? const Value.absent()
          : Value(cropName),
      type: Value(type),
      title: Value(title),
      detail: Value(detail),
      date: Value(date),
      createdAt: Value(createdAt),
    );
  }

  factory FarmActivityRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FarmActivityRow(
      id: serializer.fromJson<String>(json['id']),
      farmId: serializer.fromJson<String>(json['farmId']),
      cropId: serializer.fromJson<String?>(json['cropId']),
      cropName: serializer.fromJson<String?>(json['cropName']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      detail: serializer.fromJson<String>(json['detail']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'farmId': serializer.toJson<String>(farmId),
      'cropId': serializer.toJson<String?>(cropId),
      'cropName': serializer.toJson<String?>(cropName),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'detail': serializer.toJson<String>(detail),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FarmActivityRow copyWith(
          {String? id,
          String? farmId,
          Value<String?> cropId = const Value.absent(),
          Value<String?> cropName = const Value.absent(),
          String? type,
          String? title,
          String? detail,
          DateTime? date,
          DateTime? createdAt}) =>
      FarmActivityRow(
        id: id ?? this.id,
        farmId: farmId ?? this.farmId,
        cropId: cropId.present ? cropId.value : this.cropId,
        cropName: cropName.present ? cropName.value : this.cropName,
        type: type ?? this.type,
        title: title ?? this.title,
        detail: detail ?? this.detail,
        date: date ?? this.date,
        createdAt: createdAt ?? this.createdAt,
      );
  FarmActivityRow copyWithCompanion(FarmActivitiesCompanion data) {
    return FarmActivityRow(
      id: data.id.present ? data.id.value : this.id,
      farmId: data.farmId.present ? data.farmId.value : this.farmId,
      cropId: data.cropId.present ? data.cropId.value : this.cropId,
      cropName: data.cropName.present ? data.cropName.value : this.cropName,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      detail: data.detail.present ? data.detail.value : this.detail,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FarmActivityRow(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('cropId: $cropId, ')
          ..write('cropName: $cropName, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('detail: $detail, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, farmId, cropId, cropName, type, title, detail, date, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FarmActivityRow &&
          other.id == this.id &&
          other.farmId == this.farmId &&
          other.cropId == this.cropId &&
          other.cropName == this.cropName &&
          other.type == this.type &&
          other.title == this.title &&
          other.detail == this.detail &&
          other.date == this.date &&
          other.createdAt == this.createdAt);
}

class FarmActivitiesCompanion extends UpdateCompanion<FarmActivityRow> {
  final Value<String> id;
  final Value<String> farmId;
  final Value<String?> cropId;
  final Value<String?> cropName;
  final Value<String> type;
  final Value<String> title;
  final Value<String> detail;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FarmActivitiesCompanion({
    this.id = const Value.absent(),
    this.farmId = const Value.absent(),
    this.cropId = const Value.absent(),
    this.cropName = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.detail = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FarmActivitiesCompanion.insert({
    required String id,
    required String farmId,
    this.cropId = const Value.absent(),
    this.cropName = const Value.absent(),
    required String type,
    required String title,
    required String detail,
    required DateTime date,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        farmId = Value(farmId),
        type = Value(type),
        title = Value(title),
        detail = Value(detail),
        date = Value(date),
        createdAt = Value(createdAt);
  static Insertable<FarmActivityRow> custom({
    Expression<String>? id,
    Expression<String>? farmId,
    Expression<String>? cropId,
    Expression<String>? cropName,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? detail,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (farmId != null) 'farm_id': farmId,
      if (cropId != null) 'crop_id': cropId,
      if (cropName != null) 'crop_name': cropName,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (detail != null) 'detail': detail,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FarmActivitiesCompanion copyWith(
      {Value<String>? id,
      Value<String>? farmId,
      Value<String?>? cropId,
      Value<String?>? cropName,
      Value<String>? type,
      Value<String>? title,
      Value<String>? detail,
      Value<DateTime>? date,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return FarmActivitiesCompanion(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      cropId: cropId ?? this.cropId,
      cropName: cropName ?? this.cropName,
      type: type ?? this.type,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (farmId.present) {
      map['farm_id'] = Variable<String>(farmId.value);
    }
    if (cropId.present) {
      map['crop_id'] = Variable<String>(cropId.value);
    }
    if (cropName.present) {
      map['crop_name'] = Variable<String>(cropName.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FarmActivitiesCompanion(')
          ..write('id: $id, ')
          ..write('farmId: $farmId, ')
          ..write('cropId: $cropId, ')
          ..write('cropName: $cropName, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('detail: $detail, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecommendationsTable extends Recommendations
    with TableInfo<$RecommendationsTable, RecommendationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecommendationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
      'detail', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dismissedMeta =
      const VerificationMeta('dismissed');
  @override
  late final GeneratedColumn<bool> dismissed = GeneratedColumn<bool>(
      'dismissed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dismissed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, kind, title, detail, dismissed, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recommendations';
  @override
  VerificationContext validateIntegrity(Insertable<RecommendationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(_detailMeta,
          detail.isAcceptableOrUnknown(data['detail']!, _detailMeta));
    } else if (isInserting) {
      context.missing(_detailMeta);
    }
    if (data.containsKey('dismissed')) {
      context.handle(_dismissedMeta,
          dismissed.isAcceptableOrUnknown(data['dismissed']!, _dismissedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecommendationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecommendationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      detail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detail'])!,
      dismissed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dismissed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RecommendationsTable createAlias(String alias) {
    return $RecommendationsTable(attachedDatabase, alias);
  }
}

class RecommendationRow extends DataClass
    implements Insertable<RecommendationRow> {
  final String id;

  /// Matches [RecommendationKind.name].
  final String kind;
  final String title;
  final String detail;
  final bool dismissed;
  final DateTime createdAt;
  const RecommendationRow(
      {required this.id,
      required this.kind,
      required this.title,
      required this.detail,
      required this.dismissed,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['detail'] = Variable<String>(detail);
    map['dismissed'] = Variable<bool>(dismissed);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecommendationsCompanion toCompanion(bool nullToAbsent) {
    return RecommendationsCompanion(
      id: Value(id),
      kind: Value(kind),
      title: Value(title),
      detail: Value(detail),
      dismissed: Value(dismissed),
      createdAt: Value(createdAt),
    );
  }

  factory RecommendationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecommendationRow(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      detail: serializer.fromJson<String>(json['detail']),
      dismissed: serializer.fromJson<bool>(json['dismissed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'detail': serializer.toJson<String>(detail),
      'dismissed': serializer.toJson<bool>(dismissed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RecommendationRow copyWith(
          {String? id,
          String? kind,
          String? title,
          String? detail,
          bool? dismissed,
          DateTime? createdAt}) =>
      RecommendationRow(
        id: id ?? this.id,
        kind: kind ?? this.kind,
        title: title ?? this.title,
        detail: detail ?? this.detail,
        dismissed: dismissed ?? this.dismissed,
        createdAt: createdAt ?? this.createdAt,
      );
  RecommendationRow copyWithCompanion(RecommendationsCompanion data) {
    return RecommendationRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      detail: data.detail.present ? data.detail.value : this.detail,
      dismissed: data.dismissed.present ? data.dismissed.value : this.dismissed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecommendationRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('detail: $detail, ')
          ..write('dismissed: $dismissed, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, title, detail, dismissed, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecommendationRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.detail == this.detail &&
          other.dismissed == this.dismissed &&
          other.createdAt == this.createdAt);
}

class RecommendationsCompanion extends UpdateCompanion<RecommendationRow> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> detail;
  final Value<bool> dismissed;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RecommendationsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.detail = const Value.absent(),
    this.dismissed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecommendationsCompanion.insert({
    required String id,
    required String kind,
    required String title,
    required String detail,
    this.dismissed = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        kind = Value(kind),
        title = Value(title),
        detail = Value(detail),
        createdAt = Value(createdAt);
  static Insertable<RecommendationRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? detail,
    Expression<bool>? dismissed,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (detail != null) 'detail': detail,
      if (dismissed != null) 'dismissed': dismissed,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecommendationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? kind,
      Value<String>? title,
      Value<String>? detail,
      Value<bool>? dismissed,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return RecommendationsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      dismissed: dismissed ?? this.dismissed,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (dismissed.present) {
      map['dismissed'] = Variable<bool>(dismissed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecommendationsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('detail: $detail, ')
          ..write('dismissed: $dismissed, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlertsTable extends Alerts with TableInfo<$AlertsTable, AlertRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _detailMeta = const VerificationMeta('detail');
  @override
  late final GeneratedColumn<String> detail = GeneratedColumn<String>(
      'detail', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _readMeta = const VerificationMeta('read');
  @override
  late final GeneratedColumn<bool> read = GeneratedColumn<bool>(
      'read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("read" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, kind, title, detail, action, date, read];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alerts';
  @override
  VerificationContext validateIntegrity(Insertable<AlertRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('detail')) {
      context.handle(_detailMeta,
          detail.isAcceptableOrUnknown(data['detail']!, _detailMeta));
    } else if (isInserting) {
      context.missing(_detailMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('read')) {
      context.handle(
          _readMeta, read.isAcceptableOrUnknown(data['read']!, _readMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlertRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      detail: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}detail'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      read: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}read'])!,
    );
  }

  @override
  $AlertsTable createAlias(String alias) {
    return $AlertsTable(attachedDatabase, alias);
  }
}

class AlertRow extends DataClass implements Insertable<AlertRow> {
  final String id;

  /// Matches [AlertKind.name].
  final String kind;
  final String title;
  final String detail;
  final String action;
  final DateTime date;
  final bool read;
  const AlertRow(
      {required this.id,
      required this.kind,
      required this.title,
      required this.detail,
      required this.action,
      required this.date,
      required this.read});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['detail'] = Variable<String>(detail);
    map['action'] = Variable<String>(action);
    map['date'] = Variable<DateTime>(date);
    map['read'] = Variable<bool>(read);
    return map;
  }

  AlertsCompanion toCompanion(bool nullToAbsent) {
    return AlertsCompanion(
      id: Value(id),
      kind: Value(kind),
      title: Value(title),
      detail: Value(detail),
      action: Value(action),
      date: Value(date),
      read: Value(read),
    );
  }

  factory AlertRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertRow(
      id: serializer.fromJson<String>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      detail: serializer.fromJson<String>(json['detail']),
      action: serializer.fromJson<String>(json['action']),
      date: serializer.fromJson<DateTime>(json['date']),
      read: serializer.fromJson<bool>(json['read']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'detail': serializer.toJson<String>(detail),
      'action': serializer.toJson<String>(action),
      'date': serializer.toJson<DateTime>(date),
      'read': serializer.toJson<bool>(read),
    };
  }

  AlertRow copyWith(
          {String? id,
          String? kind,
          String? title,
          String? detail,
          String? action,
          DateTime? date,
          bool? read}) =>
      AlertRow(
        id: id ?? this.id,
        kind: kind ?? this.kind,
        title: title ?? this.title,
        detail: detail ?? this.detail,
        action: action ?? this.action,
        date: date ?? this.date,
        read: read ?? this.read,
      );
  AlertRow copyWithCompanion(AlertsCompanion data) {
    return AlertRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      detail: data.detail.present ? data.detail.value : this.detail,
      action: data.action.present ? data.action.value : this.action,
      date: data.date.present ? data.date.value : this.date,
      read: data.read.present ? data.read.value : this.read,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlertRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('detail: $detail, ')
          ..write('action: $action, ')
          ..write('date: $date, ')
          ..write('read: $read')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, title, detail, action, date, read);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.detail == this.detail &&
          other.action == this.action &&
          other.date == this.date &&
          other.read == this.read);
}

class AlertsCompanion extends UpdateCompanion<AlertRow> {
  final Value<String> id;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> detail;
  final Value<String> action;
  final Value<DateTime> date;
  final Value<bool> read;
  final Value<int> rowid;
  const AlertsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.detail = const Value.absent(),
    this.action = const Value.absent(),
    this.date = const Value.absent(),
    this.read = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertsCompanion.insert({
    required String id,
    required String kind,
    required String title,
    required String detail,
    required String action,
    required DateTime date,
    this.read = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        kind = Value(kind),
        title = Value(title),
        detail = Value(detail),
        action = Value(action),
        date = Value(date);
  static Insertable<AlertRow> custom({
    Expression<String>? id,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? detail,
    Expression<String>? action,
    Expression<DateTime>? date,
    Expression<bool>? read,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (detail != null) 'detail': detail,
      if (action != null) 'action': action,
      if (date != null) 'date': date,
      if (read != null) 'read': read,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertsCompanion copyWith(
      {Value<String>? id,
      Value<String>? kind,
      Value<String>? title,
      Value<String>? detail,
      Value<String>? action,
      Value<DateTime>? date,
      Value<bool>? read,
      Value<int>? rowid}) {
    return AlertsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      action: action ?? this.action,
      date: date ?? this.date,
      read: read ?? this.read,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (detail.present) {
      map['detail'] = Variable<String>(detail.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (read.present) {
      map['read'] = Variable<bool>(read.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('detail: $detail, ')
          ..write('action: $action, ')
          ..write('date: $date, ')
          ..write('read: $read, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CropScansTable extends CropScans
    with TableInfo<$CropScansTable, CropScanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CropScansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cropIdMeta = const VerificationMeta('cropId');
  @override
  late final GeneratedColumn<String> cropId = GeneratedColumn<String>(
      'crop_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cropNameMeta =
      const VerificationMeta('cropName');
  @override
  late final GeneratedColumn<String> cropName = GeneratedColumn<String>(
      'crop_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imagePathMeta =
      const VerificationMeta('imagePath');
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
      'image_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conditionMeta =
      const VerificationMeta('condition');
  @override
  late final GeneratedColumn<String> condition = GeneratedColumn<String>(
      'condition', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _issueLabelMeta =
      const VerificationMeta('issueLabel');
  @override
  late final GeneratedColumn<String> issueLabel = GeneratedColumn<String>(
      'issue_label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
      'severity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _affectedAreaMeta =
      const VerificationMeta('affectedArea');
  @override
  late final GeneratedColumn<String> affectedArea = GeneratedColumn<String>(
      'affected_area', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _growthStageMeta =
      const VerificationMeta('growthStage');
  @override
  late final GeneratedColumn<String> growthStage = GeneratedColumn<String>(
      'growth_stage', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _explanationMeta =
      const VerificationMeta('explanation');
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
      'explanation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionsJsonMeta =
      const VerificationMeta('actionsJson');
  @override
  late final GeneratedColumn<String> actionsJson = GeneratedColumn<String>(
      'actions_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelNameMeta =
      const VerificationMeta('modelName');
  @override
  late final GeneratedColumn<String> modelName = GeneratedColumn<String>(
      'model_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _inferenceTimeMsMeta =
      const VerificationMeta('inferenceTimeMs');
  @override
  late final GeneratedColumn<int> inferenceTimeMs = GeneratedColumn<int>(
      'inference_time_ms', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _engineMeta = const VerificationMeta('engine');
  @override
  late final GeneratedColumn<String> engine = GeneratedColumn<String>(
      'engine', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _marginMeta = const VerificationMeta('margin');
  @override
  late final GeneratedColumn<double> margin = GeneratedColumn<double>(
      'margin', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(1.0));
  static const VerificationMeta _runnerUpMeta =
      const VerificationMeta('runnerUp');
  @override
  late final GeneratedColumn<String> runnerUp = GeneratedColumn<String>(
      'runner_up', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _onlineSummaryMeta =
      const VerificationMeta('onlineSummary');
  @override
  late final GeneratedColumn<String> onlineSummary = GeneratedColumn<String>(
      'online_summary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _onlineCropMeta =
      const VerificationMeta('onlineCrop');
  @override
  late final GeneratedColumn<String> onlineCrop = GeneratedColumn<String>(
      'online_crop', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _onlineConditionMeta =
      const VerificationMeta('onlineCondition');
  @override
  late final GeneratedColumn<String> onlineCondition = GeneratedColumn<String>(
      'online_condition', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _onlineConfidenceMeta =
      const VerificationMeta('onlineConfidence');
  @override
  late final GeneratedColumn<String> onlineConfidence = GeneratedColumn<String>(
      'online_confidence', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _onlineActionsJsonMeta =
      const VerificationMeta('onlineActionsJson');
  @override
  late final GeneratedColumn<String> onlineActionsJson =
      GeneratedColumn<String>('online_actions_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _onlineModelMeta =
      const VerificationMeta('onlineModel');
  @override
  late final GeneratedColumn<String> onlineModel = GeneratedColumn<String>(
      'online_model', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _onlineConfirmsMeta =
      const VerificationMeta('onlineConfirms');
  @override
  late final GeneratedColumn<bool> onlineConfirms = GeneratedColumn<bool>(
      'online_confirms', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("online_confirms" IN (0, 1))'));
  static const VerificationMeta _onlineAskAPersonMeta =
      const VerificationMeta('onlineAskAPerson');
  @override
  late final GeneratedColumn<bool> onlineAskAPerson = GeneratedColumn<bool>(
      'online_ask_a_person', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("online_ask_a_person" IN (0, 1))'));
  static const VerificationMeta _onlineCaveatMeta =
      const VerificationMeta('onlineCaveat');
  @override
  late final GeneratedColumn<String> onlineCaveat = GeneratedColumn<String>(
      'online_caveat', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _onlineAtMeta =
      const VerificationMeta('onlineAt');
  @override
  late final GeneratedColumn<DateTime> onlineAt = GeneratedColumn<DateTime>(
      'online_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _savedToFarmMeta =
      const VerificationMeta('savedToFarm');
  @override
  late final GeneratedColumn<bool> savedToFarm = GeneratedColumn<bool>(
      'saved_to_farm', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("saved_to_farm" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _pendingSyncMeta =
      const VerificationMeta('pendingSync');
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
      'pending_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pending_sync" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cropId,
        cropName,
        imagePath,
        condition,
        issueLabel,
        confidence,
        severity,
        affectedArea,
        growthStage,
        explanation,
        actionsJson,
        status,
        modelName,
        inferenceTimeMs,
        engine,
        margin,
        runnerUp,
        onlineSummary,
        onlineCrop,
        onlineCondition,
        onlineConfidence,
        onlineActionsJson,
        onlineModel,
        onlineConfirms,
        onlineAskAPerson,
        onlineCaveat,
        onlineAt,
        savedToFarm,
        pendingSync,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crop_scans';
  @override
  VerificationContext validateIntegrity(Insertable<CropScanRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('crop_id')) {
      context.handle(_cropIdMeta,
          cropId.isAcceptableOrUnknown(data['crop_id']!, _cropIdMeta));
    }
    if (data.containsKey('crop_name')) {
      context.handle(_cropNameMeta,
          cropName.isAcceptableOrUnknown(data['crop_name']!, _cropNameMeta));
    } else if (isInserting) {
      context.missing(_cropNameMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(_imagePathMeta,
          imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta));
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('condition')) {
      context.handle(_conditionMeta,
          condition.isAcceptableOrUnknown(data['condition']!, _conditionMeta));
    } else if (isInserting) {
      context.missing(_conditionMeta);
    }
    if (data.containsKey('issue_label')) {
      context.handle(
          _issueLabelMeta,
          issueLabel.isAcceptableOrUnknown(
              data['issue_label']!, _issueLabelMeta));
    } else if (isInserting) {
      context.missing(_issueLabelMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('affected_area')) {
      context.handle(
          _affectedAreaMeta,
          affectedArea.isAcceptableOrUnknown(
              data['affected_area']!, _affectedAreaMeta));
    } else if (isInserting) {
      context.missing(_affectedAreaMeta);
    }
    if (data.containsKey('growth_stage')) {
      context.handle(
          _growthStageMeta,
          growthStage.isAcceptableOrUnknown(
              data['growth_stage']!, _growthStageMeta));
    } else if (isInserting) {
      context.missing(_growthStageMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
          _explanationMeta,
          explanation.isAcceptableOrUnknown(
              data['explanation']!, _explanationMeta));
    } else if (isInserting) {
      context.missing(_explanationMeta);
    }
    if (data.containsKey('actions_json')) {
      context.handle(
          _actionsJsonMeta,
          actionsJson.isAcceptableOrUnknown(
              data['actions_json']!, _actionsJsonMeta));
    } else if (isInserting) {
      context.missing(_actionsJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('model_name')) {
      context.handle(_modelNameMeta,
          modelName.isAcceptableOrUnknown(data['model_name']!, _modelNameMeta));
    } else if (isInserting) {
      context.missing(_modelNameMeta);
    }
    if (data.containsKey('inference_time_ms')) {
      context.handle(
          _inferenceTimeMsMeta,
          inferenceTimeMs.isAcceptableOrUnknown(
              data['inference_time_ms']!, _inferenceTimeMsMeta));
    }
    if (data.containsKey('engine')) {
      context.handle(_engineMeta,
          engine.isAcceptableOrUnknown(data['engine']!, _engineMeta));
    } else if (isInserting) {
      context.missing(_engineMeta);
    }
    if (data.containsKey('margin')) {
      context.handle(_marginMeta,
          margin.isAcceptableOrUnknown(data['margin']!, _marginMeta));
    }
    if (data.containsKey('runner_up')) {
      context.handle(_runnerUpMeta,
          runnerUp.isAcceptableOrUnknown(data['runner_up']!, _runnerUpMeta));
    }
    if (data.containsKey('online_summary')) {
      context.handle(
          _onlineSummaryMeta,
          onlineSummary.isAcceptableOrUnknown(
              data['online_summary']!, _onlineSummaryMeta));
    }
    if (data.containsKey('online_crop')) {
      context.handle(
          _onlineCropMeta,
          onlineCrop.isAcceptableOrUnknown(
              data['online_crop']!, _onlineCropMeta));
    }
    if (data.containsKey('online_condition')) {
      context.handle(
          _onlineConditionMeta,
          onlineCondition.isAcceptableOrUnknown(
              data['online_condition']!, _onlineConditionMeta));
    }
    if (data.containsKey('online_confidence')) {
      context.handle(
          _onlineConfidenceMeta,
          onlineConfidence.isAcceptableOrUnknown(
              data['online_confidence']!, _onlineConfidenceMeta));
    }
    if (data.containsKey('online_actions_json')) {
      context.handle(
          _onlineActionsJsonMeta,
          onlineActionsJson.isAcceptableOrUnknown(
              data['online_actions_json']!, _onlineActionsJsonMeta));
    }
    if (data.containsKey('online_model')) {
      context.handle(
          _onlineModelMeta,
          onlineModel.isAcceptableOrUnknown(
              data['online_model']!, _onlineModelMeta));
    }
    if (data.containsKey('online_confirms')) {
      context.handle(
          _onlineConfirmsMeta,
          onlineConfirms.isAcceptableOrUnknown(
              data['online_confirms']!, _onlineConfirmsMeta));
    }
    if (data.containsKey('online_ask_a_person')) {
      context.handle(
          _onlineAskAPersonMeta,
          onlineAskAPerson.isAcceptableOrUnknown(
              data['online_ask_a_person']!, _onlineAskAPersonMeta));
    }
    if (data.containsKey('online_caveat')) {
      context.handle(
          _onlineCaveatMeta,
          onlineCaveat.isAcceptableOrUnknown(
              data['online_caveat']!, _onlineCaveatMeta));
    }
    if (data.containsKey('online_at')) {
      context.handle(_onlineAtMeta,
          onlineAt.isAcceptableOrUnknown(data['online_at']!, _onlineAtMeta));
    }
    if (data.containsKey('saved_to_farm')) {
      context.handle(
          _savedToFarmMeta,
          savedToFarm.isAcceptableOrUnknown(
              data['saved_to_farm']!, _savedToFarmMeta));
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
          _pendingSyncMeta,
          pendingSync.isAcceptableOrUnknown(
              data['pending_sync']!, _pendingSyncMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CropScanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CropScanRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cropId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crop_id']),
      cropName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crop_name'])!,
      imagePath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_path'])!,
      condition: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}condition'])!,
      issueLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}issue_label'])!,
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}severity'])!,
      affectedArea: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}affected_area'])!,
      growthStage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}growth_stage'])!,
      explanation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}explanation'])!,
      actionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}actions_json'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      modelName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}model_name'])!,
      inferenceTimeMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}inference_time_ms'])!,
      engine: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}engine'])!,
      margin: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}margin'])!,
      runnerUp: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}runner_up']),
      onlineSummary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}online_summary']),
      onlineCrop: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}online_crop']),
      onlineCondition: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}online_condition']),
      onlineConfidence: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}online_confidence']),
      onlineActionsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}online_actions_json']),
      onlineModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}online_model']),
      onlineConfirms: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}online_confirms']),
      onlineAskAPerson: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}online_ask_a_person']),
      onlineCaveat: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}online_caveat']),
      onlineAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}online_at']),
      savedToFarm: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}saved_to_farm'])!,
      pendingSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pending_sync'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $CropScansTable createAlias(String alias) {
    return $CropScansTable(attachedDatabase, alias);
  }
}

class CropScanRow extends DataClass implements Insertable<CropScanRow> {
  final String id;
  final String? cropId;
  final String cropName;

  /// Path to the photo on device, or an `assets/…` path for demo scans.
  final String imagePath;

  /// CV class id, e.g. `maize_leaf_blight`.
  final String condition;

  /// Farmer-facing hedged label, e.g. "Possible Leaf Blight".
  final String issueLabel;
  final double confidence;
  final String severity;
  final String affectedArea;
  final String growthStage;
  final String explanation;

  /// JSON list of {title, detail}.
  final String actionsJson;

  /// Matches [HealthStatus.name].
  final String status;
  final String modelName;
  final int inferenceTimeMs;

  /// Engine that produced the explanation ("Local AI", "Amazon Bedrock").
  final String engine;

  /// How far the winning class beat the runner-up, and what it beat. Stored
  /// so the fail-safe still works when a scan is reopened from history, and
  /// so the online service can apply the same rule as the on-device guard.
  final double margin;
  final String? runnerUp;
  final String? onlineSummary;

  /// What Claude read from the photograph when the on-device model could not
  /// place it. Stored so the identification survives leaving the screen, and
  /// so the scan history shows a real crop instead of "Unknown".
  final String? onlineCrop;
  final String? onlineCondition;
  final String? onlineConfidence;
  final String? onlineActionsJson;
  final String? onlineModel;
  final bool? onlineConfirms;
  final bool? onlineAskAPerson;
  final String? onlineCaveat;
  final DateTime? onlineAt;
  final bool savedToFarm;
  final bool pendingSync;
  final DateTime createdAt;
  const CropScanRow(
      {required this.id,
      this.cropId,
      required this.cropName,
      required this.imagePath,
      required this.condition,
      required this.issueLabel,
      required this.confidence,
      required this.severity,
      required this.affectedArea,
      required this.growthStage,
      required this.explanation,
      required this.actionsJson,
      required this.status,
      required this.modelName,
      required this.inferenceTimeMs,
      required this.engine,
      required this.margin,
      this.runnerUp,
      this.onlineSummary,
      this.onlineCrop,
      this.onlineCondition,
      this.onlineConfidence,
      this.onlineActionsJson,
      this.onlineModel,
      this.onlineConfirms,
      this.onlineAskAPerson,
      this.onlineCaveat,
      this.onlineAt,
      required this.savedToFarm,
      required this.pendingSync,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || cropId != null) {
      map['crop_id'] = Variable<String>(cropId);
    }
    map['crop_name'] = Variable<String>(cropName);
    map['image_path'] = Variable<String>(imagePath);
    map['condition'] = Variable<String>(condition);
    map['issue_label'] = Variable<String>(issueLabel);
    map['confidence'] = Variable<double>(confidence);
    map['severity'] = Variable<String>(severity);
    map['affected_area'] = Variable<String>(affectedArea);
    map['growth_stage'] = Variable<String>(growthStage);
    map['explanation'] = Variable<String>(explanation);
    map['actions_json'] = Variable<String>(actionsJson);
    map['status'] = Variable<String>(status);
    map['model_name'] = Variable<String>(modelName);
    map['inference_time_ms'] = Variable<int>(inferenceTimeMs);
    map['engine'] = Variable<String>(engine);
    map['margin'] = Variable<double>(margin);
    if (!nullToAbsent || runnerUp != null) {
      map['runner_up'] = Variable<String>(runnerUp);
    }
    if (!nullToAbsent || onlineSummary != null) {
      map['online_summary'] = Variable<String>(onlineSummary);
    }
    if (!nullToAbsent || onlineCrop != null) {
      map['online_crop'] = Variable<String>(onlineCrop);
    }
    if (!nullToAbsent || onlineCondition != null) {
      map['online_condition'] = Variable<String>(onlineCondition);
    }
    if (!nullToAbsent || onlineConfidence != null) {
      map['online_confidence'] = Variable<String>(onlineConfidence);
    }
    if (!nullToAbsent || onlineActionsJson != null) {
      map['online_actions_json'] = Variable<String>(onlineActionsJson);
    }
    if (!nullToAbsent || onlineModel != null) {
      map['online_model'] = Variable<String>(onlineModel);
    }
    if (!nullToAbsent || onlineConfirms != null) {
      map['online_confirms'] = Variable<bool>(onlineConfirms);
    }
    if (!nullToAbsent || onlineAskAPerson != null) {
      map['online_ask_a_person'] = Variable<bool>(onlineAskAPerson);
    }
    if (!nullToAbsent || onlineCaveat != null) {
      map['online_caveat'] = Variable<String>(onlineCaveat);
    }
    if (!nullToAbsent || onlineAt != null) {
      map['online_at'] = Variable<DateTime>(onlineAt);
    }
    map['saved_to_farm'] = Variable<bool>(savedToFarm);
    map['pending_sync'] = Variable<bool>(pendingSync);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CropScansCompanion toCompanion(bool nullToAbsent) {
    return CropScansCompanion(
      id: Value(id),
      cropId:
          cropId == null && nullToAbsent ? const Value.absent() : Value(cropId),
      cropName: Value(cropName),
      imagePath: Value(imagePath),
      condition: Value(condition),
      issueLabel: Value(issueLabel),
      confidence: Value(confidence),
      severity: Value(severity),
      affectedArea: Value(affectedArea),
      growthStage: Value(growthStage),
      explanation: Value(explanation),
      actionsJson: Value(actionsJson),
      status: Value(status),
      modelName: Value(modelName),
      inferenceTimeMs: Value(inferenceTimeMs),
      engine: Value(engine),
      margin: Value(margin),
      runnerUp: runnerUp == null && nullToAbsent
          ? const Value.absent()
          : Value(runnerUp),
      onlineSummary: onlineSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(onlineSummary),
      onlineCrop: onlineCrop == null && nullToAbsent
          ? const Value.absent()
          : Value(onlineCrop),
      onlineCondition: onlineCondition == null && nullToAbsent
          ? const Value.absent()
          : Value(onlineCondition),
      onlineConfidence: onlineConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(onlineConfidence),
      onlineActionsJson: onlineActionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(onlineActionsJson),
      onlineModel: onlineModel == null && nullToAbsent
          ? const Value.absent()
          : Value(onlineModel),
      onlineConfirms: onlineConfirms == null && nullToAbsent
          ? const Value.absent()
          : Value(onlineConfirms),
      onlineAskAPerson: onlineAskAPerson == null && nullToAbsent
          ? const Value.absent()
          : Value(onlineAskAPerson),
      onlineCaveat: onlineCaveat == null && nullToAbsent
          ? const Value.absent()
          : Value(onlineCaveat),
      onlineAt: onlineAt == null && nullToAbsent
          ? const Value.absent()
          : Value(onlineAt),
      savedToFarm: Value(savedToFarm),
      pendingSync: Value(pendingSync),
      createdAt: Value(createdAt),
    );
  }

  factory CropScanRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CropScanRow(
      id: serializer.fromJson<String>(json['id']),
      cropId: serializer.fromJson<String?>(json['cropId']),
      cropName: serializer.fromJson<String>(json['cropName']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      condition: serializer.fromJson<String>(json['condition']),
      issueLabel: serializer.fromJson<String>(json['issueLabel']),
      confidence: serializer.fromJson<double>(json['confidence']),
      severity: serializer.fromJson<String>(json['severity']),
      affectedArea: serializer.fromJson<String>(json['affectedArea']),
      growthStage: serializer.fromJson<String>(json['growthStage']),
      explanation: serializer.fromJson<String>(json['explanation']),
      actionsJson: serializer.fromJson<String>(json['actionsJson']),
      status: serializer.fromJson<String>(json['status']),
      modelName: serializer.fromJson<String>(json['modelName']),
      inferenceTimeMs: serializer.fromJson<int>(json['inferenceTimeMs']),
      engine: serializer.fromJson<String>(json['engine']),
      margin: serializer.fromJson<double>(json['margin']),
      runnerUp: serializer.fromJson<String?>(json['runnerUp']),
      onlineSummary: serializer.fromJson<String?>(json['onlineSummary']),
      onlineCrop: serializer.fromJson<String?>(json['onlineCrop']),
      onlineCondition: serializer.fromJson<String?>(json['onlineCondition']),
      onlineConfidence: serializer.fromJson<String?>(json['onlineConfidence']),
      onlineActionsJson:
          serializer.fromJson<String?>(json['onlineActionsJson']),
      onlineModel: serializer.fromJson<String?>(json['onlineModel']),
      onlineConfirms: serializer.fromJson<bool?>(json['onlineConfirms']),
      onlineAskAPerson: serializer.fromJson<bool?>(json['onlineAskAPerson']),
      onlineCaveat: serializer.fromJson<String?>(json['onlineCaveat']),
      onlineAt: serializer.fromJson<DateTime?>(json['onlineAt']),
      savedToFarm: serializer.fromJson<bool>(json['savedToFarm']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cropId': serializer.toJson<String?>(cropId),
      'cropName': serializer.toJson<String>(cropName),
      'imagePath': serializer.toJson<String>(imagePath),
      'condition': serializer.toJson<String>(condition),
      'issueLabel': serializer.toJson<String>(issueLabel),
      'confidence': serializer.toJson<double>(confidence),
      'severity': serializer.toJson<String>(severity),
      'affectedArea': serializer.toJson<String>(affectedArea),
      'growthStage': serializer.toJson<String>(growthStage),
      'explanation': serializer.toJson<String>(explanation),
      'actionsJson': serializer.toJson<String>(actionsJson),
      'status': serializer.toJson<String>(status),
      'modelName': serializer.toJson<String>(modelName),
      'inferenceTimeMs': serializer.toJson<int>(inferenceTimeMs),
      'engine': serializer.toJson<String>(engine),
      'margin': serializer.toJson<double>(margin),
      'runnerUp': serializer.toJson<String?>(runnerUp),
      'onlineSummary': serializer.toJson<String?>(onlineSummary),
      'onlineCrop': serializer.toJson<String?>(onlineCrop),
      'onlineCondition': serializer.toJson<String?>(onlineCondition),
      'onlineConfidence': serializer.toJson<String?>(onlineConfidence),
      'onlineActionsJson': serializer.toJson<String?>(onlineActionsJson),
      'onlineModel': serializer.toJson<String?>(onlineModel),
      'onlineConfirms': serializer.toJson<bool?>(onlineConfirms),
      'onlineAskAPerson': serializer.toJson<bool?>(onlineAskAPerson),
      'onlineCaveat': serializer.toJson<String?>(onlineCaveat),
      'onlineAt': serializer.toJson<DateTime?>(onlineAt),
      'savedToFarm': serializer.toJson<bool>(savedToFarm),
      'pendingSync': serializer.toJson<bool>(pendingSync),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CropScanRow copyWith(
          {String? id,
          Value<String?> cropId = const Value.absent(),
          String? cropName,
          String? imagePath,
          String? condition,
          String? issueLabel,
          double? confidence,
          String? severity,
          String? affectedArea,
          String? growthStage,
          String? explanation,
          String? actionsJson,
          String? status,
          String? modelName,
          int? inferenceTimeMs,
          String? engine,
          double? margin,
          Value<String?> runnerUp = const Value.absent(),
          Value<String?> onlineSummary = const Value.absent(),
          Value<String?> onlineCrop = const Value.absent(),
          Value<String?> onlineCondition = const Value.absent(),
          Value<String?> onlineConfidence = const Value.absent(),
          Value<String?> onlineActionsJson = const Value.absent(),
          Value<String?> onlineModel = const Value.absent(),
          Value<bool?> onlineConfirms = const Value.absent(),
          Value<bool?> onlineAskAPerson = const Value.absent(),
          Value<String?> onlineCaveat = const Value.absent(),
          Value<DateTime?> onlineAt = const Value.absent(),
          bool? savedToFarm,
          bool? pendingSync,
          DateTime? createdAt}) =>
      CropScanRow(
        id: id ?? this.id,
        cropId: cropId.present ? cropId.value : this.cropId,
        cropName: cropName ?? this.cropName,
        imagePath: imagePath ?? this.imagePath,
        condition: condition ?? this.condition,
        issueLabel: issueLabel ?? this.issueLabel,
        confidence: confidence ?? this.confidence,
        severity: severity ?? this.severity,
        affectedArea: affectedArea ?? this.affectedArea,
        growthStage: growthStage ?? this.growthStage,
        explanation: explanation ?? this.explanation,
        actionsJson: actionsJson ?? this.actionsJson,
        status: status ?? this.status,
        modelName: modelName ?? this.modelName,
        inferenceTimeMs: inferenceTimeMs ?? this.inferenceTimeMs,
        engine: engine ?? this.engine,
        margin: margin ?? this.margin,
        runnerUp: runnerUp.present ? runnerUp.value : this.runnerUp,
        onlineSummary:
            onlineSummary.present ? onlineSummary.value : this.onlineSummary,
        onlineCrop: onlineCrop.present ? onlineCrop.value : this.onlineCrop,
        onlineCondition: onlineCondition.present
            ? onlineCondition.value
            : this.onlineCondition,
        onlineConfidence: onlineConfidence.present
            ? onlineConfidence.value
            : this.onlineConfidence,
        onlineActionsJson: onlineActionsJson.present
            ? onlineActionsJson.value
            : this.onlineActionsJson,
        onlineModel: onlineModel.present ? onlineModel.value : this.onlineModel,
        onlineConfirms:
            onlineConfirms.present ? onlineConfirms.value : this.onlineConfirms,
        onlineAskAPerson: onlineAskAPerson.present
            ? onlineAskAPerson.value
            : this.onlineAskAPerson,
        onlineCaveat:
            onlineCaveat.present ? onlineCaveat.value : this.onlineCaveat,
        onlineAt: onlineAt.present ? onlineAt.value : this.onlineAt,
        savedToFarm: savedToFarm ?? this.savedToFarm,
        pendingSync: pendingSync ?? this.pendingSync,
        createdAt: createdAt ?? this.createdAt,
      );
  CropScanRow copyWithCompanion(CropScansCompanion data) {
    return CropScanRow(
      id: data.id.present ? data.id.value : this.id,
      cropId: data.cropId.present ? data.cropId.value : this.cropId,
      cropName: data.cropName.present ? data.cropName.value : this.cropName,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      condition: data.condition.present ? data.condition.value : this.condition,
      issueLabel:
          data.issueLabel.present ? data.issueLabel.value : this.issueLabel,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      severity: data.severity.present ? data.severity.value : this.severity,
      affectedArea: data.affectedArea.present
          ? data.affectedArea.value
          : this.affectedArea,
      growthStage:
          data.growthStage.present ? data.growthStage.value : this.growthStage,
      explanation:
          data.explanation.present ? data.explanation.value : this.explanation,
      actionsJson:
          data.actionsJson.present ? data.actionsJson.value : this.actionsJson,
      status: data.status.present ? data.status.value : this.status,
      modelName: data.modelName.present ? data.modelName.value : this.modelName,
      inferenceTimeMs: data.inferenceTimeMs.present
          ? data.inferenceTimeMs.value
          : this.inferenceTimeMs,
      engine: data.engine.present ? data.engine.value : this.engine,
      margin: data.margin.present ? data.margin.value : this.margin,
      runnerUp: data.runnerUp.present ? data.runnerUp.value : this.runnerUp,
      onlineSummary: data.onlineSummary.present
          ? data.onlineSummary.value
          : this.onlineSummary,
      onlineCrop:
          data.onlineCrop.present ? data.onlineCrop.value : this.onlineCrop,
      onlineCondition: data.onlineCondition.present
          ? data.onlineCondition.value
          : this.onlineCondition,
      onlineConfidence: data.onlineConfidence.present
          ? data.onlineConfidence.value
          : this.onlineConfidence,
      onlineActionsJson: data.onlineActionsJson.present
          ? data.onlineActionsJson.value
          : this.onlineActionsJson,
      onlineModel:
          data.onlineModel.present ? data.onlineModel.value : this.onlineModel,
      onlineConfirms: data.onlineConfirms.present
          ? data.onlineConfirms.value
          : this.onlineConfirms,
      onlineAskAPerson: data.onlineAskAPerson.present
          ? data.onlineAskAPerson.value
          : this.onlineAskAPerson,
      onlineCaveat: data.onlineCaveat.present
          ? data.onlineCaveat.value
          : this.onlineCaveat,
      onlineAt: data.onlineAt.present ? data.onlineAt.value : this.onlineAt,
      savedToFarm:
          data.savedToFarm.present ? data.savedToFarm.value : this.savedToFarm,
      pendingSync:
          data.pendingSync.present ? data.pendingSync.value : this.pendingSync,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CropScanRow(')
          ..write('id: $id, ')
          ..write('cropId: $cropId, ')
          ..write('cropName: $cropName, ')
          ..write('imagePath: $imagePath, ')
          ..write('condition: $condition, ')
          ..write('issueLabel: $issueLabel, ')
          ..write('confidence: $confidence, ')
          ..write('severity: $severity, ')
          ..write('affectedArea: $affectedArea, ')
          ..write('growthStage: $growthStage, ')
          ..write('explanation: $explanation, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('status: $status, ')
          ..write('modelName: $modelName, ')
          ..write('inferenceTimeMs: $inferenceTimeMs, ')
          ..write('engine: $engine, ')
          ..write('margin: $margin, ')
          ..write('runnerUp: $runnerUp, ')
          ..write('onlineSummary: $onlineSummary, ')
          ..write('onlineCrop: $onlineCrop, ')
          ..write('onlineCondition: $onlineCondition, ')
          ..write('onlineConfidence: $onlineConfidence, ')
          ..write('onlineActionsJson: $onlineActionsJson, ')
          ..write('onlineModel: $onlineModel, ')
          ..write('onlineConfirms: $onlineConfirms, ')
          ..write('onlineAskAPerson: $onlineAskAPerson, ')
          ..write('onlineCaveat: $onlineCaveat, ')
          ..write('onlineAt: $onlineAt, ')
          ..write('savedToFarm: $savedToFarm, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        cropId,
        cropName,
        imagePath,
        condition,
        issueLabel,
        confidence,
        severity,
        affectedArea,
        growthStage,
        explanation,
        actionsJson,
        status,
        modelName,
        inferenceTimeMs,
        engine,
        margin,
        runnerUp,
        onlineSummary,
        onlineCrop,
        onlineCondition,
        onlineConfidence,
        onlineActionsJson,
        onlineModel,
        onlineConfirms,
        onlineAskAPerson,
        onlineCaveat,
        onlineAt,
        savedToFarm,
        pendingSync,
        createdAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CropScanRow &&
          other.id == this.id &&
          other.cropId == this.cropId &&
          other.cropName == this.cropName &&
          other.imagePath == this.imagePath &&
          other.condition == this.condition &&
          other.issueLabel == this.issueLabel &&
          other.confidence == this.confidence &&
          other.severity == this.severity &&
          other.affectedArea == this.affectedArea &&
          other.growthStage == this.growthStage &&
          other.explanation == this.explanation &&
          other.actionsJson == this.actionsJson &&
          other.status == this.status &&
          other.modelName == this.modelName &&
          other.inferenceTimeMs == this.inferenceTimeMs &&
          other.engine == this.engine &&
          other.margin == this.margin &&
          other.runnerUp == this.runnerUp &&
          other.onlineSummary == this.onlineSummary &&
          other.onlineCrop == this.onlineCrop &&
          other.onlineCondition == this.onlineCondition &&
          other.onlineConfidence == this.onlineConfidence &&
          other.onlineActionsJson == this.onlineActionsJson &&
          other.onlineModel == this.onlineModel &&
          other.onlineConfirms == this.onlineConfirms &&
          other.onlineAskAPerson == this.onlineAskAPerson &&
          other.onlineCaveat == this.onlineCaveat &&
          other.onlineAt == this.onlineAt &&
          other.savedToFarm == this.savedToFarm &&
          other.pendingSync == this.pendingSync &&
          other.createdAt == this.createdAt);
}

class CropScansCompanion extends UpdateCompanion<CropScanRow> {
  final Value<String> id;
  final Value<String?> cropId;
  final Value<String> cropName;
  final Value<String> imagePath;
  final Value<String> condition;
  final Value<String> issueLabel;
  final Value<double> confidence;
  final Value<String> severity;
  final Value<String> affectedArea;
  final Value<String> growthStage;
  final Value<String> explanation;
  final Value<String> actionsJson;
  final Value<String> status;
  final Value<String> modelName;
  final Value<int> inferenceTimeMs;
  final Value<String> engine;
  final Value<double> margin;
  final Value<String?> runnerUp;
  final Value<String?> onlineSummary;
  final Value<String?> onlineCrop;
  final Value<String?> onlineCondition;
  final Value<String?> onlineConfidence;
  final Value<String?> onlineActionsJson;
  final Value<String?> onlineModel;
  final Value<bool?> onlineConfirms;
  final Value<bool?> onlineAskAPerson;
  final Value<String?> onlineCaveat;
  final Value<DateTime?> onlineAt;
  final Value<bool> savedToFarm;
  final Value<bool> pendingSync;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CropScansCompanion({
    this.id = const Value.absent(),
    this.cropId = const Value.absent(),
    this.cropName = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.condition = const Value.absent(),
    this.issueLabel = const Value.absent(),
    this.confidence = const Value.absent(),
    this.severity = const Value.absent(),
    this.affectedArea = const Value.absent(),
    this.growthStage = const Value.absent(),
    this.explanation = const Value.absent(),
    this.actionsJson = const Value.absent(),
    this.status = const Value.absent(),
    this.modelName = const Value.absent(),
    this.inferenceTimeMs = const Value.absent(),
    this.engine = const Value.absent(),
    this.margin = const Value.absent(),
    this.runnerUp = const Value.absent(),
    this.onlineSummary = const Value.absent(),
    this.onlineCrop = const Value.absent(),
    this.onlineCondition = const Value.absent(),
    this.onlineConfidence = const Value.absent(),
    this.onlineActionsJson = const Value.absent(),
    this.onlineModel = const Value.absent(),
    this.onlineConfirms = const Value.absent(),
    this.onlineAskAPerson = const Value.absent(),
    this.onlineCaveat = const Value.absent(),
    this.onlineAt = const Value.absent(),
    this.savedToFarm = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CropScansCompanion.insert({
    required String id,
    this.cropId = const Value.absent(),
    required String cropName,
    required String imagePath,
    required String condition,
    required String issueLabel,
    required double confidence,
    required String severity,
    required String affectedArea,
    required String growthStage,
    required String explanation,
    required String actionsJson,
    required String status,
    required String modelName,
    this.inferenceTimeMs = const Value.absent(),
    required String engine,
    this.margin = const Value.absent(),
    this.runnerUp = const Value.absent(),
    this.onlineSummary = const Value.absent(),
    this.onlineCrop = const Value.absent(),
    this.onlineCondition = const Value.absent(),
    this.onlineConfidence = const Value.absent(),
    this.onlineActionsJson = const Value.absent(),
    this.onlineModel = const Value.absent(),
    this.onlineConfirms = const Value.absent(),
    this.onlineAskAPerson = const Value.absent(),
    this.onlineCaveat = const Value.absent(),
    this.onlineAt = const Value.absent(),
    this.savedToFarm = const Value.absent(),
    this.pendingSync = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        cropName = Value(cropName),
        imagePath = Value(imagePath),
        condition = Value(condition),
        issueLabel = Value(issueLabel),
        confidence = Value(confidence),
        severity = Value(severity),
        affectedArea = Value(affectedArea),
        growthStage = Value(growthStage),
        explanation = Value(explanation),
        actionsJson = Value(actionsJson),
        status = Value(status),
        modelName = Value(modelName),
        engine = Value(engine),
        createdAt = Value(createdAt);
  static Insertable<CropScanRow> custom({
    Expression<String>? id,
    Expression<String>? cropId,
    Expression<String>? cropName,
    Expression<String>? imagePath,
    Expression<String>? condition,
    Expression<String>? issueLabel,
    Expression<double>? confidence,
    Expression<String>? severity,
    Expression<String>? affectedArea,
    Expression<String>? growthStage,
    Expression<String>? explanation,
    Expression<String>? actionsJson,
    Expression<String>? status,
    Expression<String>? modelName,
    Expression<int>? inferenceTimeMs,
    Expression<String>? engine,
    Expression<double>? margin,
    Expression<String>? runnerUp,
    Expression<String>? onlineSummary,
    Expression<String>? onlineCrop,
    Expression<String>? onlineCondition,
    Expression<String>? onlineConfidence,
    Expression<String>? onlineActionsJson,
    Expression<String>? onlineModel,
    Expression<bool>? onlineConfirms,
    Expression<bool>? onlineAskAPerson,
    Expression<String>? onlineCaveat,
    Expression<DateTime>? onlineAt,
    Expression<bool>? savedToFarm,
    Expression<bool>? pendingSync,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cropId != null) 'crop_id': cropId,
      if (cropName != null) 'crop_name': cropName,
      if (imagePath != null) 'image_path': imagePath,
      if (condition != null) 'condition': condition,
      if (issueLabel != null) 'issue_label': issueLabel,
      if (confidence != null) 'confidence': confidence,
      if (severity != null) 'severity': severity,
      if (affectedArea != null) 'affected_area': affectedArea,
      if (growthStage != null) 'growth_stage': growthStage,
      if (explanation != null) 'explanation': explanation,
      if (actionsJson != null) 'actions_json': actionsJson,
      if (status != null) 'status': status,
      if (modelName != null) 'model_name': modelName,
      if (inferenceTimeMs != null) 'inference_time_ms': inferenceTimeMs,
      if (engine != null) 'engine': engine,
      if (margin != null) 'margin': margin,
      if (runnerUp != null) 'runner_up': runnerUp,
      if (onlineSummary != null) 'online_summary': onlineSummary,
      if (onlineCrop != null) 'online_crop': onlineCrop,
      if (onlineCondition != null) 'online_condition': onlineCondition,
      if (onlineConfidence != null) 'online_confidence': onlineConfidence,
      if (onlineActionsJson != null) 'online_actions_json': onlineActionsJson,
      if (onlineModel != null) 'online_model': onlineModel,
      if (onlineConfirms != null) 'online_confirms': onlineConfirms,
      if (onlineAskAPerson != null) 'online_ask_a_person': onlineAskAPerson,
      if (onlineCaveat != null) 'online_caveat': onlineCaveat,
      if (onlineAt != null) 'online_at': onlineAt,
      if (savedToFarm != null) 'saved_to_farm': savedToFarm,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CropScansCompanion copyWith(
      {Value<String>? id,
      Value<String?>? cropId,
      Value<String>? cropName,
      Value<String>? imagePath,
      Value<String>? condition,
      Value<String>? issueLabel,
      Value<double>? confidence,
      Value<String>? severity,
      Value<String>? affectedArea,
      Value<String>? growthStage,
      Value<String>? explanation,
      Value<String>? actionsJson,
      Value<String>? status,
      Value<String>? modelName,
      Value<int>? inferenceTimeMs,
      Value<String>? engine,
      Value<double>? margin,
      Value<String?>? runnerUp,
      Value<String?>? onlineSummary,
      Value<String?>? onlineCrop,
      Value<String?>? onlineCondition,
      Value<String?>? onlineConfidence,
      Value<String?>? onlineActionsJson,
      Value<String?>? onlineModel,
      Value<bool?>? onlineConfirms,
      Value<bool?>? onlineAskAPerson,
      Value<String?>? onlineCaveat,
      Value<DateTime?>? onlineAt,
      Value<bool>? savedToFarm,
      Value<bool>? pendingSync,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return CropScansCompanion(
      id: id ?? this.id,
      cropId: cropId ?? this.cropId,
      cropName: cropName ?? this.cropName,
      imagePath: imagePath ?? this.imagePath,
      condition: condition ?? this.condition,
      issueLabel: issueLabel ?? this.issueLabel,
      confidence: confidence ?? this.confidence,
      severity: severity ?? this.severity,
      affectedArea: affectedArea ?? this.affectedArea,
      growthStage: growthStage ?? this.growthStage,
      explanation: explanation ?? this.explanation,
      actionsJson: actionsJson ?? this.actionsJson,
      status: status ?? this.status,
      modelName: modelName ?? this.modelName,
      inferenceTimeMs: inferenceTimeMs ?? this.inferenceTimeMs,
      engine: engine ?? this.engine,
      margin: margin ?? this.margin,
      runnerUp: runnerUp ?? this.runnerUp,
      onlineSummary: onlineSummary ?? this.onlineSummary,
      onlineCrop: onlineCrop ?? this.onlineCrop,
      onlineCondition: onlineCondition ?? this.onlineCondition,
      onlineConfidence: onlineConfidence ?? this.onlineConfidence,
      onlineActionsJson: onlineActionsJson ?? this.onlineActionsJson,
      onlineModel: onlineModel ?? this.onlineModel,
      onlineConfirms: onlineConfirms ?? this.onlineConfirms,
      onlineAskAPerson: onlineAskAPerson ?? this.onlineAskAPerson,
      onlineCaveat: onlineCaveat ?? this.onlineCaveat,
      onlineAt: onlineAt ?? this.onlineAt,
      savedToFarm: savedToFarm ?? this.savedToFarm,
      pendingSync: pendingSync ?? this.pendingSync,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cropId.present) {
      map['crop_id'] = Variable<String>(cropId.value);
    }
    if (cropName.present) {
      map['crop_name'] = Variable<String>(cropName.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (condition.present) {
      map['condition'] = Variable<String>(condition.value);
    }
    if (issueLabel.present) {
      map['issue_label'] = Variable<String>(issueLabel.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (affectedArea.present) {
      map['affected_area'] = Variable<String>(affectedArea.value);
    }
    if (growthStage.present) {
      map['growth_stage'] = Variable<String>(growthStage.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (actionsJson.present) {
      map['actions_json'] = Variable<String>(actionsJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (modelName.present) {
      map['model_name'] = Variable<String>(modelName.value);
    }
    if (inferenceTimeMs.present) {
      map['inference_time_ms'] = Variable<int>(inferenceTimeMs.value);
    }
    if (engine.present) {
      map['engine'] = Variable<String>(engine.value);
    }
    if (margin.present) {
      map['margin'] = Variable<double>(margin.value);
    }
    if (runnerUp.present) {
      map['runner_up'] = Variable<String>(runnerUp.value);
    }
    if (onlineSummary.present) {
      map['online_summary'] = Variable<String>(onlineSummary.value);
    }
    if (onlineCrop.present) {
      map['online_crop'] = Variable<String>(onlineCrop.value);
    }
    if (onlineCondition.present) {
      map['online_condition'] = Variable<String>(onlineCondition.value);
    }
    if (onlineConfidence.present) {
      map['online_confidence'] = Variable<String>(onlineConfidence.value);
    }
    if (onlineActionsJson.present) {
      map['online_actions_json'] = Variable<String>(onlineActionsJson.value);
    }
    if (onlineModel.present) {
      map['online_model'] = Variable<String>(onlineModel.value);
    }
    if (onlineConfirms.present) {
      map['online_confirms'] = Variable<bool>(onlineConfirms.value);
    }
    if (onlineAskAPerson.present) {
      map['online_ask_a_person'] = Variable<bool>(onlineAskAPerson.value);
    }
    if (onlineCaveat.present) {
      map['online_caveat'] = Variable<String>(onlineCaveat.value);
    }
    if (onlineAt.present) {
      map['online_at'] = Variable<DateTime>(onlineAt.value);
    }
    if (savedToFarm.present) {
      map['saved_to_farm'] = Variable<bool>(savedToFarm.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CropScansCompanion(')
          ..write('id: $id, ')
          ..write('cropId: $cropId, ')
          ..write('cropName: $cropName, ')
          ..write('imagePath: $imagePath, ')
          ..write('condition: $condition, ')
          ..write('issueLabel: $issueLabel, ')
          ..write('confidence: $confidence, ')
          ..write('severity: $severity, ')
          ..write('affectedArea: $affectedArea, ')
          ..write('growthStage: $growthStage, ')
          ..write('explanation: $explanation, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('status: $status, ')
          ..write('modelName: $modelName, ')
          ..write('inferenceTimeMs: $inferenceTimeMs, ')
          ..write('engine: $engine, ')
          ..write('margin: $margin, ')
          ..write('runnerUp: $runnerUp, ')
          ..write('onlineSummary: $onlineSummary, ')
          ..write('onlineCrop: $onlineCrop, ')
          ..write('onlineCondition: $onlineCondition, ')
          ..write('onlineConfidence: $onlineConfidence, ')
          ..write('onlineActionsJson: $onlineActionsJson, ')
          ..write('onlineModel: $onlineModel, ')
          ..write('onlineConfirms: $onlineConfirms, ')
          ..write('onlineAskAPerson: $onlineAskAPerson, ')
          ..write('onlineCaveat: $onlineCaveat, ')
          ..write('onlineAt: $onlineAt, ')
          ..write('savedToFarm: $savedToFarm, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, ConversationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, title, startedAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(Insertable<ConversationRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConversationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class ConversationRow extends DataClass implements Insertable<ConversationRow> {
  final String id;
  final String title;
  final DateTime startedAt;
  final DateTime updatedAt;
  const ConversationRow(
      {required this.id,
      required this.title,
      required this.startedAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      title: Value(title),
      startedAt: Value(startedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ConversationRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ConversationRow copyWith(
          {String? id,
          String? title,
          DateTime? startedAt,
          DateTime? updatedAt}) =>
      ConversationRow(
        id: id ?? this.id,
        title: title ?? this.title,
        startedAt: startedAt ?? this.startedAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ConversationRow copyWithCompanion(ConversationsCompanion data) {
    return ConversationRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startedAt: $startedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, startedAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.startedAt == this.startedAt &&
          other.updatedAt == this.updatedAt);
}

class ConversationsCompanion extends UpdateCompanion<ConversationRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<DateTime> startedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String id,
    required String title,
    required DateTime startedAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        startedAt = Value(startedAt),
        updatedAt = Value(updatedAt);
  static Insertable<ConversationRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (startedAt != null) 'started_at': startedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<DateTime>? startedAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ConversationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      startedAt: startedAt ?? this.startedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startedAt: $startedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES conversations (id)'));
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _engineMeta = const VerificationMeta('engine');
  @override
  late final GeneratedColumn<String> engine = GeneratedColumn<String>(
      'engine', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _actionsJsonMeta =
      const VerificationMeta('actionsJson');
  @override
  late final GeneratedColumn<String> actionsJson = GeneratedColumn<String>(
      'actions_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pendingSyncMeta =
      const VerificationMeta('pendingSync');
  @override
  late final GeneratedColumn<bool> pendingSync = GeneratedColumn<bool>(
      'pending_sync', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pending_sync" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
      'sent_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        conversationId,
        role,
        content,
        engine,
        confidence,
        category,
        actionsJson,
        pendingSync,
        sentAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(Insertable<ChatMessageRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('engine')) {
      context.handle(_engineMeta,
          engine.isAcceptableOrUnknown(data['engine']!, _engineMeta));
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('actions_json')) {
      context.handle(
          _actionsJsonMeta,
          actionsJson.isAcceptableOrUnknown(
              data['actions_json']!, _actionsJsonMeta));
    }
    if (data.containsKey('pending_sync')) {
      context.handle(
          _pendingSyncMeta,
          pendingSync.isAcceptableOrUnknown(
              data['pending_sync']!, _pendingSyncMeta));
    }
    if (data.containsKey('sent_at')) {
      context.handle(_sentAtMeta,
          sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta));
    } else if (isInserting) {
      context.missing(_sentAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      conversationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conversation_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      engine: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}engine']),
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      actionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}actions_json']),
      pendingSync: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pending_sync'])!,
      sentAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sent_at'])!,
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }
}

class ChatMessageRow extends DataClass implements Insertable<ChatMessageRow> {
  final String id;
  final String conversationId;

  /// `user` | `assistant`.
  final String role;
  final String content;
  final String? engine;
  final double? confidence;
  final String? category;

  /// JSON list of strings.
  final String? actionsJson;
  final bool pendingSync;
  final DateTime sentAt;
  const ChatMessageRow(
      {required this.id,
      required this.conversationId,
      required this.role,
      required this.content,
      this.engine,
      this.confidence,
      this.category,
      this.actionsJson,
      required this.pendingSync,
      required this.sentAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || engine != null) {
      map['engine'] = Variable<String>(engine);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || actionsJson != null) {
      map['actions_json'] = Variable<String>(actionsJson);
    }
    map['pending_sync'] = Variable<bool>(pendingSync);
    map['sent_at'] = Variable<DateTime>(sentAt);
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      engine:
          engine == null && nullToAbsent ? const Value.absent() : Value(engine),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      actionsJson: actionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(actionsJson),
      pendingSync: Value(pendingSync),
      sentAt: Value(sentAt),
    );
  }

  factory ChatMessageRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageRow(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      engine: serializer.fromJson<String?>(json['engine']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      category: serializer.fromJson<String?>(json['category']),
      actionsJson: serializer.fromJson<String?>(json['actionsJson']),
      pendingSync: serializer.fromJson<bool>(json['pendingSync']),
      sentAt: serializer.fromJson<DateTime>(json['sentAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'engine': serializer.toJson<String?>(engine),
      'confidence': serializer.toJson<double?>(confidence),
      'category': serializer.toJson<String?>(category),
      'actionsJson': serializer.toJson<String?>(actionsJson),
      'pendingSync': serializer.toJson<bool>(pendingSync),
      'sentAt': serializer.toJson<DateTime>(sentAt),
    };
  }

  ChatMessageRow copyWith(
          {String? id,
          String? conversationId,
          String? role,
          String? content,
          Value<String?> engine = const Value.absent(),
          Value<double?> confidence = const Value.absent(),
          Value<String?> category = const Value.absent(),
          Value<String?> actionsJson = const Value.absent(),
          bool? pendingSync,
          DateTime? sentAt}) =>
      ChatMessageRow(
        id: id ?? this.id,
        conversationId: conversationId ?? this.conversationId,
        role: role ?? this.role,
        content: content ?? this.content,
        engine: engine.present ? engine.value : this.engine,
        confidence: confidence.present ? confidence.value : this.confidence,
        category: category.present ? category.value : this.category,
        actionsJson: actionsJson.present ? actionsJson.value : this.actionsJson,
        pendingSync: pendingSync ?? this.pendingSync,
        sentAt: sentAt ?? this.sentAt,
      );
  ChatMessageRow copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessageRow(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      engine: data.engine.present ? data.engine.value : this.engine,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      category: data.category.present ? data.category.value : this.category,
      actionsJson:
          data.actionsJson.present ? data.actionsJson.value : this.actionsJson,
      pendingSync:
          data.pendingSync.present ? data.pendingSync.value : this.pendingSync,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageRow(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('engine: $engine, ')
          ..write('confidence: $confidence, ')
          ..write('category: $category, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('sentAt: $sentAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, conversationId, role, content, engine,
      confidence, category, actionsJson, pendingSync, sentAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageRow &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.engine == this.engine &&
          other.confidence == this.confidence &&
          other.category == this.category &&
          other.actionsJson == this.actionsJson &&
          other.pendingSync == this.pendingSync &&
          other.sentAt == this.sentAt);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessageRow> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<String?> engine;
  final Value<double?> confidence;
  final Value<String?> category;
  final Value<String?> actionsJson;
  final Value<bool> pendingSync;
  final Value<DateTime> sentAt;
  final Value<int> rowid;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.engine = const Value.absent(),
    this.confidence = const Value.absent(),
    this.category = const Value.absent(),
    this.actionsJson = const Value.absent(),
    this.pendingSync = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    required String id,
    required String conversationId,
    required String role,
    required String content,
    this.engine = const Value.absent(),
    this.confidence = const Value.absent(),
    this.category = const Value.absent(),
    this.actionsJson = const Value.absent(),
    this.pendingSync = const Value.absent(),
    required DateTime sentAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        conversationId = Value(conversationId),
        role = Value(role),
        content = Value(content),
        sentAt = Value(sentAt);
  static Insertable<ChatMessageRow> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? engine,
    Expression<double>? confidence,
    Expression<String>? category,
    Expression<String>? actionsJson,
    Expression<bool>? pendingSync,
    Expression<DateTime>? sentAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (engine != null) 'engine': engine,
      if (confidence != null) 'confidence': confidence,
      if (category != null) 'category': category,
      if (actionsJson != null) 'actions_json': actionsJson,
      if (pendingSync != null) 'pending_sync': pendingSync,
      if (sentAt != null) 'sent_at': sentAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? conversationId,
      Value<String>? role,
      Value<String>? content,
      Value<String?>? engine,
      Value<double?>? confidence,
      Value<String?>? category,
      Value<String?>? actionsJson,
      Value<bool>? pendingSync,
      Value<DateTime>? sentAt,
      Value<int>? rowid}) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      engine: engine ?? this.engine,
      confidence: confidence ?? this.confidence,
      category: category ?? this.category,
      actionsJson: actionsJson ?? this.actionsJson,
      pendingSync: pendingSync ?? this.pendingSync,
      sentAt: sentAt ?? this.sentAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (engine.present) {
      map['engine'] = Variable<String>(engine.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (actionsJson.present) {
      map['actions_json'] = Variable<String>(actionsJson.value);
    }
    if (pendingSync.present) {
      map['pending_sync'] = Variable<bool>(pendingSync.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('engine: $engine, ')
          ..write('confidence: $confidence, ')
          ..write('category: $category, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('pendingSync: $pendingSync, ')
          ..write('sentAt: $sentAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KnowledgeArticlesTable extends KnowledgeArticles
    with TableInfo<$KnowledgeArticlesTable, KnowledgeArticleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KnowledgeArticlesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cropMeta = const VerificationMeta('crop');
  @override
  late final GeneratedColumn<String> crop = GeneratedColumn<String>(
      'crop', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('general'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symptomsJsonMeta =
      const VerificationMeta('symptomsJson');
  @override
  late final GeneratedColumn<String> symptomsJson = GeneratedColumn<String>(
      'symptoms_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _causesJsonMeta =
      const VerificationMeta('causesJson');
  @override
  late final GeneratedColumn<String> causesJson = GeneratedColumn<String>(
      'causes_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _preventionJsonMeta =
      const VerificationMeta('preventionJson');
  @override
  late final GeneratedColumn<String> preventionJson = GeneratedColumn<String>(
      'prevention_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _actionsJsonMeta =
      const VerificationMeta('actionsJson');
  @override
  late final GeneratedColumn<String> actionsJson = GeneratedColumn<String>(
      'actions_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _severityMeta =
      const VerificationMeta('severity');
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
      'severity', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('none'));
  static const VerificationMeta _keywordsMeta =
      const VerificationMeta('keywords');
  @override
  late final GeneratedColumn<String> keywords = GeneratedColumn<String>(
      'keywords', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _sectionsJsonMeta =
      const VerificationMeta('sectionsJson');
  @override
  late final GeneratedColumn<String> sectionsJson = GeneratedColumn<String>(
      'sections_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _readMinutesMeta =
      const VerificationMeta('readMinutes');
  @override
  late final GeneratedColumn<int> readMinutes = GeneratedColumn<int>(
      'read_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        category,
        crop,
        title,
        summary,
        symptomsJson,
        causesJson,
        preventionJson,
        actionsJson,
        severity,
        keywords,
        sectionsJson,
        readMinutes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'knowledge_articles';
  @override
  VerificationContext validateIntegrity(
      Insertable<KnowledgeArticleRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('crop')) {
      context.handle(
          _cropMeta, crop.isAcceptableOrUnknown(data['crop']!, _cropMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('symptoms_json')) {
      context.handle(
          _symptomsJsonMeta,
          symptomsJson.isAcceptableOrUnknown(
              data['symptoms_json']!, _symptomsJsonMeta));
    }
    if (data.containsKey('causes_json')) {
      context.handle(
          _causesJsonMeta,
          causesJson.isAcceptableOrUnknown(
              data['causes_json']!, _causesJsonMeta));
    }
    if (data.containsKey('prevention_json')) {
      context.handle(
          _preventionJsonMeta,
          preventionJson.isAcceptableOrUnknown(
              data['prevention_json']!, _preventionJsonMeta));
    }
    if (data.containsKey('actions_json')) {
      context.handle(
          _actionsJsonMeta,
          actionsJson.isAcceptableOrUnknown(
              data['actions_json']!, _actionsJsonMeta));
    }
    if (data.containsKey('severity')) {
      context.handle(_severityMeta,
          severity.isAcceptableOrUnknown(data['severity']!, _severityMeta));
    }
    if (data.containsKey('keywords')) {
      context.handle(_keywordsMeta,
          keywords.isAcceptableOrUnknown(data['keywords']!, _keywordsMeta));
    }
    if (data.containsKey('sections_json')) {
      context.handle(
          _sectionsJsonMeta,
          sectionsJson.isAcceptableOrUnknown(
              data['sections_json']!, _sectionsJsonMeta));
    }
    if (data.containsKey('read_minutes')) {
      context.handle(
          _readMinutesMeta,
          readMinutes.isAcceptableOrUnknown(
              data['read_minutes']!, _readMinutesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KnowledgeArticleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KnowledgeArticleRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      crop: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}crop'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary'])!,
      symptomsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symptoms_json'])!,
      causesJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}causes_json'])!,
      preventionJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}prevention_json'])!,
      actionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}actions_json'])!,
      severity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}severity'])!,
      keywords: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}keywords'])!,
      sectionsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sections_json'])!,
      readMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}read_minutes'])!,
    );
  }

  @override
  $KnowledgeArticlesTable createAlias(String alias) {
    return $KnowledgeArticlesTable(attachedDatabase, alias);
  }
}

class KnowledgeArticleRow extends DataClass
    implements Insertable<KnowledgeArticleRow> {
  final String id;

  /// `crop` | `disease` | `pest` | `soil` | `irrigation` | `planting` |
  /// `climate` | `tip`.
  final String category;
  final String crop;
  final String title;
  final String summary;
  final String symptomsJson;
  final String causesJson;
  final String preventionJson;
  final String actionsJson;
  final String severity;

  /// Space-separated lower-case keywords for retrieval.
  final String keywords;

  /// JSON list of {heading, body} for display.
  final String sectionsJson;
  final int readMinutes;
  const KnowledgeArticleRow(
      {required this.id,
      required this.category,
      required this.crop,
      required this.title,
      required this.summary,
      required this.symptomsJson,
      required this.causesJson,
      required this.preventionJson,
      required this.actionsJson,
      required this.severity,
      required this.keywords,
      required this.sectionsJson,
      required this.readMinutes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category'] = Variable<String>(category);
    map['crop'] = Variable<String>(crop);
    map['title'] = Variable<String>(title);
    map['summary'] = Variable<String>(summary);
    map['symptoms_json'] = Variable<String>(symptomsJson);
    map['causes_json'] = Variable<String>(causesJson);
    map['prevention_json'] = Variable<String>(preventionJson);
    map['actions_json'] = Variable<String>(actionsJson);
    map['severity'] = Variable<String>(severity);
    map['keywords'] = Variable<String>(keywords);
    map['sections_json'] = Variable<String>(sectionsJson);
    map['read_minutes'] = Variable<int>(readMinutes);
    return map;
  }

  KnowledgeArticlesCompanion toCompanion(bool nullToAbsent) {
    return KnowledgeArticlesCompanion(
      id: Value(id),
      category: Value(category),
      crop: Value(crop),
      title: Value(title),
      summary: Value(summary),
      symptomsJson: Value(symptomsJson),
      causesJson: Value(causesJson),
      preventionJson: Value(preventionJson),
      actionsJson: Value(actionsJson),
      severity: Value(severity),
      keywords: Value(keywords),
      sectionsJson: Value(sectionsJson),
      readMinutes: Value(readMinutes),
    );
  }

  factory KnowledgeArticleRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KnowledgeArticleRow(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      crop: serializer.fromJson<String>(json['crop']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String>(json['summary']),
      symptomsJson: serializer.fromJson<String>(json['symptomsJson']),
      causesJson: serializer.fromJson<String>(json['causesJson']),
      preventionJson: serializer.fromJson<String>(json['preventionJson']),
      actionsJson: serializer.fromJson<String>(json['actionsJson']),
      severity: serializer.fromJson<String>(json['severity']),
      keywords: serializer.fromJson<String>(json['keywords']),
      sectionsJson: serializer.fromJson<String>(json['sectionsJson']),
      readMinutes: serializer.fromJson<int>(json['readMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(category),
      'crop': serializer.toJson<String>(crop),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String>(summary),
      'symptomsJson': serializer.toJson<String>(symptomsJson),
      'causesJson': serializer.toJson<String>(causesJson),
      'preventionJson': serializer.toJson<String>(preventionJson),
      'actionsJson': serializer.toJson<String>(actionsJson),
      'severity': serializer.toJson<String>(severity),
      'keywords': serializer.toJson<String>(keywords),
      'sectionsJson': serializer.toJson<String>(sectionsJson),
      'readMinutes': serializer.toJson<int>(readMinutes),
    };
  }

  KnowledgeArticleRow copyWith(
          {String? id,
          String? category,
          String? crop,
          String? title,
          String? summary,
          String? symptomsJson,
          String? causesJson,
          String? preventionJson,
          String? actionsJson,
          String? severity,
          String? keywords,
          String? sectionsJson,
          int? readMinutes}) =>
      KnowledgeArticleRow(
        id: id ?? this.id,
        category: category ?? this.category,
        crop: crop ?? this.crop,
        title: title ?? this.title,
        summary: summary ?? this.summary,
        symptomsJson: symptomsJson ?? this.symptomsJson,
        causesJson: causesJson ?? this.causesJson,
        preventionJson: preventionJson ?? this.preventionJson,
        actionsJson: actionsJson ?? this.actionsJson,
        severity: severity ?? this.severity,
        keywords: keywords ?? this.keywords,
        sectionsJson: sectionsJson ?? this.sectionsJson,
        readMinutes: readMinutes ?? this.readMinutes,
      );
  KnowledgeArticleRow copyWithCompanion(KnowledgeArticlesCompanion data) {
    return KnowledgeArticleRow(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      crop: data.crop.present ? data.crop.value : this.crop,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      symptomsJson: data.symptomsJson.present
          ? data.symptomsJson.value
          : this.symptomsJson,
      causesJson:
          data.causesJson.present ? data.causesJson.value : this.causesJson,
      preventionJson: data.preventionJson.present
          ? data.preventionJson.value
          : this.preventionJson,
      actionsJson:
          data.actionsJson.present ? data.actionsJson.value : this.actionsJson,
      severity: data.severity.present ? data.severity.value : this.severity,
      keywords: data.keywords.present ? data.keywords.value : this.keywords,
      sectionsJson: data.sectionsJson.present
          ? data.sectionsJson.value
          : this.sectionsJson,
      readMinutes:
          data.readMinutes.present ? data.readMinutes.value : this.readMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KnowledgeArticleRow(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('crop: $crop, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('symptomsJson: $symptomsJson, ')
          ..write('causesJson: $causesJson, ')
          ..write('preventionJson: $preventionJson, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('severity: $severity, ')
          ..write('keywords: $keywords, ')
          ..write('sectionsJson: $sectionsJson, ')
          ..write('readMinutes: $readMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      category,
      crop,
      title,
      summary,
      symptomsJson,
      causesJson,
      preventionJson,
      actionsJson,
      severity,
      keywords,
      sectionsJson,
      readMinutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KnowledgeArticleRow &&
          other.id == this.id &&
          other.category == this.category &&
          other.crop == this.crop &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.symptomsJson == this.symptomsJson &&
          other.causesJson == this.causesJson &&
          other.preventionJson == this.preventionJson &&
          other.actionsJson == this.actionsJson &&
          other.severity == this.severity &&
          other.keywords == this.keywords &&
          other.sectionsJson == this.sectionsJson &&
          other.readMinutes == this.readMinutes);
}

class KnowledgeArticlesCompanion extends UpdateCompanion<KnowledgeArticleRow> {
  final Value<String> id;
  final Value<String> category;
  final Value<String> crop;
  final Value<String> title;
  final Value<String> summary;
  final Value<String> symptomsJson;
  final Value<String> causesJson;
  final Value<String> preventionJson;
  final Value<String> actionsJson;
  final Value<String> severity;
  final Value<String> keywords;
  final Value<String> sectionsJson;
  final Value<int> readMinutes;
  final Value<int> rowid;
  const KnowledgeArticlesCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.crop = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.symptomsJson = const Value.absent(),
    this.causesJson = const Value.absent(),
    this.preventionJson = const Value.absent(),
    this.actionsJson = const Value.absent(),
    this.severity = const Value.absent(),
    this.keywords = const Value.absent(),
    this.sectionsJson = const Value.absent(),
    this.readMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KnowledgeArticlesCompanion.insert({
    required String id,
    required String category,
    this.crop = const Value.absent(),
    required String title,
    required String summary,
    this.symptomsJson = const Value.absent(),
    this.causesJson = const Value.absent(),
    this.preventionJson = const Value.absent(),
    this.actionsJson = const Value.absent(),
    this.severity = const Value.absent(),
    this.keywords = const Value.absent(),
    this.sectionsJson = const Value.absent(),
    this.readMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        category = Value(category),
        title = Value(title),
        summary = Value(summary);
  static Insertable<KnowledgeArticleRow> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<String>? crop,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<String>? symptomsJson,
    Expression<String>? causesJson,
    Expression<String>? preventionJson,
    Expression<String>? actionsJson,
    Expression<String>? severity,
    Expression<String>? keywords,
    Expression<String>? sectionsJson,
    Expression<int>? readMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (crop != null) 'crop': crop,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (symptomsJson != null) 'symptoms_json': symptomsJson,
      if (causesJson != null) 'causes_json': causesJson,
      if (preventionJson != null) 'prevention_json': preventionJson,
      if (actionsJson != null) 'actions_json': actionsJson,
      if (severity != null) 'severity': severity,
      if (keywords != null) 'keywords': keywords,
      if (sectionsJson != null) 'sections_json': sectionsJson,
      if (readMinutes != null) 'read_minutes': readMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KnowledgeArticlesCompanion copyWith(
      {Value<String>? id,
      Value<String>? category,
      Value<String>? crop,
      Value<String>? title,
      Value<String>? summary,
      Value<String>? symptomsJson,
      Value<String>? causesJson,
      Value<String>? preventionJson,
      Value<String>? actionsJson,
      Value<String>? severity,
      Value<String>? keywords,
      Value<String>? sectionsJson,
      Value<int>? readMinutes,
      Value<int>? rowid}) {
    return KnowledgeArticlesCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      crop: crop ?? this.crop,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      symptomsJson: symptomsJson ?? this.symptomsJson,
      causesJson: causesJson ?? this.causesJson,
      preventionJson: preventionJson ?? this.preventionJson,
      actionsJson: actionsJson ?? this.actionsJson,
      severity: severity ?? this.severity,
      keywords: keywords ?? this.keywords,
      sectionsJson: sectionsJson ?? this.sectionsJson,
      readMinutes: readMinutes ?? this.readMinutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (crop.present) {
      map['crop'] = Variable<String>(crop.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (symptomsJson.present) {
      map['symptoms_json'] = Variable<String>(symptomsJson.value);
    }
    if (causesJson.present) {
      map['causes_json'] = Variable<String>(causesJson.value);
    }
    if (preventionJson.present) {
      map['prevention_json'] = Variable<String>(preventionJson.value);
    }
    if (actionsJson.present) {
      map['actions_json'] = Variable<String>(actionsJson.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (keywords.present) {
      map['keywords'] = Variable<String>(keywords.value);
    }
    if (sectionsJson.present) {
      map['sections_json'] = Variable<String>(sectionsJson.value);
    }
    if (readMinutes.present) {
      map['read_minutes'] = Variable<int>(readMinutes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KnowledgeArticlesCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('crop: $crop, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('symptomsJson: $symptomsJson, ')
          ..write('causesJson: $causesJson, ')
          ..write('preventionJson: $preventionJson, ')
          ..write('actionsJson: $actionsJson, ')
          ..write('severity: $severity, ')
          ..write('keywords: $keywords, ')
          ..write('sectionsJson: $sectionsJson, ')
          ..write('readMinutes: $readMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeatherCacheTable extends WeatherCache
    with TableInfo<$WeatherCacheTable, WeatherCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeatherCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, payloadJson, source, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weather_cache';
  @override
  VerificationContext validateIntegrity(Insertable<WeatherCacheRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeatherCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeatherCacheRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $WeatherCacheTable createAlias(String alias) {
    return $WeatherCacheTable(attachedDatabase, alias);
  }
}

class WeatherCacheRow extends DataClass implements Insertable<WeatherCacheRow> {
  /// Location key, e.g. `dili`.
  final String id;
  final String payloadJson;

  /// `cached` | `demo` | `manual`.
  final String source;
  final DateTime updatedAt;
  const WeatherCacheRow(
      {required this.id,
      required this.payloadJson,
      required this.source,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['payload_json'] = Variable<String>(payloadJson);
    map['source'] = Variable<String>(source);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WeatherCacheCompanion toCompanion(bool nullToAbsent) {
    return WeatherCacheCompanion(
      id: Value(id),
      payloadJson: Value(payloadJson),
      source: Value(source),
      updatedAt: Value(updatedAt),
    );
  }

  factory WeatherCacheRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeatherCacheRow(
      id: serializer.fromJson<String>(json['id']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      source: serializer.fromJson<String>(json['source']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'source': serializer.toJson<String>(source),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WeatherCacheRow copyWith(
          {String? id,
          String? payloadJson,
          String? source,
          DateTime? updatedAt}) =>
      WeatherCacheRow(
        id: id ?? this.id,
        payloadJson: payloadJson ?? this.payloadJson,
        source: source ?? this.source,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  WeatherCacheRow copyWithCompanion(WeatherCacheCompanion data) {
    return WeatherCacheRow(
      id: data.id.present ? data.id.value : this.id,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      source: data.source.present ? data.source.value : this.source,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeatherCacheRow(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('source: $source, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, payloadJson, source, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeatherCacheRow &&
          other.id == this.id &&
          other.payloadJson == this.payloadJson &&
          other.source == this.source &&
          other.updatedAt == this.updatedAt);
}

class WeatherCacheCompanion extends UpdateCompanion<WeatherCacheRow> {
  final Value<String> id;
  final Value<String> payloadJson;
  final Value<String> source;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WeatherCacheCompanion({
    this.id = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.source = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeatherCacheCompanion.insert({
    required String id,
    required String payloadJson,
    required String source,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        payloadJson = Value(payloadJson),
        source = Value(source),
        updatedAt = Value(updatedAt);
  static Insertable<WeatherCacheRow> custom({
    Expression<String>? id,
    Expression<String>? payloadJson,
    Expression<String>? source,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (source != null) 'source': source,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeatherCacheCompanion copyWith(
      {Value<String>? id,
      Value<String>? payloadJson,
      Value<String>? source,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return WeatherCacheCompanion(
      id: id ?? this.id,
      payloadJson: payloadJson ?? this.payloadJson,
      source: source ?? this.source,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeatherCacheCompanion(')
          ..write('id: $id, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('source: $source, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _attemptCountMeta =
      const VerificationMeta('attemptCount');
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
      'attempt_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastAttemptAtMeta =
      const VerificationMeta('lastAttemptAt');
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>('last_attempt_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityType,
        entityId,
        operation,
        payload,
        createdAt,
        attemptCount,
        lastAttemptAt,
        status,
        errorMessage
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
          _attemptCountMeta,
          attemptCount.isAcceptableOrUnknown(
              data['attempt_count']!, _attemptCountMeta));
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
          _lastAttemptAtMeta,
          lastAttemptAt.isAcceptableOrUnknown(
              data['last_attempt_at']!, _lastAttemptAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      attemptCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempt_count'])!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_attempt_at']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueRow extends DataClass implements Insertable<SyncQueueRow> {
  final int id;
  final String entityType;
  final String entityId;

  /// `create` | `update` | `delete`.
  final String operation;
  final String payload;
  final DateTime createdAt;
  final int attemptCount;
  final DateTime? lastAttemptAt;

  /// `pending` | `syncing` | `synced` | `failed`.
  final String status;
  final String? errorMessage;
  const SyncQueueRow(
      {required this.id,
      required this.entityType,
      required this.entityId,
      required this.operation,
      required this.payload,
      required this.createdAt,
      required this.attemptCount,
      this.lastAttemptAt,
      required this.status,
      this.errorMessage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      payload: Value(payload),
      createdAt: Value(createdAt),
      attemptCount: Value(attemptCount),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      status: Value(status),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
    );
  }

  factory SyncQueueRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueRow(
      id: serializer.fromJson<int>(json['id']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      status: serializer.fromJson<String>(json['status']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'status': serializer.toJson<String>(status),
      'errorMessage': serializer.toJson<String?>(errorMessage),
    };
  }

  SyncQueueRow copyWith(
          {int? id,
          String? entityType,
          String? entityId,
          String? operation,
          String? payload,
          DateTime? createdAt,
          int? attemptCount,
          Value<DateTime?> lastAttemptAt = const Value.absent(),
          String? status,
          Value<String?> errorMessage = const Value.absent()}) =>
      SyncQueueRow(
        id: id ?? this.id,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        operation: operation ?? this.operation,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        attemptCount: attemptCount ?? this.attemptCount,
        lastAttemptAt:
            lastAttemptAt.present ? lastAttemptAt.value : this.lastAttemptAt,
        status: status ?? this.status,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
      );
  SyncQueueRow copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueRow(
      id: data.id.present ? data.id.value : this.id,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      status: data.status.present ? data.status.value : this.status,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueRow(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityType, entityId, operation, payload,
      createdAt, attemptCount, lastAttemptAt, status, errorMessage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueRow &&
          other.id == this.id &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attemptCount == this.attemptCount &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.status == this.status &&
          other.errorMessage == this.errorMessage);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueRow> {
  final Value<int> id;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> attemptCount;
  final Value<DateTime?> lastAttemptAt;
  final Value<String> status;
  final Value<String?> errorMessage;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
    required DateTime createdAt,
    this.attemptCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.status = const Value.absent(),
    this.errorMessage = const Value.absent(),
  })  : entityType = Value(entityType),
        entityId = Value(entityId),
        operation = Value(operation),
        payload = Value(payload),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueRow> custom({
    Expression<int>? id,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? attemptCount,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? status,
    Expression<String>? errorMessage,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (status != null) 'status': status,
      if (errorMessage != null) 'error_message': errorMessage,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? operation,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<int>? attemptCount,
      Value<DateTime?>? lastAttemptAt,
      Value<String>? status,
      Value<String?>? errorMessage}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('status: $status, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(Insertable<AppMetaRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaRow extends DataClass implements Insertable<AppMetaRow> {
  final String key;
  final String value;
  const AppMetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppMetaRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaRow copyWith({String? key, String? value}) => AppMetaRow(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppMetaRow copyWithCompanion(AppMetaCompanion data) {
    return AppMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FarmersTable farmers = $FarmersTable(this);
  late final $FarmsTable farms = $FarmsTable(this);
  late final $FarmLocationsTable farmLocations = $FarmLocationsTable(this);
  late final $CropsTable crops = $CropsTable(this);
  late final $FarmActivitiesTable farmActivities = $FarmActivitiesTable(this);
  late final $RecommendationsTable recommendations =
      $RecommendationsTable(this);
  late final $AlertsTable alerts = $AlertsTable(this);
  late final $CropScansTable cropScans = $CropScansTable(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $KnowledgeArticlesTable knowledgeArticles =
      $KnowledgeArticlesTable(this);
  late final $WeatherCacheTable weatherCache = $WeatherCacheTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final FarmerDao farmerDao = FarmerDao(this as AppDatabase);
  late final FarmDao farmDao = FarmDao(this as AppDatabase);
  late final CropDao cropDao = CropDao(this as AppDatabase);
  late final ScanDao scanDao = ScanDao(this as AppDatabase);
  late final ChatDao chatDao = ChatDao(this as AppDatabase);
  late final KnowledgeDao knowledgeDao = KnowledgeDao(this as AppDatabase);
  late final SyncDao syncDao = SyncDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        farmers,
        farms,
        farmLocations,
        crops,
        farmActivities,
        recommendations,
        alerts,
        cropScans,
        conversations,
        chatMessages,
        knowledgeArticles,
        weatherCache,
        syncQueue,
        appMeta
      ];
}

typedef $$FarmersTableCreateCompanionBuilder = FarmersCompanion Function({
  required String id,
  required String name,
  required String location,
  Value<double> farmingYears,
  Value<String?> phone,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$FarmersTableUpdateCompanionBuilder = FarmersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> location,
  Value<double> farmingYears,
  Value<String?> phone,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$FarmersTableReferences
    extends BaseReferences<_$AppDatabase, $FarmersTable, FarmerRow> {
  $$FarmersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FarmsTable, List<FarmRow>> _farmsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.farms,
          aliasName: 'farmers__id__farms__farmer_id');

  $$FarmsTableProcessedTableManager get farmsRefs {
    final manager = $$FarmsTableTableManager($_db, $_db.farms)
        .filter((f) => f.farmerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_farmsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$FarmersTableFilterComposer
    extends Composer<_$AppDatabase, $FarmersTable> {
  $$FarmersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get farmingYears => $composableBuilder(
      column: $table.farmingYears, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> farmsRefs(
      Expression<bool> Function($$FarmsTableFilterComposer f) f) {
    final $$FarmsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.farms,
        getReferencedColumn: (t) => t.farmerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmsTableFilterComposer(
              $db: $db,
              $table: $db.farms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FarmersTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmersTable> {
  $$FarmersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get farmingYears => $composableBuilder(
      column: $table.farmingYears,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FarmersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmersTable> {
  $$FarmersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<double> get farmingYears => $composableBuilder(
      column: $table.farmingYears, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> farmsRefs<T extends Object>(
      Expression<T> Function($$FarmsTableAnnotationComposer a) f) {
    final $$FarmsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.farms,
        getReferencedColumn: (t) => t.farmerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmsTableAnnotationComposer(
              $db: $db,
              $table: $db.farms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FarmersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FarmersTable,
    FarmerRow,
    $$FarmersTableFilterComposer,
    $$FarmersTableOrderingComposer,
    $$FarmersTableAnnotationComposer,
    $$FarmersTableCreateCompanionBuilder,
    $$FarmersTableUpdateCompanionBuilder,
    (FarmerRow, $$FarmersTableReferences),
    FarmerRow,
    PrefetchHooks Function({bool farmsRefs})> {
  $$FarmersTableTableManager(_$AppDatabase db, $FarmersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> location = const Value.absent(),
            Value<double> farmingYears = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FarmersCompanion(
            id: id,
            name: name,
            location: location,
            farmingYears: farmingYears,
            phone: phone,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String location,
            Value<double> farmingYears = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FarmersCompanion.insert(
            id: id,
            name: name,
            location: location,
            farmingYears: farmingYears,
            phone: phone,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$FarmersTable, FarmerRow>(table),
                    $$FarmersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({farmsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (farmsRefs) db.farms],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (farmsRefs)
                    await $_getPrefetchedData<FarmerRow, $FarmersTable,
                            FarmRow>(
                        currentTable: table,
                        referencedTable:
                            $$FarmersTableReferences._farmsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FarmersTableReferences(db, table, p0).farmsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.farmerId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$FarmersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FarmersTable,
    FarmerRow,
    $$FarmersTableFilterComposer,
    $$FarmersTableOrderingComposer,
    $$FarmersTableAnnotationComposer,
    $$FarmersTableCreateCompanionBuilder,
    $$FarmersTableUpdateCompanionBuilder,
    (FarmerRow, $$FarmersTableReferences),
    FarmerRow,
    PrefetchHooks Function({bool farmsRefs})>;
typedef $$FarmsTableCreateCompanionBuilder = FarmsCompanion Function({
  required String id,
  required String farmerId,
  required String name,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$FarmsTableUpdateCompanionBuilder = FarmsCompanion Function({
  Value<String> id,
  Value<String> farmerId,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$FarmsTableReferences
    extends BaseReferences<_$AppDatabase, $FarmsTable, FarmRow> {
  $$FarmsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FarmersTable _farmerIdTable(_$AppDatabase db) =>
      db.farmers.createAlias('farms__farmer_id__farmers__id');

  $$FarmersTableProcessedTableManager get farmerId {
    final $_column = $_itemColumn<String>('farmer_id')!;

    final manager = $$FarmersTableTableManager($_db, $_db.farmers)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_farmerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$FarmLocationsTable, List<FarmLocationRow>>
      _farmLocationsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.farmLocations,
              aliasName: 'farms__id__farm_locations__farm_id');

  $$FarmLocationsTableProcessedTableManager get farmLocationsRefs {
    final manager = $$FarmLocationsTableTableManager($_db, $_db.farmLocations)
        .filter((f) => f.farmId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_farmLocationsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CropsTable, List<CropRow>> _cropsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.crops,
          aliasName: 'farms__id__crops__farm_id');

  $$CropsTableProcessedTableManager get cropsRefs {
    final manager = $$CropsTableTableManager($_db, $_db.crops)
        .filter((f) => f.farmId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_cropsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$FarmActivitiesTable, List<FarmActivityRow>>
      _farmActivitiesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.farmActivities,
              aliasName: 'farms__id__farm_activities__farm_id');

  $$FarmActivitiesTableProcessedTableManager get farmActivitiesRefs {
    final manager = $$FarmActivitiesTableTableManager($_db, $_db.farmActivities)
        .filter((f) => f.farmId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_farmActivitiesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$FarmsTableFilterComposer extends Composer<_$AppDatabase, $FarmsTable> {
  $$FarmsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$FarmersTableFilterComposer get farmerId {
    final $$FarmersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.farmerId,
        referencedTable: $db.farmers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmersTableFilterComposer(
              $db: $db,
              $table: $db.farmers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> farmLocationsRefs(
      Expression<bool> Function($$FarmLocationsTableFilterComposer f) f) {
    final $$FarmLocationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.farmLocations,
        getReferencedColumn: (t) => t.farmId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmLocationsTableFilterComposer(
              $db: $db,
              $table: $db.farmLocations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> cropsRefs(
      Expression<bool> Function($$CropsTableFilterComposer f) f) {
    final $$CropsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.crops,
        getReferencedColumn: (t) => t.farmId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CropsTableFilterComposer(
              $db: $db,
              $table: $db.crops,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> farmActivitiesRefs(
      Expression<bool> Function($$FarmActivitiesTableFilterComposer f) f) {
    final $$FarmActivitiesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.farmActivities,
        getReferencedColumn: (t) => t.farmId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmActivitiesTableFilterComposer(
              $db: $db,
              $table: $db.farmActivities,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FarmsTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmsTable> {
  $$FarmsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$FarmersTableOrderingComposer get farmerId {
    final $$FarmersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.farmerId,
        referencedTable: $db.farmers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmersTableOrderingComposer(
              $db: $db,
              $table: $db.farmers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FarmsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmsTable> {
  $$FarmsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FarmersTableAnnotationComposer get farmerId {
    final $$FarmersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.farmerId,
        referencedTable: $db.farmers,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmersTableAnnotationComposer(
              $db: $db,
              $table: $db.farmers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> farmLocationsRefs<T extends Object>(
      Expression<T> Function($$FarmLocationsTableAnnotationComposer a) f) {
    final $$FarmLocationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.farmLocations,
        getReferencedColumn: (t) => t.farmId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmLocationsTableAnnotationComposer(
              $db: $db,
              $table: $db.farmLocations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> cropsRefs<T extends Object>(
      Expression<T> Function($$CropsTableAnnotationComposer a) f) {
    final $$CropsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.crops,
        getReferencedColumn: (t) => t.farmId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CropsTableAnnotationComposer(
              $db: $db,
              $table: $db.crops,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> farmActivitiesRefs<T extends Object>(
      Expression<T> Function($$FarmActivitiesTableAnnotationComposer a) f) {
    final $$FarmActivitiesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.farmActivities,
        getReferencedColumn: (t) => t.farmId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmActivitiesTableAnnotationComposer(
              $db: $db,
              $table: $db.farmActivities,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FarmsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FarmsTable,
    FarmRow,
    $$FarmsTableFilterComposer,
    $$FarmsTableOrderingComposer,
    $$FarmsTableAnnotationComposer,
    $$FarmsTableCreateCompanionBuilder,
    $$FarmsTableUpdateCompanionBuilder,
    (FarmRow, $$FarmsTableReferences),
    FarmRow,
    PrefetchHooks Function(
        {bool farmerId,
        bool farmLocationsRefs,
        bool cropsRefs,
        bool farmActivitiesRefs})> {
  $$FarmsTableTableManager(_$AppDatabase db, $FarmsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> farmerId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FarmsCompanion(
            id: id,
            farmerId: farmerId,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String farmerId,
            required String name,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FarmsCompanion.insert(
            id: id,
            farmerId: farmerId,
            name: name,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$FarmsTable, FarmRow>(table),
                    $$FarmsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {farmerId = false,
              farmLocationsRefs = false,
              cropsRefs = false,
              farmActivitiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (farmLocationsRefs) db.farmLocations,
                if (cropsRefs) db.crops,
                if (farmActivitiesRefs) db.farmActivities
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (farmerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.farmerId,
                    referencedTable: $$FarmsTableReferences._farmerIdTable(db),
                    referencedColumn:
                        $$FarmsTableReferences._farmerIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (farmLocationsRefs)
                    await $_getPrefetchedData<FarmRow, $FarmsTable,
                            FarmLocationRow>(
                        currentTable: table,
                        referencedTable:
                            $$FarmsTableReferences._farmLocationsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FarmsTableReferences(db, table, p0)
                                .farmLocationsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.farmId == item.id),
                        typedResults: items),
                  if (cropsRefs)
                    await $_getPrefetchedData<FarmRow, $FarmsTable, CropRow>(
                        currentTable: table,
                        referencedTable:
                            $$FarmsTableReferences._cropsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FarmsTableReferences(db, table, p0).cropsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.farmId == item.id),
                        typedResults: items),
                  if (farmActivitiesRefs)
                    await $_getPrefetchedData<FarmRow, $FarmsTable,
                            FarmActivityRow>(
                        currentTable: table,
                        referencedTable:
                            $$FarmsTableReferences._farmActivitiesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FarmsTableReferences(db, table, p0)
                                .farmActivitiesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.farmId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$FarmsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FarmsTable,
    FarmRow,
    $$FarmsTableFilterComposer,
    $$FarmsTableOrderingComposer,
    $$FarmsTableAnnotationComposer,
    $$FarmsTableCreateCompanionBuilder,
    $$FarmsTableUpdateCompanionBuilder,
    (FarmRow, $$FarmsTableReferences),
    FarmRow,
    PrefetchHooks Function(
        {bool farmerId,
        bool farmLocationsRefs,
        bool cropsRefs,
        bool farmActivitiesRefs})>;
typedef $$FarmLocationsTableCreateCompanionBuilder = FarmLocationsCompanion
    Function({
  required String id,
  required String farmId,
  required String name,
  required double areaHa,
  required String district,
  Value<double?> latitude,
  Value<double?> longitude,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$FarmLocationsTableUpdateCompanionBuilder = FarmLocationsCompanion
    Function({
  Value<String> id,
  Value<String> farmId,
  Value<String> name,
  Value<double> areaHa,
  Value<String> district,
  Value<double?> latitude,
  Value<double?> longitude,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$FarmLocationsTableReferences extends BaseReferences<_$AppDatabase,
    $FarmLocationsTable, FarmLocationRow> {
  $$FarmLocationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $FarmsTable _farmIdTable(_$AppDatabase db) =>
      db.farms.createAlias('farm_locations__farm_id__farms__id');

  $$FarmsTableProcessedTableManager get farmId {
    final $_column = $_itemColumn<String>('farm_id')!;

    final manager = $$FarmsTableTableManager($_db, $_db.farms)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_farmIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FarmLocationsTableFilterComposer
    extends Composer<_$AppDatabase, $FarmLocationsTable> {
  $$FarmLocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get areaHa => $composableBuilder(
      column: $table.areaHa, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get district => $composableBuilder(
      column: $table.district, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$FarmsTableFilterComposer get farmId {
    final $$FarmsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.farmId,
        referencedTable: $db.farms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmsTableFilterComposer(
              $db: $db,
              $table: $db.farms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FarmLocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmLocationsTable> {
  $$FarmLocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get areaHa => $composableBuilder(
      column: $table.areaHa, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get district => $composableBuilder(
      column: $table.district, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get latitude => $composableBuilder(
      column: $table.latitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get longitude => $composableBuilder(
      column: $table.longitude, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$FarmsTableOrderingComposer get farmId {
    final $$FarmsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.farmId,
        referencedTable: $db.farms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmsTableOrderingComposer(
              $db: $db,
              $table: $db.farms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FarmLocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmLocationsTable> {
  $$FarmLocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get areaHa =>
      $composableBuilder(column: $table.areaHa, builder: (column) => column);

  GeneratedColumn<String> get district =>
      $composableBuilder(column: $table.district, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FarmsTableAnnotationComposer get farmId {
    final $$FarmsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.farmId,
        referencedTable: $db.farms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmsTableAnnotationComposer(
              $db: $db,
              $table: $db.farms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FarmLocationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FarmLocationsTable,
    FarmLocationRow,
    $$FarmLocationsTableFilterComposer,
    $$FarmLocationsTableOrderingComposer,
    $$FarmLocationsTableAnnotationComposer,
    $$FarmLocationsTableCreateCompanionBuilder,
    $$FarmLocationsTableUpdateCompanionBuilder,
    (FarmLocationRow, $$FarmLocationsTableReferences),
    FarmLocationRow,
    PrefetchHooks Function({bool farmId})> {
  $$FarmLocationsTableTableManager(_$AppDatabase db, $FarmLocationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmLocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmLocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmLocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> farmId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> areaHa = const Value.absent(),
            Value<String> district = const Value.absent(),
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FarmLocationsCompanion(
            id: id,
            farmId: farmId,
            name: name,
            areaHa: areaHa,
            district: district,
            latitude: latitude,
            longitude: longitude,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String farmId,
            required String name,
            required double areaHa,
            required String district,
            Value<double?> latitude = const Value.absent(),
            Value<double?> longitude = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FarmLocationsCompanion.insert(
            id: id,
            farmId: farmId,
            name: name,
            areaHa: areaHa,
            district: district,
            latitude: latitude,
            longitude: longitude,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$FarmLocationsTable, FarmLocationRow>(table),
                    $$FarmLocationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({farmId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (farmId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.farmId,
                    referencedTable:
                        $$FarmLocationsTableReferences._farmIdTable(db),
                    referencedColumn:
                        $$FarmLocationsTableReferences._farmIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FarmLocationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FarmLocationsTable,
    FarmLocationRow,
    $$FarmLocationsTableFilterComposer,
    $$FarmLocationsTableOrderingComposer,
    $$FarmLocationsTableAnnotationComposer,
    $$FarmLocationsTableCreateCompanionBuilder,
    $$FarmLocationsTableUpdateCompanionBuilder,
    (FarmLocationRow, $$FarmLocationsTableReferences),
    FarmLocationRow,
    PrefetchHooks Function({bool farmId})>;
typedef $$CropsTableCreateCompanionBuilder = CropsCompanion Function({
  required String id,
  required String farmId,
  Value<String?> locationId,
  required String locationName,
  required String name,
  Value<String?> variety,
  required double areaHa,
  Value<String> status,
  Value<String> growthStage,
  required DateTime plantedOn,
  Value<String?> note,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CropsTableUpdateCompanionBuilder = CropsCompanion Function({
  Value<String> id,
  Value<String> farmId,
  Value<String?> locationId,
  Value<String> locationName,
  Value<String> name,
  Value<String?> variety,
  Value<double> areaHa,
  Value<String> status,
  Value<String> growthStage,
  Value<DateTime> plantedOn,
  Value<String?> note,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$CropsTableReferences
    extends BaseReferences<_$AppDatabase, $CropsTable, CropRow> {
  $$CropsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FarmsTable _farmIdTable(_$AppDatabase db) =>
      db.farms.createAlias('crops__farm_id__farms__id');

  $$FarmsTableProcessedTableManager get farmId {
    final $_column = $_itemColumn<String>('farm_id')!;

    final manager = $$FarmsTableTableManager($_db, $_db.farms)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_farmIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CropsTableFilterComposer extends Composer<_$AppDatabase, $CropsTable> {
  $$CropsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationName => $composableBuilder(
      column: $table.locationName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get variety => $composableBuilder(
      column: $table.variety, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get areaHa => $composableBuilder(
      column: $table.areaHa, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get growthStage => $composableBuilder(
      column: $table.growthStage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get plantedOn => $composableBuilder(
      column: $table.plantedOn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$FarmsTableFilterComposer get farmId {
    final $$FarmsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.farmId,
        referencedTable: $db.farms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmsTableFilterComposer(
              $db: $db,
              $table: $db.farms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CropsTableOrderingComposer
    extends Composer<_$AppDatabase, $CropsTable> {
  $$CropsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationName => $composableBuilder(
      column: $table.locationName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get variety => $composableBuilder(
      column: $table.variety, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get areaHa => $composableBuilder(
      column: $table.areaHa, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get growthStage => $composableBuilder(
      column: $table.growthStage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get plantedOn => $composableBuilder(
      column: $table.plantedOn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$FarmsTableOrderingComposer get farmId {
    final $$FarmsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.farmId,
        referencedTable: $db.farms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmsTableOrderingComposer(
              $db: $db,
              $table: $db.farms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CropsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CropsTable> {
  $$CropsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
      column: $table.locationId, builder: (column) => column);

  GeneratedColumn<String> get locationName => $composableBuilder(
      column: $table.locationName, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get variety =>
      $composableBuilder(column: $table.variety, builder: (column) => column);

  GeneratedColumn<double> get areaHa =>
      $composableBuilder(column: $table.areaHa, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get growthStage => $composableBuilder(
      column: $table.growthStage, builder: (column) => column);

  GeneratedColumn<DateTime> get plantedOn =>
      $composableBuilder(column: $table.plantedOn, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FarmsTableAnnotationComposer get farmId {
    final $$FarmsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.farmId,
        referencedTable: $db.farms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmsTableAnnotationComposer(
              $db: $db,
              $table: $db.farms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CropsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CropsTable,
    CropRow,
    $$CropsTableFilterComposer,
    $$CropsTableOrderingComposer,
    $$CropsTableAnnotationComposer,
    $$CropsTableCreateCompanionBuilder,
    $$CropsTableUpdateCompanionBuilder,
    (CropRow, $$CropsTableReferences),
    CropRow,
    PrefetchHooks Function({bool farmId})> {
  $$CropsTableTableManager(_$AppDatabase db, $CropsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CropsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CropsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CropsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> farmId = const Value.absent(),
            Value<String?> locationId = const Value.absent(),
            Value<String> locationName = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> variety = const Value.absent(),
            Value<double> areaHa = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> growthStage = const Value.absent(),
            Value<DateTime> plantedOn = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CropsCompanion(
            id: id,
            farmId: farmId,
            locationId: locationId,
            locationName: locationName,
            name: name,
            variety: variety,
            areaHa: areaHa,
            status: status,
            growthStage: growthStage,
            plantedOn: plantedOn,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String farmId,
            Value<String?> locationId = const Value.absent(),
            required String locationName,
            required String name,
            Value<String?> variety = const Value.absent(),
            required double areaHa,
            Value<String> status = const Value.absent(),
            Value<String> growthStage = const Value.absent(),
            required DateTime plantedOn,
            Value<String?> note = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CropsCompanion.insert(
            id: id,
            farmId: farmId,
            locationId: locationId,
            locationName: locationName,
            name: name,
            variety: variety,
            areaHa: areaHa,
            status: status,
            growthStage: growthStage,
            plantedOn: plantedOn,
            note: note,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CropsTable, CropRow>(table),
                    $$CropsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({farmId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (farmId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.farmId,
                    referencedTable: $$CropsTableReferences._farmIdTable(db),
                    referencedColumn:
                        $$CropsTableReferences._farmIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CropsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CropsTable,
    CropRow,
    $$CropsTableFilterComposer,
    $$CropsTableOrderingComposer,
    $$CropsTableAnnotationComposer,
    $$CropsTableCreateCompanionBuilder,
    $$CropsTableUpdateCompanionBuilder,
    (CropRow, $$CropsTableReferences),
    CropRow,
    PrefetchHooks Function({bool farmId})>;
typedef $$FarmActivitiesTableCreateCompanionBuilder = FarmActivitiesCompanion
    Function({
  required String id,
  required String farmId,
  Value<String?> cropId,
  Value<String?> cropName,
  required String type,
  required String title,
  required String detail,
  required DateTime date,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$FarmActivitiesTableUpdateCompanionBuilder = FarmActivitiesCompanion
    Function({
  Value<String> id,
  Value<String> farmId,
  Value<String?> cropId,
  Value<String?> cropName,
  Value<String> type,
  Value<String> title,
  Value<String> detail,
  Value<DateTime> date,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$FarmActivitiesTableReferences extends BaseReferences<
    _$AppDatabase, $FarmActivitiesTable, FarmActivityRow> {
  $$FarmActivitiesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $FarmsTable _farmIdTable(_$AppDatabase db) =>
      db.farms.createAlias('farm_activities__farm_id__farms__id');

  $$FarmsTableProcessedTableManager get farmId {
    final $_column = $_itemColumn<String>('farm_id')!;

    final manager = $$FarmsTableTableManager($_db, $_db.farms)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_farmIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$FarmActivitiesTableFilterComposer
    extends Composer<_$AppDatabase, $FarmActivitiesTable> {
  $$FarmActivitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cropId => $composableBuilder(
      column: $table.cropId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cropName => $composableBuilder(
      column: $table.cropName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$FarmsTableFilterComposer get farmId {
    final $$FarmsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.farmId,
        referencedTable: $db.farms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmsTableFilterComposer(
              $db: $db,
              $table: $db.farms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FarmActivitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $FarmActivitiesTable> {
  $$FarmActivitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cropId => $composableBuilder(
      column: $table.cropId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cropName => $composableBuilder(
      column: $table.cropName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$FarmsTableOrderingComposer get farmId {
    final $$FarmsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.farmId,
        referencedTable: $db.farms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmsTableOrderingComposer(
              $db: $db,
              $table: $db.farms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FarmActivitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FarmActivitiesTable> {
  $$FarmActivitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cropId =>
      $composableBuilder(column: $table.cropId, builder: (column) => column);

  GeneratedColumn<String> get cropName =>
      $composableBuilder(column: $table.cropName, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$FarmsTableAnnotationComposer get farmId {
    final $$FarmsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.farmId,
        referencedTable: $db.farms,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FarmsTableAnnotationComposer(
              $db: $db,
              $table: $db.farms,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FarmActivitiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FarmActivitiesTable,
    FarmActivityRow,
    $$FarmActivitiesTableFilterComposer,
    $$FarmActivitiesTableOrderingComposer,
    $$FarmActivitiesTableAnnotationComposer,
    $$FarmActivitiesTableCreateCompanionBuilder,
    $$FarmActivitiesTableUpdateCompanionBuilder,
    (FarmActivityRow, $$FarmActivitiesTableReferences),
    FarmActivityRow,
    PrefetchHooks Function({bool farmId})> {
  $$FarmActivitiesTableTableManager(
      _$AppDatabase db, $FarmActivitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FarmActivitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FarmActivitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FarmActivitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> farmId = const Value.absent(),
            Value<String?> cropId = const Value.absent(),
            Value<String?> cropName = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> detail = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FarmActivitiesCompanion(
            id: id,
            farmId: farmId,
            cropId: cropId,
            cropName: cropName,
            type: type,
            title: title,
            detail: detail,
            date: date,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String farmId,
            Value<String?> cropId = const Value.absent(),
            Value<String?> cropName = const Value.absent(),
            required String type,
            required String title,
            required String detail,
            required DateTime date,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FarmActivitiesCompanion.insert(
            id: id,
            farmId: farmId,
            cropId: cropId,
            cropName: cropName,
            type: type,
            title: title,
            detail: detail,
            date: date,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$FarmActivitiesTable, FarmActivityRow>(table),
                    $$FarmActivitiesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({farmId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (farmId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.farmId,
                    referencedTable:
                        $$FarmActivitiesTableReferences._farmIdTable(db),
                    referencedColumn:
                        $$FarmActivitiesTableReferences._farmIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$FarmActivitiesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FarmActivitiesTable,
    FarmActivityRow,
    $$FarmActivitiesTableFilterComposer,
    $$FarmActivitiesTableOrderingComposer,
    $$FarmActivitiesTableAnnotationComposer,
    $$FarmActivitiesTableCreateCompanionBuilder,
    $$FarmActivitiesTableUpdateCompanionBuilder,
    (FarmActivityRow, $$FarmActivitiesTableReferences),
    FarmActivityRow,
    PrefetchHooks Function({bool farmId})>;
typedef $$RecommendationsTableCreateCompanionBuilder = RecommendationsCompanion
    Function({
  required String id,
  required String kind,
  required String title,
  required String detail,
  Value<bool> dismissed,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$RecommendationsTableUpdateCompanionBuilder = RecommendationsCompanion
    Function({
  Value<String> id,
  Value<String> kind,
  Value<String> title,
  Value<String> detail,
  Value<bool> dismissed,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$RecommendationsTableFilterComposer
    extends Composer<_$AppDatabase, $RecommendationsTable> {
  $$RecommendationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dismissed => $composableBuilder(
      column: $table.dismissed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$RecommendationsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecommendationsTable> {
  $$RecommendationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dismissed => $composableBuilder(
      column: $table.dismissed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$RecommendationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecommendationsTable> {
  $$RecommendationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<bool> get dismissed =>
      $composableBuilder(column: $table.dismissed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RecommendationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecommendationsTable,
    RecommendationRow,
    $$RecommendationsTableFilterComposer,
    $$RecommendationsTableOrderingComposer,
    $$RecommendationsTableAnnotationComposer,
    $$RecommendationsTableCreateCompanionBuilder,
    $$RecommendationsTableUpdateCompanionBuilder,
    (
      RecommendationRow,
      BaseReferences<_$AppDatabase, $RecommendationsTable, RecommendationRow>
    ),
    RecommendationRow,
    PrefetchHooks Function()> {
  $$RecommendationsTableTableManager(
      _$AppDatabase db, $RecommendationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecommendationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecommendationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecommendationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> detail = const Value.absent(),
            Value<bool> dismissed = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecommendationsCompanion(
            id: id,
            kind: kind,
            title: title,
            detail: detail,
            dismissed: dismissed,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String kind,
            required String title,
            required String detail,
            Value<bool> dismissed = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RecommendationsCompanion.insert(
            id: id,
            kind: kind,
            title: title,
            detail: detail,
            dismissed: dismissed,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$RecommendationsTable, RecommendationRow>(
                        table),
                    BaseReferences<_$AppDatabase, $RecommendationsTable,
                        RecommendationRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RecommendationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecommendationsTable,
    RecommendationRow,
    $$RecommendationsTableFilterComposer,
    $$RecommendationsTableOrderingComposer,
    $$RecommendationsTableAnnotationComposer,
    $$RecommendationsTableCreateCompanionBuilder,
    $$RecommendationsTableUpdateCompanionBuilder,
    (
      RecommendationRow,
      BaseReferences<_$AppDatabase, $RecommendationsTable, RecommendationRow>
    ),
    RecommendationRow,
    PrefetchHooks Function()>;
typedef $$AlertsTableCreateCompanionBuilder = AlertsCompanion Function({
  required String id,
  required String kind,
  required String title,
  required String detail,
  required String action,
  required DateTime date,
  Value<bool> read,
  Value<int> rowid,
});
typedef $$AlertsTableUpdateCompanionBuilder = AlertsCompanion Function({
  Value<String> id,
  Value<String> kind,
  Value<String> title,
  Value<String> detail,
  Value<String> action,
  Value<DateTime> date,
  Value<bool> read,
  Value<int> rowid,
});

class $$AlertsTableFilterComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get read => $composableBuilder(
      column: $table.read, builder: (column) => ColumnFilters(column));
}

class $$AlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get detail => $composableBuilder(
      column: $table.detail, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get read => $composableBuilder(
      column: $table.read, builder: (column) => ColumnOrderings(column));
}

class $$AlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get detail =>
      $composableBuilder(column: $table.detail, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get read =>
      $composableBuilder(column: $table.read, builder: (column) => column);
}

class $$AlertsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AlertsTable,
    AlertRow,
    $$AlertsTableFilterComposer,
    $$AlertsTableOrderingComposer,
    $$AlertsTableAnnotationComposer,
    $$AlertsTableCreateCompanionBuilder,
    $$AlertsTableUpdateCompanionBuilder,
    (AlertRow, BaseReferences<_$AppDatabase, $AlertsTable, AlertRow>),
    AlertRow,
    PrefetchHooks Function()> {
  $$AlertsTableTableManager(_$AppDatabase db, $AlertsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> detail = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<bool> read = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlertsCompanion(
            id: id,
            kind: kind,
            title: title,
            detail: detail,
            action: action,
            date: date,
            read: read,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String kind,
            required String title,
            required String detail,
            required String action,
            required DateTime date,
            Value<bool> read = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AlertsCompanion.insert(
            id: id,
            kind: kind,
            title: title,
            detail: detail,
            action: action,
            date: date,
            read: read,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AlertsTable, AlertRow>(table),
                    BaseReferences<_$AppDatabase, $AlertsTable, AlertRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AlertsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AlertsTable,
    AlertRow,
    $$AlertsTableFilterComposer,
    $$AlertsTableOrderingComposer,
    $$AlertsTableAnnotationComposer,
    $$AlertsTableCreateCompanionBuilder,
    $$AlertsTableUpdateCompanionBuilder,
    (AlertRow, BaseReferences<_$AppDatabase, $AlertsTable, AlertRow>),
    AlertRow,
    PrefetchHooks Function()>;
typedef $$CropScansTableCreateCompanionBuilder = CropScansCompanion Function({
  required String id,
  Value<String?> cropId,
  required String cropName,
  required String imagePath,
  required String condition,
  required String issueLabel,
  required double confidence,
  required String severity,
  required String affectedArea,
  required String growthStage,
  required String explanation,
  required String actionsJson,
  required String status,
  required String modelName,
  Value<int> inferenceTimeMs,
  required String engine,
  Value<double> margin,
  Value<String?> runnerUp,
  Value<String?> onlineSummary,
  Value<String?> onlineCrop,
  Value<String?> onlineCondition,
  Value<String?> onlineConfidence,
  Value<String?> onlineActionsJson,
  Value<String?> onlineModel,
  Value<bool?> onlineConfirms,
  Value<bool?> onlineAskAPerson,
  Value<String?> onlineCaveat,
  Value<DateTime?> onlineAt,
  Value<bool> savedToFarm,
  Value<bool> pendingSync,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CropScansTableUpdateCompanionBuilder = CropScansCompanion Function({
  Value<String> id,
  Value<String?> cropId,
  Value<String> cropName,
  Value<String> imagePath,
  Value<String> condition,
  Value<String> issueLabel,
  Value<double> confidence,
  Value<String> severity,
  Value<String> affectedArea,
  Value<String> growthStage,
  Value<String> explanation,
  Value<String> actionsJson,
  Value<String> status,
  Value<String> modelName,
  Value<int> inferenceTimeMs,
  Value<String> engine,
  Value<double> margin,
  Value<String?> runnerUp,
  Value<String?> onlineSummary,
  Value<String?> onlineCrop,
  Value<String?> onlineCondition,
  Value<String?> onlineConfidence,
  Value<String?> onlineActionsJson,
  Value<String?> onlineModel,
  Value<bool?> onlineConfirms,
  Value<bool?> onlineAskAPerson,
  Value<String?> onlineCaveat,
  Value<DateTime?> onlineAt,
  Value<bool> savedToFarm,
  Value<bool> pendingSync,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$CropScansTableFilterComposer
    extends Composer<_$AppDatabase, $CropScansTable> {
  $$CropScansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cropId => $composableBuilder(
      column: $table.cropId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cropName => $composableBuilder(
      column: $table.cropName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get issueLabel => $composableBuilder(
      column: $table.issueLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get affectedArea => $composableBuilder(
      column: $table.affectedArea, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get growthStage => $composableBuilder(
      column: $table.growthStage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionsJson => $composableBuilder(
      column: $table.actionsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get inferenceTimeMs => $composableBuilder(
      column: $table.inferenceTimeMs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get engine => $composableBuilder(
      column: $table.engine, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get margin => $composableBuilder(
      column: $table.margin, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get runnerUp => $composableBuilder(
      column: $table.runnerUp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get onlineSummary => $composableBuilder(
      column: $table.onlineSummary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get onlineCrop => $composableBuilder(
      column: $table.onlineCrop, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get onlineCondition => $composableBuilder(
      column: $table.onlineCondition,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get onlineConfidence => $composableBuilder(
      column: $table.onlineConfidence,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get onlineActionsJson => $composableBuilder(
      column: $table.onlineActionsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get onlineModel => $composableBuilder(
      column: $table.onlineModel, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onlineConfirms => $composableBuilder(
      column: $table.onlineConfirms,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get onlineAskAPerson => $composableBuilder(
      column: $table.onlineAskAPerson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get onlineCaveat => $composableBuilder(
      column: $table.onlineCaveat, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get onlineAt => $composableBuilder(
      column: $table.onlineAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get savedToFarm => $composableBuilder(
      column: $table.savedToFarm, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pendingSync => $composableBuilder(
      column: $table.pendingSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$CropScansTableOrderingComposer
    extends Composer<_$AppDatabase, $CropScansTable> {
  $$CropScansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cropId => $composableBuilder(
      column: $table.cropId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cropName => $composableBuilder(
      column: $table.cropName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imagePath => $composableBuilder(
      column: $table.imagePath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get condition => $composableBuilder(
      column: $table.condition, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get issueLabel => $composableBuilder(
      column: $table.issueLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get affectedArea => $composableBuilder(
      column: $table.affectedArea,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get growthStage => $composableBuilder(
      column: $table.growthStage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionsJson => $composableBuilder(
      column: $table.actionsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get modelName => $composableBuilder(
      column: $table.modelName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get inferenceTimeMs => $composableBuilder(
      column: $table.inferenceTimeMs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get engine => $composableBuilder(
      column: $table.engine, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get margin => $composableBuilder(
      column: $table.margin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get runnerUp => $composableBuilder(
      column: $table.runnerUp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get onlineSummary => $composableBuilder(
      column: $table.onlineSummary,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get onlineCrop => $composableBuilder(
      column: $table.onlineCrop, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get onlineCondition => $composableBuilder(
      column: $table.onlineCondition,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get onlineConfidence => $composableBuilder(
      column: $table.onlineConfidence,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get onlineActionsJson => $composableBuilder(
      column: $table.onlineActionsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get onlineModel => $composableBuilder(
      column: $table.onlineModel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onlineConfirms => $composableBuilder(
      column: $table.onlineConfirms,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get onlineAskAPerson => $composableBuilder(
      column: $table.onlineAskAPerson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get onlineCaveat => $composableBuilder(
      column: $table.onlineCaveat,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get onlineAt => $composableBuilder(
      column: $table.onlineAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get savedToFarm => $composableBuilder(
      column: $table.savedToFarm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
      column: $table.pendingSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$CropScansTableAnnotationComposer
    extends Composer<_$AppDatabase, $CropScansTable> {
  $$CropScansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cropId =>
      $composableBuilder(column: $table.cropId, builder: (column) => column);

  GeneratedColumn<String> get cropName =>
      $composableBuilder(column: $table.cropName, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get condition =>
      $composableBuilder(column: $table.condition, builder: (column) => column);

  GeneratedColumn<String> get issueLabel => $composableBuilder(
      column: $table.issueLabel, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get affectedArea => $composableBuilder(
      column: $table.affectedArea, builder: (column) => column);

  GeneratedColumn<String> get growthStage => $composableBuilder(
      column: $table.growthStage, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => column);

  GeneratedColumn<String> get actionsJson => $composableBuilder(
      column: $table.actionsJson, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get modelName =>
      $composableBuilder(column: $table.modelName, builder: (column) => column);

  GeneratedColumn<int> get inferenceTimeMs => $composableBuilder(
      column: $table.inferenceTimeMs, builder: (column) => column);

  GeneratedColumn<String> get engine =>
      $composableBuilder(column: $table.engine, builder: (column) => column);

  GeneratedColumn<double> get margin =>
      $composableBuilder(column: $table.margin, builder: (column) => column);

  GeneratedColumn<String> get runnerUp =>
      $composableBuilder(column: $table.runnerUp, builder: (column) => column);

  GeneratedColumn<String> get onlineSummary => $composableBuilder(
      column: $table.onlineSummary, builder: (column) => column);

  GeneratedColumn<String> get onlineCrop => $composableBuilder(
      column: $table.onlineCrop, builder: (column) => column);

  GeneratedColumn<String> get onlineCondition => $composableBuilder(
      column: $table.onlineCondition, builder: (column) => column);

  GeneratedColumn<String> get onlineConfidence => $composableBuilder(
      column: $table.onlineConfidence, builder: (column) => column);

  GeneratedColumn<String> get onlineActionsJson => $composableBuilder(
      column: $table.onlineActionsJson, builder: (column) => column);

  GeneratedColumn<String> get onlineModel => $composableBuilder(
      column: $table.onlineModel, builder: (column) => column);

  GeneratedColumn<bool> get onlineConfirms => $composableBuilder(
      column: $table.onlineConfirms, builder: (column) => column);

  GeneratedColumn<bool> get onlineAskAPerson => $composableBuilder(
      column: $table.onlineAskAPerson, builder: (column) => column);

  GeneratedColumn<String> get onlineCaveat => $composableBuilder(
      column: $table.onlineCaveat, builder: (column) => column);

  GeneratedColumn<DateTime> get onlineAt =>
      $composableBuilder(column: $table.onlineAt, builder: (column) => column);

  GeneratedColumn<bool> get savedToFarm => $composableBuilder(
      column: $table.savedToFarm, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
      column: $table.pendingSync, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CropScansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CropScansTable,
    CropScanRow,
    $$CropScansTableFilterComposer,
    $$CropScansTableOrderingComposer,
    $$CropScansTableAnnotationComposer,
    $$CropScansTableCreateCompanionBuilder,
    $$CropScansTableUpdateCompanionBuilder,
    (CropScanRow, BaseReferences<_$AppDatabase, $CropScansTable, CropScanRow>),
    CropScanRow,
    PrefetchHooks Function()> {
  $$CropScansTableTableManager(_$AppDatabase db, $CropScansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CropScansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CropScansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CropScansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> cropId = const Value.absent(),
            Value<String> cropName = const Value.absent(),
            Value<String> imagePath = const Value.absent(),
            Value<String> condition = const Value.absent(),
            Value<String> issueLabel = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<String> severity = const Value.absent(),
            Value<String> affectedArea = const Value.absent(),
            Value<String> growthStage = const Value.absent(),
            Value<String> explanation = const Value.absent(),
            Value<String> actionsJson = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> modelName = const Value.absent(),
            Value<int> inferenceTimeMs = const Value.absent(),
            Value<String> engine = const Value.absent(),
            Value<double> margin = const Value.absent(),
            Value<String?> runnerUp = const Value.absent(),
            Value<String?> onlineSummary = const Value.absent(),
            Value<String?> onlineCrop = const Value.absent(),
            Value<String?> onlineCondition = const Value.absent(),
            Value<String?> onlineConfidence = const Value.absent(),
            Value<String?> onlineActionsJson = const Value.absent(),
            Value<String?> onlineModel = const Value.absent(),
            Value<bool?> onlineConfirms = const Value.absent(),
            Value<bool?> onlineAskAPerson = const Value.absent(),
            Value<String?> onlineCaveat = const Value.absent(),
            Value<DateTime?> onlineAt = const Value.absent(),
            Value<bool> savedToFarm = const Value.absent(),
            Value<bool> pendingSync = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CropScansCompanion(
            id: id,
            cropId: cropId,
            cropName: cropName,
            imagePath: imagePath,
            condition: condition,
            issueLabel: issueLabel,
            confidence: confidence,
            severity: severity,
            affectedArea: affectedArea,
            growthStage: growthStage,
            explanation: explanation,
            actionsJson: actionsJson,
            status: status,
            modelName: modelName,
            inferenceTimeMs: inferenceTimeMs,
            engine: engine,
            margin: margin,
            runnerUp: runnerUp,
            onlineSummary: onlineSummary,
            onlineCrop: onlineCrop,
            onlineCondition: onlineCondition,
            onlineConfidence: onlineConfidence,
            onlineActionsJson: onlineActionsJson,
            onlineModel: onlineModel,
            onlineConfirms: onlineConfirms,
            onlineAskAPerson: onlineAskAPerson,
            onlineCaveat: onlineCaveat,
            onlineAt: onlineAt,
            savedToFarm: savedToFarm,
            pendingSync: pendingSync,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> cropId = const Value.absent(),
            required String cropName,
            required String imagePath,
            required String condition,
            required String issueLabel,
            required double confidence,
            required String severity,
            required String affectedArea,
            required String growthStage,
            required String explanation,
            required String actionsJson,
            required String status,
            required String modelName,
            Value<int> inferenceTimeMs = const Value.absent(),
            required String engine,
            Value<double> margin = const Value.absent(),
            Value<String?> runnerUp = const Value.absent(),
            Value<String?> onlineSummary = const Value.absent(),
            Value<String?> onlineCrop = const Value.absent(),
            Value<String?> onlineCondition = const Value.absent(),
            Value<String?> onlineConfidence = const Value.absent(),
            Value<String?> onlineActionsJson = const Value.absent(),
            Value<String?> onlineModel = const Value.absent(),
            Value<bool?> onlineConfirms = const Value.absent(),
            Value<bool?> onlineAskAPerson = const Value.absent(),
            Value<String?> onlineCaveat = const Value.absent(),
            Value<DateTime?> onlineAt = const Value.absent(),
            Value<bool> savedToFarm = const Value.absent(),
            Value<bool> pendingSync = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CropScansCompanion.insert(
            id: id,
            cropId: cropId,
            cropName: cropName,
            imagePath: imagePath,
            condition: condition,
            issueLabel: issueLabel,
            confidence: confidence,
            severity: severity,
            affectedArea: affectedArea,
            growthStage: growthStage,
            explanation: explanation,
            actionsJson: actionsJson,
            status: status,
            modelName: modelName,
            inferenceTimeMs: inferenceTimeMs,
            engine: engine,
            margin: margin,
            runnerUp: runnerUp,
            onlineSummary: onlineSummary,
            onlineCrop: onlineCrop,
            onlineCondition: onlineCondition,
            onlineConfidence: onlineConfidence,
            onlineActionsJson: onlineActionsJson,
            onlineModel: onlineModel,
            onlineConfirms: onlineConfirms,
            onlineAskAPerson: onlineAskAPerson,
            onlineCaveat: onlineCaveat,
            onlineAt: onlineAt,
            savedToFarm: savedToFarm,
            pendingSync: pendingSync,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$CropScansTable, CropScanRow>(table),
                    BaseReferences<_$AppDatabase, $CropScansTable, CropScanRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CropScansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CropScansTable,
    CropScanRow,
    $$CropScansTableFilterComposer,
    $$CropScansTableOrderingComposer,
    $$CropScansTableAnnotationComposer,
    $$CropScansTableCreateCompanionBuilder,
    $$CropScansTableUpdateCompanionBuilder,
    (CropScanRow, BaseReferences<_$AppDatabase, $CropScansTable, CropScanRow>),
    CropScanRow,
    PrefetchHooks Function()>;
typedef $$ConversationsTableCreateCompanionBuilder = ConversationsCompanion
    Function({
  required String id,
  required String title,
  required DateTime startedAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ConversationsTableUpdateCompanionBuilder = ConversationsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<DateTime> startedAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$ConversationsTableReferences extends BaseReferences<_$AppDatabase,
    $ConversationsTable, ConversationRow> {
  $$ConversationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChatMessagesTable, List<ChatMessageRow>>
      _chatMessagesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.chatMessages,
              aliasName: 'conversations__id__chat_messages__conversation_id');

  $$ChatMessagesTableProcessedTableManager get chatMessagesRefs {
    final manager = $$ChatMessagesTableTableManager($_db, $_db.chatMessages)
        .filter(
            (f) => f.conversationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_chatMessagesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> chatMessagesRefs(
      Expression<bool> Function($$ChatMessagesTableFilterComposer f) f) {
    final $$ChatMessagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chatMessages,
        getReferencedColumn: (t) => t.conversationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChatMessagesTableFilterComposer(
              $db: $db,
              $table: $db.chatMessages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> chatMessagesRefs<T extends Object>(
      Expression<T> Function($$ChatMessagesTableAnnotationComposer a) f) {
    final $$ChatMessagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chatMessages,
        getReferencedColumn: (t) => t.conversationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChatMessagesTableAnnotationComposer(
              $db: $db,
              $table: $db.chatMessages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ConversationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConversationsTable,
    ConversationRow,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableAnnotationComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder,
    (ConversationRow, $$ConversationsTableReferences),
    ConversationRow,
    PrefetchHooks Function({bool chatMessagesRefs})> {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationsCompanion(
            id: id,
            title: title,
            startedAt: startedAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required DateTime startedAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationsCompanion.insert(
            id: id,
            title: title,
            startedAt: startedAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ConversationsTable, ConversationRow>(table),
                    $$ConversationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({chatMessagesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (chatMessagesRefs) db.chatMessages],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chatMessagesRefs)
                    await $_getPrefetchedData<ConversationRow,
                            $ConversationsTable, ChatMessageRow>(
                        currentTable: table,
                        referencedTable: $$ConversationsTableReferences
                            ._chatMessagesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ConversationsTableReferences(db, table, p0)
                                .chatMessagesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.conversationId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ConversationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConversationsTable,
    ConversationRow,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableAnnotationComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder,
    (ConversationRow, $$ConversationsTableReferences),
    ConversationRow,
    PrefetchHooks Function({bool chatMessagesRefs})>;
typedef $$ChatMessagesTableCreateCompanionBuilder = ChatMessagesCompanion
    Function({
  required String id,
  required String conversationId,
  required String role,
  required String content,
  Value<String?> engine,
  Value<double?> confidence,
  Value<String?> category,
  Value<String?> actionsJson,
  Value<bool> pendingSync,
  required DateTime sentAt,
  Value<int> rowid,
});
typedef $$ChatMessagesTableUpdateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<String> id,
  Value<String> conversationId,
  Value<String> role,
  Value<String> content,
  Value<String?> engine,
  Value<double?> confidence,
  Value<String?> category,
  Value<String?> actionsJson,
  Value<bool> pendingSync,
  Value<DateTime> sentAt,
  Value<int> rowid,
});

final class $$ChatMessagesTableReferences
    extends BaseReferences<_$AppDatabase, $ChatMessagesTable, ChatMessageRow> {
  $$ChatMessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConversationsTable _conversationIdTable(_$AppDatabase db) =>
      db.conversations
          .createAlias('chat_messages__conversation_id__conversations__id');

  $$ConversationsTableProcessedTableManager get conversationId {
    final $_column = $_itemColumn<String>('conversation_id')!;

    final manager = $$ConversationsTableTableManager($_db, $_db.conversations)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get engine => $composableBuilder(
      column: $table.engine, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionsJson => $composableBuilder(
      column: $table.actionsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pendingSync => $composableBuilder(
      column: $table.pendingSync, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
      column: $table.sentAt, builder: (column) => ColumnFilters(column));

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.conversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConversationsTableFilterComposer(
              $db: $db,
              $table: $db.conversations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get engine => $composableBuilder(
      column: $table.engine, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionsJson => $composableBuilder(
      column: $table.actionsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pendingSync => $composableBuilder(
      column: $table.pendingSync, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
      column: $table.sentAt, builder: (column) => ColumnOrderings(column));

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.conversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConversationsTableOrderingComposer(
              $db: $db,
              $table: $db.conversations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get engine =>
      $composableBuilder(column: $table.engine, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get actionsJson => $composableBuilder(
      column: $table.actionsJson, builder: (column) => column);

  GeneratedColumn<bool> get pendingSync => $composableBuilder(
      column: $table.pendingSync, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  $$ConversationsTableAnnotationComposer get conversationId {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.conversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConversationsTableAnnotationComposer(
              $db: $db,
              $table: $db.conversations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChatMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessageRow,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (ChatMessageRow, $$ChatMessagesTableReferences),
    ChatMessageRow,
    PrefetchHooks Function({bool conversationId})> {
  $$ChatMessagesTableTableManager(_$AppDatabase db, $ChatMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> conversationId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> engine = const Value.absent(),
            Value<double?> confidence = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> actionsJson = const Value.absent(),
            Value<bool> pendingSync = const Value.absent(),
            Value<DateTime> sentAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatMessagesCompanion(
            id: id,
            conversationId: conversationId,
            role: role,
            content: content,
            engine: engine,
            confidence: confidence,
            category: category,
            actionsJson: actionsJson,
            pendingSync: pendingSync,
            sentAt: sentAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String conversationId,
            required String role,
            required String content,
            Value<String?> engine = const Value.absent(),
            Value<double?> confidence = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> actionsJson = const Value.absent(),
            Value<bool> pendingSync = const Value.absent(),
            required DateTime sentAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ChatMessagesCompanion.insert(
            id: id,
            conversationId: conversationId,
            role: role,
            content: content,
            engine: engine,
            confidence: confidence,
            category: category,
            actionsJson: actionsJson,
            pendingSync: pendingSync,
            sentAt: sentAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$ChatMessagesTable, ChatMessageRow>(table),
                    $$ChatMessagesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (conversationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.conversationId,
                    referencedTable:
                        $$ChatMessagesTableReferences._conversationIdTable(db),
                    referencedColumn: $$ChatMessagesTableReferences
                        ._conversationIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ChatMessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChatMessagesTable,
    ChatMessageRow,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (ChatMessageRow, $$ChatMessagesTableReferences),
    ChatMessageRow,
    PrefetchHooks Function({bool conversationId})>;
typedef $$KnowledgeArticlesTableCreateCompanionBuilder
    = KnowledgeArticlesCompanion Function({
  required String id,
  required String category,
  Value<String> crop,
  required String title,
  required String summary,
  Value<String> symptomsJson,
  Value<String> causesJson,
  Value<String> preventionJson,
  Value<String> actionsJson,
  Value<String> severity,
  Value<String> keywords,
  Value<String> sectionsJson,
  Value<int> readMinutes,
  Value<int> rowid,
});
typedef $$KnowledgeArticlesTableUpdateCompanionBuilder
    = KnowledgeArticlesCompanion Function({
  Value<String> id,
  Value<String> category,
  Value<String> crop,
  Value<String> title,
  Value<String> summary,
  Value<String> symptomsJson,
  Value<String> causesJson,
  Value<String> preventionJson,
  Value<String> actionsJson,
  Value<String> severity,
  Value<String> keywords,
  Value<String> sectionsJson,
  Value<int> readMinutes,
  Value<int> rowid,
});

class $$KnowledgeArticlesTableFilterComposer
    extends Composer<_$AppDatabase, $KnowledgeArticlesTable> {
  $$KnowledgeArticlesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get crop => $composableBuilder(
      column: $table.crop, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symptomsJson => $composableBuilder(
      column: $table.symptomsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get causesJson => $composableBuilder(
      column: $table.causesJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get preventionJson => $composableBuilder(
      column: $table.preventionJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionsJson => $composableBuilder(
      column: $table.actionsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get keywords => $composableBuilder(
      column: $table.keywords, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sectionsJson => $composableBuilder(
      column: $table.sectionsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get readMinutes => $composableBuilder(
      column: $table.readMinutes, builder: (column) => ColumnFilters(column));
}

class $$KnowledgeArticlesTableOrderingComposer
    extends Composer<_$AppDatabase, $KnowledgeArticlesTable> {
  $$KnowledgeArticlesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get crop => $composableBuilder(
      column: $table.crop, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symptomsJson => $composableBuilder(
      column: $table.symptomsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get causesJson => $composableBuilder(
      column: $table.causesJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get preventionJson => $composableBuilder(
      column: $table.preventionJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionsJson => $composableBuilder(
      column: $table.actionsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get severity => $composableBuilder(
      column: $table.severity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get keywords => $composableBuilder(
      column: $table.keywords, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sectionsJson => $composableBuilder(
      column: $table.sectionsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get readMinutes => $composableBuilder(
      column: $table.readMinutes, builder: (column) => ColumnOrderings(column));
}

class $$KnowledgeArticlesTableAnnotationComposer
    extends Composer<_$AppDatabase, $KnowledgeArticlesTable> {
  $$KnowledgeArticlesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get crop =>
      $composableBuilder(column: $table.crop, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get symptomsJson => $composableBuilder(
      column: $table.symptomsJson, builder: (column) => column);

  GeneratedColumn<String> get causesJson => $composableBuilder(
      column: $table.causesJson, builder: (column) => column);

  GeneratedColumn<String> get preventionJson => $composableBuilder(
      column: $table.preventionJson, builder: (column) => column);

  GeneratedColumn<String> get actionsJson => $composableBuilder(
      column: $table.actionsJson, builder: (column) => column);

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get keywords =>
      $composableBuilder(column: $table.keywords, builder: (column) => column);

  GeneratedColumn<String> get sectionsJson => $composableBuilder(
      column: $table.sectionsJson, builder: (column) => column);

  GeneratedColumn<int> get readMinutes => $composableBuilder(
      column: $table.readMinutes, builder: (column) => column);
}

class $$KnowledgeArticlesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $KnowledgeArticlesTable,
    KnowledgeArticleRow,
    $$KnowledgeArticlesTableFilterComposer,
    $$KnowledgeArticlesTableOrderingComposer,
    $$KnowledgeArticlesTableAnnotationComposer,
    $$KnowledgeArticlesTableCreateCompanionBuilder,
    $$KnowledgeArticlesTableUpdateCompanionBuilder,
    (
      KnowledgeArticleRow,
      BaseReferences<_$AppDatabase, $KnowledgeArticlesTable,
          KnowledgeArticleRow>
    ),
    KnowledgeArticleRow,
    PrefetchHooks Function()> {
  $$KnowledgeArticlesTableTableManager(
      _$AppDatabase db, $KnowledgeArticlesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KnowledgeArticlesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KnowledgeArticlesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KnowledgeArticlesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> crop = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> summary = const Value.absent(),
            Value<String> symptomsJson = const Value.absent(),
            Value<String> causesJson = const Value.absent(),
            Value<String> preventionJson = const Value.absent(),
            Value<String> actionsJson = const Value.absent(),
            Value<String> severity = const Value.absent(),
            Value<String> keywords = const Value.absent(),
            Value<String> sectionsJson = const Value.absent(),
            Value<int> readMinutes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              KnowledgeArticlesCompanion(
            id: id,
            category: category,
            crop: crop,
            title: title,
            summary: summary,
            symptomsJson: symptomsJson,
            causesJson: causesJson,
            preventionJson: preventionJson,
            actionsJson: actionsJson,
            severity: severity,
            keywords: keywords,
            sectionsJson: sectionsJson,
            readMinutes: readMinutes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String category,
            Value<String> crop = const Value.absent(),
            required String title,
            required String summary,
            Value<String> symptomsJson = const Value.absent(),
            Value<String> causesJson = const Value.absent(),
            Value<String> preventionJson = const Value.absent(),
            Value<String> actionsJson = const Value.absent(),
            Value<String> severity = const Value.absent(),
            Value<String> keywords = const Value.absent(),
            Value<String> sectionsJson = const Value.absent(),
            Value<int> readMinutes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              KnowledgeArticlesCompanion.insert(
            id: id,
            category: category,
            crop: crop,
            title: title,
            summary: summary,
            symptomsJson: symptomsJson,
            causesJson: causesJson,
            preventionJson: preventionJson,
            actionsJson: actionsJson,
            severity: severity,
            keywords: keywords,
            sectionsJson: sectionsJson,
            readMinutes: readMinutes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$KnowledgeArticlesTable, KnowledgeArticleRow>(
                        table),
                    BaseReferences<_$AppDatabase, $KnowledgeArticlesTable,
                        KnowledgeArticleRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$KnowledgeArticlesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $KnowledgeArticlesTable,
    KnowledgeArticleRow,
    $$KnowledgeArticlesTableFilterComposer,
    $$KnowledgeArticlesTableOrderingComposer,
    $$KnowledgeArticlesTableAnnotationComposer,
    $$KnowledgeArticlesTableCreateCompanionBuilder,
    $$KnowledgeArticlesTableUpdateCompanionBuilder,
    (
      KnowledgeArticleRow,
      BaseReferences<_$AppDatabase, $KnowledgeArticlesTable,
          KnowledgeArticleRow>
    ),
    KnowledgeArticleRow,
    PrefetchHooks Function()>;
typedef $$WeatherCacheTableCreateCompanionBuilder = WeatherCacheCompanion
    Function({
  required String id,
  required String payloadJson,
  required String source,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$WeatherCacheTableUpdateCompanionBuilder = WeatherCacheCompanion
    Function({
  Value<String> id,
  Value<String> payloadJson,
  Value<String> source,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$WeatherCacheTableFilterComposer
    extends Composer<_$AppDatabase, $WeatherCacheTable> {
  $$WeatherCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$WeatherCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $WeatherCacheTable> {
  $$WeatherCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$WeatherCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeatherCacheTable> {
  $$WeatherCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WeatherCacheTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WeatherCacheTable,
    WeatherCacheRow,
    $$WeatherCacheTableFilterComposer,
    $$WeatherCacheTableOrderingComposer,
    $$WeatherCacheTableAnnotationComposer,
    $$WeatherCacheTableCreateCompanionBuilder,
    $$WeatherCacheTableUpdateCompanionBuilder,
    (
      WeatherCacheRow,
      BaseReferences<_$AppDatabase, $WeatherCacheTable, WeatherCacheRow>
    ),
    WeatherCacheRow,
    PrefetchHooks Function()> {
  $$WeatherCacheTableTableManager(_$AppDatabase db, $WeatherCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeatherCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeatherCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeatherCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeatherCacheCompanion(
            id: id,
            payloadJson: payloadJson,
            source: source,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String payloadJson,
            required String source,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              WeatherCacheCompanion.insert(
            id: id,
            payloadJson: payloadJson,
            source: source,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$WeatherCacheTable, WeatherCacheRow>(table),
                    BaseReferences<_$AppDatabase, $WeatherCacheTable,
                        WeatherCacheRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WeatherCacheTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WeatherCacheTable,
    WeatherCacheRow,
    $$WeatherCacheTableFilterComposer,
    $$WeatherCacheTableOrderingComposer,
    $$WeatherCacheTableAnnotationComposer,
    $$WeatherCacheTableCreateCompanionBuilder,
    $$WeatherCacheTableUpdateCompanionBuilder,
    (
      WeatherCacheRow,
      BaseReferences<_$AppDatabase, $WeatherCacheTable, WeatherCacheRow>
    ),
    WeatherCacheRow,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String entityType,
  required String entityId,
  required String operation,
  required String payload,
  required DateTime createdAt,
  Value<int> attemptCount,
  Value<DateTime?> lastAttemptAt,
  Value<String> status,
  Value<String?> errorMessage,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operation,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<int> attemptCount,
  Value<DateTime?> lastAttemptAt,
  Value<String> status,
  Value<String?> errorMessage,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
      column: $table.attemptCount, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
      column: $table.lastAttemptAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueRow,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueRow,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>
    ),
    SyncQueueRow,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> attemptCount = const Value.absent(),
            Value<DateTime?> lastAttemptAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payload: payload,
            createdAt: createdAt,
            attemptCount: attemptCount,
            lastAttemptAt: lastAttemptAt,
            status: status,
            errorMessage: errorMessage,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String entityType,
            required String entityId,
            required String operation,
            required String payload,
            required DateTime createdAt,
            Value<int> attemptCount = const Value.absent(),
            Value<DateTime?> lastAttemptAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            payload: payload,
            createdAt: createdAt,
            attemptCount: attemptCount,
            lastAttemptAt: lastAttemptAt,
            status: status,
            errorMessage: errorMessage,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$SyncQueueTable, SyncQueueRow>(table),
                    BaseReferences<_$AppDatabase, $SyncQueueTable,
                        SyncQueueRow>(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueRow,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueRow,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueRow>
    ),
    SyncQueueRow,
    PrefetchHooks Function()>;
typedef $$AppMetaTableCreateCompanionBuilder = AppMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppMetaTableUpdateCompanionBuilder = AppMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppMetaTable,
    AppMetaRow,
    $$AppMetaTableFilterComposer,
    $$AppMetaTableOrderingComposer,
    $$AppMetaTableAnnotationComposer,
    $$AppMetaTableCreateCompanionBuilder,
    $$AppMetaTableUpdateCompanionBuilder,
    (AppMetaRow, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>),
    AppMetaRow,
    PrefetchHooks Function()> {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppMetaCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppMetaCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable<$AppMetaTable, AppMetaRow>(table),
                    BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppMetaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppMetaTable,
    AppMetaRow,
    $$AppMetaTableFilterComposer,
    $$AppMetaTableOrderingComposer,
    $$AppMetaTableAnnotationComposer,
    $$AppMetaTableCreateCompanionBuilder,
    $$AppMetaTableUpdateCompanionBuilder,
    (AppMetaRow, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>),
    AppMetaRow,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FarmersTableTableManager get farmers =>
      $$FarmersTableTableManager(_db, _db.farmers);
  $$FarmsTableTableManager get farms =>
      $$FarmsTableTableManager(_db, _db.farms);
  $$FarmLocationsTableTableManager get farmLocations =>
      $$FarmLocationsTableTableManager(_db, _db.farmLocations);
  $$CropsTableTableManager get crops =>
      $$CropsTableTableManager(_db, _db.crops);
  $$FarmActivitiesTableTableManager get farmActivities =>
      $$FarmActivitiesTableTableManager(_db, _db.farmActivities);
  $$RecommendationsTableTableManager get recommendations =>
      $$RecommendationsTableTableManager(_db, _db.recommendations);
  $$AlertsTableTableManager get alerts =>
      $$AlertsTableTableManager(_db, _db.alerts);
  $$CropScansTableTableManager get cropScans =>
      $$CropScansTableTableManager(_db, _db.cropScans);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$KnowledgeArticlesTableTableManager get knowledgeArticles =>
      $$KnowledgeArticlesTableTableManager(_db, _db.knowledgeArticles);
  $$WeatherCacheTableTableManager get weatherCache =>
      $$WeatherCacheTableTableManager(_db, _db.weatherCache);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
}
