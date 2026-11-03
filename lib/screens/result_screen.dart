import 'dart:io';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/scan_result.dart';
import '../theme.dart';
import '../widgets/score_ring.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = state.l10n;
    final text = result.text(state.bangla);
    final path = result.imagePath;
    final (freshLabel, freshColor, freshIcon) = switch (result.freshness) {
      Freshness.fresh => (l.t('fresh'), KColors.leaf, Icons.eco),
      Freshness.checkFirst =>
        (l.t('checkFirst'), KColors.amber, Icons.warning_amber),
      Freshness.spoiled => (l.t('spoiled'), KColors.tomato, Icons.dangerous),
      Freshness.unknown =>
        (l.t('checkFirst'), KColors.amber, Icons.help_outline),
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.t('result'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (path != null && File(path).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(path), height: 220, fit: BoxFit.cover),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ScoreRing(score: result.safetyScore),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.t('safety'),
                            style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text(
                          text.detected.join(', '),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          avatar: Icon(freshIcon, color: freshColor, size: 18),
                          label: Text(freshLabel),
                          side: BorderSide(color: freshColor),
                          backgroundColor: freshColor.withValues(alpha: 0.1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Section(
            icon: Icons.search,
            title: l.t('detected'),
            lines: text.detected,
          ),
          _Section(
            icon: Icons.health_and_safety_outlined,
            title: l.t('risks'),
            lines: text.risks,
            color: KColors.tomato,
          ),
          _Section(
            icon: Icons.spa_outlined,
            title: l.t('nutrition'),
            lines: text.nutrition,
          ),
          _Section(
            icon: Icons.scale_outlined,
            title: l.t('portion'),
            lines: [text.portion],
          ),
          _Section(
            icon: Icons.savings_outlined,
            title: l.t('budget'),
            lines: [text.budgetTip],
          ),
          const SizedBox(height: 8),
          Text(
            l.t('disclaimer'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.lines,
    this.color = KColors.olive,
  });

  final IconData icon;
  final String title;
  final List<String> lines;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final line in lines)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('•  $line'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
