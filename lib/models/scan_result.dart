enum Freshness { fresh, checkFirst, spoiled, unknown }

/// Same bands as scoreColor() in theme.dart: 75+ fresh, 50–74 check first,
/// below 50 spoiled.
Freshness freshnessForScore(int score) {
  if (score >= 75) return Freshness.fresh;
  if (score >= 50) return Freshness.checkFirst;
  return Freshness.spoiled;
}

/// The text part of a result, in one language.
class ScanText {
  const ScanText({
    required this.detected,
    required this.risks,
    required this.nutrition,
    required this.portion,
    required this.budgetTip,
  });

  final List<String> detected;
  final List<String> risks;
  final List<String> nutrition;
  final String portion;
  final String budgetTip;

  factory ScanText.fromJson(Object? json) {
    final m = json is Map<String, dynamic> ? json : const <String, dynamic>{};
    List<String> list(Object? v) =>
        v is List ? v.whereType<String>().toList() : const [];
    return ScanText(
      detected: list(m['detected']),
      risks: list(m['risks']),
      nutrition: list(m['nutrition']),
      portion: m['portion'] is String ? m['portion'] as String : '',
      budgetTip: m['budgetTip'] is String ? m['budgetTip'] as String : '',
    );
  }
}

class ScanResult {
  const ScanResult({
    required this.isFood,
    required this.freshness,
    required this.safetyScore,
    required this.en,
    required this.bn,
    required this.scannedAt,
    this.imagePath,
  });

  final bool isFood;
  final Freshness freshness;
  final int safetyScore; // 0–100
  final ScanText en;
  final ScanText bn;
  final DateTime scannedAt;
  final String? imagePath; // local only, never uploaded or stored remotely

  /// Bangla text falls back to English if the AI left it empty.
  ScanText text(bool bangla) => bangla && bn.detected.isNotEmpty ? bn : en;

  String title(bool bangla) => text(bangla).detected.join(', ');

  factory ScanResult.fromJson(
    Map<String, dynamic> json, {
    String? imagePath,
    DateTime? scannedAt,
  }) {
    final rawScore = json['safetyScore'];
    final isFood = json['isFood'] == true;
    final score = rawScore is num ? rawScore.round().clamp(0, 100) : 0;
    return ScanResult(
      isFood: isFood,
      // The label follows the score so the badge and the ring never disagree.
      // The AI's own freshness word is only used when it sent no score.
      freshness: isFood && rawScore is num
          ? freshnessForScore(score)
          : switch (json['freshness']) {
              'fresh' => Freshness.fresh,
              'check_first' => Freshness.checkFirst,
              'spoiled' => Freshness.spoiled,
              _ => Freshness.unknown,
            },
      safetyScore: score,
      en: ScanText.fromJson(json['en']),
      bn: ScanText.fromJson(json['bn']),
      scannedAt: scannedAt ?? DateTime.now(),
      imagePath: imagePath,
    );
  }
}
