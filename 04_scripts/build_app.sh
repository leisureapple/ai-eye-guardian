#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/02_working/build"
OUTPUT_DIR="$ROOT_DIR/03_outputs"
APP_NAME="Little Ant Runner"
APP_DIR="$OUTPUT_DIR/$APP_NAME.app"
EXECUTABLE_DIR="$APP_DIR/Contents/MacOS"
RESOURCE_DIR="$APP_DIR/Contents/Resources"

rm -rf "$BUILD_DIR" "$APP_DIR"
mkdir -p "$BUILD_DIR" "$EXECUTABLE_DIR" "$RESOURCE_DIR"

swiftc \
  "$ROOT_DIR/Sources/LittleAntRunner/main.swift" \
  -framework AppKit \
  -o "$EXECUTABLE_DIR/LittleAntRunner"

if [ -d "$ROOT_DIR/Assets/rooster_frames" ]; then
  cp -R "$ROOT_DIR/Assets/rooster_frames" "$RESOURCE_DIR/rooster_frames"
elif [ -d "$OUTPUT_DIR/assets/rooster_frames" ]; then
  cp -R "$OUTPUT_DIR/assets/rooster_frames" "$RESOURCE_DIR/rooster_frames"
fi

cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>zh_CN</string>
  <key>CFBundleExecutable</key>
  <string>LittleAntRunner</string>
  <key>CFBundleIdentifier</key>
  <string>com.local.littleantrunner</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>Little Ant Runner</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>10.15</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

codesign --force --deep --sign - "$APP_DIR" >/dev/null 2>&1 || true
echo "$APP_DIR"
