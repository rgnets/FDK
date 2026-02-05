import 'dart:convert';

import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/features/devices/data/models/room_model.dart';

abstract class RoomLocalDataSource {
  Future<List<RoomModel>> getCachedRooms({bool allowStale = false});
  Future<void> cacheRooms(List<RoomModel> rooms);
  Future<RoomModel?> getCachedRoom(String id);
  Future<void> cacheRoom(RoomModel room);
  Future<void> clearCache();
  Future<bool> isCacheValid();
  Future<void> updateCachePartial(List<RoomModel> rooms, {required int offset});
  Future<List<RoomModel>> getCachedRoomsPage({required int offset, required int limit});
}

class RoomLocalDataSourceImpl implements RoomLocalDataSource {
  const RoomLocalDataSourceImpl({
    required this.storageService,
  });

  final StorageService storageService;
  static final _logger = LoggerService.getLogger();
  static const String _roomsKey = 'cached_rooms';
  static const String _roomKeyPrefix = 'cached_room_';
  static const String _cacheTimestampKey = 'rooms_cache_timestamp';
  static const String _roomIndexKey = 'room_index';
  static const Duration _cacheValidityDuration = Duration(minutes: 5);

  @override
  Future<bool> isCacheValid() async {
    try {
      final timestampStr = storageService.getString(_cacheTimestampKey);
      if (timestampStr == null) {
        return false;
      }
      
      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final difference = now.difference(timestamp);
      
      return difference < _cacheValidityDuration;
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  Future<List<RoomModel>> getCachedRooms({bool allowStale = false}) async {
    try {
      // Check if cache is valid
      if (!allowStale && !await isCacheValid()) {
        _logger.d('Room cache expired or invalid');
        return [];
      }
      
      // Try to load from indexed cache first (more efficient)
      final indexJson = storageService.getString(_roomIndexKey);
      if (indexJson != null) {
        final index = (json.decode(indexJson) as List<dynamic>)
            .map((id) => id.toString())
            .toList();
        final rooms = <RoomModel>[];
        
        // Load rooms in batches to avoid memory issues
        const batchSize = 50;
        for (var i = 0; i < index.length; i += batchSize) {
          final batch = index.skip(i).take(batchSize);
          final futures = batch.map((id) async {
            final roomJson = storageService.getString('$_roomKeyPrefix$id');
            if (roomJson != null) {
              return RoomModel.fromJson(json.decode(roomJson) as Map<String, dynamic>);
            }
            return null;
          });
          
          final batchRooms = await Future.wait(futures);
          rooms.addAll(batchRooms.whereType<RoomModel>());
        }
        
        _logger.d('Loaded ${rooms.length} rooms from indexed cache');
        return rooms;
      }
      
      // Fallback to old cache format
      final roomsJson = storageService.getString(_roomsKey);
      if (roomsJson != null) {
        final roomsList = json.decode(roomsJson) as List<dynamic>;
        return roomsList
            .map((json) => RoomModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on Exception catch (e) {
      _logger.e('Failed to get cached rooms: $e');
      return [];
    }
  }

  @override
  Future<void> cacheRooms(List<RoomModel> rooms) async {
    try {
      // Update timestamp
      await storageService.setString(
        _cacheTimestampKey,
        DateTime.now().toIso8601String(),
      );
      
      // Store room index for efficient loading
      final index = rooms.map((r) => r.id.toString()).toList();
      await storageService.setString(_roomIndexKey, json.encode(index));
      
      // Store rooms individually for better performance
      // Use batching to avoid overwhelming storage
      const batchSize = 25;
      for (var i = 0; i < rooms.length; i += batchSize) {
        final batch = rooms.skip(i).take(batchSize);
        final futures = batch.map((room) async {
          final roomId = room.id.toString();
          final roomJson = json.encode(room.toJson());
          await storageService.setString('$_roomKeyPrefix$roomId', roomJson);
        });
        await Future.wait(futures);
      }
      
      _logger.d('Cached ${rooms.length} rooms with indexed storage');
    } on Exception catch (e) {
      _logger.e('Failed to cache rooms: $e');
    }
  }

  @override
  Future<void> updateCachePartial(List<RoomModel> rooms, {required int offset}) async {
    try {
      // Get existing index
      final indexJson = storageService.getString(_roomIndexKey);
      final index = indexJson != null
          ? (json.decode(indexJson) as List<dynamic>)
              .map((id) => id.toString())
              .toList()
          : <String>[];
      
      // Update index with new rooms
      for (final room in rooms) {
        final roomId = room.id.toString();
        if (!index.contains(roomId)) {
          index.add(roomId);
        }
        // Store room
        final roomJson = json.encode(room.toJson());
        await storageService.setString('$_roomKeyPrefix$roomId', roomJson);
      }
      
      // Update index
      await storageService.setString(_roomIndexKey, json.encode(index));
      
      // Update timestamp
      await storageService.setString(
        _cacheTimestampKey,
        DateTime.now().toIso8601String(),
      );
      
      _logger.d('Updated cache with ${rooms.length} rooms at offset $offset');
    } on Exception catch (e) {
      _logger.e('Failed to update cache partially: $e');
    }
  }

  @override
  Future<List<RoomModel>> getCachedRoomsPage({
    required int offset, 
    required int limit,
  }) async {
    try {
      // Check if cache is valid
      if (!await isCacheValid()) {
        return [];
      }
      
      final indexJson = storageService.getString(_roomIndexKey);
      if (indexJson == null) {
        return [];
      }
      
      final index = (json.decode(indexJson) as List<dynamic>)
          .map((id) => id.toString())
          .toList();
      
      // Get page of rooms
      final pageIds = index.skip(offset).take(limit);
      final rooms = <RoomModel>[];
      
      for (final id in pageIds) {
        final roomJson = storageService.getString('$_roomKeyPrefix$id');
        if (roomJson != null) {
          rooms.add(RoomModel.fromJson(
            json.decode(roomJson) as Map<String, dynamic>,
          ));
        }
      }
      
      return rooms;
    } on Exception catch (e) {
      _logger.e('Failed to get cached rooms page: $e');
      return [];
    }
  }

  @override
  Future<RoomModel?> getCachedRoom(String id) async {
    try {
      final roomJson = storageService.getString('$_roomKeyPrefix$id');
      if (roomJson != null) {
        final roomMap = json.decode(roomJson) as Map<String, dynamic>;
        return RoomModel.fromJson(roomMap);
      }
      return null;
    } on Exception catch (e) {
      _logger.e('Failed to get cached room: $e');
      return null;
    }
  }

  @override
  Future<void> cacheRoom(RoomModel room) async {
    try {
      final roomJson = json.encode(room.toJson());
      final roomId = room.id.toString();
      await storageService.setString('$_roomKeyPrefix$roomId', roomJson);
      
      // Update index if needed
      final indexJson = storageService.getString(_roomIndexKey);
      if (indexJson != null) {
        final index = (json.decode(indexJson) as List<dynamic>)
            .map((id) => id.toString())
            .toList();
        if (!index.contains(roomId)) {
          index.add(roomId);
          await storageService.setString(_roomIndexKey, json.encode(index));
        }
      }
    } on Exception catch (e) {
      _logger.e('Failed to cache room: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      // Clear main cache
      await storageService.remove(_roomsKey);
      await storageService.remove(_cacheTimestampKey);
      await storageService.remove(_roomIndexKey);
      
      // Clear individual room caches
      // Note: This would require tracking all keys, which we'll skip for now
      // In production, you might want to use a database like SQLite for better management
      
      _logger.i('Room cache cleared');
    } on Exception catch (e) {
      _logger.e('Failed to clear room cache: $e');
    }
  }
}
