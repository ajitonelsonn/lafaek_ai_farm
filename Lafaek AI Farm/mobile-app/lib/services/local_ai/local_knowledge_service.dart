import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../../database/app_database.dart';
import '../../models/models.dart';

/// A knowledge record with retrieval score attached.
class KnowledgeHit {
  const KnowledgeHit({required this.article, required this.score});
  final KnowledgeArticleRow article;
  final double score;
}

/// Local agricultural knowledge: seeds bundled JSON into SQLite on first run
/// and answers queries with a lightweight TF-IDF ranker. No network, no
/// vector database — deliberately simple for the MVP.
class LocalKnowledgeService {
  LocalKnowledgeService(this._db, {AssetBundle? bundle})
      : _bundle = bundle ?? rootBundle;

  final AppDatabase _db;
  final AssetBundle _bundle;

  static const List<String> bundledFiles = [
    'assets/data/agriculture/crops.json',
    'assets/data/agriculture/diseases.json',
    'assets/data/agriculture/pests.json',
    'assets/data/agriculture/soil.json',
    'assets/data/agriculture/irrigation.json',
    'assets/data/agriculture/planting.json',
    'assets/data/agriculture/climate.json',
    'assets/data/agriculture/farming_tips.json',
  ];

  static const String _seedVersionKey = 'knowledge_seed_version';
  static const String seedVersion = '2';

  // In-memory index built lazily from SQLite.
  List<KnowledgeArticleRow>? _articles;
  Map<String, double>? _idf;
  List<Map<String, double>>? _docVectors;

  /// Loads the bundled JSON into SQLite if it has not been seeded yet (or the
  /// seed version changed). Safe to call on every start-up.
  Future<int> seedIfNeeded() async {
    final current = await _db.getMeta(_seedVersionKey);
    final count = await _db.knowledgeDao.count();
    if (current == seedVersion && count > 0) return count;

    final rows = <KnowledgeArticlesCompanion>[];
    for (final path in bundledFiles) {
      final raw = await _bundle.loadString(path);
      final list = jsonDecode(raw) as List<dynamic>;
      for (final item in list) {
        final m = item as Map<String, dynamic>;
        rows.add(KnowledgeArticlesCompanion(
          id: Value(m['id'] as String),
          category: Value(m['category'] as String),
          crop: Value((m['crop'] as String?) ?? 'general'),
          title: Value(m['title'] as String),
          summary: Value(m['summary'] as String),
          symptomsJson: Value(jsonEncode(m['symptoms'] ?? const [])),
          causesJson: Value(jsonEncode(m['causes'] ?? const [])),
          preventionJson: Value(jsonEncode(m['prevention'] ?? const [])),
          actionsJson: Value(jsonEncode(m['actions'] ?? const [])),
          severity: Value((m['severity'] as String?) ?? 'none'),
          keywords: Value(((m['keywords'] as List?) ?? const [])
              .map((k) => k.toString().toLowerCase())
              .join(' ')),
          sectionsJson: Value(jsonEncode(m['sections'] ?? const [])),
          readMinutes: Value(_estimateMinutes(m)),
        ));
      }
    }
    await _db.knowledgeDao.insertAll(rows);
    await _db.setMeta(_seedVersionKey, seedVersion);
    _articles = null; // invalidate index
    return rows.length;
  }

  static int _estimateMinutes(Map<String, dynamic> m) {
    var words = (m['summary'] as String).split(' ').length;
    for (final key in ['symptoms', 'causes', 'prevention', 'actions']) {
      for (final s in (m[key] as List?) ?? const []) {
        words += s.toString().split(' ').length;
      }
    }
    return math.max(1, (words / 120).ceil());
  }

  Future<List<KnowledgeArticleRow>> all() async {
    await _ensureIndex();
    return List.unmodifiable(_articles!);
  }

  Future<KnowledgeArticleRow?> byId(String id) => _db.knowledgeDao.byId(id);

  Future<List<KnowledgeArticleRow>> byCategory(String category) =>
      _db.knowledgeDao.byCategory(category);

  /// Ranks articles for a free-text question using TF-IDF cosine similarity
  /// over title + keywords + summary + symptoms, with a bonus for crop match.
  Future<List<KnowledgeHit>> search(
    String query, {
    int limit = 3,
    String? cropHint,
    String? category,
  }) async {
    await _ensureIndex();
    final qTokens = tokenize(query);
    if (qTokens.isEmpty) return const [];

    final qVec = _vectorize(qTokens);
    final hits = <KnowledgeHit>[];
    for (var i = 0; i < _articles!.length; i++) {
      final a = _articles![i];
      if (category != null && a.category != category) continue;
      var score = _cosine(qVec, _docVectors![i]);
      if (cropHint != null && a.crop.toLowerCase() == cropHint.toLowerCase()) {
        score *= 1.35;
      }
      // Exact phrase bonus: the title appears in the query.
      if (query.toLowerCase().contains(a.title.toLowerCase())) score += 0.5;
      if (score > 0.02) hits.add(KnowledgeHit(article: a, score: score));
    }
    hits.sort((x, y) => y.score.compareTo(x.score));
    return hits.take(limit).toList();
  }

  /// Best article for a CV class id (e.g. `maize_leaf_blight`).
  Future<KnowledgeArticleRow?> forCondition(String conditionId) async {
    final direct = await byId(conditionId);
    if (direct != null) return direct;
    // Fall back to keyword search on the id words.
    final hits = await search(conditionId.replaceAll('_', ' '), limit: 1);
    return hits.isEmpty ? null : hits.first.article;
  }

  // ---- Index ----

  Future<void> _ensureIndex() async {
    if (_articles != null) return;
    final articles = await _db.knowledgeDao.all();
    final docs = articles.map(_docTokens).toList();
    final df = <String, int>{};
    for (final d in docs) {
      for (final t in d.toSet()) {
        df[t] = (df[t] ?? 0) + 1;
      }
    }
    final n = docs.length;
    _idf = {
      for (final e in df.entries) e.key: math.log((n + 1) / (e.value + 1)) + 1,
    };
    _articles = articles;
    _docVectors = docs.map(_vectorize).toList();
  }

  List<String> _docTokens(KnowledgeArticleRow a) {
    final buf = StringBuffer()
      ..write(a.title)
      ..write(' ')
      ..write(a.title) // title weighted twice
      ..write(' ')
      ..write(a.keywords)
      ..write(' ')
      ..write(a.keywords)
      ..write(' ')
      ..write(a.summary)
      ..write(' ')
      ..write(a.crop)
      ..write(' ');
    for (final s in _list(a.symptomsJson)) {
      buf.write('$s ');
    }
    for (final s in _list(a.causesJson)) {
      buf.write('$s ');
    }
    return tokenize(buf.toString());
  }

  Map<String, double> _vectorize(List<String> tokens) {
    final tf = <String, int>{};
    for (final t in tokens) {
      tf[t] = (tf[t] ?? 0) + 1;
    }
    final vec = <String, double>{};
    for (final e in tf.entries) {
      final idf = _idf?[e.key] ?? 1.0;
      vec[e.key] = (1 + math.log(e.value)) * idf;
    }
    return vec;
  }

  static double _cosine(Map<String, double> a, Map<String, double> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    var dot = 0.0, na = 0.0, nb = 0.0;
    for (final e in a.entries) {
      na += e.value * e.value;
      final bv = b[e.key];
      if (bv != null) dot += e.value * bv;
    }
    for (final v in b.values) {
      nb += v * v;
    }
    if (na == 0 || nb == 0) return 0;
    return dot / (math.sqrt(na) * math.sqrt(nb));
  }

  static const Set<String> _stop = {
    'the', 'a', 'an', 'and', 'or', 'of', 'to', 'in', 'on', 'for', 'is', 'are',
    'my', 'i', 'it', 'its', 'this', 'that', 'with', 'be', 'can', 'do', 'does',
    'what', 'why', 'how', 'when', 'where', 'which', 'should', 'me', 'we', 'you',
    'have', 'has', 'as', 'at', 'by', 'from', 'about', 'there', 'they', 'their',
    'not', 'no', 'so', 'if', 'than', 'then', 'very', 'some', 'any', 'all',
  };

  /// Lower-cases, strips punctuation, drops stop-words and applies a light
  /// stemmer so "leaves"/"leaf", "yellowing"/"yellow" match.
  static List<String> tokenize(String text) {
    final out = <String>[];
    for (final raw in text.toLowerCase().split(RegExp(r'[^a-z0-9]+'))) {
      if (raw.length < 2 || _stop.contains(raw)) continue;
      out.add(stem(raw));
    }
    return out;
  }

  static String stem(String w) {
    if (w == 'leaves') return 'leaf';
    if (w.endsWith('ies') && w.length > 4) return '${w.substring(0, w.length - 3)}y';
    // "es" only after a sibilant (boxes, bushes, patches); otherwise drop "s".
    if (w.length > 4 &&
        (w.endsWith('sses') || w.endsWith('xes') || w.endsWith('ches') || w.endsWith('shes') || w.endsWith('zes'))) {
      return w.substring(0, w.length - 2);
    }
    for (final suf in ['ing', 'ed', 's']) {
      if (w.endsWith(suf) && w.length - suf.length >= 3 && !w.endsWith('ss')) {
        return w.substring(0, w.length - suf.length);
      }
    }
    return w;
  }

  static List<String> _list(String json) {
    try {
      return (jsonDecode(json) as List).map((e) => e.toString()).toList();
    } catch (_) {
      return const [];
    }
  }
}

/// Convenience accessors on the Drift row so screens can read the JSON lists.
extension KnowledgeArticleRowX on KnowledgeArticleRow {
  List<String> get symptoms => LocalKnowledgeService._list(symptomsJson);
  List<String> get causes => LocalKnowledgeService._list(causesJson);
  List<String> get prevention => LocalKnowledgeService._list(preventionJson);
  List<String> get actions => LocalKnowledgeService._list(actionsJson);

  List<MapEntry<String, String>> get sections {
    try {
      return (jsonDecode(sectionsJson) as List)
          .map((e) => MapEntry(
              (e as Map)['heading'].toString(), e['body'].toString()))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Map the SQLite row to the UI model used by the Knowledge screens.
  KnowledgeArticle toModel() => KnowledgeArticle(
        id: id,
        category: _categoryOf(category),
        title: title,
        summary: summary,
        sections: [
          ...sections,
          if (symptoms.isNotEmpty) MapEntry('Signs to look for', _bullets(symptoms)),
          if (causes.isNotEmpty) MapEntry('Why it happens', _bullets(causes)),
          if (prevention.isNotEmpty) MapEntry('Prevention', _bullets(prevention)),
          if (actions.isNotEmpty) MapEntry('What to do', _bullets(actions)),
        ],
        readMinutes: readMinutes,
        cachedOffline: true,
      );

  static String _bullets(List<String> items) =>
      items.map((s) => '• $s').join('\n');

  static KnowledgeCategory _categoryOf(String c) {
    switch (c) {
      case 'crop':
        return KnowledgeCategory.cropGuides;
      case 'disease':
        return KnowledgeCategory.diseaseLibrary;
      case 'pest':
        return KnowledgeCategory.pestLibrary;
      case 'soil':
        return KnowledgeCategory.soilHealth;
      case 'irrigation':
        return KnowledgeCategory.waterManagement;
      default:
        return KnowledgeCategory.farmingTips;
    }
  }
}
