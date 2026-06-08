import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/services/room_data_processor.dart';
import 'package:rgnets_fdk/core/services/websocket_room_cache_service.dart';

void main() {
  // A room "with devices" carries at least one entry in any device association.
  Map<String, dynamic> room(int id, {bool withDevices = false}) => {
        'id': id,
        'room': '$id',
        if (withDevices)
          'access_points': [
            {'id': id * 10, 'name': 'AP$id'},
          ],
      };

  group('roomHasNoDevices', () {
    test('is true for a room with empty device associations', () {
      expect(roomHasNoDevices(room(1)), isTrue);
    });

    test('is false for a room that has a device', () {
      expect(roomHasNoDevices(room(2, withDevices: true)), isFalse);
    });
  });

  group('WebSocketRoomCacheService device-presence filtering', () {
    late WebSocketRoomCacheService service;

    setUp(() {
      service = WebSocketRoomCacheService();
    });

    test('applySnapshot drops rooms with no devices', () {
      service.applySnapshot([
        room(1, withDevices: true),
        room(2), // device-less -> dropped (e.g. linked sub-room 101-A)
        room(3, withDevices: true),
      ]);

      final ids = service.getCachedRooms().map((r) => r['id']).toList();
      expect(ids, [1, 3]);
    });

    test('snapshot callbacks receive only rooms with devices', () {
      List<Map<String, dynamic>>? delivered;
      service.onRoomData((rooms) => delivered = rooms);

      service.applySnapshot([room(1, withDevices: true), room(2)]);

      expect(delivered?.map((r) => r['id']).toList(), [1]);
    });

    test('applyUpsert keeps a room that has devices', () {
      service.applyUpsert(room(5, withDevices: true));
      expect(service.getCachedRooms().map((r) => r['id']).toList(), [5]);
    });

    test('applyUpsert ignores a device-less room', () {
      service.applyUpsert(room(9));
      expect(service.getCachedRooms(), isEmpty);
    });

    test('applyUpsert does NOT delete an existing room on a device-less '
        'payload (partial upsert safety)', () {
      service.applySnapshot([room(7, withDevices: true)]);
      // A partial upsert that omits the device arrays must not drop the room.
      service.applyUpsert(room(7));
      expect(service.getCachedRooms().map((r) => r['id']).toList(), [7]);
    });
  });
}
