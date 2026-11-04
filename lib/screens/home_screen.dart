import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app_state.dart';
import '../services/food_analyzer.dart';
import '../theme.dart';
import '../widgets/brand.dart';
import '../widgets/scan_tile.dart';
import 'analyzing_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();
  final _analyzer = FoodAnalyzer();

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
      navigator.push(
        MaterialPageRoute(
          builder: (_) =>
              AnalyzingScreen(imagePath: file.path, analyzer: _analyzer),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(state.l10n.t('error'))));
    }
  }

  void _openHistory() =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const HistoryScreen()));

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = state.l10n;
    final recent = state.history.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: const Row(
          children: [
            Logo(size: 34),
            SizedBox(width: 10),
            Text(
              'Khabo Ki?',
              style: TextStyle(
                color: KColors.deep,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          _LanguageToggle(bangla: state.bangla, onTap: state.toggleLanguage),
          IconButton(
            tooltip: l.t('history'),
            icon: const Icon(Icons.history, color: KColors.greenDark),
            onPressed: _openHistory,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            l.t('greeting'),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: KColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l.t('tagline'),
            style: const TextStyle(color: KColors.greenDark, fontSize: 14),
          ),
          const SizedBox(height: 18),
          _HeroScanCard(
            label: l.t('scan'),
            onTap: () => _scan(ImageSource.camera),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SourceTile(
                  icon: Icons.photo_camera_outlined,
                  label: l.t('camera'),
                  onTap: () => _scan(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SourceTile(
                  icon: Icons.photo_library_outlined,
                  label: l.t('gallery'),
                  onTap: () => _scan(ImageSource.gallery),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.t('recent'),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: KColors.ink,
                  ),
                ),
              ),
              if (recent.isNotEmpty)
                TextButton.icon(
                  onPressed: _openHistory,
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(l.t('seeAll')),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (recent.isEmpty)
            Column(
              children: [
                const SizedBox(height: 8),
                const Illustration(icon: Icons.fact_check_outlined),
                const SizedBox(height: 12),
                Text(
                  l.t('noScans'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: KColors.ink),
                ),
              ],
            )
          else
            for (final r in recent)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ScanTile(result: r),
              ),
        ],
      ),
    );
  }
}

class _LanguageToggle extends StatelessWidget {
  const _LanguageToggle({required this.bangla, required this.onTap});

  final bool bangla;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    Widget seg(String text, bool active) => AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: active ? KColors.greenDark : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: active ? Colors.white : KColors.greenDark,
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
      ),
    );
    return Semantics(
      button: true,
      label: 'Language',
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: KColors.mint,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: KColors.greenLight.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [seg('বাংলা', bangla), seg('EN', !bangla)],
          ),
        ),
      ),
    );
  }
}

class _HeroScanCard extends StatelessWidget {
  const _HeroScanCard({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(gradient: kBrandGradient),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 210,
            child: Stack(
              children: [
                // Food art along the bottom edge.
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: -6,
                  child: Text(
                    '🥬🍅🐟🥕🌶️🥦',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 40, letterSpacing: 2),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.35),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.center_focus_strong,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: KColors.mint,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: KColors.greenDark, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: KColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
