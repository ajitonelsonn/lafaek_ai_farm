// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'knowledge_dao.dart';

// ignore_for_file: type=lint
mixin _$KnowledgeDaoMixin on DatabaseAccessor<AppDatabase> {
  $KnowledgeArticlesTable get knowledgeArticles =>
      attachedDatabase.knowledgeArticles;
  KnowledgeDaoManager get managers => KnowledgeDaoManager(this);
}

class KnowledgeDaoManager {
  final _$KnowledgeDaoMixin _db;
  KnowledgeDaoManager(this._db);
  $$KnowledgeArticlesTableTableManager get knowledgeArticles =>
      $$KnowledgeArticlesTableTableManager(
          _db.attachedDatabase, _db.knowledgeArticles);
}
