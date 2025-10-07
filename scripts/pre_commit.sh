#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "Checking Dart formatting..."
flutter format --set-exit-if-changed .

echo "Running flutter analyze..."
flutter analyze

if [[ "${SKIP_TESTS:-0}" == "1" ]]; then
  echo "Skipping flutter test (set SKIP_TESTS=0 to enable)."
else
  echo "Running flutter test..."
  flutter test
fi

echo "Pre-commit checks completed."
