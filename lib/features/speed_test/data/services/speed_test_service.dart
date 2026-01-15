import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/speed_test/data/services/iperf3_service.dart';
import 'package:rgnets_fdk/features/speed_test/data/services/network_gateway_service.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Main orchestrator service for speed testing
class SpeedTestService {
  static final SpeedTestService _instance = SpeedTestService._internal();
  factory SpeedTestService() => _instance;
  SpeedTestService._internal();

  final Iperf3Service _iperf3Service = Iperf3Service();
  final NetworkGatewayService _gatewayService = NetworkGatewayService();

  // Configuration
  String _serverHost = '';
  String _serverLabel = '';
  int _serverPort = 5201;
  int _testDuration = 10;
  bool _useUdp = true;
  int _bandwidthMbps = 85; // 80 Mbps bandwidth limit for UDP
  int _parallelStreams = 16; // 16 parallel streams

  // State
  SpeedTestStatus _status = SpeedTestStatus.idle;
  SpeedTestResult? _lastResult;
  double _progress = 0.0;
  bool _isDownloadPhase = true; // Track which phase we're in
  bool _isRetryingFallback =
      false; // Track if we're in fallback retry mode
  double _completedDownloadSpeed =
      0.0; // Store completed download speed for upload phase
  double _completedUploadSpeed =
      0.0; // Store completed upload speed (for potential retest)

  // Streams
  final StreamController<SpeedTestStatus> _statusController =
      StreamController<SpeedTestStatus>.broadcast();
  final StreamController<SpeedTestResult> _resultController =
      StreamController<SpeedTestResult>.broadcast();
  final StreamController<double> _progressController =
      StreamController<double>.broadcast();
  final StreamController<String> _statusMessageController =
      StreamController<String>.broadcast();

  StreamSubscription<Map<String, dynamic>>? _progressSubscription;
  SharedPreferences? _prefs;

  // Getters
  SpeedTestStatus get status => _status;
  SpeedTestResult? get lastResult => _lastResult;
  String get serverHost => _serverHost;
  String get serverLabel => _serverLabel;
  int get serverPort => _serverPort;
  int get testDuration => _testDuration;
  bool get useUdp => _useUdp;
  int get bandwidthMbps => _bandwidthMbps;
  int get parallelStreams => _parallelStreams;

  Stream<SpeedTestStatus> get statusStream => _statusController.stream;
  Stream<SpeedTestResult> get resultStream => _resultController.stream;
  Stream<double> get progressStream => _progressController.stream;
  Stream<String> get statusMessageStream => _statusMessageController.stream;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadConfiguration();

    _useUdp = true;
    _parallelStreams = 16;
    _bandwidthMbps = 81;

    await _saveConfiguration();
    await _loadLastResult();

    _progressSubscription =
        _iperf3Service.getProgressStream().listen((progress) {
      final status = progress['status'];
      if (status != null && status is String) {
        _handleStatusUpdate(status, progress['details']);
      } else {
        _handleProgressUpdate(progress);
      }
    });
  }

  void _handleStatusUpdate(String status, dynamic details) {
    // Determine current phase based on status and add server context
    String getMessage() {
      final serverInfo = _serverHost.isNotEmpty ? ' to $_serverHost' : '';
      switch (status) {
        case 'starting':
          return 'Starting speed test...';
        case 'running':
          if (_isDownloadPhase) {
            return 'Testing download speed$serverInfo...';
          } else {
            return 'Testing upload speed$serverInfo...';
          }
        case 'completed':
          return 'Test completed!';
        case 'cancelled':
          return 'Test cancelled';
        case 'error':
          final message = (details is Map && details['message'] != null)
              ? details['message'].toString()
              : 'Speed test failed';
          return 'Error: $message';
        case 'idle':
          return 'Ready';
        default:
          return 'Performing speed test$serverInfo...';
      }
    }

    switch (status) {
      case 'starting':
        _updateStatus(SpeedTestStatus.running);
        _statusMessageController.add(getMessage());
        _progress = 0.0;
        _progressController.add(_progress);
        break;
      case 'running':
        _updateStatus(SpeedTestStatus.running);
        _statusMessageController.add(getMessage());
        break;
      case 'completed':
        _updateStatus(SpeedTestStatus.completed);
        _statusMessageController.add(getMessage());
        _progress = 100.0;
        _progressController.add(_progress);
        break;
      case 'cancelled':
        _updateStatus(SpeedTestStatus.idle);
        _statusMessageController.add(getMessage());
        _progress = 0.0;
        _progressController.add(_progress);
        break;
      case 'error':
        // Don't show errors during fallback retry - let the retry loop handle messaging
        if (!_isRetryingFallback) {
          _updateStatus(SpeedTestStatus.error);
          _statusMessageController.add(getMessage());
          final message = (details is Map && details['message'] != null)
              ? details['message'].toString()
              : 'Speed test failed';
          _setErrorResult(message);
        }
        break;
      case 'idle':
        // Don't reset to idle if we just completed - preserve completed status for UI
        if (_status != SpeedTestStatus.completed) {
          _updateStatus(SpeedTestStatus.idle);
          _statusMessageController.add(getMessage());
        }
        break;
    }
  }

  void _handleProgressUpdate(Map<String, dynamic> progress) {
    final interval = progress['interval'] as int?;
    final speedMbps = progress['mbps'] as double?;

    if (interval != null && _testDuration > 0) {
      _progress = (interval / _testDuration * 100).clamp(0.0, 100.0);
      _progressController.add(_progress);

      // Emit live speed data if available in progress
      if (speedMbps != null && speedMbps > 0) {
        // Create a partial result for live updates based on current phase
        // Preserve completed phase speed so UI shows both download AND upload
        final liveResult = SpeedTestResult(
          downloadSpeed:
              _isDownloadPhase ? speedMbps : _completedDownloadSpeed,
          uploadSpeed: !_isDownloadPhase ? speedMbps : _completedUploadSpeed,
          latency: 0.0,
          timestamp: DateTime.now(),
        );

        _resultController.add(liveResult);
      }
    }
  }

  void _updateStatus(SpeedTestStatus status) {
    _status = status;
    _statusController.add(_status);
  }

  /// Get the local IP address of the device
  Future<String?> _getLocalIpAddress() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      // Prefer non-loopback interfaces
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback) {
            return addr.address;
          }
        }
      }

      return null;
    } catch (e) {
      LoggerService.error('Failed to get local IP address: $e',
          tag: 'SpeedTestService');
      return null;
    }
  }

  /// Run speed test with automatic fallback retry
  /// If a server fails, automatically tries the next fallback
  Future<void> runSpeedTestWithFallback({String? configTarget}) async {
    if (_status == SpeedTestStatus.running) {
      LoggerService.warning('Speed test already running',
          tag: 'SpeedTestService');
      return;
    }

    _updateStatus(SpeedTestStatus.running);
    _progress = 0.0;
    _progressController.add(_progress);
    _isRetryingFallback =
        true; // Enable fallback mode to suppress intermediate errors

    // Reset completed speeds from previous test
    _completedDownloadSpeed = 0.0;
    _completedUploadSpeed = 0.0;

    // Get local IP address
    final localIp = await _getLocalIpAddress();

    // Build fallback server list
    final fallbackServers = await _buildFallbackList(configTarget);

    // Try each server until one succeeds
    for (int i = 0; i < fallbackServers.length; i++) {
      final serverInfo = fallbackServers[i];
      final serverHost = serverInfo['host'] as String;
      final serverLabel = serverInfo['label'] as String;
      _serverLabel = serverLabel; // Track current server label
      final attemptNum = i + 1;

      // Show which server we're trying
      final message =
          'Attempt $attemptNum/${fallbackServers.length}: $serverLabel ($serverHost)';
      _statusMessageController.add(message);
      LoggerService.info(message, tag: 'SpeedTestService');

      try {
        // Attempt test with this server
        final result = await _runTestWithServer(serverHost, localIp);

        if (result != null) {
          // Success!
          _isRetryingFallback = false; // Disable fallback mode
          final successMsg = 'Connected to $serverLabel';
          _statusMessageController.add(successMsg);
          LoggerService.info(successMsg, tag: 'SpeedTestService');

          _lastResult = result;
          _resultController.add(result);
          _updateStatus(SpeedTestStatus.completed);
          await _saveLastResult(result);

          LoggerService.info(
            'Speed test completed - Down: ${result.downloadSpeed.toStringAsFixed(2)} Mbps, '
            'Up: ${result.uploadSpeed.toStringAsFixed(2)} Mbps, '
            'Latency: ${result.latency.toStringAsFixed(2)} ms',
            tag: 'SpeedTestService',
          );
          return; // Success - exit the loop
        }
      } catch (e) {
        LoggerService.warning('$serverLabel ($serverHost) failed: $e',
            tag: 'SpeedTestService');
      }

      // If not the last server, try next fallback
      if (i < fallbackServers.length - 1) {
        // Show user-friendly message about what we're trying next
        final nextServer = fallbackServers[i + 1];
        final nextLabel = nextServer['label'] as String;

        String userMessage;
        if (nextLabel == 'Test configuration') {
          userMessage = 'Trying test configuration...';
        } else if (nextLabel == 'External server') {
          userMessage = 'Trying external server...';
        } else {
          userMessage = 'Trying $nextLabel...';
        }

        _statusMessageController.add(userMessage);
        LoggerService.warning(
            '$serverLabel ($serverHost) failed, $userMessage',
            tag: 'SpeedTestService');
        await Future.delayed(
            const Duration(seconds: 1)); // Brief pause between retries
      } else {
        // All servers failed - show simple user-friendly message
        _isRetryingFallback =
            false; // Disable fallback mode before showing final error
        const errorMsg =
            'Unable to connect to server. Please check your internet connection.';
        LoggerService.error(
            'All servers failed: ${fallbackServers.map((s) => "${s["label"]} (${s["host"]})").join(", ")}',
            tag: 'SpeedTestService');
        _setErrorResult(errorMsg);
      }
    }
  }

  /// Build list of fallback servers in priority order
  /// Priority: Default Gateway → Test Configuration → External Server
  Future<List<Map<String, String>>> _buildFallbackList(
      String? configTarget) async {
    final servers = <Map<String, String>>[];

    // 1. Try default gateway first (network address + 1 - fastest & most reliable)
    try {
      final gateway = await _gatewayService.getWifiGateway();
      if (gateway != null && gateway.isNotEmpty) {
        servers.add({'host': gateway, 'label': 'Default gateway'});
      }
    } catch (e) {
      LoggerService.warning('Gateway detection failed: $e',
          tag: 'SpeedTestService');
    }

    // 2. Try test configuration target (from speed test config)
    if (configTarget != null && configTarget.isNotEmpty) {
      // Only add if different from gateway
      final gatewayHost = servers.isNotEmpty ? servers[0]['host'] : null;
      if (configTarget != gatewayHost) {
        servers.add({'host': configTarget, 'label': 'Test configuration'});
      }
    }

    return servers;
  }

  /// Run test with a specific server, returns result or null if failed
  Future<SpeedTestResult?> _runTestWithServer(
      String serverHost, String? localIp) async {
    try {
      // Update the current server host being tested
      _serverHost = serverHost;

      // Set phase to download
      _isDownloadPhase = true;

      // Run download test (reverse mode - server sends to client)
      final downloadResult = await _iperf3Service.runClient(
        serverHost: serverHost,
        port: _serverPort,
        durationSeconds: _testDuration,
        parallelStreams: _parallelStreams,
        reverse: true,
        useUdp: _useUdp,
        bandwidthMbps: _useUdp ? _bandwidthMbps : null,
      );

      if (downloadResult['success'] != true) {
        final error = downloadResult['error'] ?? 'Download test failed';
        LoggerService.warning('Download failed on $serverHost: $error',
            tag: 'SpeedTestService');
        return null;
      }

      final downloadSpeed = downloadResult['receiveMbps'] ?? 0.0;

      // Store completed download speed so it's preserved during upload phase
      _completedDownloadSpeed = (downloadSpeed as num).toDouble();

      // Extract latency (RTT for TCP, jitter for UDP)
      final latency = _useUdp
          ? (downloadResult['jitter'] ?? 0.0)
          : (downloadResult['rtt'] ?? 0.0);

      // Set phase to upload
      _isDownloadPhase = false;

      // Run upload test (normal mode - client sends to server)
      final uploadResult = await _iperf3Service.runClient(
        serverHost: serverHost,
        port: _serverPort,
        durationSeconds: _testDuration,
        parallelStreams: _parallelStreams,
        reverse: false,
        useUdp: _useUdp,
        bandwidthMbps: _useUdp ? _bandwidthMbps : null,
      );

      if (uploadResult['success'] != true) {
        final error = uploadResult['error'] ?? 'Upload test failed';
        LoggerService.warning('Upload failed on $serverHost: $error',
            tag: 'SpeedTestService');
        return null;
      }

      final uploadSpeed = uploadResult['sendMbps'] ?? 0.0;

      // Create result
      return SpeedTestResult(
        downloadSpeed: (downloadSpeed as num).toDouble(),
        uploadSpeed: (uploadSpeed as num).toDouble(),
        latency: (latency as num).toDouble(),
        timestamp: DateTime.now(),
        localIpAddress: localIp,
        serverHost: serverHost,
      );
    } catch (e) {
      LoggerService.error('Test error with $serverHost: $e',
          tag: 'SpeedTestService');
      return null;
    }
  }

  /// Legacy method - now calls runSpeedTestWithFallback
  Future<void> runSpeedTest() async {
    await runSpeedTestWithFallback();
  }

  void _setErrorResult(String message) {
    final result = SpeedTestResult.error(message);
    _lastResult = result;
    _resultController.add(result);
    _updateStatus(SpeedTestStatus.error);
  }

  Future<void> cancelTest() async {
    if (_status != SpeedTestStatus.running) return;

    try {
      await _iperf3Service.cancelClient();
      _updateStatus(SpeedTestStatus.idle);
      _progress = 0.0;
      _progressController.add(_progress);
    } catch (e) {
      LoggerService.error('Failed to cancel speed test: $e',
          tag: 'SpeedTestService');
    }
  }

  /// Resolve the server host with cascade fallback
  ///
  /// Fallback order:
  /// 1. Default gateway (network address + 1)
  /// 2. Speed test target from config
  Future<String?> resolveServerWithFallback({String? configTarget}) async {
    // Step 1: Try default gateway
    try {
      final gateway = await _gatewayService.getWifiGateway();

      if (gateway != null && gateway.isNotEmpty) {
        return gateway;
      }
    } catch (e) {
      LoggerService.error('Gateway detection error: $e',
          tag: 'SpeedTestService');
    }

    // Step 2: Try speed test config target
    if (configTarget != null && configTarget.isNotEmpty) {
      return configTarget;
    }

    // No server available
    return null;
  }

  Future<void> updateConfiguration({
    String? serverHost,
    int? serverPort,
    int? testDuration,
    bool? useUdp,
    int? bandwidthMbps,
    int? parallelStreams,
  }) async {
    if (serverHost != null) _serverHost = serverHost;
    if (serverPort != null) _serverPort = serverPort;
    if (testDuration != null) _testDuration = testDuration;
    if (useUdp != null) _useUdp = useUdp;
    if (bandwidthMbps != null) _bandwidthMbps = bandwidthMbps;
    if (parallelStreams != null) _parallelStreams = parallelStreams;

    await _saveConfiguration();
  }

  Future<void> _loadConfiguration() async {
    try {
      _serverHost = _prefs?.getString('speed_test_server_host') ?? '';
      _serverPort = _prefs?.getInt('speed_test_server_port') ?? 5201;
      _testDuration = _prefs?.getInt('speed_test_duration') ?? 10;
      _useUdp =
          _prefs?.getBool('speed_test_use_udp') ?? true; // Default to UDP
      _bandwidthMbps = _prefs?.getInt('speed_test_bandwidth_mbps') ?? 500;
      _parallelStreams = _prefs?.getInt('speed_test_parallel_streams') ?? 16;
    } catch (e) {
      LoggerService.error('Failed to load speed test configuration: $e',
          tag: 'SpeedTestService');
    }
  }

  Future<void> _saveConfiguration() async {
    try {
      await _prefs?.setString('speed_test_server_host', _serverHost);
      await _prefs?.setInt('speed_test_server_port', _serverPort);
      await _prefs?.setInt('speed_test_duration', _testDuration);
      await _prefs?.setBool('speed_test_use_udp', _useUdp);
      await _prefs?.setInt('speed_test_bandwidth_mbps', _bandwidthMbps);
      await _prefs?.setInt('speed_test_parallel_streams', _parallelStreams);
    } catch (e) {
      LoggerService.error('Failed to save speed test configuration: $e',
          tag: 'SpeedTestService');
    }
  }

  Future<void> _loadLastResult() async {
    try {
      final resultJson = _prefs?.getString('speed_test_last_result');
      if (resultJson != null) {
        final map = Map<String, dynamic>.from(
          await compute(_parseJson, resultJson),
        );
        _lastResult = SpeedTestResult.fromJson(map);
      }
    } catch (e) {
      LoggerService.error('Failed to load last speed test result: $e',
          tag: 'SpeedTestService');
    }
  }

  Future<void> _saveLastResult(SpeedTestResult result) async {
    try {
      final json = await compute(_encodeJson, result.toJson());
      await _prefs?.setString('speed_test_last_result', json);
    } catch (e) {
      LoggerService.error('Failed to save speed test result: $e',
          tag: 'SpeedTestService');
    }
  }

  static Map<String, dynamic> _parseJson(String json) {
    return Map<String, dynamic>.from(
      const JsonCodec().decode(json) as Map,
    );
  }

  static String _encodeJson(Map<String, dynamic> map) {
    return const JsonCodec().encode(map);
  }

  void dispose() {
    _progressSubscription?.cancel();
    _statusController.close();
    _resultController.close();
    _progressController.close();
    _statusMessageController.close();
  }
}
