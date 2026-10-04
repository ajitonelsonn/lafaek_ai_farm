import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../navigation/app_routes.dart';
import '../../state/farm_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/list_cards.dart';
import '../../widgets/states.dart';

/// Farm Activity — full activity log.
class FarmActivityScreen extends StatelessWidget {
  const FarmActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = context.watch<FarmState>().activities;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.logActivity),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Activity'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(
              title: 'Farm Activity',
              subtitle: 'Everything you\'ve done on the farm',
              showBack: true,
              showAiStatus: false,
            ),
            Expanded(
              child: activities.isEmpty
                  ? EmptyState(
                      asset: AppAssets.icHistory,
                      title: 'No activities yet',
                      message: 'Log watering, fertilizer or planting to build your farm history.',
                      actionLabel: 'Log Activity',
                      onAction: () => Navigator.of(context).pushNamed(AppRoutes.logActivity),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.page, 0, AppSpacing.page, 96),
                      itemCount: activities.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => FadeSlideIn(
                        delay: Duration(milliseconds: 40 * i),
                        child: ActivityRow(activity: activities[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
