# Clean Architecture Implementation Plan

## Current Structure (WRONG) ❌
```
lib/features/devices/
├── data/
│   ├── models/         # Domain entities mixed with DTOs
│   ├── repositories/   # Concrete implementations only
│   └── services/       # Direct API calls
└── presentation/
    ├── providers/      # Directly uses repositories
    └── screens/        # UI
```

## Correct Clean Architecture ✅
```
lib/features/devices/
├── domain/
│   ├── entities/       # Pure business objects
│   ├── repositories/   # Abstract interfaces
│   └── usecases/       # Business logic
├── data/
│   ├── models/         # DTOs for API/DB
│   ├── datasources/    # API/Local data sources
│   └── repositories/   # Concrete implementations
└── presentation/
    ├── providers/      # Uses use cases ONLY
    └── screens/        # UI
```

## Example Implementation:

### 1. Domain Layer (Independent)
```dart
// domain/entities/device.dart
class Device {
  final String id;
  final String name;
  final DeviceStatus status;
  // Pure business entity - no JSON, no external dependencies
}

// domain/repositories/device_repository.dart
abstract class IDeviceRepository {
  Future<List<Device>> getDevices();
  Future<Device> getDevice(String id);
  Future<void> updateDevice(Device device);
}

// domain/usecases/get_devices.dart
class GetDevicesUseCase {
  final IDeviceRepository repository;
  
  GetDevicesUseCase(this.repository);
  
  Future<List<Device>> call() async {
    final devices = await repository.getDevices();
    // Business logic here: filtering, sorting, validation
    return devices.where((d) => d.isValid).toList();
  }
}
```

### 2. Data Layer (Implements Domain)
```dart
// data/models/device_model.dart
class DeviceModel extends Device {
  DeviceModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  
  Device toDomain() => Device(...);
  static DeviceModel fromDomain(Device device);
}

// data/datasources/device_remote_datasource.dart
abstract class IDeviceRemoteDataSource {
  Future<List<DeviceModel>> fetchDevices();
}

class DeviceRemoteDataSource implements IDeviceRemoteDataSource {
  final ApiService apiService;
  
  Future<List<DeviceModel>> fetchDevices() async {
    final response = await apiService.get('/devices');
    return response.map((json) => DeviceModel.fromJson(json)).toList();
  }
}

// data/repositories/device_repository_impl.dart
class DeviceRepositoryImpl implements IDeviceRepository {
  final IDeviceRemoteDataSource remoteDataSource;
  final IDeviceLocalDataSource localDataSource;
  
  Future<List<Device>> getDevices() async {
    try {
      final models = await remoteDataSource.fetchDevices();
      await localDataSource.cacheDevices(models);
      return models.map((m) => m.toDomain()).toList();
    } catch (e) {
      final cached = await localDataSource.getCachedDevices();
      return cached.map((m) => m.toDomain()).toList();
    }
  }
}
```

### 3. Presentation Layer (Uses Domain Only)
```dart
// presentation/providers/devices_provider.dart
class DevicesProvider extends ChangeNotifier {
  final GetDevicesUseCase getDevicesUseCase;
  final UpdateDeviceUseCase updateDeviceUseCase;
  
  // Provider doesn't know about repositories or data sources!
  DevicesProvider({
    required this.getDevicesUseCase,
    required this.updateDeviceUseCase,
  });
  
  Future<void> loadDevices() async {
    final devices = await getDevicesUseCase();
    // Update UI state
  }
}
```

## Dependency Injection Fix:
```dart
// di/injection.dart
void configureDependencies() {
  // Data Sources
  sl.registerLazySingleton<IDeviceRemoteDataSource>(
    () => DeviceRemoteDataSource(sl()),
  );
  
  // Repositories
  sl.registerLazySingleton<IDeviceRepository>(
    () => DeviceRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );
  
  // Use Cases
  sl.registerFactory(() => GetDevicesUseCase(sl()));
  
  // Providers
  sl.registerFactory(() => DevicesProvider(
    getDevicesUseCase: sl(),
    updateDeviceUseCase: sl(),
  ));
}
```

## Benefits of Proper Clean Architecture:

1. **Testability**: Can test business logic without UI or API
2. **Flexibility**: Can swap data sources (API → GraphQL) without touching business logic
3. **Maintainability**: Clear separation of concerns
4. **Scalability**: Easy to add new features without breaking existing ones
5. **Team Work**: Different teams can work on different layers

## Migration Steps:

1. Create domain layer with entities and repository interfaces
2. Create use cases for all business operations
3. Move models to data layer and create mappers
4. Implement repository interfaces in data layer
5. Refactor providers to use use cases only
6. Update dependency injection