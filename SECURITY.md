# Security

This is a **public** repository. Everyone who contributes must follow these rules.

## Secrets

| Secret | Lives only in | Who has it |
|---|---|---|
| Gemini API key | Cloudflare Worker secret `GEMINI_API_KEY` | Nobody needs a copy |
| App key | Worker secret `APP_KEY`, GitHub secret `KHABOKI_APP_KEY`, local `app_secrets.json` | Developers, shared privately |
| Release keystore + passwords | Owner's private backup + GitHub secrets | Owner only |

- **Never commit** `app_secrets.json`, `android/key.properties`, `*.jks`, `.env`, `.dev.vars`, `google-services.json`. All of these are gitignored.
- Turn on the secret-blocking hook after cloning: `git config core.hooksPath .githooks`
- Share secrets only through a private channel, never in GitHub issues, PRs or group chats.
- If a secret leaks, **rotate it immediately** (create a new one and delete the old one). Removing it from Git doesn't help, because Git history keeps it.

## Rules the code must keep

- **Hide API keys:** AI calls go through the Worker only. The app never talks to Gemini directly.
- **Authentication:** the Worker checks `X-App-Key` with a constant-time comparison.
- **Rate limiting:** per device and per IP (see `worker/wrangler.toml`).
- **Validation:** image type sniffed from bytes, max 2 MB, AI output sanitized (`worker/src/validate.ts`).
- **CORS / headers:** no CORS for browsers; strict security headers on every response.
- **No storage:** photos and results aren't stored on the server, and Worker logs are off.
- **Release builds:** obfuscated, minified, signed with the release key. Debug builds are never published.
- **Dependencies:** keep them updated, remove unused ones, and pin GitHub Actions to commit SHAs.
- **Future Firebase:** Firestore rules must restrict each user to their own data.

## Reporting a vulnerability

Please open a **private security advisory** on GitHub (Security → Report a vulnerability) instead of a public issue.
