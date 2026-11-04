# Architecture

## Big picture

```
┌──────────────┐  HTTPS POST /analyze         ┌────────────────────┐   HTTPS   ┌──────────────┐
│ Flutter app  │  image bytes                 │ Cloudflare Worker  │ ────────▶ │ Google Gemini│
│ (Android)    │  X-App-Key, X-Device-Id ───▶ │ khabo-ki-api       │ ◀──────── │ (vision AI)  │
│              │ ◀── JSON result (en + bn)    │ keeps GEMINI key   │   JSON    └──────────────┘
└──────────────┘                              └────────────────────┘
```

1. The user takes or picks a photo. The app shrinks it (max width 1280, JPEG quality 80, under 2 MB).
2. The app sends the raw image to the **Worker** with two headers:
   - `X-App-Key`: a shared app key, injected at build time (not a strong secret, since it ships in the APK)
   - `X-Device-Id`: a random ID created on first launch and kept in `shared_preferences`
3. The Worker checks the app key, applies **rate limits** (5/min per device, 20/min per IP), and validates the image type and size.
4. The Worker asks **Gemini** for a strict JSON answer (`responseSchema`) with English and Bangla text.
5. The Worker **sanitizes** the AI output (types, lengths, score range) and returns it. **Nothing is stored**: no photos, no logs.
6. The app shows the result and keeps history **in memory only** (it clears when the app closes).

**Why a Worker?** The Gemini API key must never be in the app, since anyone can unpack an APK. The Worker holds it as an encrypted Cloudflare secret.

## Folder map

```
KhaboKi/
├── lib/                      Flutter app (Dart)
│   ├── main.dart             App entry: theme + AppScope + HomeScreen
│   ├── app_state.dart        AppState (language, scan history) + AppScope (InheritedNotifier)
│   ├── l10n.dart             English/Bangla strings: L10n(bangla).t('key')
│   ├── theme.dart            Brand colors (KColors), Material theme, scoreColor()
│   ├── models/scan_result.dart   ScanResult + Freshness enum
│   ├── services/food_analyzer.dart  Calls the Worker; errors → AnalyzeException(code)
│   ├── screens/              home_screen, result_screen, history_screen
│   └── widgets/              score_ring (0–100 ring), scan_tile (history row)
├── test/widget_test.dart     Widget tests (run with `flutter test`)
├── worker/                   Cloudflare Worker (TypeScript)
│   ├── src/index.ts          Routing, auth, rate limits, security headers
│   ├── src/gemini.ts         Prompt + response schema + Gemini call
│   ├── src/validate.ts       Image type sniffing, device ID check, output sanitizing
│   ├── test/worker.test.ts   Vitest tests
│   └── wrangler.toml         Worker config (model name, rate limits; no secrets)
├── android/                  Android project (app ID com.khaboki.app, signing config)
├── .github/workflows/build.yml   CI: analyze + test; tag v* → signed APK release
├── .githooks/pre-commit      Blocks commits containing keys or passwords
├── tools/make_icons.ps1      Regenerates launcher icons from docs/icon-source.png
└── docs/                     Guides, icon source, screenshots
```

## Key conventions

- **State:** a single `AppState` (`ChangeNotifier`) read with `AppScope.of(context)`. There's no state-management package; keep it simple until Firebase arrives.
- **Text:** every user-facing string goes in `l10n.dart` with both `_en` and `_bn` entries. AI text arrives in both languages from the Worker.
- **Colors:** use `KColors` from `theme.dart`, never hard-coded hex values in screens.
- **Config:** build-time values come from `--dart-define-from-file=app_secrets.json` (`APP_KEY`, optional `API_URL`).

## Changing the app icon

1. Replace `docs/icon-source.png` (square PNG, at least 1024 px, art on a rounded green tile)
2. Run this in PowerShell (Windows):

```bash
powershell -ExecutionPolicy Bypass -File tools\make_icons.ps1 -SrcPath docs\icon-source.png -Res android\app\src\main\res -Docs docs
```

This writes the legacy, adaptive (background, foreground, monochrome) and Play Store (`docs/icon-512.png`) icons. If the new tile has different corners, adjust `$inset` in the script.
