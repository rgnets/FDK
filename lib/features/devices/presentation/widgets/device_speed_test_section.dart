import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/core/widgets/widgets.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:rgnets_fdk/features/speed_test/presentation/providers/speed_test_providers.dart';
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
  int? _getNumericDeviceId() {
    final id = widget.device.id;
    final parts = id.split('_');
    final rawId = parts.length >= 2 ? parts.sublist(1).join('_') : id;
    return int.tryParse(rawId);
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

  Future<void> _runSpeedTest(List<SpeedTestResult> deviceResults) async {
    if (!mounted) return;

    final cacheIntegration = ref.read(webSocketCacheIntegrationProvider);

    // Try to get config from the device's existing results (uses the same test config)
    SpeedTestConfig? config;
    if (deviceResults.isNotEmpty) {
      final speedTestId = deviceResults.first.speedTestId;
      config = cacheIntegration.getSpeedTestConfigById(speedTestId);
    }

    config ??= cacheIntegration.getAdhocSpeedTestConfig();

    final apId = _getNumericDeviceId();

    // Get the existing result to update (if any)
    final existingResult = deviceResults.isNotEmpty ? deviceResults.first : null;

    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SpeedTestPopup(
          cachedTest: config,
          onCompleted: () {
            if (mounted) {
              // Invalidate provider to refresh results
              ref.invalidate(
                speedTestResultsNotifierProvider(accessPointId: apId),
              );
            }
          },
          onResultSubmitted: (result) async {
            if (!result.hasError) {
              await _submitDeviceResult(result, existingResult);
            }
          },
        );
      },
    );
  }

  /// Update existing speed test result with new test data.
  Future<void> _submitDeviceResult(
    SpeedTestResult newTestResult,
    SpeedTestResult? existingResult,
  ) async {
    if (existingResult == null || existingResult.id == null) {
      LoggerService.warning(
        'DeviceSpeedTestSection: Cannot update - no existing result',
        tag: 'DeviceSpeedTestSection',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No existing result to update'),
            backgroundColor: AppColors.warning,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      final updatedResult = existingResult.copyWith(
        downloadMbps: newTestResult.downloadMbps,
        uploadMbps: newTestResult.uploadMbps,
        rtt: newTestResult.rtt,
        jitter: newTestResult.jitter,
        passed: newTestResult.passed,
        source: newTestResult.source,
        destination: newTestResult.destination,
        port: newTestResult.port,
        iperfProtocol: newTestResult.iperfProtocol,
        initiatedAt: newTestResult.initiatedAt,
        completedAt: newTestResult.completedAt,
      );

      final apId = _getNumericDeviceId();
      final response = await ref
          .read(speedTestRepositoryProvider)
          .updateSpeedTestResult(updatedResult);

      response.fold(
        (failure) {
          LoggerService.warning(
            'DeviceSpeedTestSection: Update failed: ${failure.message}',
            tag: 'DeviceSpeedTestSection',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Update failed: ${failure.message}'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        (updated) {
          if (mounted) {
            ref.invalidate(
              speedTestResultsNotifierProvider(accessPointId: apId),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Speed test result updated successfully'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
      );
    } catch (e) {
      LoggerService.error(
        'DeviceSpeedTestSection: Error updating result',
        error: e,
        tag: 'DeviceSpeedTestSection',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating speed test result'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showMarkNotApplicableConfirmation(SpeedTestResult result) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Mark as Not Applicable?'),
        content: const Text(
          'This speed test will be marked as not applicable. '
          'The result will be excluded from readiness calculations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _markResultNotApplicable(result);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _markResultNotApplicable(SpeedTestResult result) async {
    if (result.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot update result without ID')),
      );
      return;
    }

    try {
      final updated = result.copyWith(isApplicable: false);
      final apId = _getNumericDeviceId();

      // Use notifier's updateResult which auto-refreshes
      final updatedResult = await ref
          .read(speedTestResultsNotifierProvider(accessPointId: apId).notifier)
          .updateResult(updated);

      if (updatedResult != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speed test marked as not applicable'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update speed test'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _markResultApplicable(SpeedTestResult result) async {
    if (result.id == null) return;

    try {
      final updated = result.copyWith(isApplicable: true);
      final apId = _getNumericDeviceId();

      // Use notifier's updateResult which auto-refreshes
      final updatedResult = await ref
          .read(speedTestResultsNotifierProvider(accessPointId: apId).notifier)
          .updateResult(updated);

      if (updatedResult != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speed test marked as applicable'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update speed test'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
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

          // Not Applicable indicator and toggle
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!result.isApplicable)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gray600.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'NOT APPLICABLE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray400,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              TextButton.icon(
                onPressed: () => result.isApplicable
                    ? _showMarkNotApplicableConfirmation(result)
                    : _markResultApplicable(result),
                icon: Icon(
                  result.isApplicable
                      ? Icons.remove_circle_outline
                      : Icons.check_circle_outline,
                  size: 14,
                  color:
                      result.isApplicable ? AppColors.warning : AppColors.success,
                ),
                label: Text(
                  result.isApplicable ? 'Mark N/A' : 'Mark Applicable',
                  style: TextStyle(
                    fontSize: 10,
                    color: result.isApplicable
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
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
    final apId = _getNumericDeviceId();

    // Watch the provider for reactive updates
    final resultsAsync = ref.watch(
      speedTestResultsNotifierProvider(accessPointId: apId),
    );

    return resultsAsync.when(
      loading: () => const SectionCard(
        title: 'Speed Test',
        children: [
          Center(child: LoadingIndicator()),
        ],
      ),
      error: (error, stack) => SectionCard(
        title: 'Speed Test',
        children: [
          Center(
            child: Text(
              'Error loading results',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
      data: (deviceResults) {
        final latestResult =
            deviceResults.isNotEmpty ? deviceResults.first : null;

        return SectionCard(
          title: 'Speed Test',
          children: [
            // Show latest result if available
            if (latestResult != null) ...[
              _buildResultCard(latestResult),

              // Show count of previous results
              if (deviceResults.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${deviceResults.length - 1} previous test(s) available',
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

            // Run test button - hide if result is not applicable
            if (latestResult == null || latestResult.isApplicable)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _runSpeedTest(deviceResults),
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
      },
    );
  }
}
