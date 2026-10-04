import 'dart:convert';

/// Structured answer from the local model. When the model does not return
/// valid JSON we still fill [answer] with the raw text so nothing is lost.
class StructuredAnswer {
  const StructuredAnswer({
    required this.answer,
    this.confidence,
    this.category,
    this.recommendedActions = const [],
    this.needsMoreInformation = false,
    this.structured = true,
    this.raw = '',
  });

  final String answer;
  final double? confidence;
  final String? category;
  final List<String> recommendedActions;
  final bool needsMoreInformation;

  /// False when we fell back to plain text.
  final bool structured;
  final String raw;

  Map<String, dynamic> toJson() => {
        'answer': answer,
        'confidence': confidence,
        'category': category,
        'recommended_actions': recommendedActions,
        'needs_more_information': needsMoreInformation,
        'structured': structured,
      };
}

/// Validates and repairs the model's JSON output.
class LlmOutputParser {
  const LlmOutputParser();

  static const Set<String> _categories = {
    'crop_health', 'soil', 'water', 'pest', 'disease', 'planting', 'weather',
    'records', 'general',
  };

  /// Parses the complete generation. Never throws.
  StructuredAnswer parse(String raw) {
    final text = _stripFences(raw).trim();
    final json = _extractJsonObject(text);
    if (json != null) {
      try {
        final m = jsonDecode(json) as Map<String, dynamic>;
        final answer = (m['answer'] ?? '').toString().trim();
        if (answer.isNotEmpty) {
          return StructuredAnswer(
            answer: _clean(answer),
            confidence: _confidence(m['confidence']),
            category: _category(m['category']),
            recommendedActions: _actions(m['recommended_actions']),
            needsMoreInformation: m['needs_more_information'] == true,
            structured: true,
            raw: raw,
          );
        }
      } catch (_) {
        // fall through to the lenient path
      }
      // Truncated JSON (max tokens hit): salvage the answer string.
      final salvaged = _salvageAnswer(json);
      if (salvaged != null && salvaged.isNotEmpty) {
        return StructuredAnswer(
          answer: _clean(salvaged),
          recommendedActions: _salvageActions(json),
          structured: false,
          raw: raw,
        );
      }
    }
    // Plain-text fallback: show what the model said, minus JSON scaffolding.
    final plain = _clean(text.replaceAll(RegExp(r'^[{\[]|[}\]]$'), ''));
    return StructuredAnswer(
      answer: plain.isEmpty ? 'I could not produce an answer. Please try again.' : plain,
      structured: false,
      raw: raw,
    );
  }

  /// For streaming: the best guess of the visible answer text so far.
  /// Returns the content of the "answer" field if the model is emitting JSON,
  /// otherwise the raw partial text.
  String partialAnswer(String partial) {
    final text = _stripFences(partial);
    final m = RegExp(r'"answer"\s*:\s*"').firstMatch(text);
    if (m == null) {
      // Not (yet) JSON — if it starts with "{" hide the scaffolding.
      return text.trimLeft().startsWith('{') ? '' : text;
    }
    final start = m.end;
    final buf = StringBuffer();
    var escaped = false;
    for (var i = start; i < text.length; i++) {
      final c = text[i];
      if (escaped) {
        buf.write(_unescape(c));
        escaped = false;
      } else if (c == r'\') {
        escaped = true;
      } else if (c == '"') {
        break;
      } else {
        buf.write(c);
      }
    }
    return buf.toString();
  }

  // ---- helpers ----

  static String _stripFences(String s) =>
      s.replaceAll(RegExp(r'```(?:json)?', caseSensitive: false), '');

  static String? _extractJsonObject(String s) {
    final start = s.indexOf('{');
    if (start < 0) return null;
    final end = s.lastIndexOf('}');
    return end > start ? s.substring(start, end + 1) : s.substring(start);
  }

  static String? _salvageAnswer(String json) {
    final m = RegExp(r'"answer"\s*:\s*"((?:[^"\\]|\\.)*)').firstMatch(json);
    if (m == null) return null;
    return m.group(1)!.replaceAll(r'\n', '\n').replaceAll(r'\"', '"');
  }

  static List<String> _salvageActions(String json) {
    final m = RegExp(r'"recommended_actions"\s*:\s*\[([^\]]*)').firstMatch(json);
    if (m == null) return const [];
    return RegExp(r'"((?:[^"\\]|\\.)*)"')
        .allMatches(m.group(1)!)
        .map((x) => x.group(1)!.trim())
        .where((x) => x.isNotEmpty)
        .toList();
  }

  static double? _confidence(dynamic v) {
    if (v is num) return v.toDouble().clamp(0.0, 1.0);
    if (v is String) return double.tryParse(v)?.clamp(0.0, 1.0);
    return null;
  }

  static String? _category(dynamic v) {
    final s = v?.toString().toLowerCase().trim();
    if (s == null || s.isEmpty) return null;
    if (_categories.contains(s)) return s;
    // Accept the "a|b|c" literal a small model might echo back.
    final first = s.split('|').first.trim();
    return _categories.contains(first) ? first : 'general';
  }

  static List<String> _actions(dynamic v) {
    if (v is! List) return const [];
    return v
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty && e != '...')
        .take(6)
        .toList();
  }

  static String _clean(String s) => s
      .replaceAll(RegExp(r'\s+\n'), '\n')
      .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
      .trim();

  static String _unescape(String c) {
    switch (c) {
      case 'n':
        return '\n';
      case 't':
        return '\t';
      default:
        return c;
    }
  }
}
