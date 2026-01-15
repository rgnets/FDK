import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/core/utils/logging_utils.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/room.dart';
import 'package:rgnets_fdk/features/rooms/domain/usecases/get_rooms.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rooms_riverpod_provider.g.dart';

@Riverpod(keepAlive: true)
class RoomsNotifier extends _$RoomsNotifier {
  Logger get _logger => ref.read(loggerProvider);

  GetRooms get _getRooms => GetRooms(ref.read(roomRepositoryProvider));

  @override
  Future<List<Room>> build() async {
    if (isVerboseLoggingEnabled) {
      _logger.i('RoomsProvider: Loading rooms');
    }
    
    try {
      final getRooms = _getRooms;
      final result = await getRooms();
      
      return result.fold(
        (failure) {
          _logger.e('RoomsProvider: Failed to load rooms - ${failure.message}');
          throw Exception(failure.message);
        },
        (rooms) {
          if (isVerboseLoggingEnabled) {
            _logger.i('RoomsProvider: Successfully loaded ${rooms.length} rooms');
          }
          return rooms;
        },
      );
    } catch (e, stack) {
      _logger.e('RoomsProvider: Exception in build(): $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> refresh() async {
    if (isVerboseLoggingEnabled) {
      _logger.i('RoomsProvider: Refreshing rooms');
    }
    
    ref.invalidateSelf();
  }
}

/// Provider for room statistics
@riverpod
RoomStatistics roomStatistics(RoomStatisticsRef ref) {
  final rooms = ref.watch(roomsNotifierProvider);
  
  return rooms.when(
    data: (roomList) {
      final total = roomList.length;
      // Assuming we can calculate device stats from room metadata or deviceIds
      var totalDevices = 0;
      var onlineDevices = 0;
      var roomsWithIssues = 0;
      
      for (final room in roomList) {
        final deviceCount = room.deviceIds?.length ?? 0;
        totalDevices += deviceCount;
        
        // Mock calculation for demo - in real app this would come from device status
        final mockOnlineDevices = (deviceCount * 0.8).round(); // Assume 80% online
        onlineDevices += mockOnlineDevices;
        
        // Mock issues calculation
        if (deviceCount > 0 && mockOnlineDevices < deviceCount) {
          roomsWithIssues++;
        }
      }
      
      return RoomStatistics(
        total: total,
        totalDevices: totalDevices,
        onlineDevices: onlineDevices,
        roomsWithIssues: roomsWithIssues,
      );
    },
    loading: () => const RoomStatistics(),
    error: (_, __) => const RoomStatistics(),
  );
}

/// Room statistics class
class RoomStatistics {
  const RoomStatistics({
    this.total = 0,
    this.totalDevices = 0,
    this.onlineDevices = 0,
    this.roomsWithIssues = 0,
  });

  final int total;
  final int totalDevices;
  final int onlineDevices;
  final int roomsWithIssues;
}

/// Provider for getting a specific room by ID
@riverpod
Room? roomById(RoomByIdRef ref, String roomId) {
  final rooms = ref.watch(roomsNotifierProvider);
  
  return rooms.when(
    data: (roomList) {
      final parsedId = int.tryParse(roomId);
      if (parsedId == null) {
        return null;
      }
      final matchingRooms = roomList.where((room) => room.id == parsedId);
      return matchingRooms.isNotEmpty ? matchingRooms.first : null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
}
