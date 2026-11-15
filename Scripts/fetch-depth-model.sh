#!/bin/sh
# Downloads the depth model the Spatial Scene feature runs on the iPhone:
# Depth Anything V2 Small in Core ML form (Apache-2.0), about 48 MB.
# It is pinned to one revision and checked against known SHA-256 sums.
# The app builds without it; the Spatial Scene button is then hidden.
# `xcodegen generate` runs this by itself (project.yml, preGenCommand).
# Usage: Scripts/fetch-depth-model.sh [--optional]
#   --optional: a failed download is a warning, not an error (for building offline).
set -eu

if [ "${1:-}" = "--optional" ]; then
  "$0" || echo "warning: the depth model was not downloaded; Spatial Scene will be hidden in this build" >&2
  exit 0
fi

ROOT=$(cd "$(dirname "$0")/.." && pwd)
NAME=DepthAnythingV2SmallF16.mlpackage
DEST="$ROOT/App/Models/$NAME"
BASE="https://huggingface.co/apple/coreml-depth-anything-v2-small/resolve/cfef6f6f2a70783dedc0bfae40cecbc2052285d3/$NAME"

check() { # path, expected sum
  [ -f "$1" ] && [ "$(shasum -a 256 "$1" | cut -d' ' -f1)" = "$2" ]
}

fetch() { # relative path, expected sum
  if check "$DEST/$1" "$2"; then return 0; fi
  mkdir -p "$(dirname "$DEST/$1")"
  echo "Downloading $1"
  curl -fL --retry 3 -o "$DEST/$1.part" "$BASE/$1"
  if ! check "$DEST/$1.part" "$2"; then
    rm -f "$DEST/$1.part"
    echo "Checksum mismatch for $1" >&2
    exit 1
  fi
  mv "$DEST/$1.part" "$DEST/$1"
}

fetch Manifest.json 2883ae290c48fe916dc5ececac03a7d847fa277165a49ef5652fa1d2b9cb55f7
fetch Data/com.apple.CoreML/model.mlmodel 44ac97a3efcfd52113183fb2862ff59cd0368e9ec2e30a90a54980dd11407042
fetch Data/com.apple.CoreML/weights/weight.bin fa60d9b6a155734f59029ebb882fd54e549bfaee3539c1a9cbd2cbbab64a0fed
echo "Depth model ready: App/Models/$NAME"
