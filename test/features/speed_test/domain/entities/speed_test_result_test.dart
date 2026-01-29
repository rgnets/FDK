import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';

void main() {
  group('SpeedTestResult', () {
    group('fromJson', () {
      test('should parse basic JSON correctly', () {
        // arrange
        final json = {
          'id': 1,
          'download_mbps': 100.5,
          'upload_mbps': 50.25,
          'rtt': 15.5,
          'jitter': 2.3,
          'packet_loss': 0.5,
          'passed': true,
          'iperf_protocol': 'TCP',
          'test_type': 'iperf3',
        };

        // act
        final result = SpeedTestResult.fromJson(json);

        // assert
        expect(result.id, 1);
        expect(result.downloadMbps, 100.5);
        expect(result.uploadMbps, 50.25);
        expect(result.rtt, 15.5);
        expect(result.jitter, 2.3);
        expect(result.packetLoss, 0.5);
        expect(result.passed, true);
        expect(result.iperfProtocol, 'TCP');
        expect(result.testType, 'iperf3');
      });

      test('should handle string values for numeric fields', () {
        // arrange
        final json = {
          'id': '123',
          'download_mbps': '100.5',
          'upload_mbps': '50.25',
          'rtt': '15.5',
          'port': '5201',
        };

        // act
        final result = SpeedTestResult.fromJson(json);

        // assert
        expect(result.id, 123);
        expect(result.downloadMbps, 100.5);
        expect(result.uploadMbps, 50.25);
        expect(result.rtt, 15.5);
        expect(result.port, 5201);
      });

      test('should handle int values for double fields', () {
        // arrange
        final json = {
          'download_mbps': 100,
          'upload_mbps': 50,
          'rtt': 15,
        };

        // act
        final result = SpeedTestResult.fromJson(json);

        // assert
        expect(result.downloadMbps, 100.0);
        expect(result.uploadMbps, 50.0);
        expect(result.rtt, 15.0);
      });

      test('should handle null values gracefully', () {
        // arrange
        final json = <String, dynamic>{};

        // act
        final result = SpeedTestResult.fromJson(json);

        // assert
        expect(result.id, isNull);
        expect(result.downloadMbps, isNull);
        expect(result.uploadMbps, isNull);
        expect(result.rtt, isNull);
        expect(result.passed, false);
      });
    });

    group('fromJsonWithValidation', () {
      test('should detect and swap speeds when download < 5 and upload > 50', () {
        // arrange - typical swapped scenario
        final json = {
          'id': 1,
          'download_mbps': 2.5, // Suspiciously low
          'upload_mbps': 150.0, // Suspiciously high
        };

        // act
        final result = SpeedTestResult.fromJsonWithValidation(json);

        // assert - values should be swapped
        expect(result.downloadMbps, 150.0);
        expect(result.uploadMbps, 2.5);
      });

      test('should detect and swap speeds when upload is 10x higher than download',
          () {
        // arrange
        final json = {
          'id': 2,
          'download_mbps': 10.0,
          'upload_mbps': 150.0, // 15x higher
        };

        // act
        final result = SpeedTestResult.fromJsonWithValidation(json);

        // assert - values should be swapped
        expect(result.downloadMbps, 150.0);
        expect(result.uploadMbps, 10.0);
      });

      test('should NOT swap when speeds are reasonable', () {
        // arrange - normal scenario
        final json = {
          'id': 3,
          'download_mbps': 100.0,
          'upload_mbps': 50.0,
        };

        // act
        final result = SpeedTestResult.fromJsonWithValidation(json);

        // assert - values should NOT be swapped
        expect(result.downloadMbps, 100.0);
        expect(result.uploadMbps, 50.0);
      });

      test('should NOT swap when both speeds are 0', () {
        // arrange - incomplete test
        final json = {
          'id': 4,
          'download_mbps': 0.0,
          'upload_mbps': 0.0,
        };

        // act
        final result = SpeedTestResult.fromJsonWithValidation(json);

        // assert - values should NOT be swapped
        expect(result.downloadMbps, 0.0);
        expect(result.uploadMbps, 0.0);
      });

      test('should NOT swap when upload is less than 10x download', () {
        // arrange - edge case: 9x is ok
        final json = {
          'id': 5,
          'download_mbps': 10.0,
          'upload_mbps': 90.0, // 9x - should not trigger swap
        };

        // act
        final result = SpeedTestResult.fromJsonWithValidation(json);

        // assert - values should NOT be swapped
        expect(result.downloadMbps, 10.0);
        expect(result.uploadMbps, 90.0);
      });

      test('should extract nested association IDs', () {
        // arrange - RESTFramework sends associations as objects
        final json = {
          'id': 6,
          'download_mbps': 100.0,
          'upload_mbps': 50.0,
          'tested_via_access_point': {'id': 1309, 'name': 'AP-123'},
          'speed_test': {'id': 42, 'name': 'Test Config'},
        };

        // act
        final result = SpeedTestResult.fromJsonWithValidation(json);

        // assert
        expect(result.testedViaAccessPointId, 1309);
        expect(result.speedTestId, 42);
      });

      test('should prefer explicit ID over nested association', () {
        // arrange
        final json = {
          'id': 7,
          'download_mbps': 100.0,
          'upload_mbps': 50.0,
          'tested_via_access_point_id': 999,
          'tested_via_access_point': {'id': 1309, 'name': 'AP-123'},
        };

        // act
        final result = SpeedTestResult.fromJsonWithValidation(json);

        // assert - explicit ID should take precedence
        expect(result.testedViaAccessPointId, 999);
      });

      test('should normalize string access point ID to int', () {
        // arrange
        final json = {
          'id': 8,
          'download_mbps': 100.0,
          'upload_mbps': 50.0,
          'tested_via_access_point_id': '1234',
        };

        // act
        final result = SpeedTestResult.fromJsonWithValidation(json);

        // assert
        expect(result.testedViaAccessPointId, 1234);
      });
    });

    group('error factory', () {
      test('should create error result with message', () {
        // act
        final result = SpeedTestResult.error('Test failed: connection timeout');

        // assert
        expect(result.hasError, true);
        expect(result.errorMessage, 'Test failed: connection timeout');
        expect(result.passed, false);
      });
    });

    group('helper getters', () {
      test('isIperfTest returns true for iperf3 test type', () {
        // arrange
        const result = SpeedTestResult(testType: 'iperf3');

        // assert
        expect(result.isIperfTest, true);
      });

      test('isIperfTest returns true for iperf test type (case insensitive)', () {
        // arrange
        const result = SpeedTestResult(testType: 'IPERF');

        // assert
        expect(result.isIperfTest, true);
      });

      test('isUdp returns true for UDP protocol', () {
        // arrange
        const result = SpeedTestResult(iperfProtocol: 'udp');

        // assert
        expect(result.isUdp, true);
        expect(result.isTcp, false);
      });

      test('isTcp returns true for TCP protocol', () {
        // arrange
        const result = SpeedTestResult(iperfProtocol: 'TCP');

        // assert
        expect(result.isTcp, true);
        expect(result.isUdp, false);
      });

      test('testDuration calculates correctly', () {
        // arrange
        final initiatedAt = DateTime(2024, 1, 1, 10, 0, 0);
        final completedAt = DateTime(2024, 1, 1, 10, 0, 30);
        final result = SpeedTestResult(
          initiatedAt: initiatedAt,
          completedAt: completedAt,
        );

        // assert
        expect(result.testDuration, const Duration(seconds: 30));
      });

      test('testDuration returns null when timestamps missing', () {
        // arrange
        const result = SpeedTestResult();

        // assert
        expect(result.testDuration, isNull);
      });

      test('isCompleted returns true when completedAt is set', () {
        // arrange
        final result = SpeedTestResult(completedAt: DateTime.now());

        // assert
        expect(result.isCompleted, true);
      });

      test('isRunning returns true when initiated but not completed', () {
        // arrange
        final result = SpeedTestResult(initiatedAt: DateTime.now());

        // assert
        expect(result.isRunning, true);
      });

      test('isHealthy returns true when passed and applicable', () {
        // arrange
        const result = SpeedTestResult(passed: true, isApplicable: true);

        // assert
        expect(result.isHealthy, true);
      });

      test('averageSpeedMbps calculates correctly', () {
        // arrange
        const result = SpeedTestResult(downloadMbps: 100.0, uploadMbps: 50.0);

        // assert
        expect(result.averageSpeedMbps, 75.0);
      });

      test('averageSpeedMbps handles null values', () {
        // arrange
        const result = SpeedTestResult(downloadMbps: 100.0);

        // assert
        expect(result.averageSpeedMbps, 50.0); // 100 + 0 / 2
      });
    });

    group('formatted getters', () {
      test('formattedDownloadSpeed shows Mbps for < 1000', () {
        // arrange
        const result = SpeedTestResult(downloadMbps: 150.55);

        // assert
        expect(result.formattedDownloadSpeed, '150.55 Mbps');
      });

      test('formattedDownloadSpeed shows Gbps for >= 1000', () {
        // arrange
        const result = SpeedTestResult(downloadMbps: 1500.0);

        // assert
        expect(result.formattedDownloadSpeed, '1.50 Gbps');
      });

      test('formattedDownloadSpeed returns N/A for null', () {
        // arrange
        const result = SpeedTestResult();

        // assert
        expect(result.formattedDownloadSpeed, 'N/A');
      });

      test('formattedUploadSpeed shows Mbps correctly', () {
        // arrange
        const result = SpeedTestResult(uploadMbps: 75.25);

        // assert
        expect(result.formattedUploadSpeed, '75.25 Mbps');
      });

      test('formattedRtt shows milliseconds', () {
        // arrange
        const result = SpeedTestResult(rtt: 15.75);

        // assert
        expect(result.formattedRtt, '15.75 ms');
      });

      test('formattedJitter shows milliseconds', () {
        // arrange
        const result = SpeedTestResult(jitter: 2.5);

        // assert
        expect(result.formattedJitter, '2.50 ms');
      });

      test('formattedPacketLoss shows percentage', () {
        // arrange
        const result = SpeedTestResult(packetLoss: 1.5);

        // assert
        expect(result.formattedPacketLoss, '1.50%');
      });
    });

    group('legacy getters', () {
      test('downloadSpeed returns downloadMbps or 0', () {
        // arrange
        const result1 = SpeedTestResult(downloadMbps: 100.0);
        const result2 = SpeedTestResult();

        // assert
        expect(result1.downloadSpeed, 100.0);
        expect(result2.downloadSpeed, 0.0);
      });

      test('uploadSpeed returns uploadMbps or 0', () {
        // arrange
        const result1 = SpeedTestResult(uploadMbps: 50.0);
        const result2 = SpeedTestResult();

        // assert
        expect(result1.uploadSpeed, 50.0);
        expect(result2.uploadSpeed, 0.0);
      });

      test('latency returns rtt or 0', () {
        // arrange
        const result1 = SpeedTestResult(rtt: 15.0);
        const result2 = SpeedTestResult();

        // assert
        expect(result1.latency, 15.0);
        expect(result2.latency, 0.0);
      });
    });

    group('toJson', () {
      test('should not include local-only fields in JSON output', () {
        // arrange
        const result = SpeedTestResult(
          id: 1,
          downloadMbps: 100.0,
          uploadMbps: 50.0,
          hasError: true,
          errorMessage: 'test error',
          localIpAddress: '192.168.1.100',
          serverHost: '10.0.0.1',
        );

        // act
        final json = result.toJson();

        // assert
        expect(json.containsKey('hasError'), false);
        expect(json.containsKey('errorMessage'), false);
        expect(json.containsKey('local_ip_address'), false);
        expect(json.containsKey('server_host'), false);
        expect(json['id'], 1);
        expect(json['download_mbps'], 100.0);
      });
    });
  });
}
