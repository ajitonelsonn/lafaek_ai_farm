import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/chat_dao.dart';
import 'daos/crop_dao.dart';
import 'daos/farm_dao.dart';
import 'daos/farmer_dao.dart';
import 'daos/knowledge_dao.dart';
import 'daos/scan_dao.dart';
import 'daos/sync_dao.dart';
import 'tables/ai_tables.dart';
import 'tables/farm_tables.dart';

part 'app_database.g.dart';

/// SQLite is the device source of truth. Everything the farmer creates is
/// written here first; the cloud phase will drain [SyncQueue] later.
@DriftDatabase(
  tables: [
    Farmers,
    Farms,
    FarmLocations,
    Crops,
    FarmActivities,
    Recommendations,
    Alerts,
    CropScans,
    Conversations,
    ChatMessages,
    KnowledgeArticles,
    WeatherCache,
    SyncQueue,
    AppMeta,
  ],
  daos: [
    FarmerDao,
    FarmDao,
    CropDao,
    ScanDao,
    ChatDao,
    KnowledgeDao,
    SyncDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Opens (or creates) `lafaek.sqlite` in the app's documents directory.
  AppDatabase() : super(_openConnection());

  /// For tests and tools: run against any executor (e.g. an in-memory DB).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 3) {
            // Claude's reading of a photo the on-device model could not place.
            for (final c in [
              cropScans.onlineCrop,
              cropScans.onlineCondition,
              cropScans.onlineConfidence,
            ]) {
              await m.addColumn(cropScans, c);
            }
          }
          if (from < 2) {
            // Claude's online second opinion sits beside the local result
            // rather than replacing it, so an existing scan keeps its
            // on-device analysis and simply gains the online one later.
            for (final c in [
              cropScans.margin,
              cropScans.runnerUp,
              cropScans.onlineSummary,
              cropScans.onlineActionsJson,
              cropScans.onlineModel,
              cropScans.onlineConfirms,
              cropScans.onlineAskAPerson,
              cropScans.onlineCaveat,
              cropScans.onlineAt,
            ]) {
              await m.addColumn(cropScans, c);
            }
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // ---- Weather cache ----

  Future<WeatherCacheRow?> getWeather(String locationKey) =>
      (select(weatherCache)..where((w) => w.id.equals(locationKey)))
          .getSingleOrNull();

  Future<void> putWeather({
    required String locationKey,
    required String payloadJson,
    required String source,
  }) =>
      into(weatherCache).insertOnConflictUpdate(WeatherCacheCompanion(
        id: Value(locationKey),
        payloadJson: Value(payloadJson),
        source: Value(source),
        updatedAt: Value(DateTime.now()),
      ));

  // ---- App metadata ----

  Future<String?> getMeta(String key) async {
    final row = await (select(appMeta)..where((m) => m.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setMeta(String key, String value) =>
      into(appMeta).insertOnConflictUpdate(
        AppMetaCompanion(key: Value(key), value: Value(value)),
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'lafaek',
      native: const DriftNativeOptions(shareAcrossIsolates: true),
    );
  }
}
