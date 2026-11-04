import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';
import '../widgets/brand.dart';

/// Friendly full-screen error state: notFood, noInternet, rateLimited, failed, …
class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key, required this.kind, this.onRetry});

  final String kind;

  /// Retries the same photo. When null, the button goes back to Home.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppScope.of(context).l10n;
    final (icon, badge, badgeColor) = switch (kind) {
      'noInternet' => (Icons.wifi_off_rounded, null, KColors.tomato),
      'rateLimited' => (
        Icons.fact_check_outlined,
        Icons.schedule,
        KColors.amber,
      ),
      'notFood' => (Icons.image_outlined, Icons.close, KColors.tomato),
      _ => (Icons.cloud_off_outlined, Icons.priority_high, KColors.amber),
    };
    final hasTitle = l.t('${kind}Title') != '${kind}Title';
    final canRetry = onRetry != null && kind != 'notFood';

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              const Spacer(),
              Illustration(icon: icon, badge: badge, badgeColor: badgeColor),
              const SizedBox(height: 24),
              Text(
                hasTitle ? l.t('${kind}Title') : l.t('failedTitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: KColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l.t(kind),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: KColors.muted,
                  height: 1.4,
                ),
              ),
              const Spacer(flex: 2),
              FilledButton.icon(
                onPressed: canRetry
                    ? onRetry
                    : () => Navigator.of(context).pop(),
                icon: Icon(
                  canRetry ? Icons.refresh : Icons.photo_camera_outlined,
                ),
                label: Text(canRetry ? l.t('retry') : l.t('tryAgain')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
