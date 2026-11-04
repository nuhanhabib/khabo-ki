# Roadmap

## ✅ Done (v0.1.0)

- Flutter Android app: home, camera/gallery scan, result card, history
- English / Bangla toggle
- Live AI analysis through a secure Cloudflare Worker (Gemini), with rate limits and validation
- New app icon (adaptive + themed)
- Signed APK releases from GitHub Actions on `v*` tags
- Privacy policy, security rules, secret-blocking pre-commit hook

## 🔜 Next

1. **Save the language choice and history on the phone** (`shared_preferences` or local storage). History currently clears when the app closes.
2. **Firebase (free Spark plan):** Google sign-in plus scan history in Firestore, with rules so each user sees only their own data. Photos stay on the phone.
3. **Bangladeshi food data:** common local foods with nutrition and typical BDT prices, to improve budget tips.
4. **Better spoilage guidance:** food-specific checklists (fish eyes and gills, meat smell and color, signs of formalin in fruit) shown with the result.
5. **Error and offline UX:** clearer messages, and retry when there's no internet.

## 🏁 Later

- **Google Play Store:** $25 developer account, AAB build, store listing, closed test with **12 testers for 14 days**, then production
- Portion estimation from a reference object
- Optional partnerships for real test kits (for example formalin strips) that the app reads with the camera
