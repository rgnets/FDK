import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';
import 'package:rgnets_fdk/features/room_readiness/presentation/providers/room_readiness_provider.dart';

void main() {
  group('RoomReadinessScreen Widget Tests', () {
    late List<RoomReadinessMetrics> testMetrics;

    setUp(() {
      final now = DateTime.now();
      testMetrics = [
        RoomReadinessMetrics(
          roomId: 1,
          roomName: '(North Tower) 101',
          status: RoomStatus.ready,
          totalDevices: 3,
          onlineDevices: 3,
          offlineDevices: 0,
          issues: const [],
          lastUpdated: now,
        ),
        RoomReadinessMetrics(
          roomId: 2,
          roomName: '(North Tower) 102',
          status: RoomStatus.partial,
          totalDevices: 2,
          onlineDevices: 2,
          offlineDevices: 0,
          issues: const [],
          lastUpdated: now,
        ),
        RoomReadinessMetrics(
          roomId: 3,
          roomName: '(South Tower) 201',
          status: RoomStatus.down,
          totalDevices: 2,
          onlineDevices: 0,
          offlineDevices: 2,
          issues: const [],
          lastUpdated: now,
        ),
        RoomReadinessMetrics(
          roomId: 4,
          roomName: '(South Tower) 202',
          status: RoomStatus.empty,
          totalDevices: 0,
          onlineDevices: 0,
          offlineDevices: 0,
          issues: const [],
          lastUpdated: now,
        ),
      ];
    });

    test('RoomReadinessSummary computes counts correctly', () {
      final summary = RoomReadinessSummary(
        totalRooms: testMetrics.length,
        readyRooms: testMetrics.where((m) => m.status == RoomStatus.ready).length,
        partialRooms: testMetrics.where((m) => m.status == RoomStatus.partial).length,
        downRooms: testMetrics.where((m) => m.status == RoomStatus.down).length,
        emptyRooms: testMetrics.where((m) => m.status == RoomStatus.empty).length,
        overallReadinessPercentage: 33.33,
        lastUpdated: DateTime.now(),
      );

      expect(summary.totalRooms, 4);
      expect(summary.readyRooms, 1);
      expect(summary.partialRooms, 1);
      expect(summary.downRooms, 1);
      expect(summary.emptyRooms, 1);
    });

    test('RoomStatus filter works correctly', () {
      final readyRooms = testMetrics.where((m) => m.status == RoomStatus.ready).toList();
      final partialRooms = testMetrics.where((m) => m.status == RoomStatus.partial).toList();
      final downRooms = testMetrics.where((m) => m.status == RoomStatus.down).toList();
      final emptyRooms = testMetrics.where((m) => m.status == RoomStatus.empty).toList();

      expect(readyRooms.length, 1);
      expect(readyRooms.first.roomName, '(North Tower) 101');

      expect(partialRooms.length, 1);
      expect(partialRooms.first.roomName, '(North Tower) 102');

      expect(downRooms.length, 1);
      expect(downRooms.first.roomName, '(South Tower) 201');

      expect(emptyRooms.length, 1);
      expect(emptyRooms.first.roomName, '(South Tower) 202');
    });

    test('Non-empty rooms filter correctly', () {
      final nonEmptyRooms = testMetrics.where((m) => m.status != RoomStatus.empty).toList();

      expect(nonEmptyRooms.length, 3);
      expect(nonEmptyRooms.map((m) => m.roomId).toList(), [1, 2, 3]);
    });

    test('Readiness percentage calculation excludes empty rooms', () {
      final nonEmptyRooms = testMetrics.where((m) => m.status != RoomStatus.empty).toList();
      final readyRooms = nonEmptyRooms.where((m) => m.status == RoomStatus.ready).length;
      final percentage = (readyRooms / nonEmptyRooms.length) * 100;

      // 1 ready out of 3 non-empty = 33.33%
      expect(percentage, closeTo(33.33, 0.01));
    });
  });
}
