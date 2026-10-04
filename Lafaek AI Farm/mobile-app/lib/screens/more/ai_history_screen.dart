import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../core/formatters.dart';
import '../../navigation/app_routes.dart';
import '../../state/chat_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/chat_widgets.dart';
import '../../widgets/states.dart';

/// AI Conversation History.
class AiHistoryScreen extends StatelessWidget {
  const AiHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatState>();
    final history = chat.history;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'AI History',
              subtitle: 'Your past conversations',
              showBack: true,
              showAiStatus: false,
            ),
            Expanded(
              child: history.isEmpty
                  ? EmptyState(
                      asset: AppAssets.icAssistant,
                      title: 'No conversations yet',
                      message: 'Ask the AI Assistant a farming question to get started.',
                      actionLabel: 'Ask AI',
                      onAction: () => Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.shell,
                        (r) => false,
                        arguments: MainTab.assistant,
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.page, 0, AppSpacing.page, 32),
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final c = history[i];
                        final engine = c.messages
                            .where((m) => m.engine != null)
                            .map((m) => m.engine!)
                            .firstOrNull;
                        return AppCard(
                          onTap: () {
                            chat.openConversation(c);
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.shell,
                              (r) => false,
                              arguments: MainTab.assistant,
                            );
                          },
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              const AssistantAvatar(size: 44),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.title, style: AppTextStyles.cardTitle,
                                        maxLines: 1, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 2),
                                    Text(c.preview, style: AppTextStyles.secondary,
                                        maxLines: 2, overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        Text(Formatters.timeAgo(c.startedAt),
                                            style: AppTextStyles.caption),
                                        if (engine != null)
                                          Text('• $engine', style: AppTextStyles.caption),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: AppColors.textSecondary),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
