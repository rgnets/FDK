# WebSocket-Only Authentication Progress (2025-10-08)

## Summary
- Converted the FDK auth flow to rely exclusively on the WebSocket handshake.
- Added explicit credential approval (QR + manual entry) with session logging.
- Relaxed legacy QR validation so older badges pass (site name/timestamp optional).
- Retired REST device fetch when `USE_REST_FALLBACK=false` to avoid 404 spam.

## Current Issues
- Device repository still expects socket-delivered data; UI is empty until broadcast wiring lands.
- Camera cleanup warnings persist on some devices when the scanner route exits unexpectedly.
- Approve sheet doesn’t appear for every scan (must confirm scanner → approval flow once more on physical hardware).
- REST pathways still emit log noise if fallback is re-enabled before API endpoints are ready.

## Next Steps
1. **Socket Data Integration**  
   - Subscribe to `devices.summary`, `rooms.summary`, `scanner.events` and hydrate UI.
   - Persist broadcast payloads in cache/local storage.
2. **Scanner Polish**  
   - Ensure approval sheet always shows after scanning; add QA check on Pixel hardware.  
   - Finalise controller teardown to silence `BufferQueue` warnings.
3. **REST Rebind (Optional)**  
   - After socket feeds are live, re-enable fallback behind a toggle targeting QR fqdn.
4. **CI / Tooling**  
   - Wire the handshake smoke test into GitHub Actions (done).  
   - Add automated QR parsing tests to cover relaxed validation (done).
5. **Docs & Runbook**  
- Provide a field-ready “WebSocket login” guide once UI confirmed.

---

## Status Update (2025-10-09)
- Paused further WebSocket-only work until the gateway backend is ready for end-to-end testing.
- Restored previous REST behaviour (removed temporary guards) so existing device/room flows continue to function while backend work completes.
