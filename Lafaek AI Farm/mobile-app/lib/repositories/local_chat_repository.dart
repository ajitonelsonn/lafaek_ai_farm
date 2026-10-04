import 'dart:convert';

import 'package:drift/drift.dart' show Value;

import '../database/app_database.dart';
import '../models/models.dart';
import 'local_sync_queue_service.dart';

/// Chat history in SQLite. Messages are paginated on read so a long history
/// never lives entirely in memory.
class LocalChatRepository {
  LocalChatRepository(this._db, {required LocalSyncQueueService sync}) : _sync = sync;

  final AppDatabase _db;
  final LocalSyncQueueService _sync;

  Future<List<Conversation>> conversations({int limit = 50}) async {
    final rows = await _db.chatDao.listConversations(limit: limit);
    final out = <Conversation>[];
    for (final c in rows) {
      final last = await _db.chatDao.lastMessage(c.id);
      out.add(Conversation(
        id: c.id,
        title: c.title,
        startedAt: c.startedAt,
        messages: last == null ? const [] : [fromRow(last)],
      ));
    }
    return out;
  }

  Future<List<ChatMessage>> messages(String conversationId, {int limit = 200, int offset = 0}) async =>
      (await _db.chatDao.listMessages(conversationId, limit: limit, offset: offset)).map(fromRow).toList();

  Future<String> createConversation(String title) async {
    final id = 'conv-${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    await _db.chatDao.upsertConversation(ConversationsCompanion(
      id: Value(id),
      title: Value(title),
      startedAt: Value(now),
      updatedAt: Value(now),
    ));
    return id;
  }

  Future<void> renameConversation(String id, String title) async {
    final c = await _db.chatDao.getConversation(id);
    if (c == null) return;
    await _db.chatDao.upsertConversation(ConversationsCompanion(
      id: Value(id),
      title: Value(title),
      startedAt: Value(c.startedAt),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> addMessage(
    String conversationId,
    ChatMessage m, {
    double? confidence,
    String? category,
    List<String> actions = const [],
  }) async {
    await _db.chatDao.insertMessage(ChatMessagesCompanion(
      id: Value(m.id),
      conversationId: Value(conversationId),
      role: Value(m.role.name),
      content: Value(m.text),
      engine: Value(m.engine),
      confidence: Value(confidence),
      category: Value(category),
      actionsJson: Value(actions.isEmpty ? null : jsonEncode(actions)),
      pendingSync: const Value(true),
      sentAt: Value(m.sentAt),
    ));
    await _sync.enqueue(entityType: 'chat', entityId: m.id, operation: 'create', payload: {
      'conversationId': conversationId,
      'role': m.role.name,
      'text': m.text,
      'engine': m.engine,
      'sentAt': m.sentAt.toIso8601String(),
    });
  }

  Future<void> deleteConversation(String id) => _db.chatDao.deleteConversation(id);

  static ChatMessage fromRow(ChatMessageRow r) => ChatMessage(
        id: r.id,
        role: ChatRole.values.byName(r.role),
        text: r.content,
        sentAt: r.sentAt,
        engine: r.engine,
        pendingSync: r.pendingSync,
      );
}
