enum Freshness { fresh, checkFirst, spoiled }

class ScanResult {
  const ScanResult({
    required this.detected,
    required this.freshness,
    required this.safetyScore,
    required this.risks,
    required this.nutrition,
    required this.portion,
    required this.budgetTip,
    required this.scannedAt,
    this.imagePath,
  });

  final List<String> detected;
  final Freshness freshness;
  final int safetyScore; // 0–100
  final List<String> risks;
  final List<String> nutrition;
  final String portion;
  final String budgetTip;
  final DateTime scannedAt;
  final String? imagePath; // local only, never uploaded or stored remotely

  String get title => detected.join(', ');
}
