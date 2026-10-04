/// Which AI engine is currently serving the farmer.
///
/// The farmer never picks this manually — the connectivity layer decides.
enum AiMode {
  online,
  limited,
  offline,
  syncing;

  String get label {
    switch (this) {
      case AiMode.online:
        return 'Online AI';
      case AiMode.limited:
        return 'Limited';
      case AiMode.offline:
        return 'Offline AI';
      case AiMode.syncing:
        return 'Syncing';
    }
  }

  /// Engine label for the *connectivity* mode. In the local-first phase the
  /// AI always runs on the phone; the cloud is a future enhancement.
  String get engineName {
    switch (this) {
      case AiMode.online:
        return 'Local AI · online';
      case AiMode.limited:
        return 'Local AI · weak signal';
      case AiMode.offline:
        return 'Local AI · offline';
      case AiMode.syncing:
        return 'Local AI · syncing';
    }
  }

  String get description {
    switch (this) {
      case AiMode.online:
        return 'You are online. AI still runs on this phone; cloud sync arrives in the next phase.';
      case AiMode.limited:
        return 'Weak connection. Nothing changes — AI runs on this phone.';
      case AiMode.offline:
        return 'You\'re offline. Lafaek AI works fully on this phone and your data is saved here.';
      case AiMode.syncing:
        return 'Checking the offline outbox.';
    }
  }

  /// Whether cloud features (Bedrock) are active right now.
  bool get isCloud => this == AiMode.online || this == AiMode.syncing;
}
