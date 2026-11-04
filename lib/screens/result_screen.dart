import 'dart:io';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/scan_result.dart';
import '../theme.dart';
import '../widgets/brand.dart';
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
    final (freshLabel, freshColor, freshIcon) = freshnessStyle(
      result.freshness,
      l.t,
    );
    final freshDesc = switch (result.freshness) {
      Freshness.fresh => l.t('freshDesc'),
      Freshness.spoiled => l.t('spoiledDesc'),
      _ => l.t('okayDesc'),
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.t('result'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (path != null && File(path).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(File(path), height: 200, fit: BoxFit.cover),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              ScoreRing(score: result.safetyScore),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Pill(
                      freshLabel,
                      color: freshColor,
                      icon: freshIcon,
                      big: true,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      freshDesc,
                      style: const TextStyle(
                        fontSize: 15,
                        color: KColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _InfoCard(
            icon: Icons.format_list_bulleted,
            title: l.t('detected'),
            child: _Chips(text.detected),
          ),
          _InfoCard(
            icon: Icons.warning_amber_rounded,
            title: l.t('risks'),
            color: KColors.tomato,
            background: KColors.blush,
            child: _Lines(text.risks.isEmpty ? [l.t('noRisks')] : text.risks),
          ),
          _InfoCard(
            icon: Icons.favorite_border,
            title: l.t('nutrition'),
            note: l.t('perServing'),
            child: _Chips(text.nutrition),
          ),
          if (text.portion.isNotEmpty)
            _InfoCard(
              icon: Icons.rice_bowl_outlined,
              title: l.t('portion'),
              child: _Lines([text.portion]),
            ),
          if (text.budgetTip.isNotEmpty)
            _InfoCard(
              icon: Icons.savings_outlined,
              title: l.t('budget'),
              background: KColors.mint,
              child: _Lines([text.budgetTip]),
            ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 16, color: KColors.muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l.t('disclaimer'),
                  style: const TextStyle(fontSize: 12, color: KColors.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
    this.note,
    this.color = KColors.greenDark,
    this.background = Colors.white,
  });

  final IconData icon;
  final String title;
  final String? note;
  final Widget child;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: background,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: KColors.ink,
                        ),
                        children: [
                          if (note != null)
                            TextSpan(
                              text: '  $note',
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                color: KColors.muted,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    child,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips(this.items);

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [for (final i in items) Pill(i)],
    );
  }
}

class _Lines extends StatelessWidget {
  const _Lines(this.lines);

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final line in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line,
              style: const TextStyle(
                fontSize: 15,
                color: KColors.ink,
                height: 1.35,
              ),
            ),
          ),
      ],
    );
  }
}
