import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_state.dart';
import '../services/food_analyzer.dart';
import '../theme.dart';
import '../widgets/scan_tile.dart';
import 'history_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();
  final _analyzer = FoodAnalyzer();
  bool _busy = false;

  Future<void> _scan(ImageSource source) async {
    final state = AppScope.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      // Downscale before analysis: smaller uploads, no full-size photos kept.
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 80,
      );
      if (file == null) return;
      setState(() => _busy = true);
      final result = await _analyzer.analyze(file.path);
      state.addScan(result);
      navigator.push(
        MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(state.l10n.t('error'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _chooseSource() {
    final l = AppScope.of(context).l10n;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l.t('camera')),
              onTap: () {
                Navigator.pop(sheet);
                _scan(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l.t('gallery')),
              onTap: () {
                Navigator.pop(sheet);
                _scan(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = state.l10n;
    final recent = state.history.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('KHABO KI?'),
        actions: [
          TextButton(
            onPressed: state.toggleLanguage,
            child: Text(state.bangla ? 'EN' : 'বাংলা'),
          ),
          IconButton(
            tooltip: l.t('history'),
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l.t('tagline'),
            style: const TextStyle(fontSize: 16, color: KColors.olive),
          ),
          const SizedBox(height: 4),
          const Text(
            'Eat like a Boss, not like a Victim',
            style: TextStyle(fontWeight: FontWeight.w700, color: KColors.olive),
          ),
          const SizedBox(height: 24),
          _ScanButton(
            busy: _busy,
            label: _busy ? l.t('analyzing') : l.t('scan'),
            onTap: _busy ? null : _chooseSource,
          ),
          const SizedBox(height: 28),
          Text(
            l.t('recent'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l.t('noScans'),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
              ),
            )
          else
            for (final r in recent)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ScanTile(result: r),
              ),
        ],
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.busy, required this.label, this.onTap});

  final bool busy;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KColors.olive,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              busy
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(
                      Icons.center_focus_strong,
                      size: 72,
                      color: Colors.white,
                    ),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
