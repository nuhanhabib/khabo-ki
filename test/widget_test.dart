import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:khabo_ki/app_state.dart';
import 'package:khabo_ki/main.dart';
import 'package:khabo_ki/models/scan_result.dart';
import 'package:khabo_ki/screens/history_screen.dart';
import 'package:khabo_ki/screens/status_screen.dart';

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

Widget _screen(Widget child, AppState state) => AppScope(
  state: state,
  child: MaterialApp(home: child),
);

void main() {
  testWidgets('splash shows brand, then opens home', (tester) async {
    await tester.pumpWidget(KhaboKiApp(state: AppState()));
    expect(find.text('Khabo Ki?'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.text('Scan Food'), findsOneWidget);
  });

  testWidgets('home shows scan card and empty history', (tester) async {
    await tester.pumpWidget(KhaboKiApp(state: AppState(), showSplash: false));
    expect(find.text('Scan Food'), findsOneWidget);
    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('No scans yet — scan your first food!'), findsOneWidget);
  });

  testWidgets('language toggle switches to Bangla', (tester) async {
    await tester.pumpWidget(KhaboKiApp(state: AppState(), showSplash: false));
    await tester.tap(find.text('বাংলা'));
    await tester.pump();
    expect(find.text('খাবার স্ক্যান করুন'), findsOneWidget);
    expect(find.text('আজ কী খাচ্ছেন?'), findsOneWidget);
  });

  testWidgets('scans appear in recent list and open result', (tester) async {
    final state = AppState()..addScan(_tomato());
    await tester.pumpWidget(KhaboKiApp(state: state, showSplash: false));
    expect(find.text('Tomato'), findsOneWidget);
    expect(find.text('Nov 3, 2026'), findsOneWidget);
    await tester.tap(find.text('Tomato'));
    await tester.pumpAndSettle();
    expect(find.text('Okay'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);
    expect(find.text('Soft spots'), findsOneWidget);
  });

  testWidgets('result shows AI text in Bangla', (tester) async {
    final state = AppState()
      ..addScan(_tomato())
      ..toggleLanguage();
    await tester.pumpWidget(KhaboKiApp(state: state, showSplash: false));
    expect(find.text('টমেটো'), findsOneWidget);
    expect(find.text('৩ নভে ২০২৬'), findsOneWidget);
  });

  testWidgets('history groups by date and filters by search', (tester) async {
    final state = AppState()..addScan(_tomato());
    await tester.pumpWidget(_screen(const HistoryScreen(), state));
    expect(find.text('Nov 3, 2026'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'fish');
    await tester.pump();
    expect(find.text('No scans match your search.'), findsOneWidget);
  });

  testWidgets('error screens show title and retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      _screen(
        StatusScreen(kind: 'noInternet', onRetry: () => retried = true),
        AppState(),
      ),
    );
    expect(find.text('No internet connection'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);

    await tester.pumpWidget(
      _screen(const StatusScreen(kind: 'notFood'), AppState()),
    );
    expect(find.text("That doesn't look like food"), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
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
