import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/ai_tables.dart';

part 'knowledge_dao.g.dart';

@DriftAccessor(tables: [KnowledgeArticles])
class KnowledgeDao extends DatabaseAccessor<AppDatabase>
    with _$KnowledgeDaoMixin {
  KnowledgeDao(super.db);

  Future<List<KnowledgeArticleRow>> all() =>
      (select(knowledgeArticles)..orderBy([(k) => OrderingTerm.asc(k.title)]))
          .get();

  Future<List<KnowledgeArticleRow>> byCategory(String category) =>
      (select(knowledgeArticles)..where((k) => k.category.equals(category)))
          .get();

  Future<KnowledgeArticleRow?> byId(String id) =>
      (select(knowledgeArticles)..where((k) => k.id.equals(id)))
          .getSingleOrNull();

  /// Simple SQL pre-filter used before TF-IDF ranking in Dart.
  Future<List<KnowledgeArticleRow>> search(String term) {
    final like = '%${term.toLowerCase()}%';
    return (select(knowledgeArticles)
          ..where((k) =>
              k.keywords.like(like) |
              k.title.lower().like(like) |
              k.summary.lower().like(like)))
        .get();
  }

  Future<int> count() async {
    final c = countAll();
    final q = selectOnly(knowledgeArticles)..addColumns([c]);
    return (await q.getSingle()).read(c) ?? 0;
  }

  Future<void> insertAll(List<KnowledgeArticlesCompanion> rows) => batch((b) {
        b.insertAllOnConflictUpdate(knowledgeArticles, rows);
      });
}
