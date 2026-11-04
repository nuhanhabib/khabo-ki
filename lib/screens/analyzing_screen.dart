import 'dart:io';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../services/food_analyzer.dart';
import '../theme.dart';
import 'result_screen.dart';
import 'status_screen.dart';

/// Shows the photo with an animated scan frame while the AI analyzes it,
/// then replaces itself with the result or an error screen.
class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({
    super.key,
    required this.imagePath,
    required this.analyzer,
  });

  final String imagePath;
  final FoodAnalyzer analyzer;

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late final _line = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final state = AppScope.of(context);
    final navigator = Navigator.of(context);
    Widget next;
    try {
      final result = await widget.analyzer.analyze(widget.imagePath);
      if (result.isFood) {
        state.addScan(result);
        next = ResultScreen(result: result);
      } else {
        next = const StatusScreen(kind: 'notFood');
      }
    } on AnalyzeException catch (e) {
      next = StatusScreen(
        kind: e.code,
        onRetry: () => navigator.pushReplacement(
          MaterialPageRoute(
            builder: (_) => AnalyzingScreen(
              imagePath: widget.imagePath,
              analyzer: widget.analyzer,
            ),
          ),
        ),
      );
    } catch (_) {
      next = const StatusScreen(kind: 'failed');
    }
    if (!mounted) return;
    navigator.pushReplacement(MaterialPageRoute(builder: (_) => next));
  }

  @override
  void dispose() {
    _line.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppScope.of(context).l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.t('scan')), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(widget.imagePath), fit: BoxFit.cover),
                    const Padding(
                      padding: EdgeInsets.all(28),
                      child: CustomPaint(painter: _CornersPainter()),
                    ),
                    AnimatedBuilder(
                      animation: _line,
                      builder: (_, _) => Align(
                        alignment: Alignment(0, _line.value * 1.4 - 0.7),
                        child: Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 28),
                          decoration: BoxDecoration(
                            color: KColors.lime,
                            boxShadow: [
                              BoxShadow(
                                color: KColors.lime.withValues(alpha: 0.8),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        color: KColors.green,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l.t('analyzing'),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.t('analyzingSub'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: KColors.muted),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bright green camera-focus corners.
class _CornersPainter extends CustomPainter {
  const _CornersPainter();

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = KColors.lime
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    const len = 36.0;
    for (final (x, y, dx, dy) in [
      (0.0, 0.0, 1.0, 1.0),
      (s.width, 0.0, -1.0, 1.0),
      (0.0, s.height, 1.0, -1.0),
      (s.width, s.height, -1.0, -1.0),
    ]) {
      canvas.drawLine(Offset(x, y), Offset(x + dx * len, y), p);
      canvas.drawLine(Offset(x, y), Offset(x, y + dy * len), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
