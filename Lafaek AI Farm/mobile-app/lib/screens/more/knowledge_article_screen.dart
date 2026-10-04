import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/buttons.dart';

/// A single knowledge article.
class KnowledgeArticleScreen extends StatelessWidget {
  const KnowledgeArticleScreen({super.key, required this.article});

  final KnowledgeArticle article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: article.category.label,
              subtitle: '${article.readMinutes} min read • Available offline',
              showBack: true,
              showAiStatus: false,
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, 0, AppSpacing.page, 32),
                children: [
                  Text(article.title, style: AppTextStyles.pageTitle),
                  const SizedBox(height: 8),
                  Text(article.summary,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  for (final s in article.sections)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.key, style: AppTextStyles.cardTitle),
                            const SizedBox(height: 6),
                            Text(s.value, style: AppTextStyles.body),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  AppCard(
                    color: AppColors.lightGreen,
                    shadow: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Still have questions?',
                            style: AppTextStyles.cardTitle),
                        const SizedBox(height: 4),
                        Text('Ask the AI Assistant — it works offline too.',
                            style: AppTextStyles.secondary),
                        const SizedBox(height: 12),
                        PrimaryButton(
                          label: 'Ask AI Assistant',
                          icon: Icons.chat_bubble_rounded,
                          height: 50,
                          onPressed: () => Navigator.of(context)
                              .pushNamedAndRemoveUntil(
                            AppRoutes.shell,
                            (r) => false,
                            arguments: MainTab.assistant,
                          ),
                        ),
                      ],
                    ),
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
