#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
# Git Bash + Flutter + Node.js must be on PATH.
# pub get writes plugin metadata before checking symbolic-link support.
if ! flutter pub get; then
  node tool/prepare_windows_plugins.cjs
  flutter pub get
fi
dart run build_runner build
