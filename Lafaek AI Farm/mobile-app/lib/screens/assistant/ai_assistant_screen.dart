import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../navigation/main_shell.dart';
import '../../services/local_ai/local_ai_engine.dart';
import '../../services/local_ai/local_model_manager.dart';
import '../../core/crop_catalogue.dart';
import '../../state/chat_state.dart';
import '../../state/connectivity_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ai_status_pill.dart';
import '../../widgets/app_header.dart';
import '../../widgets/buttons.dart';
import '../../widgets/chat_widgets.dart';
import '../../widgets/states.dart';

/// Conversational farming assistant.
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();
  int _lastCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send([String? text]) {
    final msg = text ?? _controller.text;
    if (msg.trim().isEmpty) return;
    _controller.clear();
    context.read<ChatState>().send(msg);
    _focus.unfocus();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    });
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatState>();
    final engine = context.watch<ConnectivityState>().ai.engineName;
    final local = context.watch<LocalAiEngine>();
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // Scroll when a message is added or while the answer streams.
    final count = chat.messages.length + (chat.thinking ? 1 : 0) + (chat.partial.length ~/ 80);
    if (count != _lastCount) {
      _lastCount = count;
      _scrollToBottom();
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(
              title: 'AI Assistant',
              subtitle: 'Your farming companion, always here to help.',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AIStatusPill(compact: true),
                  const SizedBox(width: 8),
                  RoundIconButton(
                    icon: Icons.history_rounded,
                    tooltip: 'Conversation history',
                    size: 44,
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.aiHistory),
                  ),
                ],
              ),
            ),
            const OfflineBanner(),
            _EngineChip(engine: local),
            Expanded(
              child: ListView(
                controller: _scroll,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, 0, AppSpacing.page, 16),
                children: [
                  _WelcomePanel(onCategory: (q) => _send(q)),
                  const SizedBox(height: 16),
                  if (!chat.hasMessages && !chat.thinking)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: EmptyState(
                        asset: AppAssets.mascotChat,
                        title: 'Start a conversation',
                        message:
                            'Ask anything about your crops, soil, weather or pests.',
                      ),
                    ),
                  for (final m in chat.messages)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FadeSlideIn(
                        offset: 8,
                        child: AIMessageBubble(message: m),
                      ),
                    ),
                  if (chat.thinking && chat.partial.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AIMessageBubble(
                        message: ChatMessage(
                          id: 'streaming',
                          role: ChatRole.assistant,
                          text: '${chat.partial}▍',
                          sentAt: DateTime.now(),
                          engine: local.llmReady ? local.llmDisplayName : engine,
                        ),
                      ),
                    )
                  else if (chat.thinking)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TypingIndicator(
                        engine: local.llmReady ? local.llmDisplayName : engine,
                        label: chat.status,
                      ),
                    ),
                  if (chat.thinking)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: chat.cancel,
                          icon: const Icon(Icons.stop_circle_outlined, size: 18),
                          label: const Text('Stop'),
                          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  if (!chat.thinking && chat.hasMessages && chat.lastSources.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 48, bottom: 10),
                      child: Text(
                        'From the local library: ${chat.lastSources.join(' · ')}',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  if (chat.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(chat.error!,
                          style: AppTextStyles.secondary
                              .copyWith(color: AppColors.danger)),
                    ),
                  if (chat.hasMessages && !chat.thinking)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          _FeedbackButton(
                            icon: Icons.thumb_up_outlined,
                            onTap: () => _toast('Thanks for the feedback!'),
                          ),
                          const SizedBox(width: 8),
                          _FeedbackButton(
                            icon: Icons.thumb_down_outlined,
                            onTap: () =>
                                _toast("We'll use this to improve answers."),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: chat.startNewConversation,
                            icon: const Icon(Icons.add_comment_outlined,
                                size: 18),
                            label: const Text('New chat'),
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  // Suggested questions only while the chat is empty, so an
                  // answer is always the last thing on screen.
                  if (!chat.hasMessages && !chat.thinking) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 4),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text('Suggested questions',
                                style: AppTextStyles.sectionTitle),
                          ),
                          LinkButton(
                            label: 'See all',
                            onPressed: () => Navigator.of(context)
                                .pushNamed(AppRoutes.knowledge),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    _SuggestionGrid(onTap: _send),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'AI advice is informational. For uncertain cases, local agricultural expertise may be needed.',
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            _Composer(
              controller: _controller,
              focus: _focus,
              enabled: !chat.thinking,
              onSend: () => _send(),
              onAttach: () => MainShellScope.of(context).goTo(MainTab.scan),
              onMic: () =>
                  _toast('Voice input is coming soon. Type your question.'),
              bottomInset: bottomInset,
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel({required this.onCategory});
  final ValueChanged<String> onCategory;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.mint, AppColors.lightGreen],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 14, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(AppAssets.robot, width: 120, height: 136,
                      fit: BoxFit.contain),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hello!',
                              style: AppTextStyles.sectionTitle
                                  .copyWith(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(
                            'Ask me anything about your crops, soil, weather, pests, or farming practices. I\'m here to help! 🌱',
                            style: AppTextStyles.body.copyWith(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  CategoryChip(
                    label: 'Crop advice',
                    icon: Icons.eco_rounded,
                    onTap: () => onCategory('How do I keep my maize healthy?'),
                  ),
                  const SizedBox(width: 8),
                  CategoryChip(
                    label: 'Weather insights',
                    icon: Icons.wb_cloudy_rounded,
                    color: AppColors.skyBlue,
                    onTap: () => onCategory(
                        'How will this week\'s weather affect my crops?'),
                  ),
                  const SizedBox(width: 8),
                  CategoryChip(
                    label: 'Pest & disease',
                    icon: Icons.bug_report_rounded,
                    color: AppColors.danger,
                    onTap: () =>
                        onCategory('What are common pests in maize?'),
                  ),
                  const SizedBox(width: 8),
                  CategoryChip(
                    label: 'Farming knowledge',
                    icon: Icons.menu_book_rounded,
                    color: AppColors.primaryDark,
                    onTap: () => onCategory('How can I improve my soil health?'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionGrid extends StatelessWidget {
  const _SuggestionGrid({required this.onTap});
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    const icons = [
      (Icons.eco_rounded, AppColors.primary),
      (Icons.bug_report_rounded, AppColors.danger),
      (Icons.wb_sunny_rounded, AppColors.warning),
      (Icons.water_drop_rounded, AppColors.waterBlue),
    ];
    final qs = CropCatalogue.suggestedQuestions;
    return LayoutBuilder(
      builder: (context, c) {
        final twoCols = c.maxWidth >= 360;
        final chips = [
          for (var i = 0; i < qs.length; i++)
            SuggestionChip(
              label: qs[i],
              icon: icons[i % icons.length].$1,
              iconColor: icons[i % icons.length].$2,
              onTap: () => onTap(qs[i]),
            ),
        ];
        if (!twoCols) {
          return Column(
            children: [
              for (final ch in chips)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ch,
                ),
            ],
          );
        }
        return Column(
          children: [
            for (var i = 0; i < chips.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: chips[i]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: i + 1 < chips.length
                            ? chips[i + 1]
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  const _FeedbackButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: SizedBox(
          width: 52,
          height: 40,
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focus,
    required this.enabled,
    required this.onSend,
    required this.onAttach,
    required this.onMic,
    required this.bottomInset,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final bool enabled;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onMic;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    // Inside the shell, bottomInset equals the bottom-nav height, so the
    // composer sits just above it while the keyboard is closed.
    final pad = keyboard > 0 ? 12.0 : bottomInset + 12.0;
    return Container(
      padding: EdgeInsets.fromLTRB(12, 10, 12, pad),
      decoration: const BoxDecoration(
        color: AppColors.cream,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          RoundIconButton(
            icon: Icons.add_rounded,
            tooltip: 'Attach photo',
            size: 46,
            onPressed: onAttach,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focus,
              enabled: enabled,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              minLines: 1,
              maxLines: 4,
              style: AppTextStyles.body,
              decoration: const InputDecoration(
                hintText: 'Type your question here...',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CircleAction(
            icon: Icons.mic_rounded,
            onTap: onMic,
            tooltip: 'Voice input',
          ),
          const SizedBox(width: 8),
          _CircleAction(
            icon: Icons.send_rounded,
            onTap: enabled ? onSend : null,
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: onTap == null
              ? AppColors.primaryDark.withValues(alpha: 0.5)
              : AppColors.primaryDark,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 46,
              height: 46,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}


/// Shows which local engine answers right now; taps open the status sheet
/// (where the model can be installed).
class _EngineChip extends StatelessWidget {
  const _EngineChip({required this.engine});
  final LocalAiEngine engine;

  @override
  Widget build(BuildContext context) {
    final String text;
    final IconData icon;
    final Color color;
    if (engine.llmReady) {
      text = '${engine.llmDisplayName} · runs on this phone';
      icon = Icons.psychology_rounded;
      color = AppColors.success;
    } else if (engine.llmInstalled) {
      text = engine.llmState == ModelState.initializing
          ? 'Preparing local AI… ${engine.llmDisplayName}'
          : '${engine.llmDisplayName} installed · loads on first question';
      icon = Icons.psychology_rounded;
      color = AppColors.warning;
    } else {
      text = 'Answering from the offline library · tap to install ${engine.recommendedModel?.displayName ?? 'Llama 3.2'}';
      icon = Icons.download_for_offline_rounded;
      color = AppColors.waterBlue;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, 10),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: () => showAiStatusSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary)),
                ),
                const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
