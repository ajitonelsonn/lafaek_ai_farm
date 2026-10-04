import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../repositories/local_chat_repository.dart';
import '../services/ai_service.dart';
import '../services/local_ai/llm_prompt_builder.dart';
import 'connectivity_state.dart';

/// Conversation state for the AI Assistant. Every message is persisted to
/// SQLite; answers stream from the local model.
class ChatState extends ChangeNotifier {
  ChatState({
    required ConnectivityState connectivity,
    required LocalChatRepository repo,
    FarmContext Function()? farmContext,
    VoidCallback? onDataChanged,
  })  : _connectivity = connectivity,
        _repo = repo,
        _farmContext = farmContext,
        _onDataChanged = onDataChanged;

  final ConnectivityState _connectivity;
  final LocalChatRepository _repo;
  final FarmContext Function()? _farmContext;
  final VoidCallback? _onDataChanged;

  List<ChatMessage> _messages = [];
  List<Conversation> _history = [];
  String? _conversationId;
  bool _thinking = false;
  String? _error;
  String? _status;
  String _partial = '';
  String? _engineLabel;
  List<String> _lastSources = const [];
  StreamSubscription<AssistantEvent>? _sub;
  bool _loaded = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<Conversation> get history => List.unmodifiable(_history);
  bool get thinking => _thinking;
  String? get error => _error;
  bool get hasMessages => _messages.isNotEmpty;
  bool get loaded => _loaded;

  /// Status line while thinking ("Preparing local AI…").
  String? get status => _status;

  /// Streaming text of the answer being generated.
  String get partial => _partial;
  String? get engineLabel => _engineLabel;
  List<String> get lastSources => _lastSources;
  String? get conversationId => _conversationId;

  /// Loads history and opens the most recent conversation.
  Future<void> load() async {
    _history = await _repo.conversations();
    if (_history.isNotEmpty) {
      await openConversation(_history.first);
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _thinking) return;
    _error = null;
    _partial = '';
    _status = null;

    _conversationId ??= await _repo.createConversation(_titleFor(trimmed));
    final user = ChatMessage(
      id: 'u-${DateTime.now().millisecondsSinceEpoch}',
      role: ChatRole.user,
      text: trimmed,
      sentAt: DateTime.now(),
      pendingSync: true,
    );
    await _repo.addMessage(_conversationId!, user);
    _messages = [..._messages, user];
    _thinking = true;
    notifyListeners();

    final history = _messages.length > 1 ? _messages.sublist(0, _messages.length - 1) : const <ChatMessage>[];
    final engine = _connectivity.ai;
    _sub?.cancel();
    _sub = engine
        .answer(trimmed, history: history, farm: _farmContext?.call())
        .listen(_onEvent, onError: _onError, onDone: () => _finish());
  }

  void _onEvent(AssistantEvent e) {
    switch (e) {
      case AssistantStatus():
        _status = e.message;
        notifyListeners();
      case AssistantPartial():
        _partial = e.text;
        _status = null;
        notifyListeners();
      case AssistantDone():
        _engineLabel = e.engine;
        _lastSources = e.sources;
        final a = e.answer;
        final text = a.recommendedActions.isEmpty
            ? a.answer
            : '${a.answer}\n\n${a.recommendedActions.map((x) => '• $x').join('\n')}';
        final reply = ChatMessage(
          id: 'a-${DateTime.now().millisecondsSinceEpoch}',
          role: ChatRole.assistant,
          text: text,
          sentAt: DateTime.now(),
          engine: e.engine,
          pendingSync: true,
        );
        _messages = [..._messages, reply];
        _partial = '';
        _status = null;
        final id = _conversationId;
        if (id != null) {
          _repo
              .addMessage(id, reply,
                  confidence: a.confidence, category: a.category, actions: a.recommendedActions)
              .then((_) => _refreshHistory());
        }
        notifyListeners();
    }
  }

  void _onError(Object e, StackTrace st) {
    debugPrint('chat error: $e\n$st');
    _error = e is CloudNotConfiguredException
        ? 'Cloud AI is not available in this version. Local AI answers all questions.'
        : "Couldn't get an answer right now. Please try again.";
    _finish();
  }

  void _finish() {
    _thinking = false;
    _status = null;
    _sub = null;
    notifyListeners();
    _onDataChanged?.call();
  }

  Future<void> cancel() async {
    await _sub?.cancel();
    _sub = null;
    if (_partial.isNotEmpty && _conversationId != null) {
      // Keep whatever was generated so far.
      final reply = ChatMessage(
        id: 'a-${DateTime.now().millisecondsSinceEpoch}',
        role: ChatRole.assistant,
        text: '$_partial …',
        sentAt: DateTime.now(),
        engine: _engineLabel,
        pendingSync: true,
      );
      _messages = [..._messages, reply];
      await _repo.addMessage(_conversationId!, reply);
    }
    _partial = '';
    _finish();
  }

  Future<void> startNewConversation() async {
    await _sub?.cancel();
    _sub = null;
    _thinking = false;
    _messages = [];
    _conversationId = null;
    _error = null;
    _partial = '';
    _status = null;
    await _refreshHistory();
    notifyListeners();
  }

  Future<void> openConversation(Conversation conversation) async {
    await _sub?.cancel();
    _sub = null;
    _thinking = false;
    _conversationId = conversation.id;
    _messages = await _repo.messages(conversation.id);
    _error = null;
    _partial = '';
    notifyListeners();
  }

  Future<void> _refreshHistory() async {
    _history = await _repo.conversations();
    notifyListeners();
  }

  static String _titleFor(String q) => q.length > 40 ? '${q.substring(0, 40)}…' : q;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
