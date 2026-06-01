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

  /// Load all cached rooms from the single-entry store, falling back to the
  /// legacy per-room/indexed format (so pre-migration installs still read).
  /// Does NOT check cache validity — callers decide.
  List<RoomModel> _loadAll() {
    // Primary: all rooms in one entry (one read, one decode).
    final roomsJson = storageService.getString(_roomsKey);
    if (roomsJson != null) {
      final list = json.decode(roomsJson) as List<dynamic>;
      return list
          .map((j) => RoomModel.fromJson(j as Map<String, dynamic>))
          .toList();
    }

    // Legacy: per-room keys addressed by an index. Read once; the next
    // cacheRooms/cacheRoom/updateCachePartial rewrites everything as a single
    // entry, so this path runs at most once after upgrading.
    final indexJson = storageService.getString(_roomIndexKey);
    if (indexJson != null) {
      final index = (json.decode(indexJson) as List<dynamic>)
          .map((id) => id.toString())
          .toList();
      final rooms = <RoomModel>[];
      for (final id in index) {
        final roomJson = storageService.getString('$_roomKeyPrefix$id');
        if (roomJson != null) {
          rooms.add(
            RoomModel.fromJson(json.decode(roomJson) as Map<String, dynamic>),
          );
        }
      }
      return rooms;
    }

    return [];
  }

  /// Persist the full room list as a single entry — one SharedPreferences
  /// write instead of one-per-room. The old scheme wrote a key per room, and
  /// because SharedPreferences rewrites its entire backing store on every
  /// write, seeding N rooms meant N growing full-store rewrites (the slow
  /// startup "Finalizing…" step). Writing once fixes that.
  Future<void> _writeAll(List<RoomModel> rooms) async {
    await storageService.setString(
      _roomsKey,
      json.encode(rooms.map((r) => r.toJson()).toList()),
    );
    await storageService.setString(
      _cacheTimestampKey,
      DateTime.now().toIso8601String(),
    );
    // Retire the legacy index so stale per-room keys are never read back.
    await storageService.remove(_roomIndexKey);
  }

  @override
  Future<List<RoomModel>> getCachedRooms({bool allowStale = false}) async {
    try {
      if (!allowStale && !await isCacheValid()) {
        _logger.d('Room cache expired or invalid');
        return [];
      }
      final rooms = _loadAll();
      _logger.d('Loaded ${rooms.length} rooms from cache');
      return rooms;
    } on Exception catch (e) {
      _logger.e('Failed to get cached rooms: $e');
      return [];
    }
  }

  @override
  Future<void> cacheRooms(List<RoomModel> rooms) async {
    try {
      await _writeAll(rooms);
      _logger.d('Cached ${rooms.length} rooms in a single entry');
    } on Exception catch (e) {
      _logger.e('Failed to cache rooms: $e');
    }
  }

  @override
  Future<void> updateCachePartial(List<RoomModel> rooms, {required int offset}) async {
    try {
      // Merge the incoming rooms into the existing set (upsert by id),
      // preserving order, then persist as a single entry.
      final existing = _loadAll();
      final byId = <int, RoomModel>{for (final r in existing) r.id: r};
      for (final room in rooms) {
        byId[room.id] = room;
      }
      await _writeAll(byId.values.toList());
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
      if (!await isCacheValid()) {
        return [];
      }
      return _loadAll().skip(offset).take(limit).toList();
    } on Exception catch (e) {
      _logger.e('Failed to get cached rooms page: $e');
      return [];
    }
  }

  @override
  Future<RoomModel?> getCachedRoom(String id) async {
    try {
      final wanted = id.toString();
      for (final room in _loadAll()) {
        if (room.id.toString() == wanted) {
          return room;
        }
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
      // Upsert this room into the single-entry store.
      final rooms = _loadAll();
      final idx = rooms.indexWhere((r) => r.id == room.id);
      if (idx >= 0) {
        rooms[idx] = room;
      } else {
        rooms.add(room);
      }
      await _writeAll(rooms);
    } on Exception catch (e) {
      _logger.e('Failed to cache room: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await storageService.remove(_roomsKey);
      await storageService.remove(_cacheTimestampKey);
      await storageService.remove(_roomIndexKey);
      _logger.i('Room cache cleared');
    } on Exception catch (e) {
      _logger.e('Failed to clear room cache: $e');
    }
  }
}
