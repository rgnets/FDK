import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'room_filter_provider.g.dart';

/// State for device room filtering
class RoomFilterState {
  const RoomFilterState({this.selectedRoom = allRooms});

  /// Special value indicating no filter (show all rooms)
  static const String allRooms = 'All Rooms';

  /// Currently selected room filter
  final String selectedRoom;

  /// Returns true if actively filtering (not showing all)
  bool get isFiltering => selectedRoom != allRooms;

  /// Check if a device's room matches the current filter
  bool matchesFilter(String? deviceRoom) {
    if (!isFiltering) {
      return true; // Show all when not filtering
    }

    if (deviceRoom == null || deviceRoom.trim().isEmpty) {
      return false; // No match for null/empty room when filtering
    }

    return deviceRoom.trim().toLowerCase() == selectedRoom.toLowerCase();
  }

  /// Create a copy with updated values
  RoomFilterState copyWith({String? selectedRoom}) {
    return RoomFilterState(
      selectedRoom: selectedRoom ?? this.selectedRoom,
    );
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoomFilterState &&
          runtimeType == other.runtimeType &&
          selectedRoom == other.selectedRoom;

  @override
  int get hashCode => selectedRoom.hashCode;
}

/// Notifier for managing room filter state with persistence
@riverpod
class RoomFilterNotifier extends _$RoomFilterNotifier {
  StorageService? _storageService;

  @override
  RoomFilterState build() {
    // Try to get storage service from provider
    try {
      _storageService = ref.watch(storageServiceProvider);
    } on Object {
      // Storage service not available yet (e.g., during tests without override)
      _storageService = null;
    }

    // Load saved room synchronously from storage
    final savedRoom = _storageService?.roomFilter;
    if (savedRoom != null && savedRoom.isNotEmpty) {
      return RoomFilterState(selectedRoom: savedRoom);
    }
    return const RoomFilterState();
  }

  /// Set the selected room filter
  void setRoom(String room) {
    if (state.selectedRoom == room) {
      return;
    }
    state = state.copyWith(selectedRoom: room);
    _saveRoom(room);
  }

  /// Clear the filter (set to All Rooms)
  void clear() {
    setRoom(RoomFilterState.allRooms);
  }

  /// Save current room to storage
  Future<void> _saveRoom(String room) async {
    if (_storageService == null) {
      return;
    }
    if (room == RoomFilterState.allRooms) {
      // Remove the key when showing all rooms
      await _storageService!.clearRoomFilter();
    } else {
      await _storageService!.setRoomFilter(room);
    }
  }
}

/// Provider for available rooms based on rooms data (not devices)
@riverpod
List<String> deviceRooms(DeviceRoomsRef ref) {
  final rooms = ref.watch(roomsNotifierProvider);

  return rooms.when(
    data: (roomList) {
      if (roomList.isEmpty) {
        return [RoomFilterState.allRooms];
      }

      // Extract room names, trimmed and sorted alphabetically
      final roomNames = roomList
          .map((room) => room.name.trim())
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      return [RoomFilterState.allRooms, ...roomNames];
    },
    loading: () => [RoomFilterState.allRooms],
    error: (_, __) => [RoomFilterState.allRooms],
  );
}
