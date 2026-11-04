import 'dart:io';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/scan_result.dart';
import '../screens/result_screen.dart';
import '../theme.dart';
import 'brand.dart';

/// One row in the recent-scans / history list.
class ScanTile extends StatelessWidget {
  const ScanTile({super.key, required this.result, this.showFreshness = false});

  final ScanResult result;
  final bool showFreshness;

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final path = result.imagePath;
    final (label, color, icon) = freshnessStyle(result.freshness, state.l10n.t);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => ResultScreen(result: result))),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox.square(
                  dimension: 56,
                  child: path != null && File(path).existsSync()
                      ? Image.file(File(path), fit: BoxFit.cover)
                      : const ColoredBox(
                          color: KColors.mint,
                          child: Icon(
                            Icons.restaurant,
                            color: KColors.greenDark,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title(state.bangla),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (showFreshness)
                      Pill(label, color: color, icon: icon)
                    else
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: KColors.muted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            state.l10n.date(result.scannedAt),
                            style: const TextStyle(
                              color: KColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              ScoreBadge(result.safetyScore),
              if (showFreshness)
                const Icon(Icons.chevron_right, color: KColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
