import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/core/widgets/widgets.dart';
import 'package:rgnets_fdk/features/devices/domain/constants/device_types.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:rgnets_fdk/features/speed_test/presentation/widgets/speed_test_popup.dart';

/// A section that displays speed test results for a specific device
/// and allows running new speed tests.
class DeviceSpeedTestSection extends ConsumerStatefulWidget {
  const DeviceSpeedTestSection({
    required this.device,
    super.key,
  });

  final Device device;

  @override
  ConsumerState<DeviceSpeedTestSection> createState() =>
      _DeviceSpeedTestSectionState();
}

class _DeviceSpeedTestSectionState
    extends ConsumerState<DeviceSpeedTestSection> {
  List<SpeedTestResult> _deviceResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceResults();
  }

  /// Get prefixed device ID for speed test lookups.
  /// If already prefixed (e.g., "ap_1307"), return as-is.
  /// If raw (e.g., "1307"), add prefix based on device type.
  String _getPrefixedDeviceId() {
    final id = widget.device.id;
    // Check if already prefixed
    if (id.startsWith('ap_') || id.startsWith('ont_')) {
      return id;
    }
    // Add prefix based on device type
    final prefix = widget.device.type == DeviceTypes.accessPoint ? 'ap' : 'ont';
    return '${prefix}_$id';
  }

  int? _getNumericDeviceId() {
    final id = widget.device.id;
    final parts = id.split('_');
    final rawId = parts.length >= 2 ? parts.sublist(1).join('_') : id;
    return int.tryParse(rawId);
  }

  void _loadDeviceResults() {
    final cacheIntegration = ref.read(webSocketCacheIntegrationProvider);
    final List<SpeedTestResult> results;
    if (widget.device.type == DeviceTypes.accessPoint) {
      final apId = _getNumericDeviceId();
      results = apId == null
          ? <SpeedTestResult>[]
          : cacheIntegration.getSpeedTestResultsForAccessPointId(apId);
    } else {
      results = cacheIntegration.getSpeedTestResultsForDevice(
        _getPrefixedDeviceId(),
        deviceType: widget.device.type,
      );
    }

    LoggerService.info(
      'Loaded ${results.length} speed test result(s) for device ${_getPrefixedDeviceId()}',
      tag: 'DeviceSpeedTestSection',
    );

    if (mounted) {
      setState(() {
        _deviceResults = results;
        _isLoading = false;
      });
    }
  }

  String _formatSpeed(double speed) {
    if (speed < 1000.0) {
      return '${speed.toStringAsFixed(2)} Mbps';
    } else {
      return '${(speed / 1000).toStringAsFixed(2)} Gbps';
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}d ago';
    } else {
      return '${(diff.inDays / 30).floor()}mo ago';
    }
  }

  Future<void> _runSpeedTest() async {
    if (!mounted) return;

    final cacheIntegration = ref.read(webSocketCacheIntegrationProvider);

    // Try to get config from the device's existing results (uses the same test config)
    SpeedTestConfig? config;
    if (_deviceResults.isNotEmpty) {
      final speedTestId = _deviceResults.first.speedTestId;
      config = cacheIntegration.getSpeedTestConfigById(speedTestId);
      if (config != null) {
        LoggerService.info(
          'Running speed test for device ${_getPrefixedDeviceId()} with config from result: ${config.name} (id: $speedTestId)',
          tag: 'DeviceSpeedTestSection',
        );
      }
    }

    // Fall back to adhoc config if no matching config found
    config ??= cacheIntegration.getAdhocSpeedTestConfig();

    if (config != null) {
      LoggerService.info(
        'Running speed test for device ${_getPrefixedDeviceId()} with config: ${config.name}',
        tag: 'DeviceSpeedTestSection',
      );
    }

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SpeedTestPopup(
          cachedTest: config,
          apId: widget.device.type == DeviceTypes.accessPoint
              ? _getNumericDeviceId()
              : null,
          onCompleted: () {
            if (mounted) {
              // Reload results after test completion
              _loadDeviceResults();
            }
          },
          onResultSubmitted: (result) async {
            if (!result.hasError) {
              await _submitDeviceResult(result);
            }
          },
        );
      },
    );
  }

  Future<void> _submitDeviceResult(SpeedTestResult result) async {
    try {
      final prefixedId = _getPrefixedDeviceId();
      LoggerService.info(
        'Updating speed test result for device $prefixedId: '
        'download=${result.downloadMbps}, upload=${result.uploadMbps}',
        tag: 'DeviceSpeedTestSection',
      );

      final cacheIntegration = ref.read(webSocketCacheIntegrationProvider);
      final success = await cacheIntegration.updateDeviceSpeedTestResult(
        deviceId: prefixedId,
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
          'Speed test result updated successfully for device $prefixedId',
          tag: 'DeviceSpeedTestSection',
        );
        if (mounted) {
          // Refresh the displayed results
          _loadDeviceResults();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Speed test result submitted successfully'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        LoggerService.warning(
          'Speed test submission failed for device $prefixedId - no existing result found',
          tag: 'DeviceSpeedTestSection',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Speed test submission failed - no existing result found'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.error(
        'Error updating speed test result for device ${_getPrefixedDeviceId()}',
        error: e,
        tag: 'DeviceSpeedTestSection',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error submitting speed test result'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildResultCard(SpeedTestResult result) {
    final passedColor = result.passed ? AppColors.success : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: passedColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: passedColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with timestamp and status
          Row(
            children: [
              Icon(
                result.passed ? Icons.check_circle : Icons.warning_amber,
                color: passedColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                result.passed ? 'PASSED' : 'BELOW THRESHOLD',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: passedColor,
                ),
              ),
              const Spacer(),
              Text(
                _getTimeAgo(result.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Speed metrics row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSpeedMetric(
                'Download',
                result.downloadSpeed,
                Icons.download,
                AppColors.success,
              ),
              _buildSpeedMetric(
                'Upload',
                result.uploadSpeed,
                Icons.upload,
                AppColors.info,
              ),
              _buildSpeedMetric(
                'Latency',
                result.latency,
                Icons.timer,
                Colors.orange,
                isLatency: true,
              ),
            ],
          ),

          // Server info
          if (result.destination != null || result.serverHost != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.dns, size: 12, color: AppColors.gray500),
                const SizedBox(width: 4),
                Text(
                  'Server: ${result.destination ?? result.serverHost}',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.gray500,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpeedMetric(
    String label,
    double value,
    IconData icon,
    Color color, {
    bool isLatency = false,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 2),
        Text(
          isLatency ? '${value.toStringAsFixed(0)} ms' : _formatSpeed(value),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SectionCard(
        title: 'Speed Test',
        children: [
          Center(child: LoadingIndicator()),
        ],
      );
    }

    final latestResult =
        _deviceResults.isNotEmpty ? _deviceResults.first : null;

    return SectionCard(
      title: 'Speed Test',
      children: [
        // Show latest result if available
        if (latestResult != null) ...[
          _buildResultCard(latestResult),

          // Show count of previous results
          if (_deviceResults.length > 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${_deviceResults.length - 1} previous test(s) available',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.gray500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ] else ...[
          // No results placeholder
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(
                  Icons.speed,
                  size: 40,
                  color: AppColors.gray500,
                ),
                const SizedBox(height: 8),
                Text(
                  'No speed tests run for this device',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ],

        // Run test button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _runSpeedTest,
            icon: Icon(
              latestResult != null ? Icons.refresh : Icons.play_arrow,
              size: 18,
            ),
            label: Text(
              latestResult != null ? 'Run New Test' : 'Run Speed Test',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
