# Clean Architecture

This document explains the Clean Architecture implementation in the FDK Flutter application, including layer structure, dependency injection, use cases, repositories, and data flow patterns.

## Overview

The codebase follows a strict **three-layer Clean Architecture** with feature-based organization:

```
lib/
├── core/                         # Shared infrastructure
│   ├── config/                   # Environment configuration
│   ├── errors/                   # Failure hierarchy
│   ├── models/                   # Shared domain models
│   ├── navigation/               # Routing and deep linking
│   ├── providers/                # Global dependency injection
│   ├── services/                 # Singleton services
│   ├── usecases/                 # Base UseCase classes
│   ├── utils/                    # Shared utilities
│   └── widgets/                  # Reusable UI components
│
└── features/
    └── {feature}/
        ├── domain/               # Business logic (framework-independent)
        │   ├── entities/         # Pure domain objects
        │   ├── repositories/     # Abstract interfaces
        │   ├── services/         # Domain services
        │   └── usecases/         # Business logic encapsulation
        │
        ├── data/                 # Data access & transformation
        │   ├── datasources/      # Local/Remote/Mock implementations
        │   ├── models/           # DTOs with JSON serialization
        │   ├── repositories/     # Concrete implementations
        │   └── services/         # Data-specific services
        │
        └── presentation/         # UI & state management
            ├── providers/        # Riverpod notifiers
            ├── screens/          # Full-page widgets
            └── widgets/          # Feature-specific components
```

---

## Layer Responsibilities

### Domain Layer (Innermost)

**Location**: `lib/features/{feature}/domain/`

**Purpose**: Pure business logic independent of any framework or external dependency.

**Components**:

| Component | Purpose |
|-----------|---------|
| **Entities** | Immutable data objects representing business concepts |
| **Repositories** | Abstract interface contracts (no implementation) |
| **Use Cases** | Single-responsibility business operations |
| **Services** | Domain-level business services |

**Rules**:
- No imports from data or presentation layers
- No framework dependencies (Flutter, JSON, HTTP)
- Uses Freezed for immutability and pattern matching

### Data Layer (Middle)

**Location**: `lib/features/{feature}/data/`

**Purpose**: Data access, transformation, caching, and persistence.

**Components**:

| Component | Purpose |
|-----------|---------|
| **Data Sources** | Abstract interfaces + implementations (local, remote, mock) |
| **Models** | DTOs with JSON serialization (`@JsonKey`) |
| **Repositories** | Concrete implementations of domain interfaces |
| **Services** | Data-specific services (uploads, sync) |

**Rules**:
- Implements domain repository interfaces
- Handles all external communication (API, database, cache)
- Maps between Models and Entities

### Presentation Layer (Outermost)

**Location**: `lib/features/{feature}/presentation/`

**Purpose**: UI rendering, user interaction, and state management.

**Components**:

| Component | Purpose |
|-----------|---------|
| **Providers** | Riverpod state management (notifiers, computed) |
| **Screens** | Full-page widgets |
| **Widgets** | Reusable UI components |

**Rules**:
- Only interacts with domain layer (use cases, entities)
- Never directly accesses data sources
- Manages UI state via Riverpod

### Core Layer (Shared)

**Location**: `lib/core/`

**Purpose**: Shared utilities, services, and base classes used across features.

**Key Files**:

| File | Purpose |
|------|---------|
| `providers/core_providers.dart` | Logger, storage, event buses |
| `providers/repository_providers.dart` | All repository & data source DI |
| `providers/websocket_providers.dart` | WebSocket service & cache integration |
| `usecases/usecase.dart` | Base UseCase & Params classes |
| `errors/failures.dart` | Failure hierarchy for error handling |
| `config/environment.dart` | Environment-aware configuration |

---

## Dependency Flow

Dependencies flow **inward** only. Outer layers depend on inner layers, never the reverse.

```
┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                         │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ AuthNotifier (@Riverpod)                                  │  │
│  │  - Watches: authRepositoryProvider                        │  │
│  │  - Uses: AuthenticateUser use case                        │  │
│  │  - Manages: AuthStatus state                              │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↓ depends on
┌─────────────────────────────────────────────────────────────────┐
│                        DOMAIN LAYER                             │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ AuthenticateUser (UseCase)                                │  │
│  │  - Dependency: AuthRepository (abstract)                  │  │
│  │  - Input: AuthenticateUserParams                          │  │
│  │  - Output: Either<Failure, User>                          │  │
│  └───────────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ AuthRepository (Abstract Interface)                       │  │
│  │  - Defines: authenticate(), signOut(), getCurrentUser()   │  │
│  │  - Returns: Either<Failure, T>                            │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↓ implemented by
┌─────────────────────────────────────────────────────────────────┐
│                         DATA LAYER                              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ AuthRepositoryImpl                                        │  │
│  │  - Implements: AuthRepository interface                   │  │
│  │  - Dependencies: AuthLocalDataSource, MockDataService     │  │
│  │  - Handles: Caching, error mapping, data transformation   │  │
│  └───────────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ AuthLocalDataSource                                       │  │
│  │  - Storage: SharedPreferences                             │  │
│  │  - Caches: UserModel, credentials, session                │  │
│  │  - Handles: JSON serialization/deserialization            │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↓ uses
┌─────────────────────────────────────────────────────────────────┐
│                         CORE LAYER                              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ core_providers.dart                                       │  │
│  │  - StorageService, Logger, SharedPreferences              │  │
│  └───────────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │ repository_providers.dart                                 │  │
│  │  - Wires all dependencies via Riverpod                    │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Use Cases Pattern

Use cases encapsulate a single business operation with clear input/output contracts.

### Base Classes

**File**: `lib/core/usecases/usecase.dart`

```dart
/// Use case with parameters
abstract base class UseCase<T, P> {
  const UseCase();
  Future<Either<Failure, T>> call(P params);
}

/// Use case without parameters
abstract base class UseCaseNoParams<T> {
  const UseCaseNoParams();
  Future<Either<Failure, T>> call();
}

/// Base class for use case parameters
abstract class Params extends Equatable {
  const Params();
  @override
  List<Object?> get props => [];
}
```

### Example Implementation

**File**: `lib/features/auth/domain/usecases/authenticate_user.dart`

```dart
final class AuthenticateUser extends UseCase<User, AuthenticateUserParams> {
  AuthenticateUser(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(AuthenticateUserParams params) async {
    return repository.authenticate(
      fqdn: params.fqdn,
      login: params.login,
      token: params.token,
      siteName: params.siteName,
      issuedAt: params.issuedAt,
      signature: params.signature,
    );
  }
}

class AuthenticateUserParams extends Params {
  const AuthenticateUserParams({
    required this.fqdn,
    required this.login,
    required this.token,
    this.siteName,
    this.issuedAt,
    this.signature,
  });

  final String fqdn;
  final String login;
  final String token;
  final String? siteName;
  final DateTime? issuedAt;
  final String? signature;

  @override
  List<Object?> get props => [fqdn, login, token, siteName, issuedAt, signature];
}
```

### Usage in Presentation

**File**: `lib/features/auth/presentation/providers/auth_notifier.dart`

```dart
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  // Lazily create use case with repository dependency
  AuthenticateUser get _authenticateUser =>
      AuthenticateUser(ref.read(authRepositoryProvider));

  Future<void> authenticate({
    required String fqdn,
    required String login,
    required String token,
    String? siteName,
  }) async {
    state = const AsyncLoading();

    final params = AuthenticateUserParams(
      fqdn: fqdn,
      login: login,
      token: token,
      siteName: siteName,
    );

    final result = await _authenticateUser(params);

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (user) => AsyncData(AuthStatus.authenticated(user)),
    );
  }
}
```

---

## Repository Pattern

Repositories abstract data access, allowing the domain layer to remain independent of data sources.

### Abstract Repository (Domain Layer)

**File**: `lib/features/devices/domain/repositories/device_repository.dart`

```dart
abstract class DeviceRepository {
  /// Get all devices with optional field selection
  Future<Either<Failure, List<Device>>> getDevices({List<String>? fields});

  /// Get a single device by ID
  Future<Either<Failure, Device>> getDevice(
    String id, {
    List<String>? fields,
    bool forceRefresh = false,
  });

  /// Get devices filtered by room
  Future<Either<Failure, List<Device>>> getDevicesByRoom(String roomId);

  /// Update device properties
  Future<Either<Failure, Device>> updateDevice(Device device);

  /// Reboot a device
  Future<Either<Failure, void>> rebootDevice(String deviceId);

  /// Stream of device updates for real-time sync
  Stream<List<Device>> get devicesStream;
}
```

### Concrete Implementation (Data Layer)

**File**: `lib/features/devices/data/repositories/device_repository.dart`

```dart
class DeviceRepositoryImpl implements DeviceRepository {
  DeviceRepositoryImpl({
    required this.dataSource,
    required this.apLocalDataSource,
    required this.ontLocalDataSource,
    required this.switchLocalDataSource,
    required this.wlanLocalDataSource,
    required this.storageService,
    this.webSocketCacheIntegration,
  }) {
    _loadIdToTypeIndex();
    _initializePaginationService();
    _setupWebSocketListener();
  }

  final DeviceDataSource dataSource;
  final APLocalDataSource apLocalDataSource;
  final ONTLocalDataSource ontLocalDataSource;
  final SwitchLocalDataSource switchLocalDataSource;
  final WLANLocalDataSource wlanLocalDataSource;
  final StorageService storageService;
  final WebSocketCacheIntegration? webSocketCacheIntegration;

  @override
  Future<Either<Failure, List<Device>>> getDevices({List<String>? fields}) async {
    try {
      // 1. Try WebSocket cache first (real-time source)
      if (webSocketCacheIntegration != null) {
        final models = await webSocketCacheIntegration!.getAllCachedDeviceModels();
        if (models.isNotEmpty) {
          return Right(models.map((m) => m.toEntity()).toList());
        }
      }

      // 2. Fall back to typed local caches
      final cachedModels = await _getAllCachedDevices(allowStale: true);
      if (cachedModels.isNotEmpty) {
        return Right(cachedModels.map((m) => m.toEntity()).toList());
      }

      // 3. Fetch from remote data source
      final models = await dataSource.getDevices(fields: fields);
      await _cacheDevicesByType(models);
      return Right(models.map((m) => m.toEntity()).toList());

    } on Exception catch (e) {
      return Left(DeviceFailure(message: 'Failed to get devices: $e'));
    }
  }

  /// Aggregates devices from all typed caches
  Future<List<DeviceModelSealed>> _getAllCachedDevices({
    bool allowStale = false,
  }) async {
    final results = await Future.wait([
      apLocalDataSource.getCachedDevices(allowStale: allowStale),
      ontLocalDataSource.getCachedDevices(allowStale: allowStale),
      switchLocalDataSource.getCachedDevices(allowStale: allowStale),
      wlanLocalDataSource.getCachedDevices(allowStale: allowStale),
    ]);
    return [...results[0], ...results[1], ...results[2], ...results[3]];
  }
}
```

---

## Entity vs Model Separation

Entities and Models serve different purposes and belong to different layers.

### Domain Entity

**File**: `lib/features/auth/domain/entities/user.dart`

```dart
@freezed
class User with _$User {
  const factory User({
    required String username,
    required String siteUrl,
    String? displayName,
    String? email,
  }) = _User;
}
```

**Characteristics**:
- Pure business object
- No JSON serialization
- No framework dependencies
- Uses Freezed for immutability

### Data Model

**File**: `lib/features/auth/data/models/user_model.dart`

```dart
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String username,
    @JsonKey(name: 'site_url') required String siteUrl,
    @JsonKey(name: 'display_name') String? displayName,
    String? email,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

/// Extension for mapping to domain entity
extension UserModelX on UserModel {
  User toEntity() {
    return User(
      username: username,
      siteUrl: siteUrl,
      displayName: displayName,
      email: email,
    );
  }
}
```

**Characteristics**:
- Data Transfer Object (DTO)
- JSON serialization via `@JsonKey`
- Handles API field name mapping (snake_case to camelCase)
- Provides `toEntity()` mapper

### Comparison

| Aspect | Entity (Domain) | Model (Data) |
|--------|-----------------|--------------|
| Location | `domain/entities/` | `data/models/` |
| JSON support | No | Yes (`fromJson`, `toJson`) |
| Framework deps | None | json_serializable |
| Field naming | camelCase | Maps to API (snake_case) |
| Purpose | Business logic | Data transfer |

---

## Sealed Union Types

For polymorphic data (like device types), Freezed sealed unions provide type safety.

**File**: `lib/features/devices/data/models/device_model_sealed.dart`

```dart
@Freezed(unionKey: 'device_type')
sealed class DeviceModelSealed with _$DeviceModelSealed {

  @FreezedUnionValue('access_point')
  const factory DeviceModelSealed.ap({
    required String id,
    required String name,
    String? status,
    // AP-specific fields
    @JsonKey(name: 'signal_strength') int? signalStrength,
    @JsonKey(name: 'connected_clients') int? connectedClients,
    String? ssid,
    int? channel,
  }) = APModel;

  @FreezedUnionValue('ont')
  const factory DeviceModelSealed.ont({
    required String id,
    required String name,
    String? status,
    // ONT-specific fields
    String? uptime,
    @JsonKey(name: 'is_registered') bool? isRegistered,
  }) = ONTModel;

  @FreezedUnionValue('switch')
  const factory DeviceModelSealed.switch_({
    required String id,
    required String name,
    String? status,
    // Switch-specific fields
    @JsonKey(name: 'port_count') int? portCount,
  }) = SwitchModel;

  @FreezedUnionValue('wlan')
  const factory DeviceModelSealed.wlan({
    required String id,
    required String name,
    String? status,
    // WLAN-specific fields
    @JsonKey(name: 'controller_ip') String? controllerIp,
  }) = WLANModel;

  factory DeviceModelSealed.fromJson(Map<String, dynamic> json) =>
      _$DeviceModelSealedFromJson(json);
}

/// Extension for mapping to domain entity
extension DeviceModelSealedX on DeviceModelSealed {
  Device toEntity() {
    return when(
      ap: (id, name, status, signalStrength, connectedClients, ssid, channel) =>
          Device(
            id: id,
            name: name,
            type: DeviceType.accessPoint,
            status: status,
            signalStrength: signalStrength,
            connectedClients: connectedClients,
            ssid: ssid,
            channel: channel,
          ),
      ont: (id, name, status, uptime, isRegistered) =>
          Device(
            id: id,
            name: name,
            type: DeviceType.ont,
            status: status,
            uptime: int.tryParse(uptime ?? '0'),
            isRegistered: isRegistered,
          ),
      switch_: (id, name, status, portCount) =>
          Device(
            id: id,
            name: name,
            type: DeviceType.switch_,
            status: status,
            portCount: portCount,
          ),
      wlan: (id, name, status, controllerIp) =>
          Device(
            id: id,
            name: name,
            type: DeviceType.wlan,
            status: status,
            controllerIp: controllerIp,
          ),
    );
  }
}
```

---

## Dependency Injection with Riverpod

### Provider Wiring

**File**: `lib/core/providers/repository_providers.dart`

```dart
// Data Source Providers
final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthLocalDataSource(prefs);
});

final deviceDataSourceProvider = Provider<DeviceDataSource>((ref) {
  // Environment-aware selection
  if (EnvironmentConfig.isDevelopment) {
    return ref.watch(deviceMockDataSourceProvider);
  }

  return DeviceWebSocketDataSource(
    webSocketCacheIntegration: ref.watch(webSocketCacheIntegrationProvider),
    imageBaseUrl: ref.watch(storageServiceProvider).siteUrl,
    logger: LoggerConfig.getLogger(),
  );
});

// Repository Providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    localDataSource: ref.watch(authLocalDataSourceProvider),
    mockDataService: ref.watch(mockDataServiceProvider),
  );
});

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepositoryImpl(
    dataSource: ref.watch(deviceDataSourceProvider),
    apLocalDataSource: ref.watch(apLocalDataSourceProvider),
    ontLocalDataSource: ref.watch(ontLocalDataSourceProvider),
    switchLocalDataSource: ref.watch(switchLocalDataSourceProvider),
    wlanLocalDataSource: ref.watch(wlanLocalDataSourceProvider),
    storageService: ref.watch(storageServiceProvider),
    webSocketCacheIntegration: ref.watch(webSocketCacheIntegrationProvider),
  );
});
```

### Provider Graph

```
sharedPreferencesProvider
         │
         ▼
authLocalDataSourceProvider ────────────┐
         │                              │
         ▼                              ▼
mockDataServiceProvider ────────► authRepositoryProvider
                                        │
                                        ▼
                                 authProvider (Notifier)
```

---

## Error Handling

### Failure Hierarchy

**File**: `lib/core/errors/failures.dart`

```dart
abstract class Failure extends Equatable {
  const Failure({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

// Feature-specific failures
class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.statusCode});
}

class DeviceFailure extends Failure {
  const DeviceFailure({required super.message, super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.statusCode});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.statusCode});
}
```

### Either-Based Results

All operations return `Either<Failure, T>` for explicit error handling:

```dart
// In repository
Future<Either<Failure, User>> authenticate(...) async {
  try {
    final model = await dataSource.authenticate(...);
    return Right(model.toEntity());
  } on AuthException catch (e) {
    return Left(AuthFailure(message: e.message));
  } on Exception catch (e) {
    return Left(AuthFailure(message: 'Unexpected error: $e'));
  }
}

// In presentation
final result = await authenticateUser(params);

result.fold(
  (failure) => state = AsyncError(failure, StackTrace.current),
  (user) => state = AsyncData(AuthStatus.authenticated(user)),
);
```

---

## State Management with Freezed

### Union States for UI

```dart
@freezed
class AuthStatus with _$AuthStatus {
  const factory AuthStatus.unauthenticated() = _Unauthenticated;
  const factory AuthStatus.authenticating() = _Authenticating;
  const factory AuthStatus.authenticated(User user) = _Authenticated;
  const factory AuthStatus.failure(String message) = _Failure;
}

// Exhaustive pattern matching in UI
Widget build(BuildContext context) {
  final authStatus = ref.watch(authProvider);

  return authStatus.when(
    unauthenticated: () => const AuthScreen(),
    authenticating: () => const LoadingScreen(),
    authenticated: (user) => HomeScreen(user: user),
    failure: (message) => ErrorScreen(message: message),
  );
}
```

---

## Environment Configuration

**File**: `lib/core/config/environment.dart`

```dart
enum Environment { development, staging, production }

class EnvironmentConfig {
  static late Environment _environment;
  static late bool _useSyntheticData;

  static void initialize({
    required Environment environment,
    bool useSyntheticData = false,
  }) {
    _environment = environment;
    _useSyntheticData = useSyntheticData;
  }

  static bool get isDevelopment => _environment == Environment.development;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.production;

  static bool get useSyntheticData => isDevelopment && _useSyntheticData;

  static String get websocketBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'ws://localhost:3000/cable';
      case Environment.staging:
        return 'wss://staging.example.com/cable';
      case Environment.production:
        return 'wss://api.example.com/cable';
    }
  }
}
```

---

## Features

| Feature | Description | Key Components |
|---------|-------------|----------------|
| `auth` | Authentication with WebSocket handshake | User entity, AuthRepository, AuthNotifier |
| `devices` | Device management (4 types) | Sealed union models, typed caches, real-time sync |
| `rooms` | Room/zone management | RoomRepository, RoomsNotifier |
| `speed_test` | Network performance testing | SpeedTestConfigs, Results, RunNotifier |
| `notifications` | Push notifications | NotificationRepository, permission handling |
| `home` | Dashboard | Aggregated stats, health notices |
| `settings` | App configuration | User preferences, theme |
| `scanner` | Device scanning | QR/barcode scanning |
| `issues` | Health/issue reporting | Issue tracking, resolution |
| `initialization` | App startup | Dependency initialization |
| `onboarding` | First-time user setup | Welcome flow |
| `splash` | Splash screen | Initial loading |

---

## Key Files Reference

| File | Purpose |
|------|---------|
| `lib/core/providers/core_providers.dart` | Logger, storage, event buses |
| `lib/core/providers/repository_providers.dart` | Repository & data source DI |
| `lib/core/providers/websocket_providers.dart` | WebSocket service & cache |
| `lib/core/usecases/usecase.dart` | Base UseCase & Params |
| `lib/core/errors/failures.dart` | Failure hierarchy |
| `lib/core/config/environment.dart` | Environment configuration |
| `lib/core/services/storage_service.dart` | Persistent storage |
| `lib/core/services/cache_manager.dart` | Stale-while-revalidate cache |

---

## Best Practices

1. **Layer Isolation**: Domain layer has zero external dependencies
2. **Dependency Inversion**: Repositories are abstract in domain, implemented in data
3. **Single Responsibility**: Each use case handles one business operation
4. **Explicit Errors**: Use `Either<Failure, T>` instead of throwing exceptions
5. **Immutability**: All entities and models use Freezed
6. **Type Safety**: Sealed unions for polymorphic data
7. **Environment Awareness**: Data sources swap based on environment
8. **Reactive State**: Riverpod providers auto-rebuild on dependency changes
