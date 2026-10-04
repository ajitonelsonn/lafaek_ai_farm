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
import '../../widgets/states.dart';

/// Knowledge — offline-friendly farming library.
class KnowledgeScreen extends StatefulWidget {
  const KnowledgeScreen({super.key, this.initialCategory});

  final KnowledgeCategory? initialCategory;

  @override
  State<KnowledgeScreen> createState() => _KnowledgeScreenState();
}

class _KnowledgeScreenState extends State<KnowledgeScreen> {
  late KnowledgeCategory? _category = widget.initialCategory;
  final _search = TextEditingController();
  String _query = '';

  /// Illustrated icon per category, used where the tile keeps a light
  /// background. The chips below tint their icon white when selected, so they
  /// stay on the Material glyphs from [visualFor].
  static String assetFor(KnowledgeCategory c) {
    switch (c) {
      case KnowledgeCategory.cropGuides:
        return AppAssets.icCropField;
      case KnowledgeCategory.diseaseLibrary:
        return AppAssets.glyphDiseased;
      case KnowledgeCategory.pestLibrary:
        return AppAssets.icPest;
      case KnowledgeCategory.farmingTips:
        return AppAssets.icTip;
      case KnowledgeCategory.soilHealth:
        return AppAssets.icSoil;
      case KnowledgeCategory.waterManagement:
        return AppAssets.icWater;
    }
  }

  static (IconData, Color, Color) visualFor(KnowledgeCategory c) {
    switch (c) {
      case KnowledgeCategory.cropGuides:
        return (Icons.eco_rounded, AppColors.primary, AppColors.lightGreen);
      case KnowledgeCategory.diseaseLibrary:
        return (Icons.coronavirus_rounded, AppColors.danger, AppColors.dangerTint);
      case KnowledgeCategory.pestLibrary:
        return (Icons.bug_report_rounded, AppColors.warning, AppColors.warningTint);
      case KnowledgeCategory.farmingTips:
        return (Icons.lightbulb_rounded, AppColors.lavender, AppColors.lavenderTint);
      case KnowledgeCategory.soilHealth:
        return (Icons.grass_rounded, AppColors.earthBrown, AppColors.earthTint);
      case KnowledgeCategory.waterManagement:
        return (Icons.water_drop_rounded, AppColors.waterBlue, AppColors.skyTint);
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = context.watch<FarmState>().knowledge;
    final q = _query.toLowerCase();
    final articles = all.where((a) {
      final catOk = _category == null || a.category == _category;
      final qOk = q.isEmpty ||
          a.title.toLowerCase().contains(q) ||
          a.summary.toLowerCase().contains(q);
      return catOk && qOk;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Knowledge',
              subtitle: 'Farming guides that work offline',
              showBack: true,
              showAiStatus: false,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page, 0, AppSpacing.page, 12),
              child: TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Search guides…',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                children: [
                  _CatChip(
                    label: 'All',
                    icon: Icons.apps_rounded,
                    color: AppColors.primary,
                    selected: _category == null,
                    onTap: () => setState(() => _category = null),
                  ),
                  for (final c in KnowledgeCategory.values)
                    _CatChip(
                      label: c.label,
                      icon: visualFor(c).$1,
                      color: visualFor(c).$2,
                      selected: _category == c,
                      onTap: () => setState(() => _category = c),
                    ),
                ],
              ),
            ),
            Expanded(
              child: articles.isEmpty
                  ? const EmptyState(
                      asset: AppAssets.icSearch,
                      title: 'Nothing found',
                      message: 'Try another word or category.',
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.page, 16, AppSpacing.page, 32),
                      itemCount: articles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final a = articles[i];
                        final (_, color, tint) = visualFor(a.category);
                        return FadeSlideIn(
                          delay: Duration(milliseconds: 40 * i),
                          child: AppCard(
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.knowledgeArticle,
                              arguments: a,
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                IconTile(
                                    asset: assetFor(a.category),
                                    background: tint),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(a.title, style: AppTextStyles.cardTitle),
                                      const SizedBox(height: 2),
                                      Text(a.summary, style: AppTextStyles.secondary,
                                          maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 8,
                                        runSpacing: 2,
                                        children: [
                                          Text(a.category.label,
                                              style: AppTextStyles.caption
                                                  .copyWith(color: color)),
                                          Text('• ${a.readMinutes} min',
                                              style: AppTextStyles.caption),
                                          if (a.cachedOffline)
                                            Wrap(
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              spacing: 3,
                                              children: [
                                                const Icon(Icons.offline_pin_rounded,
                                                    size: 14, color: AppColors.success),
                                                Text('Offline',
                                                    style: AppTextStyles.caption
                                                        .copyWith(color: AppColors.success)),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded,
                                    color: AppColors.textSecondary),
                              ],
                            ),
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

class _CatChip extends StatelessWidget {
  const _CatChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: selected ? AppColors.primary : AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: selected ? Colors.white : color),
                const SizedBox(width: 6),
                Text(label,
                    style: AppTextStyles.bodyStrong.copyWith(
                      fontSize: 14,
                      color: selected ? Colors.white : AppColors.textPrimary,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
