import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/room.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/room_view_models.dart';

void main() {
  group('RoomViewModel', () {
    late Room testRoom;

    setUp(() {
      testRoom = const Room(
        id: 1,
        name: 'Test Room 101',
      );
    });

    test('should have status field from RoomStatus enum', () {
      final viewModel = RoomViewModel(
        room: testRoom,
        deviceCount: 5,
        onlineDevices: 5,
        status: RoomStatus.ready,
      );

      expect(viewModel.status, RoomStatus.ready);
    });

    test('should return correct statusText for ready status', () {
      final viewModel = RoomViewModel(
        room: testRoom,
        deviceCount: 5,
        onlineDevices: 5,
        status: RoomStatus.ready,
      );

      expect(viewModel.statusText, 'Ready');
    });

    test('should return correct statusText for partial status', () {
      final viewModel = RoomViewModel(
        room: testRoom,
        deviceCount: 5,
        onlineDevices: 4,
        status: RoomStatus.partial,
      );

      expect(viewModel.statusText, 'Partial');
    });

    test('should return correct statusText for down status', () {
      final viewModel = RoomViewModel(
        room: testRoom,
        deviceCount: 5,
        onlineDevices: 0,
        status: RoomStatus.down,
      );

      expect(viewModel.statusText, 'Down');
    });

    test('should return correct statusText for empty status', () {
      final viewModel = RoomViewModel(
        room: testRoom,
        deviceCount: 0,
        onlineDevices: 0,
        status: RoomStatus.empty,
      );

      expect(viewModel.statusText, 'Empty');
    });

    test('hasIssues should be true for partial status', () {
      final viewModel = RoomViewModel(
        room: testRoom,
        deviceCount: 5,
        onlineDevices: 4,
        status: RoomStatus.partial,
      );

      expect(viewModel.hasIssues, true);
    });

    test('hasIssues should be true for down status', () {
      final viewModel = RoomViewModel(
        room: testRoom,
        deviceCount: 5,
        onlineDevices: 0,
        status: RoomStatus.down,
      );

      expect(viewModel.hasIssues, true);
    });

    test('hasIssues should be false for ready status', () {
      final viewModel = RoomViewModel(
        room: testRoom,
        deviceCount: 5,
        onlineDevices: 5,
        status: RoomStatus.ready,
      );

      expect(viewModel.hasIssues, false);
    });

    test('hasIssues should be false for empty status', () {
      final viewModel = RoomViewModel(
        room: testRoom,
        deviceCount: 0,
        onlineDevices: 0,
        status: RoomStatus.empty,
      );

      expect(viewModel.hasIssues, false);
    });
  });

  group('RoomStats', () {
    test('should have partial, down, and empty counts', () {
      const stats = RoomStats(
        total: 10,
        ready: 5,
        withIssues: 3,
        partial: 2,
        down: 1,
        empty: 2,
      );

      expect(stats.total, 10);
      expect(stats.ready, 5);
      expect(stats.withIssues, 3);
      expect(stats.partial, 2);
      expect(stats.down, 1);
      expect(stats.empty, 2);
    });
  });
}
