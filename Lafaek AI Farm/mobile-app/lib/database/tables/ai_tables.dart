import 'package:drift/drift.dart';

/// A completed crop scan (local CV + local LLM explanation).
@DataClassName('CropScanRow')
class CropScans extends Table {
  TextColumn get id => text()();
  TextColumn get cropId => text().nullable()();
  TextColumn get cropName => text()();

  /// Path to the photo on device, or an `assets/…` path for demo scans.
  TextColumn get imagePath => text()();

  /// CV class id, e.g. `maize_leaf_blight`.
  TextColumn get condition => text()();

  /// Farmer-facing hedged label, e.g. "Possible Leaf Blight".
  TextColumn get issueLabel => text()();
  RealColumn get confidence => real()();
  TextColumn get severity => text()();
  TextColumn get affectedArea => text()();
  TextColumn get growthStage => text()();
  TextColumn get explanation => text()();

  /// JSON list of {title, detail}.
  TextColumn get actionsJson => text()();

  /// Matches [HealthStatus.name].
  TextColumn get status => text()();
  TextColumn get modelName => text()();
  IntColumn get inferenceTimeMs => integer().withDefault(const Constant(0))();

  /// Engine that produced the explanation ("Local AI", "Amazon Bedrock").
  TextColumn get engine => text()();
  /// How far the winning class beat the runner-up, and what it beat. Stored
  /// so the fail-safe still works when a scan is reopened from history, and
  /// so the online service can apply the same rule as the on-device guard.
  RealColumn get margin => real().withDefault(const Constant(1.0))();
  TextColumn get runnerUp => text().nullable()();

  // ---- Online re-analysis (Claude Haiku, via the project's own backend) ----
  // Null until the farmer has a signal. The local result above is written
  // first and never overwritten; this sits beside it so the farmer can see
  // both, and so an offline scan is complete on its own.
  TextColumn get onlineSummary => text().nullable()();

  /// What Claude read from the photograph when the on-device model could not
  /// place it. Stored so the identification survives leaving the screen, and
  /// so the scan history shows a real crop instead of "Unknown".
  TextColumn get onlineCrop => text().nullable()();
  TextColumn get onlineCondition => text().nullable()();
  TextColumn get onlineConfidence => text().nullable()();
  TextColumn get onlineActionsJson => text().nullable()();
  TextColumn get onlineModel => text().nullable()();
  BoolColumn get onlineConfirms => boolean().nullable()();
  BoolColumn get onlineAskAPerson => boolean().nullable()();
  TextColumn get onlineCaveat => text().nullable()();
  DateTimeColumn get onlineAt => dateTime().nullable()();

  BoolColumn get savedToFarm => boolean().withDefault(const Constant(false))();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ConversationRow')
class Conversations extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ChatMessageRow')
class ChatMessages extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId => text().references(Conversations, #id)();

  /// `user` | `assistant`.
  TextColumn get role => text()();
  TextColumn get content => text()();
  TextColumn get engine => text().nullable()();
  RealColumn get confidence => real().nullable()();
  TextColumn get category => text().nullable()();

  /// JSON list of strings.
  TextColumn get actionsJson => text().nullable()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();
  DateTimeColumn get sentAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Seeded from `assets/data/agriculture/*.json`; searchable offline.
@DataClassName('KnowledgeArticleRow')
class KnowledgeArticles extends Table {
  TextColumn get id => text()();

  /// `crop` | `disease` | `pest` | `soil` | `irrigation` | `planting` |
  /// `climate` | `tip`.
  TextColumn get category => text()();
  TextColumn get crop => text().withDefault(const Constant('general'))();
  TextColumn get title => text()();
  TextColumn get summary => text()();
  TextColumn get symptomsJson => text().withDefault(const Constant('[]'))();
  TextColumn get causesJson => text().withDefault(const Constant('[]'))();
  TextColumn get preventionJson => text().withDefault(const Constant('[]'))();
  TextColumn get actionsJson => text().withDefault(const Constant('[]'))();
  TextColumn get severity => text().withDefault(const Constant('none'))();

  /// Space-separated lower-case keywords for retrieval.
  TextColumn get keywords => text().withDefault(const Constant(''))();

  /// JSON list of {heading, body} for display.
  TextColumn get sectionsJson => text().withDefault(const Constant('[]'))();
  IntColumn get readMinutes => integer().withDefault(const Constant(3))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached / bundled / manually-entered weather, never labelled as live.
@DataClassName('WeatherCacheRow')
class WeatherCache extends Table {
  /// Location key, e.g. `dili`.
  TextColumn get id => text()();
  TextColumn get payloadJson => text()();

  /// `cached` | `demo` | `manual`.
  TextColumn get source => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Offline outbox for the future cloud phase. Upload is disabled for now.
@DataClassName('SyncQueueRow')
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();

  /// `create` | `update` | `delete`.
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  /// `pending` | `syncing` | `synced` | `failed`.
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get errorMessage => text().nullable()();
}

/// Small key/value store for app metadata (seed flags, model choice…).
@DataClassName('AppMetaRow')
class AppMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
