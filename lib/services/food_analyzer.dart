import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/scan_result.dart';

/// Error codes map to l10n keys shown to the user.
class AnalyzeException implements Exception {
  const AnalyzeException(this.code);
  final String code; // noInternet | rateLimited | tooLarge | notConfigured | failed
}

/// Sends a food photo to the Khabo Ki? Worker, which calls the AI.
/// The app key is injected at build time (--dart-define-from-file=app_secrets.json)
/// and is never stored in source control.
class FoodAnalyzer {
  FoodAnalyzer({http.Client? client}) : _client = client ?? http.Client();

  static const _apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://khabo-ki-api.khaboki.workers.dev',
  );
  static const _appKey = String.fromEnvironment('APP_KEY');
  static const _maxBytes = 2 * 1024 * 1024;
  static const _deviceIdKey = 'device_id';

  final http.Client _client;

  Future<ScanResult> analyze(String imagePath) async {
    if (_appKey.isEmpty) throw const AnalyzeException('notConfigured');
    final bytes = await File(imagePath).readAsBytes();
    if (bytes.length > _maxBytes) throw const AnalyzeException('tooLarge');
    final deviceId = await _deviceId();

    // One retry for brief upstream hiccups; never for client errors.
    for (var attempt = 0; ; attempt++) {
      final http.Response res;
      try {
        res = await _client
            .post(
              Uri.parse('$_apiUrl/analyze'),
              headers: {
                'Content-Type': 'image/jpeg',
                'X-App-Key': _appKey,
                'X-Device-Id': deviceId,
              },
              body: bytes,
            )
            .timeout(const Duration(seconds: 45));
      } on SocketException {
        throw const AnalyzeException('noInternet');
      } on TimeoutException {
        if (attempt == 0) continue;
        throw const AnalyzeException('failed');
      } on http.ClientException {
        throw const AnalyzeException('noInternet');
      }

      switch (res.statusCode) {
        case 200:
          final json = jsonDecode(utf8.decode(res.bodyBytes));
          if (json is! Map<String, dynamic>) {
            throw const AnalyzeException('failed');
          }
          return ScanResult.fromJson(json, imagePath: imagePath);
        case 429:
          throw const AnalyzeException('rateLimited');
        case 413:
          throw const AnalyzeException('tooLarge');
        case 502 || 503 when attempt == 0:
          continue;
        default:
          throw const AnalyzeException('failed');
      }
    }
  }

  /// A random per-install ID used only for rate limiting.
  Future<String> _deviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null) return existing;
    final id = _uuidV4();
    await prefs.setString(_deviceIdKey, id);
    return id;
  }

  static String _uuidV4() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    final h = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }
}
