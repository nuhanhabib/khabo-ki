import 'dart:io';

import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/scan_result.dart';
import '../screens/result_screen.dart';
import '../theme.dart';

/// One row in the recent-scans / history list.
class ScanTile extends StatelessWidget {
  const ScanTile({super.key, required this.result});

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    final path = result.imagePath;
    final t = result.scannedAt;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox.square(
            dimension: 48,
            child: path != null && File(path).existsSync()
                ? Image.file(File(path), fit: BoxFit.cover)
                : const ColoredBox(
                    color: KColors.cream,
                    child: Icon(Icons.restaurant, color: KColors.olive),
                  ),
          ),
        ),
        title: Text(
          result.title(AppScope.of(context).bangla),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${t.day}/${t.month}/${t.year}  '
          '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
        ),
        trailing: CircleAvatar(
          backgroundColor: scoreColor(result.safetyScore),
          foregroundColor: Colors.white,
          child: Text(
            '${result.safetyScore}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
        ),
      ),
    );
  }
}
