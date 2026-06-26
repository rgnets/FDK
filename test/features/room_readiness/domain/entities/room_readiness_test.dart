import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/room_readiness.dart';
import 'package:rgnets_fdk/features/room_readiness/domain/entities/issue.dart';

void main() {
  group('RoomStatus', () {
    test('should have all required status values', () {
      expect(RoomStatus.values, containsAll([
        RoomStatus.ready,
        RoomStatus.partial,
        RoomStatus.down,
        RoomStatus.empty,
      ]));
    });
  });

  group('Issue', () {
    test('should create Issue with required fields', () {
      final issue = Issue(
        id: 'test-issue-1',
        code: 'DEVICE_OFFLINE',
        title: 'Device Offline',
        description: 'Device is currently offline',
        severity: IssueSeverity.critical,
        category: IssueCategory.connectivity,
        detectedAt: DateTime(2024, 1, 1, 10, 0, 0),
      );

      expect(issue.id, 'test-issue-1');
      expect(issue.code, 'DEVICE_OFFLINE');
      expect(issue.title, 'Device Offline');
      expect(issue.severity, IssueSeverity.critical);
      expect(issue.category, IssueCategory.connectivity);
    });

    test('should create deviceOffline issue with factory constructor', () {
      final issue = Issue.deviceOffline(
        deviceId: 1,
        deviceName: 'AP-001',
        deviceType: 'AP',
      );

      expect(issue.id, 'offline_AP_1');
      expect(issue.code, 'DEVICE_OFFLINE');
      expect(issue.severity, IssueSeverity.critical);
      expect(issue.category, IssueCategory.connectivity);
      expect(issue.metadata['deviceId'], 1);
      expect(issue.metadata['deviceName'], 'AP-001');
    });

    test('should create coverageSpeedTestFailed issue with factory constructor', () {
      final issue = Issue.coverageSpeedTestFailed(
        roomId: 245,
        roomName: '7206',
        detectedAt: DateTime(2026, 6, 25, 9, 0, 0),
      );

      expect(issue.code, 'COVERAGE_SPEED_TEST_FAILED');
      expect(issue.severity, IssueSeverity.info);
      expect(issue.category, IssueCategory.performance);
      expect(issue.metadata['roomId'], 245);
      expect(issue.metadata.containsKey('deviceId'), isFalse);
      expect(issue.id, contains('245'));
      expect(issue.resolution, isNotNull);
    });

    test('should create onboardingError issue with factory constructor', () {
      final issue = Issue.onboardingError(
        deviceId: 700,
        deviceName: 'AP1-2-1206',
        deviceType: 'AP',
        error: 'CSR and Cert missing from DB',
      );

      expect(issue.code, 'ONBOARDING_ERROR');
      expect(issue.severity, IssueSeverity.warning);
      expect(issue.metadata['deviceId'], 700);
      expect(issue.metadata['error'], 'CSR and Cert missing from DB');
      expect(issue.description, contains('CSR and Cert missing from DB'));
    });

    test('should have all severity levels', () {
      expect(IssueSeverity.values, containsAll([
        IssueSeverity.critical,
        IssueSeverity.warning,
        IssueSeverity.info,
      ]));
    });

    test('should have all category values', () {
      expect(IssueCategory.values, containsAll([
        IssueCategory.connectivity,
        IssueCategory.configuration,
        IssueCategory.performance,
        IssueCategory.compliance,
        IssueCategory.maintenance,
        IssueCategory.documentation,
        IssueCategory.onboarding,
      ]));
    });
  });

  group('RoomReadinessMetrics', () {
    late List<Issue> testIssues;

    setUp(() {
      testIssues = [
        Issue.deviceOffline(
          deviceId: 1,
          deviceName: 'AP-001',
          deviceType: 'AP',
        ),
        Issue(
          id: 'warning-1',
          code: 'CONFIG_WARNING',
          title: 'Configuration Warning',
          description: 'Minor configuration issue',
          severity: IssueSeverity.warning,
          category: IssueCategory.configuration,
          detectedAt: DateTime.now(),
        ),
        Issue(
          id: 'info-1',
          code: 'MISSING_IMAGES',
          title: 'Missing Images',
          description: 'No images attached',
          severity: IssueSeverity.info,
          category: IssueCategory.documentation,
          detectedAt: DateTime.now(),
        ),
      ];
    });

    test('should create RoomReadinessMetrics with required fields', () {
      final metrics = RoomReadinessMetrics(
        roomId: 1,
        roomName: 'Room 101',
        status: RoomStatus.partial,
        totalDevices: 5,
        onlineDevices: 4,
        offlineDevices: 1,
        issues: testIssues,
        lastUpdated: DateTime(2024, 1, 1, 12, 0, 0),
      );

      expect(metrics.roomId, 1);
      expect(metrics.roomName, 'Room 101');
      expect(metrics.status, RoomStatus.partial);
      expect(metrics.totalDevices, 5);
      expect(metrics.onlineDevices, 4);
      expect(metrics.offlineDevices, 1);
      expect(metrics.issues.length, 3);
    });

    test('should count critical issues correctly', () {
      final metrics = RoomReadinessMetrics(
        roomId: 1,
        roomName: 'Room 101',
        status: RoomStatus.down,
        totalDevices: 5,
        onlineDevices: 4,
        offlineDevices: 1,
        issues: testIssues,
        lastUpdated: DateTime.now(),
      );

      expect(metrics.criticalIssueCount, 1);
    });

    test('should count warning issues correctly', () {
      final metrics = RoomReadinessMetrics(
        roomId: 1,
        roomName: 'Room 101',
        status: RoomStatus.partial,
        totalDevices: 5,
        onlineDevices: 4,
        offlineDevices: 1,
        issues: testIssues,
        lastUpdated: DateTime.now(),
      );

      expect(metrics.warningIssueCount, 1);
    });

    test('should count info issues correctly', () {
      final metrics = RoomReadinessMetrics(
        roomId: 1,
        roomName: 'Room 101',
        status: RoomStatus.partial,
        totalDevices: 5,
        onlineDevices: 4,
        offlineDevices: 1,
        issues: testIssues,
        lastUpdated: DateTime.now(),
      );

      expect(metrics.infoIssueCount, 1);
    });

    test('should return correct total issue count', () {
      final metrics = RoomReadinessMetrics(
        roomId: 1,
        roomName: 'Room 101',
        status: RoomStatus.partial,
        totalDevices: 5,
        onlineDevices: 4,
        offlineDevices: 1,
        issues: testIssues,
        lastUpdated: DateTime.now(),
      );

      expect(metrics.totalIssueCount, 3);
    });

    test('should return isReady true when status is ready', () {
      final metrics = RoomReadinessMetrics(
        roomId: 1,
        roomName: 'Room 101',
        status: RoomStatus.ready,
        totalDevices: 5,
        onlineDevices: 5,
        offlineDevices: 0,
        issues: const [],
        lastUpdated: DateTime.now(),
      );

      expect(metrics.isReady, true);
    });

    test('should return isEmpty true when status is empty', () {
      final metrics = RoomReadinessMetrics(
        roomId: 1,
        roomName: 'Room 101',
        status: RoomStatus.empty,
        totalDevices: 0,
        onlineDevices: 0,
        offlineDevices: 0,
        issues: const [],
        lastUpdated: DateTime.now(),
      );

      expect(metrics.isEmpty, true);
    });

    test('should return hasIssues true when issues exist', () {
      final metrics = RoomReadinessMetrics(
        roomId: 1,
        roomName: 'Room 101',
        status: RoomStatus.partial,
        totalDevices: 5,
        onlineDevices: 4,
        offlineDevices: 1,
        issues: testIssues,
        lastUpdated: DateTime.now(),
      );

      expect(metrics.hasIssues, true);
    });

    test('should return correct statusText for each status', () {
      final readyMetrics = RoomReadinessMetrics(
        roomId: 1,
        roomName: 'Room 101',
        status: RoomStatus.ready,
        totalDevices: 5,
        onlineDevices: 5,
        offlineDevices: 0,
        issues: const [],
        lastUpdated: DateTime.now(),
      );

      final partialMetrics = RoomReadinessMetrics(
        roomId: 2,
        roomName: 'Room 102',
        status: RoomStatus.partial,
        totalDevices: 5,
        onlineDevices: 4,
        offlineDevices: 1,
        issues: testIssues,
        lastUpdated: DateTime.now(),
      );

      final downMetrics = RoomReadinessMetrics(
        roomId: 3,
        roomName: 'Room 103',
        status: RoomStatus.down,
        totalDevices: 5,
        onlineDevices: 0,
        offlineDevices: 5,
        issues: testIssues,
        lastUpdated: DateTime.now(),
      );

      final emptyMetrics = RoomReadinessMetrics(
        roomId: 4,
        roomName: 'Room 104',
        status: RoomStatus.empty,
        totalDevices: 0,
        onlineDevices: 0,
        offlineDevices: 0,
        issues: const [],
        lastUpdated: DateTime.now(),
      );

      expect(readyMetrics.statusText, 'Ready');
      expect(partialMetrics.statusText, 'Partial');
      expect(downMetrics.statusText, 'Down');
      expect(emptyMetrics.statusText, 'Empty');
    });
  });

  group('readinessScore room-level issues', () {
    test('a room-level coverage issue (no deviceId) counts as an extra failed check', () {
      final metrics = RoomReadinessMetrics(
        roomId: 245,
        roomName: '7206',
        status: RoomStatus.partial,
        totalDevices: 2,
        onlineDevices: 2,
        offlineDevices: 0,
        issues: [
          Issue.coverageSpeedTestFailed(roomId: 245, roomName: '7206'),
        ],
        lastUpdated: DateTime.now(),
      );

      // 2 devices all ready, +1 room-level failed check => 2 of 3 checks pass.
      expect(metrics.readinessScore, closeTo(66.66, 0.5));
    });

    test('a generic issue without a roomId marker does not count as a room-level fail', () {
      final metrics = RoomReadinessMetrics(
        roomId: 1,
        roomName: 'Room 101',
        status: RoomStatus.partial,
        totalDevices: 2,
        onlineDevices: 2,
        offlineDevices: 0,
        issues: [
          // No deviceId AND no roomId — must not silently lower the score.
          Issue(
            id: 'adhoc-1',
            code: 'ADHOC',
            title: 'Ad hoc',
            description: 'No device or room marker',
            severity: IssueSeverity.info,
            category: IssueCategory.maintenance,
            detectedAt: DateTime.now(),
          ),
        ],
        lastUpdated: DateTime.now(),
      );

      // 2 devices, both ready, no room-level fails => 100.
      expect(metrics.readinessScore, 100);
    });

    test('an empty room with a coverage issue does not divide by zero', () {
      final metrics = RoomReadinessMetrics(
        roomId: 9,
        roomName: 'X',
        status: RoomStatus.empty,
        totalDevices: 0,
        onlineDevices: 0,
        offlineDevices: 0,
        issues: [
          Issue.coverageSpeedTestFailed(roomId: 9, roomName: 'X'),
        ],
        lastUpdated: DateTime.now(),
      );

      expect(metrics.readinessScore, 0);
    });
  });

  group('RoomReadinessUpdate', () {
    test('should create RoomReadinessUpdate with required fields', () {
      final metrics = RoomReadinessMetrics(
        roomId: 1,
        roomName: 'Room 101',
        status: RoomStatus.ready,
        totalDevices: 5,
        onlineDevices: 5,
        offlineDevices: 0,
        issues: const [],
        lastUpdated: DateTime.now(),
      );

      final update = RoomReadinessUpdate.create(
        roomId: 1,
        metrics: metrics,
        type: RoomReadinessUpdateType.fullRefresh,
      );

      expect(update.roomId, 1);
      expect(update.metrics, metrics);
      expect(update.type, RoomReadinessUpdateType.fullRefresh);
      expect(update.timestamp, isNotNull);
    });

    test('should have all update types', () {
      expect(RoomReadinessUpdateType.values, containsAll([
        RoomReadinessUpdateType.deviceStatusChanged,
        RoomReadinessUpdateType.issueDetected,
        RoomReadinessUpdateType.issueResolved,
        RoomReadinessUpdateType.fullRefresh,
      ]));
    });
  });
}
