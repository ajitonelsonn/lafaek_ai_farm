import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../models/models.dart';
import '../../navigation/app_routes.dart';
import '../../state/farm_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/buttons.dart';
import '../../widgets/states.dart';

/// Disease Details — "Learn more" target from a scan result. Finds the
/// matching knowledge article (if any) and presents it with a photo.
class DiseaseDetailsScreen extends StatelessWidget {
  const DiseaseDetailsScreen({super.key, required this.diseaseName});

  final String diseaseName;

  String get _cleanName => diseaseName
      .replaceAll(RegExp(r'^(Possible|Likely|Signs of)\s+', caseSensitive: false), '')
      .trim();

  @override
  Widget build(BuildContext context) {
    final knowledge = context.watch<FarmState>().knowledge;
    final key = _cleanName.toLowerCase();
    final article = knowledge
        .where((a) =>
            a.category == KnowledgeCategory.diseaseLibrary &&
            a.title.toLowerCase().contains(key.split(' ').first))
        .firstOrNull;
    final healthy = key == 'healthy' || key == 'normal';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: _cleanName,
              subtitle: healthy ? 'Good news' : 'Disease Library',
              showBack: true,
              showAiStatus: false,
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, 0, AppSpacing.page, 32),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    child: Image.asset(
                      healthy ? AppAssets.scanMaizeHealthy : AppAssets.leafBlight,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (healthy)
                    const EmptyState(
                      asset: AppAssets.icSuccess,
                      title: 'Your crop looks healthy',
                      message:
                          'Keep monitoring and scan again if you notice spots, wilting or yellowing.',
                    )
                  else if (article == null)
                    EmptyState(
                      asset: AppAssets.icKnowledge,
                      title: 'Guide not available offline yet',
                      message:
                          'We\'ll download the guide for $_cleanName the next time you\'re online.',
                      actionLabel: 'Browse Disease Library',
                      onAction: () => Navigator.of(context).pushNamed(
                        AppRoutes.knowledge,
                        arguments: KnowledgeCategory.diseaseLibrary,
                      ),
                    )
                  else ...[
                    Text(article.summary,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 16),
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
                  ],
                  const SizedBox(height: 8),
                  AppCard(
                    color: AppColors.warningTint,
                    shadow: false,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_rounded, color: AppColors.warning),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'AI results are possible diagnoses, not confirmed ones. For uncertain cases, consider checking with a local agricultural extension officer.',
                            style: AppTextStyles.body.copyWith(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SecondaryButton(
                    label: 'Browse Disease Library',
                    icon: Icons.menu_book_rounded,
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.knowledge,
                      arguments: KnowledgeCategory.diseaseLibrary,
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
