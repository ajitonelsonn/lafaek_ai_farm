import '../../database/app_database.dart';
import 'local_knowledge_service.dart';

/// Snapshot of the farm passed into prompts so answers are specific.
class FarmContext {
  const FarmContext({
    this.location = 'Timor-Leste',
    this.crops = const [],
    this.season,
    this.weatherSummary,
  });

  final String location;

  /// e.g. ["Maize 2.0 ha (vegetative)", "Rice 1.0 ha (tillering)"]
  final List<String> crops;
  final String? season;
  final String? weatherSummary;

  String render() {
    final b = StringBuffer('Farm: $location.');
    if (crops.isNotEmpty) b.write(' Crops: ${crops.join('; ')}.');
    if (season != null) b.write(' Season: $season.');
    if (weatherSummary != null) b.write(' Weather: $weatherSummary.');
    return b.toString();
  }
}

/// Builds prompts for the Lafaek AI Farmer Assistant.
///
/// Kept short because a 1B model follows short, concrete instructions far
/// better than long policy text.
class LlmPromptBuilder {
  const LlmPromptBuilder();

  static const String systemPrompt = '''
You are Lafaek, a friendly farming assistant for smallholder farmers in Timor-Leste. Answer in simple English a farmer can act on.
Priorities: crop care, soil, irrigation, pests, crop diseases, planting, weather-related decisions, farm records.
Rules:
- Use the KNOWLEDGE notes when relevant; they are trusted local guidance.
- Never claim certainty. Use words like "possible", "likely", "signs may be consistent with", "consider checking".
- Never give pesticide dosages or product names; say to ask the local extension officer for approved options.
- Keep the answer under 120 words, then give 2-4 short practical actions.
- If the question cannot be answered from the notes or general farming knowledge, say what to check or who to ask.
Respond ONLY with JSON in this exact shape:
{"answer":"...","confidence":0.0,"category":"crop_health|soil|water|pest|disease|planting|weather|records|general","recommended_actions":["..."],"needs_more_information":false}''';

  /// Compact system prompt used when the model is small and we want the
  /// answer text first (JSON still requested but tolerated if missing).
  static const String scanSystemPrompt = '''
You are Lafaek, a farming assistant in Timor-Leste. A local image model has looked at a crop photo. Explain the finding to the farmer in simple English.
Rules: be honest about uncertainty; use "possible" or "likely"; no pesticide dosages or product names; under 90 words; then 3-4 short actions.
Respond ONLY with JSON: {"answer":"...","confidence":0.0,"category":"disease","recommended_actions":["..."],"needs_more_information":false}''';

  /// User turn for a free-text question with retrieved knowledge.
  String question({
    required String question,
    required List<KnowledgeHit> knowledge,
    FarmContext? farm,
  }) {
    final b = StringBuffer();
    if (farm != null) b.writeln('CONTEXT: ${farm.render()}');
    if (knowledge.isNotEmpty) {
      b.writeln('KNOWLEDGE:');
      for (final hit in knowledge) {
        b.writeln(_renderArticle(hit.article));
      }
    }
    b.writeln('QUESTION: $question');
    return b.toString();
  }

  /// User turn for explaining a CV classification.
  String scan({
    required String cropName,
    required String conditionLabel,
    required double confidence,
    required String confidenceBand,
    KnowledgeArticleRow? article,
    FarmContext? farm,
  }) {
    final b = StringBuffer();
    if (farm != null) b.writeln('CONTEXT: ${farm.render()}');
    b.writeln(
        'IMAGE RESULT: crop=$cropName, finding=$conditionLabel, model confidence=${(confidence * 100).round()}% ($confidenceBand).');
    if (article != null) {
      b.writeln('KNOWLEDGE:');
      b.writeln(_renderArticle(article, maxItems: 4));
    }
    b.writeln('TASK: Explain what this may mean and what the farmer should do next.');
    return b.toString();
  }

  /// User turn for explaining a rule-based risk assessment.
  String risk({
    required String cropName,
    required String level,
    required List<String> reasons,
    FarmContext? farm,
  }) {
    final b = StringBuffer();
    if (farm != null) b.writeln('CONTEXT: ${farm.render()}');
    b.writeln('RISK: $cropName has $level risk this week because: ${reasons.join('; ')}.');
    b.writeln('TASK: In 2-3 sentences tell the farmer what this means and the most useful thing to do.');
    return b.toString();
  }

  static String _renderArticle(KnowledgeArticleRow a, {int maxItems = 3}) {
    final b = StringBuffer('- ${a.title}: ${a.summary}');
    final sym = a.symptoms.take(maxItems).toList();
    if (sym.isNotEmpty) b.write(' Signs: ${sym.join('; ')}.');
    final act = a.actions.take(maxItems).toList();
    if (act.isNotEmpty) b.write(' Actions: ${act.join('; ')}.');
    return b.toString();
  }
}
