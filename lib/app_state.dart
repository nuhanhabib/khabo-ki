import 'package:flutter/widgets.dart';

import 'l10n.dart';
import 'models/scan_result.dart';

/// App-wide state: language and scan history (in memory for now; Firestore later).
class AppState extends ChangeNotifier {
  bool _bangla = false;
  final List<ScanResult> _history = [];

  bool get bangla => _bangla;
  L10n get l10n => L10n(_bangla);
  List<ScanResult> get history => List.unmodifiable(_history);

  void toggleLanguage() {
    _bangla = !_bangla;
    notifyListeners();
  }

  void addScan(ScanResult result) {
    _history.insert(0, result);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
