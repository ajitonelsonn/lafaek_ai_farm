import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../repositories/local_sync_queue_service.dart';
import '../services/ai_service.dart';
import '../services/connectivity_service.dart';

/// Tracks network quality, exposes the active [AIService] and drives the
/// offline outbox.
///
/// Local-first phase: the local engine is *always* the active AI, online or
/// not. The cloud engine is kept behind [cloudEnabled] for the AWS phase.
class ConnectivityState extends ChangeNotifier {
  ConnectivityState({
    required ConnectivityService connectivity,
    required AIService localAI,
    required LocalSyncQueueService syncQueue,
    AIService? cloudAI,
    this.cloudEnabled = false,
  })  : _connectivity = connectivity,
        _localAI = localAI,
        _cloudAI = cloudAI,
        _queue = syncQueue {
    _quality = _connectivity.current;
    _sub = _connectivity.onChanged.listen(_onQuality);
    refreshPending();
  }

  final ConnectivityService _connectivity;
  final AIService _localAI;
  final AIService? _cloudAI;
  final LocalSyncQueueService _queue;

  /// False until the AWS phase; the UI never depends on it.
  final bool cloudEnabled;

  StreamSubscription<NetworkQuality>? _sub;
  NetworkQuality _quality = NetworkQuality.good;
  bool _syncing = false;
  bool _manualOverride = false;
  List<SyncItem> _pending = const [];
  final List<SyncItem> _syncedThisRun = [];
  DateTime? _lastSyncedAt;
  bool _lastSyncFailed = false;
  String? _lastSyncMessage;

  NetworkQuality get quality => _quality;
  bool get isSyncing => _syncing;
  bool get manualOverride => _manualOverride;
  List<SyncItem> get pending => List.unmodifiable(_pending);
  List<SyncItem> get syncedThisRun => List.unmodifiable(_syncedThisRun);
  DateTime? get lastSyncedAt => _lastSyncedAt;
  bool get lastSyncFailed => _lastSyncFailed;
  String? get lastSyncMessage => _lastSyncMessage;
  int get pendingCount => _pending.fold(0, (s, i) => s + i.count);
  bool get isOnline => _quality == NetworkQuality.good;
  bool get isOffline => _quality == NetworkQuality.none;

  /// What the phone is attached to — Wi-Fi, mobile data, nothing.
  NetworkTransport get transport => _connectivity.transport;

  /// Measured round-trip to the reachability endpoint, null if never measured.
  int? get latencyMs => _connectivity.latencyMs;
  DateTime? get lastCheckedAt => _connectivity.lastCheckedAt;

  /// One line stating what was measured, not what was assumed — e.g.
  /// "Mobile data · 180 ms" or "Wi-Fi · no internet".
  String get connectionDetail {
    if (_manualOverride) return 'Demo override';
    final t = transport;
    if (t == NetworkTransport.none) return 'No network';
    final ms = latencyMs;
    if (_quality == NetworkQuality.none) return '${t.label} · no internet';
    if (ms == null) return '${t.label} · checking…';
    return '${t.label} · $ms ms';
  }

  /// Re-measure the connection now.
  Future<void> recheck() async {
    await _connectivity.check(force: true);
    notifyListeners();
  }

  AiMode get mode {
    if (_syncing) return AiMode.syncing;
    switch (_quality) {
      case NetworkQuality.good:
        return AiMode.online;
      case NetworkQuality.limited:
        return AiMode.limited;
      case NetworkQuality.none:
        return AiMode.offline;
    }
  }

  /// The engine the UI should use right now. Widgets never pick this.
  AIService get ai => (cloudEnabled && _cloudAI != null && isOnline) ? _cloudAI : _localAI;

  /// Demo control: force a network quality (or null to go back to automatic).
  void simulate(NetworkQuality? quality) {
    _manualOverride = quality != null;
    _connectivity.setOverride(quality);
  }

  /// Re-read the outbox counts from SQLite.
  Future<void> refreshPending() async {
    try {
      _pending = await _queue.pendingItems();
    } catch (e) {
      debugPrint('refreshPending: $e');
    }
    notifyListeners();
  }

  /// Kept for callers that add records offline; the repositories already
  /// enqueue, so this just refreshes the counts.
  void queueForSync(String label) => refreshPending();

  Future<void> retrySync() => _runSync();

  void _onQuality(NetworkQuality next) {
    final wasOffline = _quality != NetworkQuality.good;
    _quality = next;
    notifyListeners();
    if (wasOffline && next == NetworkQuality.good && cloudEnabled) {
      _runSync();
    }
  }

  /// Walks the outbox. In this phase upload is disabled, so rows are
  /// attempted, marked with a clear message and kept — nothing is deleted.
  Future<void> _runSync() async {
    if (_syncing) return;
    await refreshPending();
    if (_pending.isEmpty) return;
    if (!isOnline) {
      _lastSyncFailed = true;
      _lastSyncMessage = 'No internet connection.';
      notifyListeners();
      return;
    }
    _syncing = true;
    _lastSyncFailed = false;
    _lastSyncMessage = null;
    _syncedThisRun.clear();
    notifyListeners();
    try {
      await for (final item in _queue.sync(List.of(_pending))) {
        if (item.count > 0) _syncedThisRun.add(item);
      }
      await refreshPending();
      if (_pending.isNotEmpty) {
        _lastSyncFailed = true;
        _lastSyncMessage = cloudEnabled
            ? 'Some records could not be uploaded.'
            : 'Cloud upload is not enabled yet — your data stays safe on this phone.';
      } else {
        _lastSyncedAt = DateTime.now();
      }
    } catch (e) {
      // Never delete offline data because a sync failed.
      _lastSyncFailed = true;
      _lastSyncMessage = 'Sync error: $e';
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
