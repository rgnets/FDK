# Council Implementation Plan: FDK Code Review Fixes

**Branch**: `zew/AIConcerns`
**Workflow**: Each fix implemented by Claude, reviewed by Codex & Gemini
**Total Issues**: 18 (4 Critical, 6 High, 8 Medium)

---

## Implementation Order

Issues ordered by: **Severity → Dependency → Complexity**

| Phase | Issue | Severity | Est. Changes |
|-------|-------|----------|--------------|
| 1 | Debug Route in Production | CRITICAL | 1 file, ~10 lines |
| 2 | State Leak on Sign-out | CRITICAL | 1 file, ~5 lines |
| 3 | Unbounded Family Providers | CRITICAL | 1 file, ~10 lines |
| 4 | Circular Provider Dependency | CRITICAL | 2-3 files, ~50 lines |
| 5 | Mock Data in Production | HIGH | 1 file, ~30 lines |
| 6 | Silent Error Handling | HIGH | 2 files, ~20 lines |
| 7 | SharedPreferences Silent Failure | HIGH | 1 file, ~30 lines |
| 8 | Async onDispose Not Awaited | HIGH | 1 file, ~5 lines |
| 9 | riverpod_lint Disabled | HIGH | 2 files, testing |
| 10 | Premature Stream Subscription | HIGH | 1 file, ~10 lines |
| 11-18 | Medium Priority Issues | MEDIUM | Backlog |

---

## Phase 1: Debug Route in Production ✅

**File**: `lib/core/navigation/app_router.dart:57-61`

**Fix**: Gate debug route behind `EnvironmentConfig.isProduction` check

```dart
// Debug screen - only available in non-production builds
if (!EnvironmentConfig.isProduction)
  GoRoute(
    path: '/debug',
    builder: (context, state) => const DebugScreen(),
  ),
```

---

## Phase 2: State Leak on Sign-out ✅

**File**: `lib/features/auth/presentation/providers/auth_notifier.dart`

**Fix**: Add rooms provider invalidation to sign-out cleanup

```dart
ref.invalidate(rooms_providers.roomsNotifierProvider);
```

---

## Phase 3: Unbounded Family Providers ✅

**File**: `lib/features/devices/presentation/providers/devices_provider.dart`

**Fix**: Remove `keepAlive: true` from `DeviceNotifier` and `DeviceSearchNotifier`

Changed `@Riverpod(keepAlive: true)` to `@riverpod` for auto-dispose behavior.

---

## Phase 4: Circular Provider Dependency ✅

**Files**:
- `lib/core/providers/websocket_providers.dart`
- `lib/core/providers/websocket_sync_providers.dart` (new)

**Fix**: Extract sync-related providers to new file to break circular dependency between `repository_providers.dart` and `websocket_providers.dart`.

---

## Phase 5: Mock Data in Production ✅

**File**: `lib/features/rooms/presentation/providers/rooms_riverpod_provider.dart`

**Fix**: Replace mock 80% online calculation with real device status from `devicesNotifierProvider`.

---

## Phase 6: Silent Error Handling ✅

**Files**:
- `lib/features/initialization/presentation/providers/initialization_provider.dart`
- `lib/features/rooms/presentation/providers/rooms_riverpod_provider.dart`

**Fix**: Add proper error logging instead of swallowing errors silently.

---

## Phase 7: SharedPreferences Silent Failure ✅

**File**: `lib/main.dart`

**Fix**: Show error UI with retry button instead of silent exit when SharedPreferences fails to initialize.

---

## Phase 8: Async onDispose Not Awaited ✅

**File**: `lib/core/providers/websocket_sync_providers.dart`

**Fix**: Use `unawaited()` with error logging to document that Riverpod doesn't await async onDispose callbacks.

---

## Phase 9: Enable riverpod_lint ✅

**Files**:
- `pubspec.yaml`
- `analysis_options.yaml`

**Fix**:
- Enabled `custom_lint: ^0.6.3` and `riverpod_lint: ^2.3.10` in pubspec.yaml
- Added `analyzer.plugins: - custom_lint` to analysis_options.yaml
- Sorted dev_dependencies alphabetically to satisfy lint rules

---

## Phase 10: Premature Stream Subscription ✅

**File**: `lib/features/devices/presentation/providers/devices_provider.dart`

**Fix**: Move `_attachDevicesStream()` call to after authentication check.

---

## Verification Checklist

After all phases:
- [x] `flutter analyze` passes (only info-level issues, no errors)
- [x] `dart run build_runner build` succeeds
- [x] App builds successfully (`flutter build apk --debug`)
- [ ] App runs in dev mode - all features work
- [ ] App runs in prod mode - /debug inaccessible
- [ ] Sign out clears all user data
- [ ] Memory stable after browsing many devices/searches
- [ ] Dashboard shows real online counts
- [ ] Errors logged, not swallowed
