import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/features/speed_test/data/services/iperf3_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Iperf3Service', () {
    late Iperf3Service service;
    late List<MethodCall> methodCalls;

    setUp(() {
      service = Iperf3Service();
      methodCalls = [];

      // Set up mock method channel handler
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.rgnets.fdk/iperf3'),
        (MethodCall methodCall) async {
          methodCalls.add(methodCall);
          return _handleMethodCall(methodCall);
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.rgnets.fdk/iperf3'),
        null,
      );
    });

    group('runClient', () {
      test('should call native method with correct parameters for TCP download',
          () async {
        // act
        await service.runClient(
          serverHost: '10.0.0.1',
          port: 5201,
          durationSeconds: 10,
          parallelStreams: 1,
          reverse: true, // download
          useUdp: false, // TCP
        );

        // assert
        expect(methodCalls.length, 1);
        expect(methodCalls.first.method, 'runClient');
        expect(methodCalls.first.arguments['host'], '10.0.0.1');
        expect(methodCalls.first.arguments['port'], 5201);
        expect(methodCalls.first.arguments['duration'], 10);
        expect(methodCalls.first.arguments['parallel'], 1);
        expect(methodCalls.first.arguments['reverse'], true);
        expect(methodCalls.first.arguments['useUdp'], false);
      });

      test('should call native method with correct parameters for UDP upload',
          () async {
        // act
        await service.runClient(
          serverHost: '192.168.1.1',
          port: 5300,
          durationSeconds: 5,
          parallelStreams: 2,
          reverse: false, // upload
          useUdp: true, // UDP
          bandwidthMbps: 100,
        );

        // assert
        expect(methodCalls.length, 1);
        expect(methodCalls.first.arguments['host'], '192.168.1.1');
        expect(methodCalls.first.arguments['port'], 5300);
        expect(methodCalls.first.arguments['duration'], 5);
        expect(methodCalls.first.arguments['parallel'], 2);
        expect(methodCalls.first.arguments['reverse'], false);
        expect(methodCalls.first.arguments['useUdp'], true);
        expect(methodCalls.first.arguments['bandwidthBps'], 100000000);
      });

      test('should parse TCP download results correctly', () async {
        // act
        final result = await service.runClient(
          serverHost: '10.0.0.1',
          reverse: true,
          useUdp: false,
        );

        // assert
        expect(result['success'], true);
        expect(result['receiveMbps'], closeTo(94.5, 0.1));
        expect(result['rtt'], closeTo(15.5, 0.1));
      });

      test('should parse TCP upload results correctly', () async {
        // Modify the mock to return upload results
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.rgnets.fdk/iperf3'),
          (MethodCall methodCall) async {
            methodCalls.add(methodCall);
            return _createTcpUploadResult();
          },
        );

        // act
        final result = await service.runClient(
          serverHost: '10.0.0.1',
          reverse: false,
          useUdp: false,
        );

        // assert
        expect(result['success'], true);
        expect(result['sendMbps'], closeTo(48.2, 0.1));
      });

      test('should parse UDP download results correctly', () async {
        // Modify the mock to return UDP results
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.rgnets.fdk/iperf3'),
          (MethodCall methodCall) async {
            methodCalls.add(methodCall);
            return _createUdpDownloadResult();
          },
        );

        // act
        final result = await service.runClient(
          serverHost: '10.0.0.1',
          reverse: true, // download
          useUdp: true,
        );

        // assert
        expect(result['success'], true);
        expect(result['receiveMbps'], closeTo(85.5, 0.1));
        expect(result['jitter'], closeTo(1.25, 0.1));
        expect(result['lostPercent'], closeTo(0.5, 0.1));
      });

      test('should parse UDP upload results correctly', () async {
        // Modify the mock to return UDP upload results
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.rgnets.fdk/iperf3'),
          (MethodCall methodCall) async {
            methodCalls.add(methodCall);
            return _createUdpUploadResult();
          },
        );

        // act
        final result = await service.runClient(
          serverHost: '10.0.0.1',
          reverse: false, // upload
          useUdp: true,
        );

        // assert
        expect(result['success'], true);
        expect(result['sendMbps'], closeTo(42.8, 0.1));
        expect(result['jitter'], closeTo(2.1, 0.1));
      });

      test('should handle failed test result', () async {
        // Modify the mock to return failure
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.rgnets.fdk/iperf3'),
          (MethodCall methodCall) async {
            return {
              'success': false,
              'error': 'Connection refused',
            };
          },
        );

        // act
        final result = await service.runClient(serverHost: '10.0.0.1');

        // assert
        expect(result['success'], false);
        expect(result['error'], 'Connection refused');
      });

      test('should handle null jsonOutput gracefully', () async {
        // Modify the mock to return no JSON output
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.rgnets.fdk/iperf3'),
          (MethodCall methodCall) async {
            return {'success': true};
          },
        );

        // act
        final result = await service.runClient(serverHost: '10.0.0.1');

        // assert
        expect(result['success'], true);
        expect(result['jsonOutput'], isNull);
      });

      test('should handle malformed JSON gracefully', () async {
        // Modify the mock to return invalid JSON
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.rgnets.fdk/iperf3'),
          (MethodCall methodCall) async {
            return {
              'success': true,
              'jsonOutput': 'not valid json {{{',
            };
          },
        );

        // act
        final result = await service.runClient(serverHost: '10.0.0.1');

        // assert - should not throw, just return success without parsed data
        expect(result['success'], true);
        expect(result['receiveMbps'], isNull);
      });

      test('should throw exception on platform error', () async {
        // Modify the mock to throw platform exception
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.rgnets.fdk/iperf3'),
          (MethodCall methodCall) async {
            throw PlatformException(
              code: 'ERROR',
              message: 'Native library not found',
            );
          },
        );

        // act & assert
        expect(
          () => service.runClient(serverHost: '10.0.0.1'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('startServer', () {
      test('should call native startServer method', () async {
        // act
        await service.startServer(port: 5201);

        // assert
        expect(methodCalls.length, 1);
        expect(methodCalls.first.method, 'startServer');
        expect(methodCalls.first.arguments['port'], 5201);
      });
    });

    group('stopServer', () {
      test('should call native stopServer method', () async {
        // act
        await service.stopServer();

        // assert
        expect(methodCalls.length, 1);
        expect(methodCalls.first.method, 'stopServer');
      });
    });

    group('getVersion', () {
      test('should return version string', () async {
        // act
        final version = await service.getVersion();

        // assert
        expect(version, 'iperf 3.14');
      });
    });

    group('cancelClient', () {
      test('should call native cancelClient method', () async {
        // act
        final result = await service.cancelClient();

        // assert
        expect(methodCalls.length, 1);
        expect(methodCalls.first.method, 'cancelClient');
        expect(result, true);
      });
    });

    group('getDefaultGateway', () {
      test('should return gateway IP address', () async {
        // act
        final gateway = await service.getDefaultGateway();

        // assert
        expect(gateway, '192.168.1.1');
      });

      test('should return null for empty gateway', () async {
        // Modify the mock to return empty string
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.rgnets.fdk/iperf3'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getDefaultGateway') {
              return '';
            }
            return null;
          },
        );

        // act
        final gateway = await service.getDefaultGateway();

        // assert
        expect(gateway, isNull);
      });
    });

    group('getGatewayForDestination', () {
      test('should return gateway info for destination', () async {
        // act
        final result = await service.getGatewayForDestination('example.com');

        // assert
        expect(result['success'], true);
        expect(result['gateway'], '10.0.0.1');
      });

      test('should handle platform exception gracefully', () async {
        // Modify the mock to throw
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('com.rgnets.fdk/iperf3'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getGatewayForDestination') {
              throw PlatformException(code: 'ERROR', message: 'DNS failure');
            }
            return null;
          },
        );

        // act
        final result = await service.getGatewayForDestination('invalid.host');

        // assert
        expect(result['success'], false);
        expect(result['error'], contains('DNS failure'));
      });
    });

    group('getProgressStream', () {
      test('should return progress stream', () {
        // act
        final stream = service.getProgressStream();

        // assert
        expect(stream, isA<Stream<Map<String, dynamic>>>());
      });

      test('should return same stream instance on multiple calls', () {
        // act
        final stream1 = service.getProgressStream();
        final stream2 = service.getProgressStream();

        // assert
        expect(identical(stream1, stream2), true);
      });
    });
  });

  group('Iperf3 JSON parsing edge cases', () {
    late Iperf3Service service;

    setUp(() {
      service = Iperf3Service();
    });

    test('should handle JSON with no end section', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.rgnets.fdk/iperf3'),
        (MethodCall methodCall) async {
          return {
            'success': true,
            'jsonOutput': jsonEncode({
              'start': {'timestamp': '2024-01-01T00:00:00Z'},
              'intervals': <Map<String, dynamic>>[],
              // no 'end' section
            }),
          };
        },
      );

      // act
      final result = await service.runClient(serverHost: '10.0.0.1');

      // assert - should not throw
      expect(result['success'], true);
    });

    test('should handle JSON with missing sum_received', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.rgnets.fdk/iperf3'),
        (MethodCall methodCall) async {
          return {
            'success': true,
            'jsonOutput': jsonEncode({
              'end': {
                'sum_sent': {
                  'bits_per_second': 50000000.0,
                  'bytes': 6250000,
                },
                // no sum_received
              },
            }),
          };
        },
      );

      // act
      final result = await service.runClient(
        serverHost: '10.0.0.1',
        useUdp: false,
      );

      // assert
      expect(result['success'], true);
      expect(result['sendMbps'], closeTo(50.0, 0.1));
    });

    test('should extract RTT from TCP streams', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.rgnets.fdk/iperf3'),
        (MethodCall methodCall) async {
          return {
            'success': true,
            'jsonOutput': jsonEncode({
              'end': {
                'sum_sent': {'bits_per_second': 50000000.0, 'bytes': 6250000},
                'sum_received': {
                  'bits_per_second': 100000000.0,
                  'bytes': 12500000,
                },
                'streams': [
                  {
                    'sender': {
                      'mean_rtt': 25000, // 25ms in microseconds
                    },
                  },
                ],
              },
            }),
          };
        },
      );

      // act
      final result = await service.runClient(
        serverHost: '10.0.0.1',
        useUdp: false,
      );

      // assert
      expect(result['rtt'], closeTo(25.0, 0.1)); // Should be 25ms
    });

    test('should handle UDP with lost packets info', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.rgnets.fdk/iperf3'),
        (MethodCall methodCall) async {
          return {
            'success': true,
            'jsonOutput': jsonEncode({
              'end': {
                'sum_received': {
                  'bits_per_second': 80000000.0,
                  'bytes': 10000000,
                },
                'sum': {
                  'jitter_ms': 3.5,
                  'lost_packets': 10,
                  'packets': 1000,
                  'lost_percent': 1.0,
                },
              },
            }),
          };
        },
      );

      // act
      final result = await service.runClient(
        serverHost: '10.0.0.1',
        reverse: true,
        useUdp: true,
      );

      // assert
      expect(result['jitter'], closeTo(3.5, 0.1));
      expect(result['lostPackets'], 10);
      expect(result['totalPackets'], 1000);
      expect(result['lostPercent'], closeTo(1.0, 0.1));
    });
  });
}

/// Mock method call handler
dynamic _handleMethodCall(MethodCall methodCall) {
  switch (methodCall.method) {
    case 'runClient':
      return _createTcpDownloadResult();
    case 'startServer':
      return true;
    case 'stopServer':
      return true;
    case 'getVersion':
      return 'iperf 3.14';
    case 'cancelClient':
      return true;
    case 'getDefaultGateway':
      return '192.168.1.1';
    case 'getGatewayForDestination':
      return {'success': true, 'gateway': '10.0.0.1'};
    default:
      return null;
  }
}

/// Create a mock TCP download result with JSON output
Map<String, dynamic> _createTcpDownloadResult() {
  return {
    'success': true,
    'jsonOutput': jsonEncode({
      'end': {
        'sum_sent': {
          'bits_per_second': 48200000.0,
          'bytes': 6025000,
        },
        'sum_received': {
          'bits_per_second': 94500000.0,
          'bytes': 11812500,
        },
        'streams': [
          {
            'sender': {
              'mean_rtt': 15500, // microseconds
            },
          },
        ],
      },
    }),
  };
}

/// Create a mock TCP upload result with JSON output
Map<String, dynamic> _createTcpUploadResult() {
  return {
    'success': true,
    'jsonOutput': jsonEncode({
      'end': {
        'sum_sent': {
          'bits_per_second': 48200000.0,
          'bytes': 6025000,
        },
        'sum_received': {
          'bits_per_second': 45000000.0,
          'bytes': 5625000,
        },
        'streams': [
          {
            'sender': {
              'mean_rtt': 12000,
            },
          },
        ],
      },
    }),
  };
}

/// Create a mock UDP download result with JSON output
Map<String, dynamic> _createUdpDownloadResult() {
  return {
    'success': true,
    'jsonOutput': jsonEncode({
      'end': {
        'sum_received': {
          'bits_per_second': 85500000.0,
          'bytes': 10687500,
        },
        'sum': {
          'jitter_ms': 1.25,
          'lost_packets': 5,
          'packets': 1000,
          'lost_percent': 0.5,
        },
      },
    }),
  };
}

/// Create a mock UDP upload result with JSON output
Map<String, dynamic> _createUdpUploadResult() {
  return {
    'success': true,
    'jsonOutput': jsonEncode({
      'end': {
        'sum_received': {
          'bits_per_second': 42800000.0,
          'bytes': 5350000,
        },
        'sum': {
          'jitter_ms': 2.1,
          'lost_packets': 12,
          'packets': 800,
          'lost_percent': 1.5,
        },
      },
    }),
  };
}
