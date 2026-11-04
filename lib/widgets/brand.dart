import 'package:flutter/material.dart';

import '../models/scan_result.dart';
import '../theme.dart';

/// The app logo tile.
class Logo extends StatelessWidget {
  const Logo({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: Image.asset('assets/images/logo.png', width: size, height: size),
    );
  }
}

/// Label, colour and icon for a freshness value.
(String, Color, IconData) freshnessStyle(
  Freshness f,
  String Function(String) t,
) {
  return switch (f) {
    Freshness.fresh => (t('fresh'), KColors.fresh, Icons.eco),
    Freshness.checkFirst => (
      t('okay'),
      KColors.amber,
      Icons.warning_amber_rounded,
    ),
    Freshness.spoiled => (
      t('spoiled'),
      KColors.tomato,
      Icons.dangerous_outlined,
    ),
    Freshness.unknown => (t('okay'), KColors.amber, Icons.help_outline),
  };
}

/// Small rounded pill, e.g. "Fresh" or "High protein".
class Pill extends StatelessWidget {
  const Pill(
    this.label, {
    super.key,
    this.color = KColors.greenDark,
    this.icon,
    this.big = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: big ? 14 : 10,
        vertical: big ? 7 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: big ? 18 : 14, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: big ? 16 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Round coloured score badge used in lists.
class ScoreBadge extends StatelessWidget {
  const ScoreBadge(this.score, {super.key});

  final int score;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: scoreColor(score),
      foregroundColor: Colors.white,
      child: Text(
        '$score',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// Friendly illustration: a big icon in a soft circle with leaves and sparks.
class Illustration extends StatelessWidget {
  const Illustration({
    super.key,
    required this.icon,
    this.badge,
    this.badgeColor = KColors.tomato,
  });

  final IconData icon;
  final IconData? badge;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 170,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              color: KColors.mint,
              shape: BoxShape.circle,
            ),
          ),
          const Positioned(
            left: 8,
            bottom: 10,
            child: Icon(Icons.eco, size: 44, color: KColors.lime),
          ),
          const Positioned(
            right: 10,
            bottom: 6,
            child: Icon(Icons.spa, size: 40, color: KColors.greenLight),
          ),
          const Positioned(
            right: 30,
            top: 4,
            child: Icon(Icons.auto_awesome, size: 26, color: KColors.amber),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: KColors.greenDark, width: 3),
            ),
            child: Icon(icon, size: 54, color: KColors.greenDark),
          ),
          if (badge != null)
            Positioned(
              right: 44,
              bottom: 26,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: badgeColor,
                child: Icon(badge, color: Colors.white, size: 24),
              ),
            ),
        ],
      ),
    );
  }
}
