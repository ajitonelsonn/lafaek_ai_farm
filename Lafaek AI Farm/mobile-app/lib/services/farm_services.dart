import '../models/models.dart';

/// Farm data (crops, locations, activities). Mocked in-memory for now; the
/// real implementation will read/write a local store and sync to the cloud.
abstract class FarmService {
  Future<Farmer> farmer();
  Future<List<Crop>> crops();
  Future<List<FarmLocation>> locations();
  Future<List<FarmActivity>> activities();
  Future<List<Recommendation>> recommendations();
  Future<List<FarmAlert>> alerts();
  Future<List<KnowledgeArticle>> knowledge();
}


/// Scan history storage.
abstract class CropScanService {
  Future<List<ScanResult>> history();
}


/// Weather + farm-risk provider.
abstract class WeatherService {
  Future<WeatherBundle> current();
}


/// Uploads offline records when the connection returns.
abstract class SyncService {
  /// Emits progress lines ("3 records uploaded") and completes when done.
  Stream<SyncItem> sync(List<SyncItem> pending);
}

