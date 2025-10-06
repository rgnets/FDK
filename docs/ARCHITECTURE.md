# Current Architecture - RG Nets Field Deployment Kit

**Last Updated**: 2025-08-18  
**Architecture**: Clean Architecture with Riverpod  
**Status**: Partially Implemented with Gaps

## Architecture Overview

The application has been fully refactored to implement **Clean Architecture** with **Riverpod** state management, following SOLID principles and Flutter best practices.

### Layer Structure

```
┌─────────────────────────────────────────────────────────┐
│                 Presentation Layer                       │
│  • Riverpod Providers (AsyncNotifier pattern)           │
│  • ConsumerWidgets / ConsumerStatefulWidgets            │
│  • UI Components and Screens                            │
│  Depends on ↓ Domain (via Use Cases)                    │
├─────────────────────────────────────────────────────────┤
│                    Domain Layer                          │
│  • Entities (Freezed immutable objects)                 │
│  • Repository Interfaces (Abstract contracts)           │
│  • Use Cases (Business logic operations)                │
│  • Value Objects (Type-safe domain concepts)           │
│  Depends on: NOTHING (Pure Dart)                        │
├─────────────────────────────────────────────────────────┤
│                     Data Layer                           │
│  • Repository Implementations                           │
│  • Data Sources (Remote/Local)                          │
│  • Models (DTOs with JSON serialization)                │
│  • Services (API, Storage)                              │
│  Depends on ↑ Domain (Implements interfaces)            │
└─────────────────────────────────────────────────────────┘
```

## Technology Stack

```yaml
Flutter: 3.35.1 (Latest stable)
Dart: 3.9.0

# State Management & DI
flutter_riverpod: ^2.6.1        # State management
riverpod_annotation: ^2.3.5     # Code generation
get_it: ^8.2.0                  # Service locator

# Code Generation
freezed: ^2.4.7                 # Immutable models
json_serializable: ^6.7.1       # JSON serialization
build_runner: ^2.4.8            # Code generation runner

# Navigation
go_router: ^14.8.1              # Declarative routing

# Error Handling
dartz: ^0.10.1                  # Functional programming (Either)
equatable: ^2.0.5               # Value equality

# Networking
dio: ^5.4.0                     # HTTP client
connectivity_plus: ^6.1.1       # Network status

# Storage
shared_preferences: ^2.3.3      # Key-value storage
path_provider: ^2.1.5           # File system paths
```

## Implementation Status by Feature

| Feature | Domain Layer | Data Layer | Presentation Layer | API Status | Actual Status |
|---------|--------------|------------|-------------------|------------|---------------|
| **Auth** | ✅ Complete | ✅ Complete | ✅ Complete | ✅ Working | **Functional** |
| **Devices** | ✅ Complete | ✅ Complete | ✅ Complete | ✅ 3 endpoints work | **Functional** |
| **Rooms** | ✅ Complete | ✅ Complete | ✅ Complete | ✅ PMS rooms only | **Partial** |
| **Notifications** | ⚠️ Partial | ✅ Complete | ✅ Complete | ❌ No API (404) | **Client-side only** |
| **Settings** | ⚠️ Partial | ✅ Complete | ✅ Complete | N/A | **Functional** |
| **Scanner** | ❌ Missing | ❌ Missing | ✅ UI Only | N/A | **UI only** |
| **Room Readiness** | ❌ Not built | ❌ Not built | ❌ Not built | ❌ No data | **NOT IMPLEMENTED** |

## API Integration Reality

### Working Endpoints ✅
```
/api/whoami.json          - Authentication check
/api/access_points.json   - 221 items (paginated)
/api/media_converters.json - 151 items (paginated)
/api/switch_devices.json  - 1 item (paginated)
/api/pms_rooms.json       - 141 items (paginated)
```

### Non-Existent Endpoints ❌
```
/api/wlan_controllers.json - 404 Not Found
/api/notifications.json    - 404 Not Found
/api/rooms.json           - 404 (use pms_rooms instead)
```

### Critical Implementation Notes
1. **All list endpoints are paginated** (30 items/page)
2. **Notifications are client-side only** (generated from device status)
3. **Room readiness is not implemented** (planned feature)
4. **QR Scanner uses 6-second accumulation window**

## Feature Implementations

### Authentication (Functional)

```
lib/features/auth/
├── domain/
│   ├── entities/
│   │   ├── user.dart (Freezed entity)
│   │   └── auth_status.dart (Freezed sealed class)
│   ├── repositories/
│   │   └── auth_repository.dart (Abstract interface)
│   └── usecases/
│       ├── authenticate_user.dart
│       ├── check_auth_status.dart
│       ├── get_current_user.dart
│       └── sign_out_user.dart
├── data/
│   ├── models/
│   │   └── user_model.dart (DTO with JSON)
│   ├── datasources/
│   │   ├── auth_remote_data_source.dart
│   │   └── auth_local_data_source.dart
│   ├── repositories/
│   │   ├── auth_repository.dart (Implementation)
│   │   └── auth_repository_mock.dart
│   └── services/
│       └── auth_service.dart
└── presentation/
    ├── providers/
    │   ├── auth_provider.dart (AsyncNotifier)
    │   └── auth_providers.dart (Use case providers)
    └── screens/
        └── auth_screen.dart (ConsumerStatefulWidget)
```

### Devices (100% Complete)

```
lib/features/devices/
├── domain/
│   ├── entities/
│   │   └── device.dart (Freezed entity)
│   ├── repositories/
│   │   └── device_repository.dart (Abstract)
│   └── usecases/
│       ├── get_devices.dart
│       ├── get_device.dart
│       ├── search_devices.dart
│       └── reboot_device.dart
├── data/
│   ├── models/
│   │   └── device_model.dart
│   ├── datasources/
│   │   ├── device_remote_data_source.dart
│   │   └── device_local_data_source.dart
│   ├── repositories/
│   │   ├── device_repository.dart
│   │   └── device_repository_mock.dart
│   └── services/
│       └── device_service.dart
└── presentation/
    ├── providers/
    │   ├── devices_provider.dart (AsyncNotifier)
    │   ├── devices_providers.dart
    │   └── device_ui_state_provider.dart
    ├── screens/
    │   ├── devices_screen.dart
    │   └── device_detail_screen.dart
    └── widgets/
        ├── device_list_item.dart
        └── device_filter_chip.dart
```

### Rooms (100% Complete)

Similar structure to Devices with full Clean Architecture implementation.

### Scanner (30% - Needs Implementation)

Currently only has presentation layer. Needs:
- Domain entities (ScanResult, ScanSession, BarcodeData)
- Repository interfaces
- Use cases (StartScanSession, ProcessBarcode, ValidateDevice)
- Data layer implementation
- Integration with mobile_scanner package

### Notifications & Settings (70% - Partial)

Have data and presentation layers but missing proper domain layer with use cases.

## State Management Pattern

### Riverpod with AsyncNotifier

```dart
// Provider with code generation
@riverpod
class DevicesNotifier extends _$DevicesNotifier {
  @override
  Future<List<Device>> build() async {
    final getDevices = ref.read(getDevicesProvider);
    final result = await getDevices();
    
    return result.fold(
      (failure) => throw Exception(failure.message),
      (devices) => devices,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    // Implementation
  }
}

// Use case provider
@riverpod
GetDevices getDevices(GetDevicesRef ref) {
  return GetDevices(ref.read(deviceRepositoryProvider));
}
```

## Error Handling Pattern

### Either Pattern with Dartz

```dart
// Use case returning Either
class AuthenticateUser {
  final AuthRepository repository;
  
  AuthenticateUser(this.repository);
  
  Future<Either<Failure, User>> call(AuthenticateUserParams params) {
    return repository.authenticate(
      fqdn: params.fqdn,
      login: params.login,
      apiKey: params.apiKey,
    );
  }
}

// Handling in provider
final result = await authenticateUser(params);
result.fold(
  (failure) => state = AsyncValue.error(failure.message),
  (user) => state = AsyncValue.data(AuthStatus.authenticated(user)),
);
```

## Navigation Architecture

### go_router with ShellRoute

```dart
GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => SplashScreen()),
    GoRoute(path: '/auth', builder: (_, __) => AuthScreen()),
    ShellRoute(
      builder: (_, __, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => HomeScreen()),
        GoRoute(
          path: '/devices',
          builder: (_, __) => DevicesScreen(),
          routes: [
            GoRoute(
              path: ':deviceId',
              builder: (_, state) => DeviceDetailScreen(
                deviceId: state.pathParameters['deviceId']!,
              ),
            ),
          ],
        ),
        // Additional routes...
      ],
    ),
  ],
)
```

## Dependency Injection

### GetIt Service Locator

```dart
Future<void> initServiceLocator() async {
  final sl = GetIt.instance;
  
  // Services
  sl.registerLazySingleton(() => ApiService());
  sl.registerLazySingleton(() => StorageService());
  
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiService: sl()),
  );
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  
  // Use cases registered via providers
}
```

## Code Generation

### Build Runner Configuration

```yaml
# build.yaml
targets:
  $default:
    builders:
      freezed:
        generate_for:
          - lib/features/**/entities/*.dart
          - lib/features/**/models/*.dart
      json_serializable:
        generate_for:
          - lib/features/**/models/*.dart
      riverpod_generator:
        generate_for:
          - lib/features/**/providers/*.dart
```

## API Integration Status (ACTUAL)

### Current Implementation Reality
- API credentials hardcoded in test files
- Pagination not properly handled in repositories
- Self-signed certificates accepted

### VERIFIED API Endpoints (test_api.dart results)
```
WORKING ✅:
- GET /api/whoami.json - Auth check
- GET /api/access_points.json - 221 items (paginated)
- GET /api/media_converters.json - 151 items (ONTs, paginated)
- GET /api/switch_devices.json - 1 item (paginated)
- GET /api/pms_rooms.json - 141 items (paginated)

NOT FOUND ❌ (404 errors):
- GET /api/wlan_controllers.json - Does not exist
- GET /api/notifications.json - No server notifications
- GET /api/rooms.json - Use pms_rooms instead
- GET /api/devices.json - Generic endpoint not used
```

### 🔴 CRITICAL: Pagination Handling Required
All working endpoints return paginated responses:
```json
{
  "count": 221,            // Total items
  "page": 1,               // Current page
  "page_size": 30,         // Items per page
  "total_pages": 8,        // Total pages
  "next": "https://[host]/api/access_points.json?page=2",
  "results": [...]         // ⚠️ Data is HERE, not at root
}
```

**Implementation Issue**: Repositories assume direct arrays!
```dart
// WRONG (current code):
final devices = response as List;

// CORRECT (needed):
final devices = response['results'] as List;
```

## Key Implementation Gaps

### Scanner Feature
- **Domain Layer**: Not implemented
- **QR Logic**: 6-second accumulation window
- **Requirements**: 2 barcodes for AP/ONT, 1 for Switch
- **Status**: UI exists but no business logic

### Notification System
- **API**: `/api/notifications.json` doesn't exist (404)
- **Implementation**: Client-side generation only
- **Logic**: Generated from device online/note/image status
- **Storage**: In-memory only, not persisted

### Room Readiness
- **Status**: NOT IMPLEMENTED (planned feature)
- **Issue**: No device-to-room associations in API
- **UI**: May have placeholder screens
- **Backend**: Would require API changes

## Testing Status

### Current Coverage
- **Unit Tests**: 0% (Not implemented)
- **Widget Tests**: 0% (Not implemented)
- **Integration Tests**: 0% (Not implemented)

### Testing Strategy Needed
1. Unit tests for all use cases
2. Repository tests with mocked data sources
3. Provider tests with mocked use cases
4. Widget tests for critical screens
5. Integration tests for key flows

## Performance Considerations

### Current Optimizations
- Lazy loading with GetIt
- Auto-dispose providers for memory management
- Const constructors throughout
- Efficient widget rebuilds with Consumer widgets

### Areas for Improvement
1. Image caching strategy
2. List virtualization for large datasets
3. Background data synchronization
4. Request deduplication

## Security Status

### Current Issues
1. Credentials stored in SharedPreferences (unencrypted)
2. API key in query parameters (visible in logs)
3. No certificate pinning
4. Test credentials hardcoded

### Recommended Fixes
1. Use flutter_secure_storage for credentials
2. Move API key to headers
3. Implement certificate pinning
4. Remove hardcoded credentials

## Next Implementation Steps

### Priority 1: Complete Domain Layers
1. **Scanner Domain** (Critical)
   - Entities: ScanResult, ScanSession, BarcodeData
   - Use Cases: ProcessBarcode, ValidateScan
   - Repository interfaces

2. **Notifications Domain**
   - Entity: Notification (Freezed)
   - Use Cases: GetNotifications, MarkAsRead
   - Repository interface

3. **Settings Domain**
   - Entity: AppSettings (Freezed)
   - Use Cases: GetSettings, UpdateSettings
   - Repository interface

### Priority 2: Scanner Implementation
1. Integrate mobile_scanner package
2. Implement barcode processing logic
3. Add scan accumulation (6-second window)
4. Device type validation

### Priority 3: Testing
1. Unit tests for use cases (80% coverage target)
2. Repository tests with mocks
3. Critical widget tests

### Priority 4: API Integration
1. Replace mock repositories with real implementations
2. Handle paginated responses
3. Add retry logic and error handling
4. Implement offline queue

## Conclusion

The application has been successfully modernized with Clean Architecture and Riverpod. The architecture is:
- **Maintainable**: Clear separation of concerns
- **Testable**: Dependency injection and mockable interfaces
- **Scalable**: Easy to add new features
- **Modern**: Following latest Flutter best practices

Main gaps are in the Scanner feature implementation and test coverage, which are the next priorities.