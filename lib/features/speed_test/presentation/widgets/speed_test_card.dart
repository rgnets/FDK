import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';
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
  @override
  void initState() {
    super.initState();
    // Initialize the notifier (idempotent - safe to call multiple times)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(speedTestRunNotifierProvider.notifier).initialize();
    });
  }

  String _formatSpeed(double speed) {
    if (speed < 1000.0) {
      return '${speed.toStringAsFixed(2)} Mbps';
    } else {
      return '${(speed / 1000).toStringAsFixed(2)} Gbps';
    }
  }

  String _getLastTestTime(SpeedTestResult? lastResult) {
    if (lastResult == null) return 'Never';

    final now = DateTime.now();
    final timestamp = lastResult.completedAt ?? lastResult.timestamp;
    final diff = now.difference(timestamp);

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

    // Get adhoc config from cache (pre-loaded at WebSocket connect)
    final cacheIntegration = ref.read(webSocketCacheIntegrationProvider);
    final adhocConfig = cacheIntegration.getAdhocSpeedTestConfig();

    if (adhocConfig != null) {
      LoggerService.info(
        'Using adhoc config from cache: ${adhocConfig.name} (id: ${adhocConfig.id})',
        tag: 'SpeedTestCard',
      );
    } else {
      LoggerService.info(
        'No configs in cache - running adhoc test without config',
        tag: 'SpeedTestCard',
      );
    }

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SpeedTestPopup(
          cachedTest: adhocConfig,
          onCompleted: () {
            if (mounted) {
              LoggerService.info(
                'Speed test completed - UI will update via Riverpod',
                tag: 'SpeedTestCard',
              );
            }
          },
          onResultSubmitted: (result) async {
            if (!result.hasError) {
              await _submitAdhocResult(result);
            }
          },
        );
      },
    );
  }

  /// Submit adhoc speed test result to the server via WebSocket cache integration
  Future<void> _submitAdhocResult(SpeedTestResult result) async {
    try {
      LoggerService.info(
        'Submitting adhoc speed test result: '
        'source=${result.source}, '
        'destination=${result.destination}, '
        'download=${result.downloadMbps}, '
        'upload=${result.uploadMbps}, '
        'ping=${result.rtt}',
        tag: 'SpeedTestCard',
      );

      final cacheIntegration = ref.read(webSocketCacheIntegrationProvider);
      final success = await cacheIntegration.createAdhocSpeedTestResult(
        downloadSpeed: result.downloadMbps ?? 0,
        uploadSpeed: result.uploadMbps ?? 0,
        latency: result.rtt ?? 0,
        source: result.source,
        destination: result.destination,
        port: result.port,
        protocol: result.iperfProtocol,
        passed: result.passed,
      );

      if (success) {
        LoggerService.info(
          'Adhoc speed test result submitted successfully',
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
      builder: (BuildContext dialogContext) {
        return Consumer(
          builder: (context, ref, child) {
            final testState = ref.watch(speedTestRunNotifierProvider);
            final notifier = ref.read(speedTestRunNotifierProvider.notifier);

            return AlertDialog(
              title: const Text('Speed Test Settings'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text('Use UDP Protocol'),
                      subtitle: Text(testState.useUdp
                          ? 'UDP (faster, less reliable)'
                          : 'TCP (slower, more reliable)'),
                      value: testState.useUdp,
                      onChanged: (value) {
                        notifier.updateConfiguration(useUdp: value);
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.router),
                      title: const Text('Default Gateway'),
                      subtitle: Text(
                          '${testState.serverHost}:${testState.serverPort}'),
                      trailing: const Icon(Icons.info_outline),
                    ),
                    ListTile(
                      title: const Text('Test Duration'),
                      subtitle: Text('${testState.testDuration} seconds'),
                      trailing: const Icon(Icons.timer),
                    ),
                    ListTile(
                      title: const Text('Bandwidth Limit'),
                      subtitle: Text('${testState.bandwidthMbps} Mbps'),
                      trailing: const Icon(Icons.speed),
                    ),
                    ListTile(
                      title: const Text('Parallel Streams'),
                      subtitle: Text('${testState.parallelStreams} streams'),
                      trailing: const Icon(Icons.stream),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(speedTestRunNotifierProvider);
    final status = testState.executionStatus;
    final lastResult = testState.completedResult;
    final hasError = lastResult?.hasError == true;

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
                    status == SpeedTestStatus.running
                        ? Icons.speed
                        : Icons.network_check,
                    color: status == SpeedTestStatus.running
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
                          testState.useUdp
                              ? 'UDP Protocol'
                              : 'TCP Protocol',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.gray500),
                        ),
                        if (testState.localIpAddress != null ||
                            testState.serverHost.isNotEmpty)
                          Text(
                            '${testState.localIpAddress ?? "Unknown"} → ${testState.serverHost}',
                            style: TextStyle(
                                fontSize: 9, color: AppColors.gray500),
                          ),
                      ],
                    ),
                  ),
                  if (lastResult != null && !hasError)
                    Text(
                      _getLastTestTime(lastResult),
                      style: TextStyle(fontSize: 10, color: AppColors.gray500),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Results or placeholder
              if (lastResult != null && !hasError) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSpeedMetric('Down', testState.downloadSpeed,
                        AppColors.success, Icons.download),
                    _buildSpeedMetric('Up', testState.uploadSpeed,
                        AppColors.info, Icons.upload),
                    _buildSpeedMetric(
                        'Ping', testState.latency, Colors.orange, Icons.timer,
                        isLatency: true),
                  ],
                ),
              ] else if (hasError) ...[
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline,
                          size: 32, color: AppColors.error),
                      const SizedBox(height: 4),
                      const Text('Test failed',
                          style:
                              TextStyle(color: AppColors.error, fontSize: 12)),
                      if (testState.errorMessage != null)
                        Text(
                          testState.errorMessage!,
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
              if (status == SpeedTestStatus.running) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: testState.progress / 100,
                  backgroundColor: AppColors.gray700,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${testState.progress.toStringAsFixed(0)}% Complete',
                      style: TextStyle(fontSize: 10, color: AppColors.gray500),
                    ),
                    if (testState.serverHost.isNotEmpty)
                      Text(
                        'Testing to ${testState.serverHost}',
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
                  onPressed: status == SpeedTestStatus.running
                      ? null
                      : _showSpeedTestPopup,
                  icon: Icon(
                    status == SpeedTestStatus.running
                        ? Icons.speed
                        : (hasError ? Icons.refresh : Icons.play_arrow),
                    size: 14,
                  ),
                  label: Text(
                    status == SpeedTestStatus.running
                        ? 'Test Running...'
                        : (hasError ? 'Retry Test' : 'Run Test'),
                    style: const TextStyle(fontSize: 11),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: status == SpeedTestStatus.running
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
