import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/speed_test/data/services/speed_test_service.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_status.dart';
import 'package:rgnets_fdk/features/speed_test/presentation/providers/speed_test_providers.dart';
import 'package:rgnets_fdk/features/speed_test/presentation/widgets/speed_test_popup.dart';

class SpeedTestCard extends ConsumerStatefulWidget {
  const SpeedTestCard({super.key});

  @override
  ConsumerState<SpeedTestCard> createState() => _SpeedTestCardState();
}

class _SpeedTestCardState extends ConsumerState<SpeedTestCard> {
  final SpeedTestService _speedTestService = SpeedTestService();
  SpeedTestStatus _status = SpeedTestStatus.idle;
  SpeedTestResult? _lastResult;
  double _progress = 0.0;
  StreamSubscription<SpeedTestStatus>? _statusSubscription;
  StreamSubscription<SpeedTestResult>? _resultSubscription;
  StreamSubscription<double>? _progressSubscription;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _speedTestService.initialize();

    _status = _speedTestService.status;
    _lastResult = _speedTestService.lastResult;

    _statusSubscription = _speedTestService.statusStream.listen((status) {
      if (mounted) {
        setState(() => _status = status);
      }
    });

    _resultSubscription = _speedTestService.resultStream.listen((result) {
      if (mounted) {
        setState(() => _lastResult = result);
      }
    });

    _progressSubscription = _speedTestService.progressStream.listen((progress) {
      if (mounted) {
        setState(() => _progress = progress);
      }
    });

    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _resultSubscription?.cancel();
    _progressSubscription?.cancel();
    super.dispose();
  }

  String _formatSpeed(double speed) {
    if (speed < 1000.0) {
      return '${speed.toStringAsFixed(2)} Mbps';
    } else {
      return '${(speed / 1000).toStringAsFixed(2)} Gbps';
    }
  }

  String _getLastTestTime() {
    if (_lastResult == null) return 'Never';

    final now = DateTime.now();
    final diff = now.difference(_lastResult!.timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  Widget _buildSpeedMetric(
      String label, double value, Color color, IconData icon,
      {bool isLatency = false}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          isLatency ? '${value.toStringAsFixed(0)} ms' : _formatSpeed(value),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: AppColors.gray500),
        ),
      ],
    );
  }

  Future<void> _showSpeedTestPopup() async {
    if (!mounted) return;

    // Get available configs from provider - use first config if available (adhoc)
    final configsAsync = ref.read(speedTestConfigsNotifierProvider);
    final adhocConfig = configsAsync.whenOrNull(
      data: (configs) => configs.isNotEmpty ? configs.first : null,
    );

    if (adhocConfig != null) {
      LoggerService.info(
        'Using adhoc config: ${adhocConfig.name} (id: ${adhocConfig.id})',
        tag: 'SpeedTestCard',
      );
    } else {
      LoggerService.info(
        'No configs available - running adhoc test without config',
        tag: 'SpeedTestCard',
      );
    }

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SpeedTestPopup(
          cachedTest: adhocConfig,
          onCompleted: () async {
            if (mounted) {
              LoggerService.info(
                  'Speed test completed - reloading result for dashboard',
                  tag: 'SpeedTestCard');

              final result = _speedTestService.lastResult;
              setState(() {
                _lastResult = result;
              });

              // Submit adhoc result to server if test completed successfully
              if (result != null && !result.hasError) {
                await _submitAdhocResult(result, adhocConfig?.id);
              }
            }
          },
        );
      },
    );
  }

  /// Submit adhoc speed test result to the server
  Future<void> _submitAdhocResult(SpeedTestResult result, int? configId) async {
    try {
      LoggerService.info(
        'Submitting adhoc speed test result: '
        'source=${result.localIpAddress}, '
        'destination=${result.serverHost}, '
        'download=${result.downloadMbps}, '
        'upload=${result.uploadMbps}, '
        'ping=${result.rtt}',
        tag: 'SpeedTestCard',
      );

      // Check if requirements are met (for pass/fail determination)
      bool passed = true;
      if (configId != null) {
        final configsAsync = ref.read(speedTestConfigsNotifierProvider);
        final config = configsAsync.whenOrNull(
          data: (configs) => configs.where((c) => c.id == configId).firstOrNull,
        );

        if (config != null) {
          final downloadOk = config.minDownloadMbps == null ||
              (result.downloadMbps ?? 0) >= config.minDownloadMbps!;
          final uploadOk = config.minUploadMbps == null ||
              (result.uploadMbps ?? 0) >= config.minUploadMbps!;
          passed = downloadOk && uploadOk;
        }
      }

      // Create result with all required fields for submission
      final resultToSubmit = SpeedTestResult(
        speedTestId: configId,
        testType: 'iperf3',
        source: result.localIpAddress,
        destination: result.serverHost,
        port: _speedTestService.serverPort,
        iperfProtocol: _speedTestService.useUdp ? 'udp' : 'tcp',
        downloadMbps: result.downloadMbps,
        uploadMbps: result.uploadMbps,
        rtt: result.rtt,
        jitter: result.jitter,
        passed: passed,
        completedAt: DateTime.now(),
        localIpAddress: result.localIpAddress,
        serverHost: result.serverHost,
      );

      // Submit via provider
      final saved = await ref
          .read(speedTestResultsNotifierProvider().notifier)
          .createResult(resultToSubmit);

      if (saved != null) {
        LoggerService.info(
          'Adhoc speed test result submitted successfully: id=${saved.id}',
          tag: 'SpeedTestCard',
        );
      } else {
        LoggerService.warning(
          'Failed to submit adhoc speed test result',
          tag: 'SpeedTestCard',
        );
      }
    } catch (e) {
      LoggerService.error(
        'Error submitting adhoc speed test result',
        error: e,
        tag: 'SpeedTestCard',
      );
    }
  }

  void _showConfigDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Speed Test Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Use UDP Protocol'),
                  subtitle: Text(_speedTestService.useUdp
                      ? 'UDP (faster, less reliable)'
                      : 'TCP (slower, more reliable)'),
                  value: _speedTestService.useUdp,
                  onChanged: (value) {
                    _speedTestService.updateConfiguration(useUdp: value);
                    setState(() {});
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.router),
                  title: const Text('Default Gateway'),
                  subtitle: Text(
                      '${_speedTestService.serverHost}:${_speedTestService.serverPort}'),
                  trailing: const Icon(Icons.info_outline),
                ),
                ListTile(
                  title: const Text('Test Duration'),
                  subtitle: Text('${_speedTestService.testDuration} seconds'),
                  trailing: const Icon(Icons.timer),
                ),
                ListTile(
                  title: const Text('Bandwidth Limit'),
                  subtitle: Text('${_speedTestService.bandwidthMbps} Mbps'),
                  trailing: const Icon(Icons.speed),
                ),
                ListTile(
                  title: const Text('Parallel Streams'),
                  subtitle: Text('${_speedTestService.parallelStreams} streams'),
                  trailing: const Icon(Icons.stream),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: _showConfigDialog,
      child: Card(
        elevation: 2,
        color: AppColors.cardDark,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    _status == SpeedTestStatus.running
                        ? Icons.speed
                        : Icons.network_check,
                    color: _status == SpeedTestStatus.running
                        ? AppColors.primary
                        : AppColors.gray500,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Network Speed Test',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _speedTestService.useUdp
                              ? 'UDP Protocol'
                              : 'TCP Protocol',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.gray500),
                        ),
                        if (_lastResult?.localIpAddress != null ||
                            _lastResult?.serverHost != null)
                          Text(
                            '${_lastResult?.localIpAddress ?? "Unknown"} → ${_lastResult?.serverHost ?? _speedTestService.serverHost}',
                            style: TextStyle(
                                fontSize: 9, color: AppColors.gray500),
                          ),
                      ],
                    ),
                  ),
                  if (_lastResult != null && !_lastResult!.hasError)
                    Text(
                      _getLastTestTime(),
                      style: TextStyle(fontSize: 10, color: AppColors.gray500),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Results or placeholder
              if (_lastResult != null && !_lastResult!.hasError) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSpeedMetric('Down', _lastResult!.downloadSpeed,
                        AppColors.success, Icons.download),
                    _buildSpeedMetric('Up', _lastResult!.uploadSpeed,
                        AppColors.info, Icons.upload),
                    _buildSpeedMetric(
                        'Ping', _lastResult!.latency, Colors.orange, Icons.timer,
                        isLatency: true),
                  ],
                ),
              ] else if (_lastResult?.hasError == true) ...[
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 32, color: AppColors.error),
                      const SizedBox(height: 4),
                      const Text('Test failed',
                          style:
                              TextStyle(color: AppColors.error, fontSize: 12)),
                      if (_lastResult!.errorMessage != null)
                        Text(
                          _lastResult!.errorMessage!,
                          style: const TextStyle(
                              color: AppColors.error, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ] else ...[
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.speed, size: 32, color: AppColors.gray500),
                      const SizedBox(height: 4),
                      Text('No tests run yet',
                          style: TextStyle(
                              color: AppColors.gray500, fontSize: 12)),
                    ],
                  ),
                ),
              ],

              // Progress bar
              if (_status == SpeedTestStatus.running) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _progress / 100,
                  backgroundColor: AppColors.gray700,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_progress.toStringAsFixed(0)}% Complete',
                      style: TextStyle(fontSize: 10, color: AppColors.gray500),
                    ),
                    if (_speedTestService.serverHost.isNotEmpty)
                      Text(
                        'Testing to ${_speedTestService.serverHost}',
                        style: TextStyle(
                            fontSize: 9,
                            color: AppColors.gray500,
                            fontStyle: FontStyle.italic),
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 12),

              // Action button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _status == SpeedTestStatus.running
                      ? null
                      : _showSpeedTestPopup,
                  icon: Icon(
                    _status == SpeedTestStatus.running
                        ? Icons.speed
                        : (_lastResult?.hasError == true
                            ? Icons.refresh
                            : Icons.play_arrow),
                    size: 14,
                  ),
                  label: Text(
                    _status == SpeedTestStatus.running
                        ? 'Test Running...'
                        : (_lastResult?.hasError == true
                            ? 'Retry Test'
                            : 'Run Test'),
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _status == SpeedTestStatus.running
                        ? AppColors.gray600
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
