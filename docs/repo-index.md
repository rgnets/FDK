# Repository Index - RG Nets FDK

**Generated**: 2025-08-17
**Repository**: RG-Nets-FDK
**Flutter SDK**: ^3.5.4
**Version**: 0.7.7

## Executive Summary

Enterprise-grade Flutter application for RG Nets Field Deployment Kit (Scanner App) with barcode/QR scanning capabilities, device registration, and room management. Built with clean architecture principles, comprehensive testing infrastructure, and multi-platform support.

## Repository Statistics

- **Total Dart Files**: 163 (89 lib/, 74 test/)
- **Platform Support**: iOS, Android, Web, macOS, Linux, Windows
- **Test Coverage**: Comprehensive with 74 test files
- **Documentation Files**: 32 markdown files
- **Asset Files**: 3,010+ (icons, images, data)
- **Build Flavors**: None explicitly defined (single production configuration)

## Directory Structure

```
/home/scl/Documents/RG-Nets-FDK/
├── lib/                         # Application source code
│   ├── core/                    # Core infrastructure (17 files)
│   │   ├── async/               # Async operation management
│   │   ├── camera/              # Camera lifecycle management
│   │   ├── connection/          # Connection state management
│   │   ├── error_handling/      # Error recovery systems
│   │   ├── initialization/      # App initialization pipeline
│   │   ├── navigation/          # Smart navigation controller
│   │   ├── network/             # Network resilience
│   │   ├── offline/             # Offline mode management
│   │   ├── state/               # App state management
│   │   └── telemetry/           # Telemetry tracking
│   ├── features/                # Feature modules
│   │   └── scanner/             # Scanner feature (24 files)
│   │       ├── domain/          # Business logic layer
│   │       ├── data/            # Data layer
│   │       ├── presentation/    # UI layer
│   │       └── di/              # Dependency injection
│   ├── views/                   # Legacy view controllers (8 files)
│   ├── services/                # Application services (7 files)
│   ├── rxg_api/                 # RXG API client (3 files)
│   ├── utils/                   # Utilities (10 files)
│   ├── widgets/                 # Shared widgets (2 files)
│   └── mocks/                   # Mock implementations (2 files)
├── test/                        # Test suite (74 files)
│   ├── core/                    # Core module tests
│   ├── features/                # Feature tests
│   ├── integration/             # Integration tests
│   ├── performance/             # Performance benchmarks
│   ├── quality/                 # Quality gates
│   ├── helpers/                 # Test utilities
│   └── fixtures/                # Test data
├── android/                     # Android platform
├── ios/                         # iOS platform
├── web/                         # Web platform
├── macos/                       # macOS platform
├── linux/                       # Linux platform
├── windows/                     # Windows platform
├── assets/                      # Application assets
│   ├── mac_unified.csv          # MAC address database
│   ├── oui.csv                  # OUI database
│   └── [various images]         # UI assets
├── docs/                        # Documentation
│   ├── development/             # Development guides
│   ├── deployment/              # Deployment documentation
│   ├── ci-cd/                   # CI/CD documentation
│   └── archive/                 # Historical documentation
├── scripts/                     # Build and utility scripts
└── .github/                     # GitHub Actions workflows
```

## Key Technologies

### Core Dependencies (Trace: pubspec.yaml:9-31)
- **Flutter SDK**: Material & Cupertino
- **Scanner**: mobile_scanner ^7.0.1
- **Networking**: http ^1.2.2, connectivity_plus ^6.1.1
- **State Management**: provider ^6.1.5
- **Storage**: shared_preferences ^2.3.3, path_provider ^2.1.5
- **Error Tracking**: sentry_flutter ^9.3.0
- **Dependency Injection**: get_it ^8.2.0
- **Permissions**: permission_handler ^12.0.0+1

### Development Dependencies (Trace: pubspec.yaml:33-42)
- **Testing**: flutter_test, mockito ^5.4.4
- **Linting**: flutter_lints ^6.0.0
- **Code Generation**: build_runner ^2.4.11
- **Test Utilities**: network_image_mock ^2.1.1, fake_async ^1.3.1

## Architecture Pattern

**Clean Architecture with Feature-First Organization**
- Domain layer (entities, repositories, services)
- Data layer (implementations, models)
- Presentation layer (screens, widgets, providers)
- Dependency injection via GetIt
- State management via Provider

## Build Configuration

### Environment Modes (Trace: lib/utils/environment_config.dart:8-13)
- **synthetic**: Mock data from factories
- **real**: Live API calls (default)
- **recorded**: Saved fixtures
- **mixed**: Chaos testing mode

### API Configuration (Trace: lib/utils/environment_config.dart:103-108)
- Default FQDN: vgw1-01.dal-interurban.mdu.attwifi.com
- Authentication: API key based
- SSL: Self-signed certificate support

## Testing Infrastructure

### Test Categories
- **Unit Tests**: Domain logic, services, utilities
- **Integration Tests**: Navigation, camera, API
- **Performance Tests**: Benchmarks, data operations
- **Quality Gates**: Test validation, coverage checks
- **Mutation Testing**: Code resilience validation

### Test Tools (Trace: test/)
- Test runner with multiple modes
- Fixture recording and playback
- Mock factories for all entities
- Performance benchmarking
- Test stability monitoring

## CI/CD Pipeline

### GitHub Actions (Trace: .github/workflows/)
- **update-oui.yml**: Weekly MAC database updates
- Automated testing on push/PR
- Build artifact generation

## Platform Specifics

### Android (Trace: android/)
- MinSDK: Flutter default (21)
- TargetSDK: Flutter default (34)
- CompileSDK: 36
- Kotlin: MainActivity.kt
- NDK Version: 27.0.12077973

### iOS (Trace: ios/)
- Swift: AppDelegate.swift
- CocoaPods integration
- Complete icon sets

## Security Features

### Credential Management (Trace: lib/services/credential_service.dart)
- API key validation
- Self-signed certificate support
- Secure storage via SharedPreferences

### Environment Security (Trace: lib/utils/environment_config.dart:103-108)
- API credentials configurable via environment
- Multiple data modes for testing
- Force offline mode support

## Known Issues

### Missing Components
- No code generation setup (*.g.dart files)
- No internationalization (*.arb files)
- No Docker configuration
- No explicit build flavors in Gradle

### Technical Debt
- Mixed architecture (views/ and features/)
- No structured error codes
- Limited offline capability implementation

## Development Patterns

### Code Organization
- Feature-first module structure
- Clean architecture layers
- Dependency injection
- Repository pattern
- Value objects for domain entities

### Testing Patterns
- TDD support with dedicated scripts
- Mock implementations for all external dependencies
- Fixture-based testing
- Performance benchmarking

## Entry Points

### Main Application (Trace: lib/main.dart)
- Primary entry point for production app
- Environment configuration initialization
- Sentry error tracking setup

### Test Utilities
- RUN_TDD_MODE.bat: TDD execution
- scripts/test-all.sh: Complete test suite
- test/test_runner.dart: Programmatic test execution

## Asset Management

### Data Files
- **mac_unified.csv**: Unified MAC address database
- **oui.csv**: IEEE OUI database
- Updated weekly via GitHub Actions

### UI Assets
- Complete icon sets for all platforms
- Screenshots for app stores
- Device type icons
- Connection state indicators

## Build & Deployment

### Build Commands
- Standard Flutter build commands
- Platform-specific build configurations
- Release signing configuration (Android)

### Deployment Targets
- Google Play Store (Android)
- Apple App Store (iOS)
- Web deployment
- Desktop distributions

## Quality Metrics

### Code Quality
- flutter_lints ^6.0.0 enforcement
- Analysis options configuration
- No custom lint rules

### Test Coverage
- 74 test files
- Unit, integration, and performance tests
- Quality gate validations

## Next Steps for Modernization

1. **Add Code Generation**: Setup build_runner with freezed/json_serializable
2. **Implement Flavors**: Development, staging, production
3. **Add Internationalization**: ARB files and l10n support
4. **Upgrade State Management**: Consider Riverpod or Bloc
5. **Implement Proper Navigation**: Migrate to go_router
6. **Add CI/CD**: Complete GitHub Actions pipeline
7. **Improve Error Handling**: Structured error codes and recovery
8. **Enhanced Offline Mode**: Complete offline-first architecture