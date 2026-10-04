import 'package:drift/drift.dart' show Value;
import 'package:lafaek_ai_farm/database/app_database.dart';
import 'package:lafaek_ai_farm/models/models.dart';

/// Creates a small farm so widget tests have something to render.
///
/// This lives in `test/` on purpose. The app itself no longer seeds anything:
/// a new installation starts empty and the farmer creates their own records
/// through onboarding. Keeping the fixture here means test convenience can
/// never leak into a build a farmer runs.
Future<void> seedTestFarm(AppDatabase db) async {
  final now = DateTime.now();
  await db.farmerDao.upsert(FarmersCompanion(
    id: const Value('farmer-local'),
    name: const Value('Test Farmer'),
    location: const Value('Dili'),
    farmingYears: const Value(2),
    createdAt: Value(now),
    updatedAt: Value(now),
  ));
  await db.farmDao.insertFarm(FarmsCompanion(
    id: const Value('farm-local'),
    farmerId: const Value('farmer-local'),
    name: const Value('Test Farm'),
    createdAt: Value(now),
  ));
  await db.farmDao.insertLocation(FarmLocationsCompanion(
    id: const Value('loc-1'),
    farmId: const Value('farm-local'),
    name: const Value('Home field'),
    areaHa: const Value(1.5),
    district: const Value('Dili'),
    createdAt: Value(now),
  ));
  for (final crop in [
    ('crop-1', 'Maize', 1.0, HealthStatus.healthy),
    ('crop-2', 'Rice', 0.5, HealthStatus.monitor),
  ]) {
    await db.cropDao.insert(CropsCompanion(
      id: Value(crop.$1),
      farmId: const Value('farm-local'),
      locationName: const Value('Home field'),
      name: Value(crop.$2),
      areaHa: Value(crop.$3),
      status: Value(crop.$4.name),
      growthStage: const Value('Vegetative'),
      plantedOn: Value(now.subtract(const Duration(days: 30))),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
  }
}
