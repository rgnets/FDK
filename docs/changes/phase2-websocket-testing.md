# Phase 2 – WebSocket Testing Toolkit

## Overview
To iterate safely on the client socket stack before the production gateway is ready, we need a lightweight local simulator that mimics the `auth.init` handshake and emits the domain events Phase 2 depends on. This toolkit documents the approach and provides scripts developers can run alongside the Flutter app.

## Components
1. **Fake Gateway Script** (`tool/fake_websocket_gateway.dart`)
   - Uses `dart:io` WebSocket server.
   - Listens on `ws://127.0.0.1:9443/ws` (matching default dev config).
   - Validates incoming `auth.init` payloads: ensures timestamp within ±15 minutes, required fields present.
   - Responds with `auth.ack` containing a mock session token.
   - Periodically broadcasts sample messages across the same channels the real backend will expose:
     - `devices.summary`
     - `rooms.summary`
     - `scanner.events`
   - Echoes commands received on `cmd/*` namespaces for testing command round-trips.
   - Optional `--verbose` flag prints connection, handshake, heartbeat, and broadcast activity to stdout.

2. **Launch Script** (`scripts/run_fake_gateway.sh`)
   - Wraps the Dart server with `dart run` (pass flags like `--verbose`, `--broadcast=5` as needed).
   - Prints connection instructions and environment overrides.

3. **Environment Overrides**
   - Set `USE_WEBSOCKETS=true`, `DEV_WS_URL=ws://127.0.0.1:9443/ws`, and (optionally) `USE_REST_FALLBACK=false` when you want to exercise pure socket flows.
   - The Flutter app will reuse the existing REST fallback when sockets drop, so testers can toggle behaviour easily by flipping `USE_REST_FALLBACK`.

## Implementation Plan
- [ ] Add `tool/fake_websocket_gateway.dart` with a minimal state machine to accept handshake, store connections, and broadcast demo payloads.
- [ ] Expose CLI flags for interval timings and sample payload selection (e.g., `--device-count 3`).
- [ ] Add `scripts/run_fake_gateway.sh` helper (with explanation in README/setup docs).
- [ ] Extend `docs/setup.md` with a "WebSocket Testing" section covering environment variables, how to run the fake gateway, and sample `wscat` commands for manual inspection.
- [ ] Wire a simple integration test harness (optional) that spins up the fake gateway inside the test suite for smoke coverage of the connection state provider.

## Usage Notes
- The fake gateway is intentionally stateless between runs. For more complex scenarios, consider recording real socket traffic once the production gateway is online and replaying it through this script.
- When testing reconnect logic, stop the fake server to simulate outages; the Flutter client should transition to `reconnecting` and back to `connected` once the server restarts.
- Keep the fake gateway under `tool/` so it’s excluded from production builds but still accessible to developers.

## Open Questions
- Should we persist the mock session token to mirror backend behaviour exactly? (Current plan: yes, return a fake JWT-like string and store it so we can test reconnect handshakes once backend defines the spec.)
- Do we want to feed data from the local `~/Git/rXg` or `~/Git/field_engineering` repos into the fake gateway? (Future enhancement: reuse their fixtures or REST responses to broadcast real-looking data.)
