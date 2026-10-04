import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_assets.dart';
import '../../navigation/app_routes.dart';
import '../../state/farm_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/buttons.dart';
import '../../widgets/list_cards.dart';
import '../../widgets/states.dart';

/// Alerts & Recommendations — each with a clear recommended action.
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmState>();
    final alerts = farm.alerts;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Alerts',
              subtitle: 'What to do and when',
              showBack: true,
              trailing: farm.unreadAlerts == 0
                  ? null
                  : LinkButton(
                      label: 'Mark all read',
                      onPressed: farm.markAllAlertsRead,
                    ),
            ),
            Expanded(
              child: alerts.isEmpty
                  ? const EmptyState(
                      asset: AppAssets.icAlerts,
                      title: 'No alerts',
                      message: 'We\'ll let you know when weather or crop conditions need attention.',
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.page, 0, AppSpacing.page, 32),
                      itemCount: alerts.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        if (i == alerts.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: SecondaryButton(
                              label: 'See full weather forecast',
                              icon: Icons.wb_cloudy_rounded,
                              onPressed: () =>
                                  Navigator.of(context).pushNamed(AppRoutes.weather),
                            ),
                          );
                        }
                        final a = alerts[i];
                        return FadeSlideIn(
                          delay: Duration(milliseconds: 40 * i),
                          child: AlertCard(
                            alert: a,
                            showAction: true,
                            onTap: () => farm.markAlertRead(a.id),
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
