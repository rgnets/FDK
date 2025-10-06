# Complete Clean Architecture Implementation Plan

## Core Principles We Will Follow

1. **Dependency Rule**: Dependencies only point inward. Domain knows nothing about outer layers.
2. **Abstraction Rule**: Inner layers define interfaces, outer layers implement them.
3. **Independence Rule**: Business logic is independent of UI, Database, Framework.

## Layer Structure

```
┌─────────────────────────────────────────────────────────┐
│ Presentation Layer (Widgets, Screens, Providers)        │
│   Depends on ↓ (Uses Use Cases)                         │
├─────────────────────────────────────────────────────────┤
│ Domain Layer (Entities, Use Cases, Repository Interfaces)│
│   Depends on: NOTHING (Pure Dart)                       │
├─────────────────────────────────────────────────────────┤
│ Data Layer (Implementations, APIs, Mappers)             │
│   Depends on ↑ (Implements Domain Interfaces)           │
└─────────────────────────────────────────────────────────┘
```

## Detailed Implementation for Each Feature

### Example: Devices Feature

#### 1. DOMAIN LAYER (Pure Business Logic)
```
lib/features/devices/domain/
├── entities/
│   ├── device.dart           # Pure entity
│   └── device_status.dart    # Enum/value object
├── repositories/
│   └── device_repository.dart # Abstract interface
├── usecases/
│   ├── get_all_devices.dart
│   ├── get_device_by_id.dart
│   ├── update_device_status.dart
│   └── register_device.dart
└── failures/
    └── device_failures.dart   # Domain-specific errors
```

#### 2. DATA LAYER (Implementation Details)
```
lib/features/devices/data/
├── models/
│   └── device_model.dart     # DTO with fromJson/toJson
├── datasources/
│   ├── device_remote_datasource.dart  # API calls
│   └── device_local_datasource.dart   # Local storage
├── repositories/
│   └── device_repository_impl.dart    # Implements domain interface
└── mappers/
    └── device_mapper.dart     # Model <-> Entity conversion
```

#### 3. PRESENTATION LAYER (UI & State)
```
lib/features/devices/presentation/
├── providers/
│   └── devices_provider.dart  # Uses use cases ONLY
├── screens/
│   ├── devices_screen.dart
│   └── device_detail_screen.dart
└── widgets/
    └── device_list_item.dart
```

## Implementation Order

### Phase 1: Domain Layer (Pure Dart, No Dependencies)
1. Create entities (pure data classes)
2. Define repository interfaces (abstract classes)
3. Implement use cases (one per business operation)
4. Define failure types

### Phase 2: Data Layer (Implements Domain)
1. Create models (DTOs with JSON serialization)
2. Create mappers (Model <-> Entity)
3. Implement datasources (API, Local)
4. Implement repositories (concrete classes)

### Phase 3: Presentation Layer (Uses Domain)
1. Refactor providers to use use cases
2. Remove all data layer imports
3. Update dependency injection

## Concrete Example: Device Entity

```dart
// domain/entities/device.dart
class Device {
  final String id;
  final String name;
  final String type;
  final DeviceStatus status;
  final String ipAddress;
  final String macAddress;
  final DateTime lastSeen;
  
  const Device({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    required this.ipAddress,
    required this.macAddress,
    required this.lastSeen,
  });
  
  // Business logic methods
  bool get isOnline => status == DeviceStatus.online;
  bool get needsAttention => status == DeviceStatus.warning || status == DeviceStatus.error;
}

// domain/repositories/device_repository.dart
abstract class DeviceRepository {
  Future<Either<Failure, List<Device>>> getAllDevices();
  Future<Either<Failure, Device>> getDeviceById(String id);
  Future<Either<Failure, void>> updateDevice(Device device);
}

// domain/usecases/get_all_devices.dart
class GetAllDevices {
  final DeviceRepository repository;
  
  GetAllDevices(this.repository);
  
  Future<Either<Failure, List<Device>>> call() {
    return repository.getAllDevices();
  }
}
```

## Questions I Need Answered Before Starting:

1. **Error Handling**: Should we use Either<Failure, Success> pattern (like dartz) or throw exceptions?
   
2. **State Management**: Keep Provider or switch to Riverpod/Bloc for better separation?

3. **Code Generation**: Should we use freezed for entities and json_serializable for models?

4. **Feature Scope**: Which features should we refactor first?
   - [ ] Auth
   - [ ] Devices  
   - [ ] Rooms
   - [ ] Scanner
   - [ ] All at once

5. **Testing**: Should we write tests as we refactor each layer?

6. **Migration Strategy**: 
   - Option A: Refactor everything, then test
   - Option B: Refactor feature by feature with tests
   - Option C: Create new structure parallel to old, then switch

7. **Mock Data**: Should mock data be:
   - In data layer as a MockDataSource
   - In a separate testing package
   - Removed completely until we have real API

## File Naming Conventions:

- Entities: `device.dart` (singular)
- Models: `device_model.dart` 
- Use Cases: `get_all_devices.dart` (verb_noun)
- Repositories: `device_repository.dart` (abstract)
- Implementations: `device_repository_impl.dart`
- Providers: `devices_provider.dart` (plural)

## Dependency Injection Structure:

```dart
// Injectable annotations approach
@module
abstract class DataModule {
  @lazySingleton
  DeviceRepository get deviceRepository => DeviceRepositoryImpl(
    remoteDataSource: getIt(),
    localDataSource: getIt(),
  );
}

@module  
abstract class DomainModule {
  @injectable
  GetAllDevices get getAllDevices => GetAllDevices(getIt());
}
```

## What We Will NOT Do:
- Mix layers
- Import data layer in presentation
- Put business logic in widgets
- Use models in domain layer
- Make domain depend on Flutter/packages