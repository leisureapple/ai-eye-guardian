#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="$ROOT_DIR/03_outputs"
APP_DIR="$OUTPUT_DIR/AI Eye Guardian.app"
ZIP_PATH="$OUTPUT_DIR/AIEyeGuardian-macOS.zip"

if [ ! -d "$APP_DIR" ]; then
  "$ROOT_DIR/04_scripts/build_app.sh" >/dev/null
fi

rm -f "$ZIP_PATH"
ditto -c -k --keepParent "$APP_DIR" "$ZIP_PATH"
echo "$ZIP_PATH"
