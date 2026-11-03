import 'package:flutter_test/flutter_test.dart';
import 'package:khabo_ki/app_state.dart';
import 'package:khabo_ki/main.dart';
import 'package:khabo_ki/models/scan_result.dart';

ScanResult _tomato() => ScanResult.fromJson({
      'isFood': true,
      'freshness': 'check_first',
      'safetyScore': 60,
      'en': {
        'detected': ['Tomato'],
        'risks': ['Soft spots'],
        'nutrition': ['Vitamin C'],
        'portion': '1 piece',
        'budgetTip': 'Cheap in winter',
      },
      'bn': {
        'detected': ['টমেটো'],
        'risks': ['নরম দাগ'],
        'nutrition': ['ভিটামিন সি'],
        'portion': '১টি',
        'budgetTip': 'শীতে সস্তা',
      },
    }, scannedAt: DateTime(2026, 11, 3));

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
    final state = AppState()..addScan(_tomato());
    await tester.pumpWidget(KhaboKiApp(state: state));
    expect(find.text('Tomato'), findsOneWidget);
    await tester.tap(find.text('Tomato'));
    await tester.pumpAndSettle();
    expect(find.text('Check before eating'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
  });

  testWidgets('result shows AI text in Bangla', (tester) async {
    final state = AppState()
      ..addScan(_tomato())
      ..toggleLanguage();
    await tester.pumpWidget(KhaboKiApp(state: state));
    expect(find.text('টমেটো'), findsOneWidget);
  });

  test('fromJson clamps score and handles bad input', () {
    final r = ScanResult.fromJson({
      'isFood': 'yes',
      'freshness': 'weird',
      'safetyScore': 300,
      'en': 'not a map',
    });
    expect(r.isFood, isFalse);
    expect(r.freshness, Freshness.unknown);
    expect(r.safetyScore, 100);
    expect(r.en.detected, isEmpty);
  });
}
