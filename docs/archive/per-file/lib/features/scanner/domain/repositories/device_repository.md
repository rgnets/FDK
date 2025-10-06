Path: lib/features/scanner/domain/repositories/device_repository.dart
Responsibility: Defines device data models and repository interface for device CRUD operations and room assignments.
Public API:
  - class Device:
    - Constructor: Device({required String id, String? mac/serialNumber/partNumber, required DeviceType type, String? name, int? roomId, String? roomName, bool isOnboarded=false, Map metadata}) (16-27)
    - Factory: fromApi(Map json, DeviceType type) (30-43)
    - Method: toApi() -> Map (46-59)
  - class DeviceRegistration:
    - Constructor: DeviceRegistration({required ScanData, int? roomId, String? notes, Map additionalData}) (82-87)
    - Method: toApi() -> Map (90-104)
  - class RepositoryException extends Exception (108-116)
  - abstract class DeviceRepository:
    - findByMac(String) -> Future<Device?> (124)
    - findBySerial(String) -> Future<Device?> (127)
    - findByPartNumber(String) -> Future<Device?> (130)
    - search(String) -> Future<Device?> (133)
    - register(DeviceRegistration) -> Future<Device> (136)
    - updateRoom(String deviceId, int roomId) -> Future<Device> (139)
    - moveDevice(String deviceId, int newRoomId) -> Future<Device> (142)
    - getDevicesInRoom(int roomId) -> Future<List<Device>> (145)
    - getById(String) -> Future<Device?> (148)
    - exists(String) -> Future<bool> (151)
    - delete(String) -> Future<void> (154)
State & Side-effects:
  - Device: immutable data holder, no side effects
  - DeviceRegistration: immutable data holder for registration payload
  - RepositoryException: exception type for error propagation
  - DeviceRepository: abstract interface, implementations handle actual data mutations
Imports/Exports:
  - Imports: scan_data entity (1) for ScanData and DeviceType
  - Exports: Device, DeviceRegistration, RepositoryException, DeviceRepository interface
Lifecycle:
  - Init: Simple constructors, no special initialization
  - Dispose: No disposal needed for data classes
  - Interface: Implementations handle connection lifecycle
Routing/UI role: None - pure domain layer repository interface
Error handling:
  - RepositoryException class for domain-specific errors (108-116)
  - Interface methods return Future for async error propagation
  - Null returns indicate not found (124, 127, 130, 133, 148)
Performance notes:
  - All repository methods are async (Future return types)
  - Device.fromApi/toApi involve Map operations (30-59)
  - No caching defined at interface level
Security notes:
  - MAC addresses and serial numbers are device identifiers
  - No authentication/authorization at repository level
  - metadata Map could contain sensitive data (14, 26, 41, 57)
Tests touching this file: Unknown (would need to search test files)
Refactor suggestions:
  - Consider Result<T, Error> pattern instead of exceptions
  - Add repository method for batch operations
  - Consider separating Device entity from API mapping logic
  - Add validation to Device.fromApi for required fields
Trace:
  - Device class: 4-73
  - Device.fromApi factory: 30-43
  - Device.toApi method: 46-59
  - DeviceRegistration class: 76-105
  - RepositoryException: 108-116
  - DeviceRepository interface: 118-155