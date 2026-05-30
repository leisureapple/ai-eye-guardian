#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/03_outputs/AI Eye Guardian.app"

if [ ! -d "$APP_DIR" ]; then
  "$ROOT_DIR/04_scripts/build_app.sh" >/dev/null
fi

open "$APP_DIR"
