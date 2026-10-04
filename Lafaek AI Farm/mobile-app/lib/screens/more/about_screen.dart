import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/local_ai/local_ai_engine.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_header.dart';
import '../../widgets/states.dart';

/// About — what Lafaek AI Farm is and how it works.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = context.watch<LocalAiEngine>();
    final vi = engine.visionInfo;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(title: 'About', showBack: true, showAiStatus: false),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, 8, AppSpacing.page, 32),
                children: [
                  const Center(child: LafaekLogo(size: 120, glow: true)),
                  const SizedBox(height: 16),
                  Text('Lafaek AI Farm',
                      textAlign: TextAlign.center, style: AppTextStyles.pageTitle),
                  Text('Version 0.1.0 • Hackathon build',
                      textAlign: TextAlign.center, style: AppTextStyles.secondary),
                  const SizedBox(height: 20),
                  AppCard(
                    color: AppColors.lightGreen,
                    shadow: false,
                    child: Text(
                      'A trusted farming companion that works anywhere.\n\nLafaek helps farmers in Timor-Leste scan crops, understand weather risk and get practical advice — online with Amazon Bedrock, or offline with Local AI on the phone.',
                      style: AppTextStyles.body,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Our principle', style: AppTextStyles.cardTitle),
                        SizedBox(height: 6),
                        Text('Cloud is the enhancement. Offline is the guarantee.',
                            style: AppTextStyles.body),
                        SizedBox(height: 14),
                        Text('Good to know', style: AppTextStyles.cardTitle),
                        SizedBox(height: 6),
                        Text(
                          'AI advice is informational. Results use words like "possible" and "likely" because no photo can confirm a diagnosis. For uncertain cases, check with a local agricultural extension officer.',
                          style: AppTextStyles.body,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Local AI models', style: AppTextStyles.cardTitle),
                        const SizedBox(height: 8),
                        Text('Vision: ${vi?.architecture ?? 'MobileNetV3-Small'} v${vi?.version ?? '—'}',
                            style: AppTextStyles.body.copyWith(fontSize: 14)),
                        if (vi != null) ...[
                          Text('Classes: ${vi.classes.join(', ')}', style: AppTextStyles.secondary),
                          Text('Validation accuracy: ${(vi.valAccuracy * 100).toStringAsFixed(1)}%',
                              style: AppTextStyles.secondary),
                          Text('Training data: ${vi.trainingData}', style: AppTextStyles.secondary),
                          Text('Status: ${vi.status}', style: AppTextStyles.secondary),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          'Language: ${engine.selectedModel?.spec.displayName ?? 'Llama 3.2 1B (not installed)'}'
                          '${engine.selectedModel != null ? ' · ${engine.selectedModel!.spec.parameters} · ${engine.selectedModel!.spec.license}' : ''}',
                          style: AppTextStyles.body.copyWith(fontSize: 14),
                        ),
                        Text('Runtime: llama.cpp (on-device) · TensorFlow Lite (on-device) · SQLite (Drift)',
                            style: AppTextStyles.secondary),
                        const SizedBox(height: 4),
                        Text('Device: ${engine.device ?? 'detecting…'}', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('What needs the internet',
                            style: AppTextStyles.cardTitle),
                        const SizedBox(height: 8),
                        Text(
                          'Only two things. Everything else — your records, the '
                          'crop scanner, the assistant and the knowledge library '
                          '— runs on this phone.',
                          style: AppTextStyles.body.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text('• Weather forecast, from Open-Meteo. Fetched when '
                            'you have a signal and saved on the phone, so the '
                            'last forecast is always there offline.',
                            style: AppTextStyles.secondary),
                        Text('• Map tiles, from OpenStreetMap. Tiles you have '
                            'already seen are kept on the phone and shown offline.',
                            style: AppTextStyles.secondary),
                        const SizedBox(height: 8),
                        Text('Your position is never sent anywhere. It is saved '
                            'on this phone and used to ask for the forecast at '
                            'that point.',
                            style: AppTextStyles.secondary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Built for the Hack-Nation Global AI Hackathon.\n'
                    'Weather data by Open-Meteo.com (CC BY 4.0).\n'
                    'Map data © OpenStreetMap contributors (ODbL).\n'
                    'Inter font © The Inter Project Authors (SIL OFL 1.1).',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption,
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
