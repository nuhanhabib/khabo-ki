# Setup guide

Follow these steps on a new Windows PC. It takes about 45 minutes, mostly downloads.

## 1. Install the tools

| Tool | Version | Get it |
|---|---|---|
| Git | any recent | https://git-scm.com |
| Flutter SDK | **3.47.9** (stable) | https://docs.flutter.dev/get-started/install/windows. Extract to `C:\dev\flutter` |
| Android Studio | latest | https://developer.android.com/studio. Includes the Android SDK, emulator and Java 17 |
| VS Code + Flutter extension | optional | https://code.visualstudio.com |
| Node.js | 20+ | Only needed if you work on the Worker (`worker/`) |

Add `C:\dev\flutter\bin` to your PATH, then run:

```bash
flutter doctor --android-licenses
```
```bash
flutter doctor
```

Fix anything marked ✗ under **Flutter** and **Android toolchain**. You can ignore "Visual Studio", which is only needed for Windows desktop apps.

## 2. Clone the repo (not inside OneDrive)

> ⚠️ **Don't put the project in OneDrive, Desktop or Documents if they're synced.** OneDrive locks build files and makes builds fail. Use `C:\dev`.

```bash
cd C:\dev
```
```bash
git clone https://github.com/nuhanhabib/khabo-ki.git KhaboKi
```
```bash
cd KhaboKi
```

**Turn on the secret blocker** (required). It stops you from committing keys or passwords by accident:

```bash
git config core.hooksPath .githooks
```

## 3. Get the app config from Nuhan

The app needs one private file to talk to the AI server. **Nuhan will send you `app_secrets.json` privately.** Save it in the project root (`C:\dev\KhaboKi\app_secrets.json`). It's gitignored, so never commit or share it.

```json
{"APP_KEY": "…"}
```

Without it the app still runs, but scanning shows "not configured".

## 4. Run the app

Start an emulator (Android Studio → Device Manager → ▶), or plug in your phone with USB debugging on. Then:

```bash
flutter pub get
```
```bash
flutter run --dart-define-from-file=app_secrets.json
```

While it's running, press `r` to hot reload and `R` to restart.

**Tip:** if the emulator gets stuck on "offline", start it with software graphics:

```bash
emulator -avd <name> -gpu swiftshader_indirect -no-snapshot-load
```

## 5. Check your work

Run these before every push. CI runs the same checks.

```bash
flutter analyze
```
```bash
flutter test
```

## Worker (optional)

You only need this if you change the AI server in `worker/`:

```bash
cd worker
```
```bash
npm ci
```
```bash
npm test
```
```bash
npm run typecheck
```

Deploying needs access to the Cloudflare account. Ask Nuhan to invite you as a member. **Never ask for the account password.**

## You do NOT need

- The **release keystore** (`.jks`). Releases are built by GitHub Actions. See [CONTRIBUTING.md](../CONTRIBUTING.md#releasing).
- The **Gemini API key**. It lives only inside Cloudflare.
