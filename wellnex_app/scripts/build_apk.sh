#!/usr/bin/env bash
set -euo pipefail

# Helper script to build Android artifacts locally from the repo root: wellnex_app/scripts/build_apk.sh
# Usage:
#   ./wellnex_app/scripts/build_apk.sh            # release APK
#   ./wellnex_app/scripts/build_apk.sh --debug    # debug APK
#   ./wellnex_app/scripts/build_apk.sh --aab      # build app bundle (AAB)
#   ./wellnex_app/scripts/build_apk.sh --split    # build split per-ABI APKs

DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$DIR"

MODE="--release"
BUILD_AAB=false
BUILD_SPLIT=false
if [[ "${1:-}" == "--debug" ]]; then
  MODE=""
fi
if [[ "${1:-}" == "--aab" ]]; then
  BUILD_AAB=true
fi
if [[ "${1:-}" == "--split" ]]; then
  BUILD_SPLIT=true
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter not found in PATH. Install Flutter and retry." >&2
  exit 2
fi

echo "Running flutter clean"
flutter clean

echo "Running flutter pub get"
flutter pub get

if [ "$BUILD_AAB" = true ]; then
  echo "Building app bundle (AAB)"
  flutter build appbundle $MODE
fi

if [ "$BUILD_SPLIT" = true ]; then
  echo "Building split per-ABI APKs"
  flutter build apk --target-platform android-arm,android-arm64 $MODE --split-per-abi
fi

if [ "$BUILD_AAB" = false ] && [ "$BUILD_SPLIT" = false ]; then
  echo "Building APK ($MODE)"
  flutter build apk $MODE
fi

APK_DIR=build/app/outputs/flutter-apk
AAB_DIR=build/app/outputs/bundle/release

echo "Build finished. Artifacts:"
ls -lah "$APK_DIR" || true
ls -lah "$AAB_DIR" || true

echo "To install to a connected device run:\n  adb install -r $APK_DIR/app-release.apk"
