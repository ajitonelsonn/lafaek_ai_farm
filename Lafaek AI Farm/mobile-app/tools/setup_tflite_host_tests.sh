#!/usr/bin/env bash
# Copies the TensorFlow Lite C library shipped with tflite_flutter into the
# Flutter engine cache so `flutter test` can run real on-host inference on
# macOS. Safe to re-run. Only needed for the CV tests; the Android app bundles
# its own native library.
set -euo pipefail
PKG=$(ls -d "$HOME"/.pub-cache/hosted/pub.dev/tflite_flutter-* | sort -V | tail -1)
ENGINE="$(dirname "$(dirname "$(which flutter)")")/bin/cache/artifacts/engine"
# `which flutter` may be a symlink (homebrew); resolve the real cache dir.
FLUTTER_ROOT=$(flutter --version --machine 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)['flutterRoot'])")
ENGINE="$FLUTTER_ROOT/bin/cache/artifacts/engine"
mkdir -p "$ENGINE/resources"
cp "$PKG/macos/libtensorflowlite_c-mac.dylib" "$ENGINE/resources/"
echo "Installed $(basename "$PKG") dylib to $ENGINE/resources/"
