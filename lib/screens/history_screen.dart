import 'package:flutter/material.dart';

import '../app_state.dart';
import '../widgets/scan_tile.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final l = state.l10n;
    final history = state.history;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('history')),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              tooltip: l.t('clear'),
              icon: const Icon(Icons.delete_outline),
              onPressed: state.clearHistory,
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(child: Text(l.t('noScans')))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => ScanTile(result: history[i]),
            ),
    );
  }
}
