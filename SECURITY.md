# Security

This is a public repository. Rules every contributor must follow:

- **No secrets in Git.** API keys live only in the Cloudflare Worker's secrets (`wrangler secret put`), never in the app or the repo.
- **Signing keystore** (`*.jks`) and `android/key.properties` stay local and are backed up privately.
- **Firebase config** (`google-services.json`, `firebase_options.dart`) is gitignored; each developer downloads their own.
- **Users access only their own data** — enforced by Firestore security rules.
- **Release builds** only: no debug mode, obfuscated (`--obfuscate --split-debug-info`).
- **Rate limiting and CORS** are enforced in the AI proxy Worker.

Enable the secret-scanning hook after cloning:

```bash
git config core.hooksPath .githooks
```

## Reporting a vulnerability

Please open a private security advisory on GitHub instead of a public issue.
