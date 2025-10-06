# Dependency Analysis - RG Nets Field Deployment Kit

**Generated**: 2025-08-17
**Trace Source**: pubspec.yaml, pubspec.lock

## Direct Dependencies

### Core Flutter
| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| flutter | SDK | Core framework | All UI components |
| cupertino_icons | ^1.0.8 | iOS-style icons | iOS UI elements |

### Scanning & Camera
| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| mobile_scanner | ^7.0.1 | Barcode/QR scanning | lib/features/scanner/presentation/camera/camera_adapter.dart |
| image_picker | ^1.1.2 | Image selection | Not currently used in codebase |

### Networking & Connectivity
| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| http | ^1.2.2 | HTTP client | lib/rxg_api/*, lib/services/rxg_http_client.dart |
| connectivity_plus | ^6.1.1 | Network state monitoring | lib/core/connection/connection_manager.dart |

### Storage & Persistence
| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| shared_preferences | ^2.3.3 | Key-value storage | lib/utils/shared_prefs*.dart, credential storage |
| path_provider | ^2.1.5 | File system paths | lib/core/offline/offline_manager.dart |
| csv | ^6.0.0 | CSV parsing | MAC database processing |

### State Management & DI
| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| provider | ^6.1.5 | State management | lib/features/scanner/presentation/providers/scanner_provider.dart |
| get_it | ^8.2.0 | Service locator | lib/features/scanner/di/scanner_injection.dart |

### Utilities & Core
| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| equatable | ^2.0.5 | Value equality | Domain entities |
| collection | ^1.18.0 | Collection utilities | Data processing |
| async | ^2.13.0 | Async utilities | Async operations |
| mutex | ^3.1.0 | Mutual exclusion | Thread-safe operations |
| synchronized | ^3.4.0 | Synchronized execution | Critical sections |

### Platform & Device
| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| permission_handler | ^12.0.0+1 | Permission management | Camera, storage permissions |
| device_info_plus | ^11.5.0 | Device information | Telemetry, debugging |
| package_info_plus | ^8.3.0 | App package info | Version display, telemetry |

### UI Components
| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| dropdown_search | ^6.0.2 | Searchable dropdown | Device selection UI |

### Error Tracking & Monitoring
| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| sentry_flutter | ^9.3.0 | Error tracking | lib/main.dart, error reporting |

## Development Dependencies

### Testing
| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| flutter_test | SDK | Testing framework | All test files |
| mockito | ^5.4.4 | Mock generation | Test mocks |
| network_image_mock | ^2.1.1 | Network image mocking | Widget tests |
| fake_async | ^1.3.1 | Fake async zone | Async tests |
| test | ^1.25.15 | Test runner | Test execution |

### Code Quality
| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| flutter_lints | ^6.0.0 | Lint rules | analysis_options.yaml |
| build_runner | ^2.4.11 | Code generation | Not currently used |

### Utilities
| Package | Version | Purpose | Used In |
|---------|---------|---------|---------|
| args | ^2.7.0 | CLI arguments | Script utilities |

## Transitive Dependencies (Key)

### HTTP & Networking
- **http_parser**: HTTP header parsing
- **typed_data**: Typed data lists
- **web_socket**: WebSocket support

### Platform Channels
- **plugin_platform_interface**: Plugin interfaces
- **flutter_web_plugins**: Web plugin support

### File System
- **path**: Path manipulation
- **file**: File system abstraction
- **xdg_directories**: Linux directory standards

### Async & Streams
- **stream_channel**: Stream utilities
- **async**: Additional async primitives

## Dependency Usage Map

### Scanner Feature Dependencies
```
mobile_scanner (camera scanning)
├── camera_adapter.dart
├── scanner_screen.dart
└── barcode_validator.dart

provider (state management)
├── scanner_provider.dart
└── scanner_screen.dart

get_it (dependency injection)
└── scanner_injection.dart
```

### API Layer Dependencies
```
http (network requests)
├── rxg_api.dart
├── rxg_api_adapter.dart
├── rxg_api_resilient.dart
└── rxg_http_client.dart

connectivity_plus (network monitoring)
└── connection_manager.dart
```

### Storage Layer Dependencies
```
shared_preferences (key-value storage)
├── shared_prefs.dart
├── shared_prefs_wrapper.dart
└── credential_service.dart

path_provider (file paths)
└── offline_manager.dart
```

## Version Constraints

### Flutter SDK
- **Minimum**: ^3.5.4
- **Dart SDK**: Inferred >=3.0.0 <4.0.0

### Android
- **minSdkVersion**: Flutter default (21)
- **targetSdkVersion**: Flutter default (34)
- **compileSdkVersion**: 36

### iOS
- **Minimum iOS Version**: 12.0 (inferred from dependencies)

## Security Considerations

### Network Security
- **http**: Supports HTTPS, self-signed certificates handled
- **sentry_flutter**: Sends crash reports to external service

### Storage Security
- **shared_preferences**: Not encrypted, visible to user
- **Credentials**: Stored in SharedPreferences (security risk)

## Performance Implications

### Heavy Dependencies
- **mobile_scanner**: Camera processing overhead
- **sentry_flutter**: Background error reporting

### Optimization Opportunities
- **build_runner**: Not utilized for code generation
- **image_picker**: Imported but unused

## Missing Dependencies for Modern Flutter

### Code Generation
- ❌ **freezed**: Immutable models
- ❌ **json_serializable**: JSON serialization
- ❌ **freezed_annotation**: Freezed annotations

### State Management (Alternative)
- ❌ **flutter_bloc**: BLoC pattern
- ❌ **riverpod**: Modern provider alternative

### Navigation
- ❌ **go_router**: Declarative routing
- ❌ **auto_route**: Generated routing

### Testing
- ❌ **golden_toolkit**: Golden tests
- ❌ **integration_test**: Official integration testing

### Localization
- ❌ **flutter_localizations**: i18n support
- ❌ **intl**: Internationalization

## Dependency Health

### Update Candidates
All dependencies are using recent versions compatible with Flutter 3.5.4.

### Deprecated Packages
None detected.

### Security Vulnerabilities
No known vulnerabilities in current versions.

## Recommendations

### Immediate Actions
1. **Remove unused**: image_picker (imported but not used)
2. **Security**: Move credentials from SharedPreferences to secure storage
3. **Activate build_runner**: For code generation

### Modernization Path
1. **Add freezed + json_serializable**: For models
2. **Consider Riverpod**: Modern state management
3. **Add go_router**: Better navigation
4. **Add flutter_localizations**: i18n support
5. **Add integration_test**: Official integration testing

### Performance Optimizations
1. **Lazy load heavy dependencies**: mobile_scanner only when needed
2. **Configure Sentry**: Reduce reporting in debug mode
3. **Optimize imports**: Remove unused packages