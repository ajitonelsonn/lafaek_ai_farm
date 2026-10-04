import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/ai_tables.dart';

part 'chat_dao.g.dart';

@DriftAccessor(tables: [Conversations, ChatMessages])
class ChatDao extends DatabaseAccessor<AppDatabase> with _$ChatDaoMixin {
  ChatDao(super.db);

  Future<List<ConversationRow>> listConversations({int limit = 50}) =>
      (select(conversations)
            ..orderBy([(c) => OrderingTerm.desc(c.updatedAt)])
            ..limit(limit))
          .get();

  Future<ConversationRow?> getConversation(String id) =>
      (select(conversations)..where((c) => c.id.equals(id))).getSingleOrNull();

  /// Messages for a conversation, oldest first. Paginated so long chats are
  /// never loaded fully into memory.
  Future<List<ChatMessageRow>> listMessages(String conversationId,
          {int limit = 200, int offset = 0}) =>
      (select(chatMessages)
            ..where((m) => m.conversationId.equals(conversationId))
            ..orderBy([(m) => OrderingTerm.asc(m.sentAt)])
            ..limit(limit, offset: offset))
          .get();

  Future<ChatMessageRow?> lastMessage(String conversationId) =>
      (select(chatMessages)
            ..where((m) => m.conversationId.equals(conversationId))
            ..orderBy([(m) => OrderingTerm.desc(m.sentAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> upsertConversation(ConversationsCompanion row) =>
      into(conversations).insertOnConflictUpdate(row);

  Future<void> insertMessage(ChatMessagesCompanion row) => transaction(() async {
        await into(chatMessages).insert(row);
        await (update(conversations)
              ..where((c) => c.id.equals(row.conversationId.value)))
            .write(ConversationsCompanion(updatedAt: Value(DateTime.now())));
      });

  Future<int> deleteConversation(String id) => transaction(() async {
        await (delete(chatMessages)..where((m) => m.conversationId.equals(id)))
            .go();
        return (delete(conversations)..where((c) => c.id.equals(id))).go();
      });
}
