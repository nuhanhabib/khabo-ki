import 'package:flutter_test/flutter_test.dart';
import 'package:khabo_ki/app_state.dart';
import 'package:khabo_ki/main.dart';
import 'package:khabo_ki/models/scan_result.dart';

void main() {
  testWidgets('home shows scan button and empty history', (tester) async {
    await tester.pumpWidget(KhaboKiApp(state: AppState()));
    expect(find.text('Scan Food'), findsOneWidget);
    expect(find.text('No scans yet. Scan your first food!'), findsOneWidget);
  });

  testWidgets('language toggle switches to Bangla', (tester) async {
    await tester.pumpWidget(KhaboKiApp(state: AppState()));
    await tester.tap(find.text('বাংলা'));
    await tester.pump();
    expect(find.text('খাবার স্ক্যান করুন'), findsOneWidget);
  });

  testWidgets('scans appear in recent list and open result', (tester) async {
    final state = AppState()
      ..addScan(ScanResult(
        detected: const ['Tomato'],
        freshness: Freshness.checkFirst,
        safetyScore: 60,
        risks: const ['Soft spots'],
        nutrition: const ['Vitamin C'],
        portion: '1 piece',
        budgetTip: 'Cheap in winter',
        scannedAt: DateTime(2026, 11, 3),
      ));
    await tester.pumpWidget(KhaboKiApp(state: state));
    expect(find.text('Tomato'), findsOneWidget);
    await tester.tap(find.text('Tomato'));
    await tester.pumpAndSettle();
    expect(find.text('Check before eating'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
  });
}
