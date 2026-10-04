import 'package:drift/drift.dart';

/// Farmer profile. One row for the local user in this phase.
@DataClassName('FarmerRow')
class Farmers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get location => text()();
  RealColumn get farmingYears => real().withDefault(const Constant(0))();
  TextColumn get phone => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A farm belongs to a farmer and groups locations, crops and activities.
@DataClassName('FarmRow')
class Farms extends Table {
  TextColumn get id => text()();
  TextColumn get farmerId => text().references(Farmers, #id)();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A named field / plot within a farm.
@DataClassName('FarmLocationRow')
class FarmLocations extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().references(Farms, #id)();
  TextColumn get name => text()();
  RealColumn get areaHa => real()();
  TextColumn get district => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A crop planted on the farm.
@DataClassName('CropRow')
class Crops extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().references(Farms, #id)();
  TextColumn get locationId => text().nullable()();
  TextColumn get locationName => text()();
  TextColumn get name => text()();
  TextColumn get variety => text().nullable()();
  RealColumn get areaHa => real()();

  /// `healthy` | `monitor` | `atRisk` — matches [HealthStatus.name].
  TextColumn get status => text().withDefault(const Constant('healthy'))();
  TextColumn get growthStage => text().withDefault(const Constant('Vegetative'))();
  DateTimeColumn get plantedOn => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Log of work done on the farm.
@DataClassName('FarmActivityRow')
class FarmActivities extends Table {
  TextColumn get id => text()();
  TextColumn get farmId => text().references(Farms, #id)();
  TextColumn get cropId => text().nullable()();
  TextColumn get cropName => text().nullable()();

  /// Matches [ActivityType.name].
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get detail => text()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Dashboard recommendations.
@DataClassName('RecommendationRow')
class Recommendations extends Table {
  TextColumn get id => text()();

  /// Matches [RecommendationKind.name].
  TextColumn get kind => text()();
  TextColumn get title => text()();
  TextColumn get detail => text()();
  BoolColumn get dismissed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Weather / crop alerts, each with a recommended action.
@DataClassName('AlertRow')
class Alerts extends Table {
  TextColumn get id => text()();

  /// Matches [AlertKind.name].
  TextColumn get kind => text()();
  TextColumn get title => text()();
  TextColumn get detail => text()();
  TextColumn get action => text()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get read => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
