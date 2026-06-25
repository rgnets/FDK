import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/compliance/domain/entities/compliance_failure.dart';
import 'package:rgnets_fdk/features/compliance/presentation/providers/compliance_providers.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';
import 'package:rgnets_fdk/features/room_readiness/presentation/providers/room_readiness_provider.dart';

RoomReadinessMetrics _room({
  required int roomId,
  RoomStatus status = RoomStatus.ready,
  List<int> accessPointIds = const [],
  List<int> ontDeviceIds = const [],
  int totalDevices = 2,
}) {
  return RoomReadinessMetrics(
    roomId: roomId,
    roomName: '$roomId',
    status: status,
    totalDevices: totalDevices,
    onlineDevices: totalDevices,
    offlineDevices: 0,
    issues: const [],
    lastUpdated: DateTime(2026, 6, 25),
    accessPointIds: accessPointIds,
    ontDeviceIds: ontDeviceIds,
  );
}

ComplianceFailure _failure({
  required String deviceType,
  required int deviceId,
  String reason = 'latest coverage speed test failed',
  String ruleName = ComplianceNames.speedTestRule,
}) {
  return ComplianceFailure(
    deviceType: deviceType,
    deviceId: deviceId,
    deviceName: '$deviceId',
    reason: reason,
    ruleName: ruleName,
    ruleId: 7,
    checkedAt: DateTime(2026, 6, 25),
  );
}

void main() {
  group('attachComplianceIssues — room-level coverage (pms_room)', () {
    test('a pms_room speedTest failure adds one coverage issue to the matching room', () {
      final rooms = [_room(roomId: 245), _room(roomId: 246)];
      final failures = [_failure(deviceType: 'pms_room', deviceId: 245)];

      final result = attachComplianceIssues(rooms, failures);

      final r245 = result.firstWhere((r) => r.roomId == 245);
      final r246 = result.firstWhere((r) => r.roomId == 246);

      final coverage = r245.issues
          .where((i) => i.code == 'COVERAGE_SPEED_TEST_FAILED')
          .toList();
      expect(coverage, hasLength(1));
      expect(coverage.first.metadata['roomId'], 245);
      expect(coverage.first.metadata.containsKey('deviceId'), isFalse);
      expect(r245.status, RoomStatus.partial);
      expect(r246.issues, isEmpty);
      expect(r246.status, RoomStatus.ready);
    });

    test('a room with no access points still receives the coverage issue', () {
      final rooms = [_room(roomId: 245, accessPointIds: const [])];
      final failures = [_failure(deviceType: 'pms_room', deviceId: 245)];

      final result = attachComplianceIssues(rooms, failures);

      expect(
        result.single.issues.where((i) => i.code == 'COVERAGE_SPEED_TEST_FAILED'),
        hasLength(1),
      );
      expect(result.single.status, RoomStatus.partial);
    });

    test('a pms_room row under a non-speed-test rule is ignored', () {
      final rooms = [_room(roomId: 245)];
      final failures = [
        _failure(
          deviceType: 'pms_room',
          deviceId: 245,
          ruleName: ComplianceNames.imagesRule,
        ),
      ];

      final result = attachComplianceIssues(rooms, failures);

      expect(result.single.issues, isEmpty);
      expect(result.single.status, RoomStatus.ready);
    });

    test('duplicate pms_room rows for the same room do not double-add', () {
      final rooms = [_room(roomId: 245)];
      final failures = [
        _failure(deviceType: 'pms_room', deviceId: 245),
        _failure(deviceType: 'pms_room', deviceId: 245),
      ];

      final result = attachComplianceIssues(rooms, failures);

      expect(
        result.single.issues.where((i) => i.code == 'COVERAGE_SPEED_TEST_FAILED'),
        hasLength(1),
      );
    });

    test('a down room is not downgraded to partial by a coverage issue', () {
      final rooms = [_room(roomId: 245, status: RoomStatus.down)];
      final failures = [_failure(deviceType: 'pms_room', deviceId: 245)];

      final result = attachComplianceIssues(rooms, failures);

      expect(result.single.status, RoomStatus.down);
    });
  });

  group('attachComplianceIssues — existing access_point path preserved', () {
    test('an access_point speedTest failure still maps to a per-AP missing speed test', () {
      final rooms = [_room(roomId: 245, accessPointIds: const [501])];
      final failures = [_failure(deviceType: 'access_point', deviceId: 501)];

      final result = attachComplianceIssues(rooms, failures);

      final issues = result.single.issues;
      expect(issues.where((i) => i.code == 'MISSING_SPEED_TEST'), hasLength(1));
      expect(issues.where((i) => i.code == 'COVERAGE_SPEED_TEST_FAILED'), isEmpty);
      expect(result.single.status, RoomStatus.partial);
    });

    test('an access_point imagesRule failure still maps to missing images', () {
      final rooms = [_room(roomId: 245, accessPointIds: const [501])];
      final failures = [
        _failure(
          deviceType: 'access_point',
          deviceId: 501,
          ruleName: ComplianceNames.imagesRule,
          reason: 'missing installation images',
        ),
      ];

      final issues = attachComplianceIssues(rooms, failures).single.issues;

      expect(issues.where((i) => i.code == 'MISSING_IMAGES'), hasLength(1));
      expect(issues.where((i) => i.code == 'COVERAGE_SPEED_TEST_FAILED'), isEmpty);
    });

    test('empty failure list returns the rooms unchanged', () {
      final rooms = [_room(roomId: 245)];
      expect(attachComplianceIssues(rooms, const []), same(rooms));
    });

    test('an ont imagesRule failure maps to ONT missing images on its room', () {
      final rooms = [_room(roomId: 245, ontDeviceIds: const [901])];
      final failures = [
        _failure(
          deviceType: 'ont',
          deviceId: 901,
          ruleName: ComplianceNames.imagesRule,
          reason: 'missing installation images',
        ),
      ];

      final issues = attachComplianceIssues(rooms, failures).single.issues;
      final missing =
          issues.where((i) => i.code == 'MISSING_IMAGES').toList();

      expect(missing, hasLength(1));
      expect(missing.first.metadata['deviceType'], 'ONT');
      expect(missing.first.metadata['deviceId'], 901);
      expect(attachComplianceIssues(rooms, failures).single.status,
          RoomStatus.partial);
    });

    test('an ont speedTestRule failure maps to ONT missing speed test on its room', () {
      final rooms = [_room(roomId: 245, ontDeviceIds: const [901])];
      final failures = [
        _failure(
          deviceType: 'ont',
          deviceId: 901,
          ruleName: ComplianceNames.speedTestRule,
          reason: 'latest validation ONT speed test failed',
        ),
      ];

      final issues = attachComplianceIssues(rooms, failures).single.issues;
      final mst =
          issues.where((i) => i.code == 'MISSING_SPEED_TEST').toList();

      expect(mst, hasLength(1));
      expect(mst.first.id, 'missing_speed_test_ONT_901');
      expect(mst.first.metadata['deviceType'], 'ONT');
      expect(attachComplianceIssues(rooms, failures).single.status,
          RoomStatus.partial);
    });

    test('an ont failure for an ONT not in the room is not attached', () {
      final rooms = [_room(roomId: 245, ontDeviceIds: const [901])];
      final failures = [
        _failure(
          deviceType: 'ont',
          deviceId: 999,
          ruleName: ComplianceNames.imagesRule,
        ),
      ];

      expect(attachComplianceIssues(rooms, failures).single.issues, isEmpty);
    });

    test('an empty room is not downgraded by a coverage failure', () {
      final rooms = [
        _room(roomId: 245, status: RoomStatus.empty, totalDevices: 0),
      ];
      final failures = [_failure(deviceType: 'pms_room', deviceId: 245)];

      final result = attachComplianceIssues(rooms, failures).single;

      // The coverage issue is still attached, but an empty room stays empty.
      expect(
        result.issues.where((i) => i.code == 'COVERAGE_SPEED_TEST_FAILED'),
        hasLength(1),
      );
      expect(result.status, RoomStatus.empty);
    });

    test('AP id and room id colliding on 245 yield both issues in separate namespaces', () {
      // Room 245 has an AP whose id is also 245. An access_point failure and a
      // pms_room failure both reference id 245 but must not cross-contaminate.
      final rooms = [_room(roomId: 245, accessPointIds: const [245])];
      final failures = [
        _failure(deviceType: 'access_point', deviceId: 245),
        _failure(deviceType: 'pms_room', deviceId: 245),
      ];

      final issues = attachComplianceIssues(rooms, failures).single.issues;

      expect(issues.where((i) => i.code == 'MISSING_SPEED_TEST'), hasLength(1));
      expect(
        issues.where((i) => i.code == 'COVERAGE_SPEED_TEST_FAILED'),
        hasLength(1),
      );
    });
  });
}
