import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../database/app_database.dart';
import '../models/models.dart';
import '../services/farm_services.dart';
import '../services/local_ai/local_knowledge_service.dart';
import 'local_sync_queue_service.dart';

/// SQLite-backed farm data. Implements the existing [FarmService] read
/// interface and adds the writes the screens need. Every write goes to the
/// database first and is then recorded in the offline outbox.
class LocalFarmRepository implements FarmService {
  LocalFarmRepository(this._db, {required LocalSyncQueueService sync, LocalKnowledgeService? knowledge})
      : _sync = sync,
        _knowledge = knowledge ?? LocalKnowledgeService(_db);

  final AppDatabase _db;
  final LocalSyncQueueService _sync;
  final LocalKnowledgeService _knowledge;

  String? _farmId;

  /// The single local farm (created on first run by the seeder).
  Future<String> farmId() async {
    if (_farmId != null) return _farmId!;
    final farm = await _db.farmDao.getFarm();
    if (farm != null) return _farmId = farm.id;
    // No farm yet: create an empty one so writes never fail.
    final farmer = await _db.farmerDao.getFarmer();
    final farmerId = farmer?.id ?? 'farmer-local';
    if (farmer == null) {
      await _db.farmerDao.upsert(FarmersCompanion(
        id: Value(farmerId),
        name: const Value('Farmer'),
        location: const Value('Timor-Leste'),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ));
    }
    await _db.farmDao.insertFarm(FarmsCompanion(
      id: const Value('farm-local'),
      farmerId: Value(farmerId),
      name: const Value('My Farm'),
      createdAt: Value(DateTime.now()),
    ));
    return _farmId = 'farm-local';
  }

  // ---- FarmService (reads) ----

  /// True when the app has never been set up — no farmer record exists.
  /// Drives the first-run onboarding instead of a seeded demo farm.
  Future<bool> needsOnboarding() async =>
      await _db.farmerDao.getFarmer() == null;

  /// Writes the farmer and their farm from the onboarding form.
  Future<void> createFarmer({
    required String name,
    required String location,
    String? phone,
    String farmName = 'My Farm',
  }) async {
    final now = DateTime.now();
    const farmerId = 'farmer-local';
    await _db.farmerDao.upsert(FarmersCompanion(
      id: const Value(farmerId),
      name: Value(name),
      location: Value(location),
      farmingYears: const Value(0),
      phone: Value(phone),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
    final existing = await _db.farmDao.getFarm();
    if (existing == null) {
      _farmId = 'farm-local';
      await _db.farmDao.insertFarm(FarmsCompanion(
        id: Value(_farmId!),
        farmerId: const Value(farmerId),
        name: Value(farmName),
        createdAt: Value(now),
      ));
    }
    await _sync.enqueue(
      entityType: 'farmer',
      entityId: farmerId,
      operation: 'create',
      payload: {'name': name, 'location': location, 'farm': farmName},
    );
  }

  @override
  Future<Farmer> farmer() async {
    final r = await _db.farmerDao.getFarmer();
    if (r == null) {
      await farmId();
      return farmer();
    }
    return Farmer(name: r.name, location: r.location, farmingYears: r.farmingYears, phone: r.phone);
  }

  @override
  Future<List<Crop>> crops() async =>
      (await _db.cropDao.all(await farmId())).map(cropFromRow).toList();

  @override
  Future<List<FarmLocation>> locations() async =>
      (await _db.farmDao.listLocations(await farmId()))
          .map((l) => FarmLocation(
                id: l.id,
                name: l.name,
                areaHa: l.areaHa,
                district: l.district,
                latitude: l.latitude,
                longitude: l.longitude,
              ))
          .toList();

  @override
  Future<List<FarmActivity>> activities() async =>
      (await _db.farmDao.listActivities(await farmId(), limit: 100)).map(activityFromRow).toList();

  @override
  Future<List<Recommendation>> recommendations() async =>
      (await _db.farmDao.listRecommendations())
          .map((r) => Recommendation(
                id: r.id,
                kind: RecommendationKind.values.byName(r.kind),
                title: r.title,
                detail: r.detail,
              ))
          .toList();

  @override
  Future<List<FarmAlert>> alerts() async => (await _db.farmDao.listAlerts())
      .map((a) => FarmAlert(
            id: a.id,
            kind: AlertKind.values.byName(a.kind),
            title: a.title,
            detail: a.detail,
            action: a.action,
            date: a.date,
            read: a.read,
          ))
      .toList();

  @override
  Future<List<KnowledgeArticle>> knowledge() async =>
      (await _knowledge.all()).map((r) => r.toModel()).toList();

  // ---- Writes ----

  Future<void> updateProfile({String? name, String? location, String? phone, double? farmingYears}) async {
    final r = await _db.farmerDao.getFarmer();
    if (r == null) return;
    await _db.farmerDao.updateProfile(
        id: r.id, name: name, location: location, phone: phone, farmingYears: farmingYears);
    await _sync.enqueue(entityType: 'farmer', entityId: r.id, operation: 'update', payload: {
      'name': name,
      'location': location,
      'phone': phone,
      'farmingYears': farmingYears,
    });
  }

  Future<void> addCrop(Crop c) async {
    final fid = await farmId();
    await _db.cropDao.insert(CropsCompanion(
      id: Value(c.id),
      farmId: Value(fid),
      locationName: Value(c.locationName),
      name: Value(c.name),
      variety: Value(c.variety),
      areaHa: Value(c.areaHa),
      status: Value(c.status.name),
      growthStage: Value(c.growthStage),
      plantedOn: Value(c.plantedOn),
      note: Value(c.note),
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
    await _sync.enqueue(entityType: 'crop', entityId: c.id, operation: 'create', payload: {
      'name': c.name,
      'areaHa': c.areaHa,
      'variety': c.variety,
      'plantedOn': c.plantedOn.toIso8601String(),
      'location': c.locationName,
    });
  }

  Future<void> updateCropStatus(String cropName, HealthStatus status) async {
    await _db.cropDao.updateStatusByName(cropName, status.name);
  }

  Future<void> addLocation(FarmLocation l) async {
    final fid = await farmId();
    await _db.farmDao.insertLocation(FarmLocationsCompanion(
      id: Value(l.id),
      farmId: Value(fid),
      name: Value(l.name),
      areaHa: Value(l.areaHa),
      district: Value(l.district),
      latitude: Value(l.latitude),
      longitude: Value(l.longitude),
      createdAt: Value(DateTime.now()),
    ));
    await _sync.enqueue(entityType: 'location', entityId: l.id, operation: 'create', payload: {
      'name': l.name,
      'areaHa': l.areaHa,
      'district': l.district,
      'latitude': l.latitude,
      'longitude': l.longitude,
    });
  }

  Future<void> logActivity(FarmActivity a) async {
    final fid = await farmId();
    await _db.farmDao.insertActivity(FarmActivitiesCompanion(
      id: Value(a.id),
      farmId: Value(fid),
      cropName: Value(a.cropName),
      type: Value(a.type.name),
      title: Value(a.title),
      detail: Value(a.detail),
      date: Value(a.date),
      createdAt: Value(DateTime.now()),
    ));
    await _sync.enqueue(entityType: 'activity', entityId: a.id, operation: 'create', payload: {
      'type': a.type.name,
      'title': a.title,
      'detail': a.detail,
      'date': a.date.toIso8601String(),
      'crop': a.cropName,
    });
  }

  Future<void> markAlertRead(String id) => _db.farmDao.markAlertRead(id);
  Future<void> markAllAlertsRead() => _db.farmDao.markAllAlertsRead();

  /// Replaces dashboard recommendations (computed locally from risk + scans).
  Future<void> replaceRecommendations(List<Recommendation> recs) =>
      _db.farmDao.replaceRecommendations([
        for (final r in recs)
          RecommendationsCompanion(
            id: Value(r.id),
            kind: Value(r.kind.name),
            title: Value(r.title),
            detail: Value(r.detail),
            createdAt: Value(DateTime.now()),
          ),
      ]);

  Future<void> upsertAlert(FarmAlert a) => _db.farmDao.insertAlert(AlertsCompanion(
        id: Value(a.id),
        kind: Value(a.kind.name),
        title: Value(a.title),
        detail: Value(a.detail),
        action: Value(a.action),
        date: Value(a.date),
        read: Value(a.read),
      ));

  // ---- Mapping ----

  static Crop cropFromRow(CropRow r) => Crop(
        id: r.id,
        name: r.name,
        areaHa: r.areaHa,
        status: HealthStatus.values.byName(r.status),
        plantedOn: r.plantedOn,
        locationName: r.locationName,
        variety: r.variety,
        growthStage: r.growthStage,
        note: r.note,
      );

  static FarmActivity activityFromRow(FarmActivityRow r) => FarmActivity(
        id: r.id,
        type: ActivityType.values.byName(r.type),
        title: r.title,
        detail: r.detail,
        date: r.date,
        cropName: r.cropName,
      );

  static String encode(Map<String, dynamic> m) => jsonEncode(m);
}
