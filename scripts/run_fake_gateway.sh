#!/usr/bin/env bash

# Convenience wrapper to launch the fake WebSocket gateway.
# Mirrors the default dev configuration used by EnvironmentConfig.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "Starting fake WebSocket gateway..."
echo "Listening on ws://127.0.0.1:9443/ws (override with --host/--port/--path)."

dart run tool/fake_websocket_gateway.dart "$@"
