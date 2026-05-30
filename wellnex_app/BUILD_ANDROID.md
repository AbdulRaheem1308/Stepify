Local Android build & install

Prerequisites
- Flutter SDK installed and on PATH
- Android SDK + platform tools (adb)
- JDK 17+

Quick commands (from `wellnex_app/`):

```bash
flutter clean
flutter pub get
# build a single universal release APK
flutter build apk --release
# or split per-ABI to reduce download size
flutter build apk --target-platform android-arm,android-arm64 --split-per-abi
# build an app bundle (AAB) for Play Store
flutter build appbundle --release

# install to connected device
adb install -r build/app/outputs/flutter-apk/app-release.apk
# for split apks, install the matching ABI apk (e.g. app-arm64-v8a-release.apk)
```

Signing
- Create a keystore if you don't have one:

```bash
keytool -genkey -v -keystore ~/release_keystore.jks -alias wellnex_key -keyalg RSA -keysize 2048 -validity 10000
```

- Copy `android/key.properties.example` to `android/key.properties` and update values. The build script will pick it up automatically and use the release signing config. If `key.properties` is missing, the project falls back to the debug signing config so `flutter run --release` still works for development.

Optional helper script
- Run the helper script from the repo root to perform the steps and build the APK/AAB:

```bash
./wellnex_app/scripts/build_apk.sh            # release APK (default)
./wellnex_app/scripts/build_apk.sh --debug    # debug APK
./wellnex_app/scripts/build_apk.sh --aab      # build app bundle (AAB)
./wellnex_app/scripts/build_apk.sh --split    # build split per-ABI APKs
```

CI builds
- A GitHub Actions workflow was added at `.github/workflows/android-build.yml` to produce signed artifacts.
- Provide these repository Secrets to enable release signing in CI:
  - `KEYSTORE_BASE64` — base64 of `release_keystore.jks` (use `base64 -w 0 release_keystore.jks`)
  - `KEYSTORE_PASSWORD`
  - `KEY_ALIAS`
  - `KEY_PASSWORD`

- The workflow builds a universal APK, an AAB, and split per-ABI APKs and uploads them as artifacts (`wellnex-apks`, `wellnex-aab`).
