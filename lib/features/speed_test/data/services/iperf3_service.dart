import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

/// Service for interacting with native iPerf3 implementation
class Iperf3Service {
  static const MethodChannel _channel =
      MethodChannel('com.rgnets.fdk/iperf3');
  static const EventChannel _progressChannel =
      EventChannel('com.rgnets.fdk/iperf3_progress');

  Stream<Map<String, dynamic>>? _progressStream;

  /// Parse iperf3 JSON output to extract results
  ///
  /// **IMPORTANT**: Must pass the correct [reverse] parameter to properly identify test direction
  /// - [reverse]=true: DOWNLOAD test (server sends to client, -R flag)
  ///   - sum_received = what client received FROM server = DOWNLOAD speed
  /// - [reverse]=false: UPLOAD test (client sends to server, normal mode)
  ///   - sum_received = what server received FROM client = UPLOAD speed
  Map<String, dynamic> _parseIperf3Json(String jsonOutput,
      {required bool reverse}) {
    try {
      final json = jsonDecode(jsonOutput);
      final results = <String, dynamic>{};

      // Extract end summary data
      if (json['end'] != null) {
        final end = json['end'];

        // Check if this is TCP or UDP test
        // UDP has jitter_ms in sum, TCP doesn't
        final isUdp = end['sum'] != null && end['sum']['jitter_ms'] != null;
        final isTcp = !isUdp;

        if (isTcp) {
          // TCP: Has separate sum_sent and sum_received
          developer.log('Parsing TCP test results', name: 'Iperf3Service');

          // Get sent data (upload speed)
          if (end['sum_sent'] != null) {
            final sumSent = end['sum_sent'];
            results['sentBitsPerSecond'] = sumSent['bits_per_second'] ?? 0.0;
            results['sendMbps'] =
                (sumSent['bits_per_second'] ?? 0.0) / 1000000.0;
            results['sentBytes'] = sumSent['bytes'] ?? 0;
          }

          // Get received data (download speed)
          if (end['sum_received'] != null) {
            final sumReceived = end['sum_received'];
            results['receivedBitsPerSecond'] =
                sumReceived['bits_per_second'] ?? 0.0;
            results['receiveMbps'] =
                (sumReceived['bits_per_second'] ?? 0.0) / 1000000.0;
            results['receivedBytes'] = sumReceived['bytes'] ?? 0;
          }

          // Get TCP-specific data (RTT)
          if (end['streams'] != null &&
              end['streams'] is List &&
              (end['streams'] as List).isNotEmpty) {
            final firstStream = end['streams'][0];
            if (firstStream['sender'] != null &&
                firstStream['sender']['mean_rtt'] != null) {
              results['rtt'] = firstStream['sender']['mean_rtt'] /
                  1000.0; // Convert microseconds to milliseconds
            }
          }
        } else {
          // UDP test - use the reverse parameter to determine if this is upload or download
          developer.log('Parsing UDP test results (reverse=$reverse)',
              name: 'Iperf3Service');

          // Get the sum_received which contains the server-measured throughput
          // This is the most accurate measurement for both upload and download
          final sumReceived = end['sum_received'];

          if (sumReceived != null) {
            final receivedBps = sumReceived['bits_per_second'] ?? 0.0;
            final receivedBytes = sumReceived['bytes'] ?? 0;

            if (reverse) {
              // DOWNLOAD test (reverse=true): server sends to client
              // sum_received contains the download speed (what client received from server)
              developer.log(
                  'UDP DOWNLOAD (reverse): received ${receivedBps / 1000000.0} Mbps',
                  name: 'Iperf3Service');
              results['receivedBitsPerSecond'] = receivedBps;
              results['receiveMbps'] = receivedBps / 1000000.0;
              results['receivedBytes'] = receivedBytes;

              // No upload data in download test
              results['sentBitsPerSecond'] = 0.0;
              results['sendMbps'] = 0.0;
              results['sentBytes'] = 0;
            } else {
              // UPLOAD test (reverse=false): client sends to server
              // sum_received contains the upload speed (what server received from client)
              developer.log(
                  'UDP UPLOAD (normal): sent ${receivedBps / 1000000.0} Mbps',
                  name: 'Iperf3Service');
              results['sentBitsPerSecond'] = receivedBps;
              results['sendMbps'] = receivedBps / 1000000.0;
              results['sentBytes'] = receivedBytes;

              // No download data in upload test
              results['receivedBitsPerSecond'] = 0.0;
              results['receiveMbps'] = 0.0;
              results['receivedBytes'] = 0;
            }
          } else {
            // No sum_received - shouldn't happen in normal tests
            developer.log('UDP: no sum_received data!', name: 'Iperf3Service');
            results['sentBitsPerSecond'] = 0.0;
            results['sendMbps'] = 0.0;
            results['sentBytes'] = 0;
            results['receivedBitsPerSecond'] = 0.0;
            results['receiveMbps'] = 0.0;
            results['receivedBytes'] = 0;
          }

          // UDP-specific metrics (jitter, packet loss) from sum
          if (end['sum'] != null) {
            final sum = end['sum'];
            if (sum['jitter_ms'] != null) {
              results['jitter'] = sum['jitter_ms'];
            }
            if (sum['lost_packets'] != null) {
              results['lostPackets'] = sum['lost_packets'];
            }
            if (sum['packets'] != null) {
              results['totalPackets'] = sum['packets'];
            }
            if (sum['lost_percent'] != null) {
              results['lostPercent'] = sum['lost_percent'];
            }
          }
        }
      }

      developer.log(
          'Parsed JSON results: sendMbps=${results['sendMbps']}, receiveMbps=${results['receiveMbps']}, jitter=${results['jitter']}',
          name: 'Iperf3Service');

      return results;
    } catch (e) {
      developer.log('Failed to parse JSON: $e', name: 'Iperf3Service', error: e);
      return {};
    }
  }

  /// Run iperf3 client test
  Future<Map<String, dynamic>> runClient({
    required String serverHost,
    int port = 5201,
    int durationSeconds = 10,
    int parallelStreams = 1,
    bool reverse = false,
    bool useUdp = true, // Default to UDP
    int? bandwidthMbps, // Target bandwidth in Mbps (null = use iperf3 default)
  }) async {
    try {
      developer.log('=== Flutter: Starting iperf3 client test ===',
          name: 'Iperf3Service');
      developer.log(
          'Host: $serverHost, Port: $port, Duration: $durationSeconds sec',
          name: 'Iperf3Service');
      developer.log(
          'Protocol: ${useUdp ? "UDP" : "TCP"}, Parallel: $parallelStreams, Reverse: $reverse',
          name: 'Iperf3Service');

      // Convert Mbps to bits/sec for native layer
      final int bandwidthBps =
          bandwidthMbps != null ? bandwidthMbps * 1000000 : 0;
      if (bandwidthBps > 0) {
        developer.log('Bandwidth limit: $bandwidthMbps Mbits/sec',
            name: 'Iperf3Service');
      }

      developer.log('Calling native method...', name: 'Iperf3Service');
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'runClient', {
        'host': serverHost,
        'port': port,
        'duration': durationSeconds,
        'parallel': parallelStreams,
        'reverse': reverse,
        'useUdp': useUdp,
        'bandwidthBps': bandwidthBps,
      });

      developer.log('Native method returned', name: 'Iperf3Service');
      final resultMap = Map<String, dynamic>.from(result ?? {});

      if (resultMap['success'] == true) {
        developer.log('Test completed successfully', name: 'Iperf3Service');

        // Parse JSON output to extract actual results
        if (resultMap['jsonOutput'] != null &&
            resultMap['jsonOutput'] is String) {
          developer.log('Parsing JSON output...', name: 'Iperf3Service');
          final parsedResults = _parseIperf3Json(
            resultMap['jsonOutput'] as String,
            reverse: reverse,
          );

          // Merge parsed results into the result map (overwriting the 0 values from native)
          resultMap.addAll(parsedResults);

          developer.log(
              'Final results: sendMbps=${resultMap['sendMbps']}, receiveMbps=${resultMap['receiveMbps']}',
              name: 'Iperf3Service');
        } else {
          developer.log('No JSON output to parse', name: 'Iperf3Service');
        }
      } else {
        developer.log('Test failed: ${resultMap['error']}',
            name: 'Iperf3Service');
      }

      return resultMap;
    } on PlatformException catch (e) {
      developer.log('Platform exception: ${e.message}',
          name: 'Iperf3Service', error: e);
      throw Exception('Failed to run iperf3 client: ${e.message}');
    } catch (e) {
      developer.log('Unexpected error: $e', name: 'Iperf3Service', error: e);
      rethrow;
    }
  }

  /// Run iperf3 server
  Future<bool> startServer({int port = 5201, bool useUdp = false}) async {
    try {
      final result = await _channel.invokeMethod<bool>('startServer', {
        'port': port,
        'useUdp': useUdp,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to start iperf3 server: ${e.message}');
    }
  }

  /// Stop iperf3 server
  Future<bool> stopServer() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopServer');
      return result ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to stop iperf3 server: ${e.message}');
    }
  }

  /// Get iperf3 version
  Future<String> getVersion() async {
    try {
      final version = await _channel.invokeMethod<String>('getVersion');
      return version ?? '';
    } on PlatformException catch (e) {
      throw Exception('Failed to get iperf3 version: ${e.message}');
    }
  }

  /// Cancel running client test
  Future<bool> cancelClient() async {
    try {
      final bool? wasRunning =
          await _channel.invokeMethod<bool>('cancelClient');
      return wasRunning ?? false;
    } on PlatformException catch (e) {
      throw Exception('Failed to cancel iperf3 client: ${e.message}');
    }
  }

  /// Get default gateway IP address
  Future<String?> getDefaultGateway() async {
    try {
      final String? gateway =
          await _channel.invokeMethod<String>('getDefaultGateway');
      if (gateway == null || gateway.isEmpty) {
        return null;
      }
      return gateway;
    } on PlatformException catch (e) {
      throw Exception('Failed to fetch default gateway: ${e.message}');
    }
  }

  /// Get gateway for a specific destination hostname
  Future<Map<String, dynamic>> getGatewayForDestination(String hostname) async {
    try {
      final result = await _channel
          .invokeMethod<Map<dynamic, dynamic>>('getGatewayForDestination', {
        'hostname': hostname,
      });
      return Map<String, dynamic>.from(result ?? {});
    } on PlatformException catch (e) {
      return {
        'success': false,
        'error': e.message ?? 'Failed to resolve gateway for destination',
      };
    }
  }

  /// Get real-time progress stream
  Stream<Map<String, dynamic>> getProgressStream() {
    _progressStream ??=
        _progressChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return Map<String, dynamic>.from(event);
      }
      return <String, dynamic>{};
    });
    return _progressStream!;
  }
}
