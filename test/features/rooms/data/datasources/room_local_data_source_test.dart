import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rgnets_fdk/core/services/secure_storage_service.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/features/devices/data/models/room_model.dart';
import 'package:rgnets_fdk/features/rooms/data/datasources/room_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  group('slimRoomMetadata', () {
    test('keeps only the consumed keys and drops the rest of the raw record',
        () {
      final slim = slimRoomMetadata(<String, dynamic>{
        'description': 'Suite',
        'location': 'North',
        'created_at': '2024-01-01T00:00:00Z',
        'area_sqft': 320,
        'capacity': 4,
        'department': 'Housekeeping',
        'last_maintenance': '2026-01-01T00:00:00Z',
        // Noise that should be dropped:
        'poll_state': 'polled',
        'switch_ports': [1, 2, 3],
        'pms_property': {'name': 'Hotel'},
        'snmp_community': 'public',
      });

      expect(slim, isNotNull);
      expect(slim!.keys, containsAll(<String>['description', 'area_sqft', 'capacity']));
      expect(slim.containsKey('poll_state'), isFalse);
      expect(slim.containsKey('switch_ports'), isFalse);
      expect(slim.containsKey('pms_property'), isFalse);
    });

    test('returns null when nothing relevant is present', () {
      expect(slimRoomMetadata(<String, dynamic>{'poll_state': 'x'}), isNull);
      expect(slimRoomMetadata(null), isNull);
    });
  });

  group('RoomLocalDataSourceImpl single-key storage', () {
    late SharedPreferences prefs;
    late RoomLocalDataSourceImpl dataSource;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      dataSource = RoomLocalDataSourceImpl(
        storageService: StorageService(prefs, MockSecureStorageService()),
      );
    });

    List<RoomModel> sampleRooms() => const [
          RoomModel(id: 1, name: '(Tower) 101', number: '101'),
          RoomModel(id: 2, name: '(Tower) 102', number: '102'),
          RoomModel(id: 3, name: '(Tower) 103', number: '103'),
        ];

    test('cacheRooms then getCachedRooms round-trips', () async {
      await dataSource.cacheRooms(sampleRooms());

      final loaded = await dataSource.getCachedRooms();
      expect(loaded.map((r) => r.id), [1, 2, 3]);
      expect(loaded.map((r) => r.name), [
        '(Tower) 101',
        '(Tower) 102',
        '(Tower) 103',
      ]);
    });

    test('writes one entry for all rooms, not one key per room', () async {
      await dataSource.cacheRooms(sampleRooms());

      // The whole list lives under the single cache key...
      final blob = prefs.getString('cached_rooms');
      expect(blob, isNotNull);
      expect((json.decode(blob!) as List<dynamic>).length, 3);

      // ...and no per-room keys were written.
      final perRoomKeys =
          prefs.getKeys().where((k) => k.startsWith('cached_room_'));
      expect(perRoomKeys, isEmpty);
    });

    test('getCachedRoom finds a room from the single-entry store', () async {
      await dataSource.cacheRooms(sampleRooms());
      final room = await dataSource.getCachedRoom('2');
      expect(room?.name, '(Tower) 102');
    });

    test('getCachedRoomsPage paginates over the single entry', () async {
      await dataSource.cacheRooms(sampleRooms());
      final page = await dataSource.getCachedRoomsPage(offset: 1, limit: 1);
      expect(page.map((r) => r.id), [2]);
    });

    test('cacheRoom upserts into the single entry', () async {
      await dataSource.cacheRooms(sampleRooms());
      await dataSource.cacheRoom(
        const RoomModel(id: 2, name: '(Tower) 102 RENAMED', number: '102'),
      );
      final room = await dataSource.getCachedRoom('2');
      expect(room?.name, '(Tower) 102 RENAMED');
      expect((await dataSource.getCachedRooms()).length, 3);
    });
  });
}
