import 'package:flutter/material.dart';

import 'app_state.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

void main() {
  runApp(KhaboKiApp(state: AppState()));
}

class KhaboKiApp extends StatelessWidget {
  const KhaboKiApp({super.key, required this.state, this.showSplash = true});

  final AppState state;
  final bool showSplash;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Khabo Ki?',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: showSplash ? const SplashScreen() : const HomeScreen(),
      ),
    );
  }
}
