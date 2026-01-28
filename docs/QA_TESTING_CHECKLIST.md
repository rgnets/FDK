# FDK (Field Deployment Kit) - Comprehensive QA Testing Checklist

**Version:** 0.9.1
**Created:** 2026-01-27
**Status:** Pre-Release QA

This document provides a comprehensive checklist for testing all functions of the FDK mobile app before release. All three AI reviewers (Claude, Codex, Gemini) have contributed to ensure 100% coverage.

---

## Test Environment Requirements

### Staging Environment
- **API URL:** Staging RXG server with valid HTTPS certificate
- **Credentials:** Valid API token with read/write permissions
- **Test Data:** Pre-populated devices, rooms, and notifications

### Test Devices
- [ ] iOS device (iPhone/iPad)
- [ ] Android device
- [ ] Web browser (optional)
- [ ] Various network conditions (WiFi, cellular, offline)

---

## 1. Authentication & Security

### 1.1 QR Code Authentication
- [ ] Scan valid authentication QR code
- [ ] Verify successful login and navigation to home screen
- [ ] Scan malformed QR code - expect graceful error message
- [ ] Scan expired/invalid QR code - expect error handling
- [ ] Camera permissions denied - expect appropriate prompt

### 1.2 Manual Token Authentication
- [ ] Enter valid FQDN, username, and API token
- [ ] Verify successful authentication
- [ ] Enter invalid credentials - expect clear error message
- [ ] Leave fields empty - expect validation errors
- [ ] Test token with insufficient permissions

### 1.3 Session Management
- [ ] App remembers credentials after restart
- [ ] Logout clears all stored credentials
- [ ] Session timeout handling (if applicable)
- [ ] Authentication state persists across app backgrounding

### 1.4 Certificate Handling
- [ ] Valid certificate - successful connection
- [ ] Self-signed certificate - warning with option to proceed (debug mode)
- [ ] Expired certificate - appropriate error message
- [ ] Certificate mismatch - rejection with clear error

---

## 2. Device Management

### 2.1 Device List Display
- [ ] All device types displayed (APs, ONTs, Switches, WLAN Controllers)
- [ ] Device count matches server data
- [ ] Device status indicators show correctly (online/offline/warning/error)
- [ ] Pull-to-refresh updates device list
- [ ] Loading indicator appears during fetch
- [ ] Empty state displayed when no devices

### 2.2 Device Filtering & Search
- [ ] Filter by device type (AP, ONT, Switch)
- [ ] Filter by status (online, offline, etc.)
- [ ] Search by device name
- [ ] Search by MAC address
- [ ] Search by IP address
- [ ] Clear filters resets view
- [ ] Multiple filters work together correctly

### 2.3 Device Sorting
- [ ] Sort by name (A-Z, Z-A)
- [ ] Sort by status
- [ ] Sort by last seen/updated
- [ ] Sort persists after navigation

### 2.4 Device Detail View
- [ ] Navigate to device detail from list
- [ ] All device information displayed correctly
  - [ ] Name, type, status
  - [ ] MAC address
  - [ ] IP address
  - [ ] Serial number
  - [ ] Model/firmware information
  - [ ] Room assignment
  - [ ] Notes
- [ ] Back navigation returns to list with scroll position preserved

### 2.5 Device Image Management
- [ ] View existing device images
- [ ] Open image in full-screen viewer
- [ ] Upload new image from camera
- [ ] Upload new image from gallery
- [ ] Upload progress indicator displayed
- [ ] Upload success confirmation
- [ ] Image appears after upload (may require refresh)
- [ ] Delete image with confirmation
- [ ] Delete cancellation preserves image
- [ ] Handle upload failure gracefully
- [ ] Handle large images (compression applied)
- [ ] **Delete image failure handling** (API error, offline, permission denied)
- [ ] **Cache refresh after image deletion** (list updates without full refresh)
- [ ] **Invalid image URL handling** (broken link, 404)

### 2.6 Device Notes
- [ ] View existing notes
- [ ] Edit notes
- [ ] Save note changes
- [ ] Cancel note editing preserves original
- [ ] Notes sync with server
- [ ] Notes persist after app restart

### 2.7 Device Reboot
- [ ] Reboot button visible for supported devices
- [ ] Confirmation dialog before reboot
- [ ] Reboot progress/status indicator
- [ ] Success message after reboot initiated
- [ ] Handle reboot failure gracefully

---

## 3. Barcode/QR Scanning

### 3.1 Scanner Initialization
- [ ] Camera permissions requested on first use
- [ ] Camera preview displays correctly
- [ ] Flash toggle works (if device supports)
- [ ] Scanner guidelines visible

### 3.2 Device Type Selection
- [ ] AP scan mode (requires 2 barcodes: serial + MAC)
- [ ] ONT scan mode (requires 2 barcodes: serial + MAC)
- [ ] Switch scan mode (requires 1 barcode: serial)
- [ ] Mode switch clears previous scan session

### 3.3 Barcode Scanning
- [ ] Scan valid serial number barcode
- [ ] Scan valid MAC address barcode
- [ ] Barcode detected feedback (visual/audio)
- [ ] Progress indication (1 of 2 scanned)
- [ ] Session complete when all required barcodes scanned

### 3.4 Device Registration
- [ ] Registration popup appears after successful scan
- [ ] Correct device info displayed
- [ ] Confirm registration - device created/updated
- [ ] Cancel registration - scan session cleared
- [ ] Handle duplicate device gracefully
- [ ] Handle unrecognized barcode format

### 3.5 Scan Session Management
- [ ] 6-second accumulation window works correctly
- [ ] Session timeout clears partial scans
- [ ] Manual cancel/reset works
- [ ] Scanner resumes after registration

### 3.6 Edge Cases
- [ ] Scan same barcode twice - appropriate handling
- [ ] Scan barcodes in wrong order - still works
- [ ] Poor lighting conditions - scanner still functional
- [ ] Barcode at angle - still scans
- [ ] Multiple barcodes in frame - handles correctly

---

## 4. Room Management

### 4.1 Room List Display
- [ ] All rooms displayed
- [ ] Room count matches server data
- [ ] Pull-to-refresh updates room list
- [ ] Loading indicator during fetch
- [ ] Empty state when no rooms

### 4.2 Room Detail View
- [ ] Navigate to room detail
- [ ] Room information displayed correctly
- [ ] Associated devices listed
- [ ] Device status summary (X online, Y offline)
- [ ] Navigate to device from room detail

### 4.3 Room-Device Association
- [ ] Devices correctly assigned to rooms
- [ ] Unassigned devices shown appropriately
- [ ] Room filter in device list works

---

## 5. Notifications

### 5.1 Notification Display
- [ ] Notification list displays
- [ ] Unread count badge shown
- [ ] Notification types displayed with appropriate icons
  - [ ] Error notifications
  - [ ] Warning notifications
  - [ ] Info notifications
  - [ ] Success notifications
- [ ] Timestamp displayed correctly

### 5.2 Notification Interactions
- [ ] Mark single notification as read
- [ ] Mark all notifications as read
- [ ] Clear all notifications
- [ ] Navigate to related device/room (if applicable)
- [ ] **Deep-link to missing device** (device deleted, graceful error handling)
- [ ] **Deep-link to missing room** (room deleted, graceful error handling)

### 5.3 Notification Generation
- [ ] Device status change generates notification
- [ ] Image upload completion generates notification
- [ ] Connectivity issues generate notification

---

## 6. Settings

### 6.1 Settings Display
- [ ] Settings screen accessible from navigation
- [ ] All settings options displayed

### 6.2 Settings Operations
- [ ] Change theme (if available)
- [ ] Change logging level
- [ ] Export settings to file
- [ ] Import settings from file
- [ ] Clear cache
- [ ] Reset to defaults
- [ ] Settings persist after app restart

### 6.3 Account Settings
- [ ] View current user/server info
- [ ] Logout functionality
- [ ] Logout clears all cached data

---

## 7. Speed Test (Diagnostic Tool)

### 7.1 Speed Test Execution
- [ ] Speed test card visible on home screen
- [ ] Start speed test
- [ ] Progress indicator during test
- [ ] Results displayed (download/upload speeds)
- [ ] Results history (if applicable)

### 7.2 Network Gateway Discovery
- [ ] Gateway detected automatically
- [ ] Manual gateway configuration (if supported)

---

## 8. Offline Functionality

### 8.1 Offline Data Access
- [ ] Cached device list accessible offline
- [ ] Cached room list accessible offline
- [ ] Device details accessible offline
- [ ] Clear offline indicator displayed

### 8.2 Offline Operations
- [ ] Queue operations while offline
- [ ] Sync when connectivity restored
- [ ] Conflict resolution for concurrent changes

### 8.3 Connectivity Transitions
- [ ] Online to offline - graceful transition
- [ ] Offline to online - automatic sync
- [ ] Intermittent connectivity - resilient behavior

---

## 9. WebSocket Real-Time Updates

### 9.1 Connection Management
- [ ] WebSocket connects on app start
- [ ] Connection status indicator (if visible)
- [ ] Automatic reconnection after disconnect
- [ ] Exponential backoff for reconnection attempts
- [ ] Heartbeat/ping-pong keeps connection alive

### 9.2 Real-Time Data Sync
- [ ] Device status changes reflect immediately
- [ ] New devices appear without manual refresh
- [ ] Deleted devices removed without manual refresh
- [ ] Image changes reflect in real-time

---

## 10. Navigation & UX

### 10.1 Bottom Navigation
- [ ] Home tab navigation
- [ ] Scanner tab navigation
- [ ] Devices tab navigation
- [ ] Rooms tab navigation
- [ ] Notifications tab navigation (if applicable)
- [ ] Settings tab navigation
- [ ] Active tab indicator correct

### 10.2 Screen Navigation
- [ ] Back navigation works correctly
- [ ] Deep link navigation works
- [ ] Navigation state preserved on rotation
- [ ] Navigation state preserved on background/foreground

### 10.3 Gesture Handling
- [ ] Pull-to-refresh on lists
- [ ] Swipe gestures (if applicable)
- [ ] Long press actions (if applicable)
- [ ] Pinch-to-zoom on images

### 10.4 Loading States
- [ ] Initial load indicators
- [ ] Refresh indicators
- [ ] Skeleton loading (if implemented)
- [ ] Progress indicators for long operations

### 10.5 Error States
- [ ] Network error displays
- [ ] Server error displays
- [ ] Empty state displays
- [ ] Retry mechanisms available

---

## 11. Performance

### 11.1 Startup Performance
- [ ] App launches within acceptable time (<3s)
- [ ] Splash screen displays correctly
- [ ] Initial data loads within acceptable time

### 11.2 List Performance
- [ ] Large device lists scroll smoothly
- [ ] Image loading doesn't block UI
- [ ] Pagination works for large datasets

### 11.3 Memory Management
- [ ] No memory leaks during extended use
- [ ] Image cache doesn't grow unbounded
- [ ] App doesn't crash under memory pressure

### 11.4 Battery Usage
- [ ] WebSocket doesn't drain battery excessively
- [ ] Background refresh is reasonable

---

## 12. Platform-Specific Testing

### 12.1 iOS-Specific
- [ ] Face ID/Touch ID integration (if applicable)
- [ ] iOS share sheet integration
- [ ] iOS notification permissions
- [ ] iOS camera permissions
- [ ] Safe area handling (notch, home indicator)

### 12.2 Android-Specific
- [ ] Android permissions handling
- [ ] Android back button behavior
- [ ] Android share intent
- [ ] Various Android versions (API 21+)

### 12.3 Responsive Design
- [ ] Tablet layout (if supported)
- [ ] Landscape orientation handling
- [ ] Different screen sizes

---

## 13. Edge Cases & Error Recovery

### 13.1 Network Errors
- [ ] Request timeout handling
- [ ] Server 500 errors
- [ ] Server 404 errors
- [ ] Authentication expiration (401)
- [ ] Rate limiting (429)

### 13.2 Data Integrity
- [ ] Corrupt cache recovery
- [ ] Invalid server response handling
- [ ] Version mismatch handling

### 13.3 App State Recovery
- [ ] Crash recovery
- [ ] Force quit recovery
- [ ] Low memory recovery
- [ ] Process death recovery

---

## 14. Accessibility

### 14.1 Screen Reader Support
- [ ] VoiceOver (iOS) navigation
- [ ] TalkBack (Android) navigation
- [ ] All interactive elements labeled

### 14.2 Visual Accessibility
- [ ] Sufficient color contrast
- [ ] Text scales with system settings
- [ ] Touch targets are sufficiently large (44x44pt minimum)

---

## 15. App Update & Data Migration (Gemini Addition)

### 15.1 Version Migration
- [ ] Test app update from previous version
- [ ] Verify cached data migrates correctly (credentials, device lists, settings)
- [ ] No data loss during update
- [ ] No re-authentication required after update (unless intentional)

### 15.2 Server-Side Token Revocation
- [ ] API token revoked on server while app is running
- [ ] App gracefully logs out on next authenticated request
- [ ] Clear error message displayed to user
- [ ] Cached data cleared on forced logout

---

## 16. Environmental & Device Interference (Gemini Addition)

### 16.1 Sensor Quality
- [ ] Barcode scanning on lower-quality cameras
- [ ] Scanning with smudged/dirty lens
- [ ] Scanning in various lighting conditions (bright sunlight, low light)

### 16.2 System Interruptions
- [ ] Incoming phone call during scanning
- [ ] Incoming phone call during image upload
- [ ] Alarm notification during critical process
- [ ] Low battery notification during upload
- [ ] App resumes correctly after interruption

### 16.3 Long-Term Stability
- [ ] App running for extended period (24-48 hours)
- [ ] No memory leaks during extended use
- [ ] WebSocket reconnects properly after backgrounding
- [ ] Battery drain is reasonable with WebSocket active

---

## 18. Localization (If Applicable)

### 18.1 Text Display
- [ ] All text strings localized
- [ ] Date/time formats localized
- [ ] Number formats localized

### 18.2 RTL Support
- [ ] Layout adapts for RTL languages
- [ ] Icons flip appropriately

---

## Test Execution Summary

| Category | Total Tests | Passed | Failed | Blocked |
|----------|-------------|--------|--------|---------|
| Authentication | | | | |
| Devices | | | | |
| Scanning | | | | |
| Rooms | | | | |
| Notifications | | | | |
| Settings | | | | |
| Speed Test | | | | |
| Offline | | | | |
| WebSocket | | | | |
| Navigation | | | | |
| Performance | | | | |
| Platform | | | | |
| Edge Cases | | | | |
| Accessibility | | | | |
| **TOTAL** | | | | |

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| QA Lead | | | |
| Dev Lead | | | |
| Product Owner | | | |

---

## Automated Test Status

**Status: 806 tests passing, 0 tests skipped**

### Completed Migrations
- ✅ `rest_image_upload_service_test.dart` - Fully migrated from http.Client to Dio mocking (18 tests)
- ✅ Timer management resolved with `NoopWebSocketService` and `NoopBackgroundRefreshService` in test harness
- ✅ Full-app integration tests moved to `integration_test/` directory (7 tests)
- ✅ Redundant skipped widget tests removed after integration test validation

### Integration Tests Setup

Full-app tests that require the complete `FDKApp` widget use Flutter integration tests:

**Run integration tests with:**
```bash
# Headless (no device required)
flutter test integration_test/app_test.dart

# With device/emulator
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart
```

**Integration test coverage:**
- Development environment navigation with mock data
- Development environment device list loading
- Staging environment auto-authentication
- Production environment authentication requirement
- Production auth screen input fields
- Splash screen display
- Bottom navigation functionality

### Technical Note

The `FDKApp` widget uses `ref.listen` inside `initState` via `WidgetsBinding.instance.addPostFrameCallback`. This is incompatible with `UncontrolledProviderScope` used in widget tests, which is why full-app tests are run as integration tests instead.

---

## Notes

- Tests marked with blocking issues should be documented in issue tracker
- All failed tests require a linked bug report
- Performance tests should include metrics (load time, memory usage, etc.)
- Platform-specific issues should note affected versions
- Skipped automated tests shift burden to manual QA - prioritize re-enabling them

---

## Review Consensus

This checklist has been reviewed and approved by:

| Reviewer | Status | Key Feedback Incorporated |
|----------|--------|---------------------------|
| **Claude** | ✅ Approved | Created initial comprehensive checklist |
| **Codex** | ✅ Approved | Added image deletion failure paths, cache refresh, deep-link handling |
| **Gemini** | ✅ Approved | Added app migration, system interruptions, long-term stability |

All three reviewers have reached consensus that this checklist provides comprehensive coverage for pre-release QA testing.

---

*Document generated with consensus from Claude, Codex, and Gemini AI reviewers - 2026-01-27*
