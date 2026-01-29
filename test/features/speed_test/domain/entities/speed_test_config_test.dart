import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';

void main() {
  group('SpeedTestConfig', () {
    group('fromJson', () {
      test('should parse basic JSON correctly', () {
        // arrange
        final json = {
          'id': 1,
          'name': 'Default Speed Test',
          'test_type': 'iperf3',
          'target': '10.0.0.1',
          'port': 5201,
          'iperf_protocol': 'TCP',
          'min_download_mbps': 50.0,
          'min_upload_mbps': 25.0,
          'period': 300,
          'period_unit': 'seconds',
          'passing': true,
        };

        // act
        final config = SpeedTestConfig.fromJson(json);

        // assert
        expect(config.id, 1);
        expect(config.name, 'Default Speed Test');
        expect(config.testType, 'iperf3');
        expect(config.target, '10.0.0.1');
        expect(config.port, 5201);
        expect(config.iperfProtocol, 'TCP');
        expect(config.minDownloadMbps, 50.0);
        expect(config.minUploadMbps, 25.0);
        expect(config.period, 300);
        expect(config.periodUnit, 'seconds');
        expect(config.passing, true);
      });

      test('should handle string values for numeric fields', () {
        // arrange
        final json = {
          'id': '123',
          'port': '5201',
          'min_download_mbps': '100.5',
          'min_upload_mbps': '50.25',
          'period': '60',
          'max_failures': '3',
        };

        // act
        final config = SpeedTestConfig.fromJson(json);

        // assert
        expect(config.id, 123);
        expect(config.port, 5201);
        expect(config.minDownloadMbps, 100.5);
        expect(config.minUploadMbps, 50.25);
        expect(config.period, 60);
        expect(config.maxFailures, 3);
      });

      test('should handle int values for double fields', () {
        // arrange
        final json = {
          'min_download_mbps': 100,
          'min_upload_mbps': 50,
        };

        // act
        final config = SpeedTestConfig.fromJson(json);

        // assert
        expect(config.minDownloadMbps, 100.0);
        expect(config.minUploadMbps, 50.0);
      });

      test('should handle null values gracefully', () {
        // arrange
        final json = <String, dynamic>{};

        // act
        final config = SpeedTestConfig.fromJson(json);

        // assert
        expect(config.id, isNull);
        expect(config.name, isNull);
        expect(config.target, isNull);
        expect(config.port, isNull);
        expect(config.passing, false);
        expect(config.disableUplinkOnFailure, false);
      });

      test('should parse datetime fields', () {
        // arrange
        final now = DateTime.now();
        final json = {
          'starts_at': now.toIso8601String(),
          'next_check_at': now.add(const Duration(hours: 1)).toIso8601String(),
          'last_checked_at': now.subtract(const Duration(hours: 1)).toIso8601String(),
        };

        // act
        final config = SpeedTestConfig.fromJson(json);

        // assert
        expect(config.startsAt, isNotNull);
        expect(config.nextCheckAt, isNotNull);
        expect(config.lastCheckedAt, isNotNull);
      });
    });

    group('protocol getters', () {
      test('isIperfTest returns true for iperf3 test type', () {
        // arrange
        const config = SpeedTestConfig(testType: 'iperf3');

        // assert
        expect(config.isIperfTest, true);
      });

      test('isIperfTest returns true for iperf test type (case insensitive)', () {
        // arrange
        const config = SpeedTestConfig(testType: 'IPERF');

        // assert
        expect(config.isIperfTest, true);
      });

      test('isIperfTest returns false for non-iperf test types', () {
        // arrange
        const config = SpeedTestConfig(testType: 'http');

        // assert
        expect(config.isIperfTest, false);
      });

      test('isUdp returns true for UDP protocol', () {
        // arrange
        const config = SpeedTestConfig(iperfProtocol: 'udp');

        // assert
        expect(config.isUdp, true);
        expect(config.isTcp, false);
      });

      test('isTcp returns true for TCP protocol', () {
        // arrange
        const config = SpeedTestConfig(iperfProtocol: 'TCP');

        // assert
        expect(config.isTcp, true);
        expect(config.isUdp, false);
      });

      test('isTcp handles case insensitivity', () {
        // arrange
        const config = SpeedTestConfig(iperfProtocol: 'tcp');

        // assert
        expect(config.isTcp, true);
      });
    });

    group('server getters', () {
      test('serverHost returns target value', () {
        // arrange
        const config = SpeedTestConfig(target: '192.168.1.1');

        // assert
        expect(config.serverHost, '192.168.1.1');
      });

      test('serverPort returns port with default fallback', () {
        // arrange
        const config1 = SpeedTestConfig(port: 5300);
        const config2 = SpeedTestConfig();

        // assert
        expect(config1.serverPort, 5300);
        expect(config2.serverPort, 5201); // default port
      });

      test('durationSeconds returns period value', () {
        // arrange
        const config = SpeedTestConfig(period: 10);

        // assert
        expect(config.durationSeconds, 10);
      });
    });

    group('scheduling getters', () {
      test('isScheduled returns true when nextCheckAt is in future', () {
        // arrange
        final config = SpeedTestConfig(
          nextCheckAt: DateTime.now().add(const Duration(hours: 1)),
        );

        // assert
        expect(config.isScheduled, true);
      });

      test('isScheduled returns false when nextCheckAt is in past', () {
        // arrange
        final config = SpeedTestConfig(
          nextCheckAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        // assert
        expect(config.isScheduled, false);
      });

      test('isScheduled returns false when nextCheckAt is null', () {
        // arrange
        const config = SpeedTestConfig();

        // assert
        expect(config.isScheduled, false);
      });

      test('hasRun returns true when lastCheckedAt is set', () {
        // arrange
        final config = SpeedTestConfig(lastCheckedAt: DateTime.now());

        // assert
        expect(config.hasRun, true);
      });

      test('hasRun returns false when lastCheckedAt is null', () {
        // arrange
        const config = SpeedTestConfig();

        // assert
        expect(config.hasRun, false);
      });

      test('timeUntilNextTest calculates correctly', () {
        // arrange
        final nextCheck = DateTime.now().add(const Duration(hours: 2));
        final config = SpeedTestConfig(nextCheckAt: nextCheck);

        // act
        final duration = config.timeUntilNextTest;

        // assert
        expect(duration, isNotNull);
        expect(duration!.inMinutes, greaterThan(110));
        expect(duration.inMinutes, lessThan(130));
      });

      test('timeUntilNextTest returns null when nextCheckAt is in past', () {
        // arrange
        final config = SpeedTestConfig(
          nextCheckAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        // assert
        expect(config.timeUntilNextTest, isNull);
      });

      test('timeUntilNextTest returns null when nextCheckAt is null', () {
        // arrange
        const config = SpeedTestConfig();

        // assert
        expect(config.timeUntilNextTest, isNull);
      });

      test('timeSinceLastTest calculates correctly', () {
        // arrange
        final lastCheck = DateTime.now().subtract(const Duration(hours: 3));
        final config = SpeedTestConfig(lastCheckedAt: lastCheck);

        // act
        final duration = config.timeSinceLastTest;

        // assert
        expect(duration, isNotNull);
        expect(duration!.inMinutes, greaterThan(170));
        expect(duration.inMinutes, lessThan(190));
      });

      test('timeSinceLastTest returns null when lastCheckedAt is null', () {
        // arrange
        const config = SpeedTestConfig();

        // assert
        expect(config.timeSinceLastTest, isNull);
      });
    });

    group('toJson', () {
      test('should serialize config to JSON correctly', () {
        // arrange
        const config = SpeedTestConfig(
          id: 1,
          name: 'Test Config',
          target: '10.0.0.1',
          port: 5201,
          iperfProtocol: 'TCP',
          minDownloadMbps: 50.0,
          minUploadMbps: 25.0,
        );

        // act
        final json = config.toJson();

        // assert
        expect(json['id'], 1);
        expect(json['name'], 'Test Config');
        expect(json['target'], '10.0.0.1');
        expect(json['port'], 5201);
        expect(json['iperf_protocol'], 'TCP');
        expect(json['min_download_mbps'], 50.0);
        expect(json['min_upload_mbps'], 25.0);
      });
    });
  });
}
