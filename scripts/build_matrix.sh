#!/bin/bash
set -euo pipefail

LOG_DIR="$(cd "$(dirname "$0")/.." && pwd)/build_logs"
mkdir -p "$LOG_DIR"

run_build() {
  local name="$1"
  local cmd="$2"
  local log_file="$LOG_DIR/${name}.log"
  echo "Running $name..."
  (set -x; eval "$cmd") &>"$log_file" && echo "$name succeeded" || {
    echo "$name failed. See $log_file" >&2
    return 1
  }
}

run_build "apk_debug" "flutter build apk --debug"
run_build "ios_simulator" "flutter build ios --simulator"
run_build "macos" "flutter build macos"
run_build "windows" "flutter build windows"
