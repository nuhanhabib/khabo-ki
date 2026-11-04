import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/scan_result.dart';
import '../theme.dart';
import '../widgets/brand.dart';
import '../widgets/scan_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = state.l10n;
    final q = _query.trim().toLowerCase();
    final items = state.history
        .where(
          (r) => q.isEmpty || r.title(state.bangla).toLowerCase().contains(q),
        )
        .toList();

    // Group by calendar day, newest first (history is already newest first).
    final groups = <String, List<ScanResult>>{};
    for (final r in items) {
      groups.putIfAbsent(l.date(r.scannedAt), () => []).add(r);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('history')),
        actions: [
          if (state.history.isNotEmpty)
            TextButton.icon(
              onPressed: state.clearHistory,
              icon: const Icon(Icons.delete_outline, size: 20),
              label: Text(l.t('clear')),
            ),
        ],
      ),
      body: state.history.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Illustration(icon: Icons.history),
                    const SizedBox(height: 16),
                    Text(
                      l.t('noScans'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: l.t('search'),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: KColors.greenDark,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(l.t('noMatch'), textAlign: TextAlign.center),
                  ),
                for (final entry in groups.entries) ...[
                  Container(
                    margin: const EdgeInsets.only(top: 4, bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: KColors.mint,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      entry.key,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  for (final r in entry.value)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ScanTile(result: r, showFreshness: true),
                    ),
                ],
              ],
            ),
    );
  }
}
