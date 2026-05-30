#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 /path/to/rooster-video.mp4" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INPUT_VIDEO="$1"
OUTPUT_DIR="$ROOT_DIR/Assets/rooster_frames"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ffmpeg is required to generate rooster frames." >&2
  exit 1
fi

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

ffmpeg -y \
  -i "$INPUT_VIDEO" \
  -vf "fps=12,scale=360:-1,format=rgba,colorkey=0xb2b2b2:0.28:0.08" \
  -frames:v 96 \
  "$OUTPUT_DIR/rooster_%03d.png"

echo "$OUTPUT_DIR"
