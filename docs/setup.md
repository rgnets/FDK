# FDK Setup Guide

This document captures environment expectations and daily workflows for developing RG Nets Field Deployment Kit.

## 1. Environment Baseline

- **Host OS:** macOS 15.6.1 (Apple Silicon)
- **Flutter:** 3.35.5 (stable)
- **Dart:** 3.9.2
- **Android Studio:** 2025.1 + Android SDK 36 / build-tools 36.1.0-rc1
- **Xcode:** 16.4, CocoaPods 1.16.2
- **VS Code:** 1.103.2 (optional)

Run `flutter doctor -v` to verify tooling. Capture any discrepancies in `docs/changes/`.

## 2. Initial Setup

```bash
git clone <repository-url>
cd FDK

flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

For recurring development:

- `scripts/pre_commit.sh` — format, analyze, and test (set `SKIP_TESTS=1` to bypass tests until legacy failures are resolved).
- `scripts/build_matrix.sh` — builds Android debug APK, iOS simulator app, and macOS desktop binary; requires macOS host. Windows build runs only on Windows.

## 3. Environment Variables & dart-defines

| Key | Purpose | Default | Notes |
|-----|---------|---------|-------|
| `ENVIRONMENT` | Selects environment (development, staging, production) | `development` | Controls API endpoints & feature flags |
| `LOG_LEVEL` | Overrides logging verbosity (`off`, `error`, `warning`, `info`, `debug`, `trace`, `auto`) | auto | Auto resolves based on environment |
| `ENABLE_CRASH_REPORTING` | Enables `ErrorReporter` forwarding | true in production, false otherwise | Placeholder until Sentry integration |
| `API_URL` / `API_USERNAME` / `API_KEY` | Production runtime credentials | none | Required for production run/build |
| `TEST_API_*` | Staging/test overrides (see `AppConfig`) | provided | Used for interurban staging |

Example:

```bash
flutter run -t lib/main_staging.dart \
  --dart-define=ENVIRONMENT=staging \
  --dart-define=LOG_LEVEL=debug
```

## 4. Known Issues (Phase 1)

- Legacy unit tests referencing deprecated `RoomModel` getters currently fail (`test/mock_data_test.dart`). Track progress in `docs/changes/phase1-upgrade.md`.
- Flutter analyze emits a large volume of info-level hints from legacy files; clean-up scheduled post Phase 1.

## 5. Troubleshooting

- **Android build duplicate class** — run `rm -rf build` if `battery_plus` Kotlin classes conflict, then rerun build matrix.
- **Windows build on macOS** — expect `"build windows" only supported on Windows hosts`; run on Windows CI/host when required.
- **Podfile.lock changes** — remove `ios/Podfile.lock` and `macos/Podfile.lock` after simulator builds to keep repo clean.

## 6. Useful Commands

```bash
flutter analyze
flutter test              # (fails currently; see Known Issues)
dart run build_runner build --delete-conflicting-outputs
flutter pub outdated
```

Log any environment adjustments or notable failures in `docs/changes/phase1-upgrade.md` so future runs remain reproducible.
