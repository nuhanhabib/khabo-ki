import 'package:flutter/material.dart';

import '../theme.dart';

/// Circular 0–100 safety score indicator.
class ScoreRing extends StatelessWidget {
  const ScoreRing({super.key, required this.score, this.size = 104});

  final int score;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = scoreColor(score);
    return SizedBox.square(
      dimension: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: score / 100,
            strokeWidth: size / 9,
            strokeCap: StrokeCap.round,
            color: color,
            backgroundColor: color.withValues(alpha: 0.15),
          ),
          Center(
            child: Text(
              '$score',
              style: TextStyle(
                fontSize: size / 3,
                fontWeight: FontWeight.w800,
                color: KColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
