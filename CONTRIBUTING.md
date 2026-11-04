# Contributing

## Workflow

`main` is protected: **all changes go through a pull request**, and CI (analyze + tests) must pass.

1. Update `main`, then create a branch:
   ```bash
   git switch main
   ```
   ```bash
   git pull
   ```
   ```bash
   git switch -c feature/short-name
   ```
2. Make your change. Run `flutter analyze` and `flutter test`, plus `npm test` in `worker/` if you touched the Worker.
3. Commit in small steps with clear messages (for example `Add Bangla text for history screen`).
4. Push and open a PR:
   ```bash
   git push -u origin feature/short-name
   ```
   ```bash
   gh pr create --fill
   ```
5. The other person reviews it. Merge once CI is green.

Branch names: `feature/…`, `fix/…`, `docs/…`.

## Code style

- Follow `flutter analyze` with zero warnings. Format with `dart format .`
- Add every new user-facing string to **both** English and Bangla in `lib/l10n.dart`
- Use `KColors` and the theme instead of raw colors
- Add or update a test in `test/` for new behavior
- Don't add a package unless it's really needed, and remove any you stop using

## Security checklist (every PR)

- [ ] No keys, passwords, tokens or `app_secrets.json` in the diff (the pre-commit hook helps, but check yourself)
- [ ] User input and AI output are validated before use
- [ ] No debug-only code or `print()` with personal data
- [ ] New dependencies are well known and up to date

See [SECURITY.md](SECURITY.md) for the full rules.

## Releasing

Only maintainers release. GitHub Actions builds and signs the APK, so **nobody needs the keystore file**.

1. Make sure `main` is green, and bump `version:` in `pubspec.yaml` (for example `0.1.1+3`)
2. Tag and push:
   ```bash
   git tag -a v0.1.1 -m "Short summary"
   ```
   ```bash
   git push origin v0.1.1
   ```
3. After about 6 minutes, **Releases** shows `KhaboKi-v0.1.1.apk`. Install it over the old version to test.

Repo secrets used by CI (managed by Nuhan): `KHABOKI_KEYSTORE_B64`, `KHABOKI_KEYSTORE_PASSWORD`, `KHABOKI_KEY_ALIAS`, `KHABOKI_KEY_PASSWORD`, `KHABOKI_APP_KEY`.
