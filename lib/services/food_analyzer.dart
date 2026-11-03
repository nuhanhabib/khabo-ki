import '../models/scan_result.dart';

/// Analyzes a food photo. This is a placeholder that returns sample data;
/// it will be replaced by a call to the Cloudflare Worker AI proxy.
class FoodAnalyzer {
  Future<ScanResult> analyze(String imagePath) async {
    await Future.delayed(const Duration(seconds: 2));
    return ScanResult(
      detected: const ['Rui fish', 'Tomato', 'Red bell pepper'],
      freshness: Freshness.fresh,
      safetyScore: 88,
      risks: const [
        'Fish eyes look clear and gills red — signs of freshness',
        'Keep fish refrigerated; cook within 1 day',
        'Wash vegetables in clean water before eating',
      ],
      nutrition: const [
        'High protein (fish)',
        'Rich in vitamin A & C (pepper, tomato)',
        'Good source of fibre',
      ],
      portion: 'About 2 servings (~350 g)',
      budgetTip:
          'Rui gives good protein per ৳100. Seasonal tomatoes are cheapest in winter.',
      scannedAt: DateTime.now(),
      imagePath: imagePath,
    );
  }
}
