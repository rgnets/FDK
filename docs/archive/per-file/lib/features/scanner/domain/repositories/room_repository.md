Path: lib/features/scanner/domain/repositories/room_repository.dart
Responsibility: Defines room data model and repository interface for room CRUD operations and device count tracking.
Public API:
  - class Room:
    - Constructor: Room({required int id, required String name, String? building/floor/roomNumber, bool isActive=true, int deviceCount=0, Map metadata}) (12-21)
    - Factory: fromApi(Map json) (24-35)
    - Method: toApi() -> Map (38-49)
    - Getter: displayName -> String (52-57)
  - abstract class RoomRepository:
    - getAllRooms() -> Future<List<Room>> (66)
    - getActiveRooms() -> Future<List<Room>> (69)
    - getById(int) -> Future<Room?> (72)
    - search(String query) -> Future<List<Room>> (75)
    - getRoomsByBuilding(String) -> Future<List<Room>> (78)
    - getRoomsByFloor(String) -> Future<List<Room>> (81)
    - createRoom(String name, {String? building/floor/roomNumber}) -> Future<Room> (84)
    - updateRoom(int id, {String? name/building/floor/roomNumber}) -> Future<Room> (87)
    - deactivateRoom(int) -> Future<void> (90)
    - activateRoom(int) -> Future<void> (93)
    - getDeviceCount(int roomId) -> Future<int> (96)
    - exists(int) -> Future<bool> (99)
State & Side-effects:
  - Room: immutable data holder, no side effects
  - RoomRepository: abstract interface, implementations handle actual data mutations
  - deviceCount field tracks associated devices (9, 19, 32, 46)
  - isActive flag for soft delete pattern (8, 18, 31, 45)
Imports/Exports:
  - No imports (self-contained)
  - Exports: Room class, RoomRepository interface
Lifecycle:
  - Init: Simple constructors, no special initialization
  - Dispose: No disposal needed for data classes
  - Interface: Implementations handle connection lifecycle
Routing/UI role: None - pure domain layer repository interface
Error handling:
  - No explicit error types defined
  - Interface methods return Future for async error propagation
  - Null returns indicate not found (72)
Performance notes:
  - All repository methods are async (Future return types)
  - Room.fromApi/toApi involve Map operations (24-49)
  - Search operations could be expensive depending on implementation (75)
Security notes:
  - No PII or sensitive data in room model
  - metadata Map could contain arbitrary data (10, 20, 33, 47)
  - No authorization defined at repository level
Tests touching this file: Unknown (would need to search test files)
Refactor suggestions:
  - Add explicit error types for room operations
  - Consider pagination for getAllRooms/search methods
  - Add batch operations for efficiency
  - Consider separating Room entity from API mapping
  - Add validation to Room.fromApi for required fields
Trace:
  - Room class: 2-58
  - Room.fromApi factory: 24-35
  - Room.toApi method: 38-49
  - displayName getter: 52-57
  - RoomRepository interface: 60-100