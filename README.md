# Rishta Ads

Android app for short matrimonial classified ads. **Powered by Biah.pk.**
Native Flutter app (no WebView) that uses the existing Biah.pk PHP API.

## Features
- **Browse** – ads from the API, filters (city, gender, min/max age, marital
  status), pagination, pull-to-refresh, hidden phone numbers with *Show Number*.
- **Post Ad** – native form, no account needed, consent checkbox, ads are
  reviewed before publication.
- **More** – About, How It Works, Safety, Privacy and Terms (all inside the
  app), Contact Us, Share App, Visit Biah.pk, app version.

## Versions
- Flutter 3.27.4 (stable), pinned in `.github/workflows/android-build.yml`
- Packages: `http ^1.2.2`, `url_launcher ^6.3.1`, `share_plus ^10.1.4`,
  `package_info_plus ^8.1.2`, `flutter_secure_storage ^9.2.2`
- Android 6.0 (API 23) or newer

## Project structure
```
lib/
  main.dart
  app/            app.dart, theme.dart, main_shell.dart (3 tabs), dependencies.dart
  models/         ad_model, ad_filters, api_response_model
  services/       api_service (HTTP + cookies), cookie_store (encrypted), city_service
  screens/        splash, browse, post_ad, more, static_pages
  widgets/        header, loading, error, empty state
  utils/          constants, validators, external_links
server/cities.php   backend file to upload (see docs/API.md)
tools/generate_icons.py   builds launcher icons during the CI build
docs/API.md       API reference
test/             unit tests
.github/workflows/android-build.yml
```
The `android/` folder is **generated in CI** by `flutter create`, so it is not
stored in the repository. Keep it that way unless you need custom native code.

## Backend
Endpoints: `ads.php`, `submit.php`, `reveal-phone.php` (existing, unchanged) and
`cities.php` (new, read-only). See `docs/API.md`. Upload `server/cities.php`
to `/ads/api/v1/` – without it the city filter shows an error.

## Build an APK (no local Flutter needed)
1. Push/upload this repository to GitHub.
2. Open **Actions → Android Build → Run workflow** (also runs on push to `main`).
3. When finished, open the run and download the artifact **rishta-ads-android**.
4. Unzip it and install `app-debug.apk` on your phone (allow installs from
   your browser/file manager when Android asks).

The workflow generates the Android project, sets the app name and permissions,
generates the launcher icon, then runs `flutter analyze`, `flutter test` and
`flutter build apk --debug`.

## Signed release APK (later)
Do **not** commit keys or passwords.
1. Create a keystore once: `keytool -genkey -v -keystore upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Keep `upload.jks` safe; add it (base64) and its passwords as GitHub
   **Secrets** (Settings → Secrets and variables → Actions).
3. Extend the workflow to restore the keystore, write `android/key.properties`,
   patch `android/app/build.gradle` with a `signingConfigs` block, and run
   `flutter build apk --release` (or `appbundle` for Google Play).
Because `android/` is generated in CI, step 3 must be done by a workflow step.

## Developer notes
- **Session cookie:** PHP limits (30 s submit cooldown, 15 reveals per 5 min)
  rely on sessions. `SessionCookieStore` keeps the cookie in encrypted storage,
  restores it on start, and makes concurrent first requests share one session.
  The server deletes idle sessions after its own timeout.
- **Cities:** never hard-coded. Browse uses `cities.php`; Post Ad accepts any
  typed city and only uses the list for suggestions.
- **Share App:** shares `AppConstants.appShareUrl` (currently https://biah.pk).
  Replace it when an official store link exists.
- **Content:** edit the info pages in `lib/screens/static_pages/`.
- **Ad duration:** `submit.php` sets `expires_at` 7 days after submission.
- Tests: `flutter test` (models, validators, cookie store, API service).
