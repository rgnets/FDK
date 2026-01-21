import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_status.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/presentation/providers/speed_test_providers.dart';

class SpeedTestPopup extends ConsumerStatefulWidget {
  /// The speed test configuration
  final SpeedTestConfig? cachedTest;

  final VoidCallback? onCompleted;

  /// Callback when result should be submitted (auto-called when test passes)
  final void Function(SpeedTestResult result)? onResultSubmitted;

  const SpeedTestPopup({
    super.key,
    this.cachedTest,
    this.onCompleted,
    this.onResultSubmitted,
  });

  @override
  ConsumerState<SpeedTestPopup> createState() => _SpeedTestPopupState();
}

class _SpeedTestPopupState extends ConsumerState<SpeedTestPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _resultSubmitted = false;

  @override
  void initState() {
    super.initState();
    _initializePulseAnimation();
    // Initialize notifier (idempotent)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(speedTestRunNotifierProvider.notifier).initialize();
    });
  }

  void _initializePulseAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /// Get the effective config
  SpeedTestConfig? get _effectiveConfig => widget.cachedTest;

  double? _getMinDownload() => _effectiveConfig?.minDownloadMbps;
  double? _getMinUpload() => _effectiveConfig?.minUploadMbps;
  String? _getConfigTarget() => _effectiveConfig?.target;
  String? _getConfigName() => _effectiveConfig?.name;

  Future<void> _startTest() async {
    final notifier = ref.read(speedTestRunNotifierProvider.notifier);
    final configTarget = _getConfigTarget();

    await notifier.startTest(
      config: _effectiveConfig,
      configTarget: configTarget,
    );
  }

  Future<void> _cancelTest() async {
    await ref.read(speedTestRunNotifierProvider.notifier).cancelTest();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _handleTestCompleted() {
    if (_resultSubmitted) return;

    final testState = ref.read(speedTestRunNotifierProvider);
    final result = testState.completedResult;

    if (result == null) return;

    // Submit result via callback if provided
    if (widget.onResultSubmitted != null) {
      final submitResult = SpeedTestResult(
        downloadMbps: testState.downloadSpeed,
        uploadMbps: testState.uploadSpeed,
        rtt: testState.latency,
        localIpAddress: testState.localIpAddress,
        serverHost: testState.serverHost,
        speedTestId: _effectiveConfig?.id,
        passed: testState.testPassed ?? false,
        initiatedAt: result.initiatedAt,
        completedAt: DateTime.now(),
        testType: 'iperf3',
        source: testState.localIpAddress,
        destination: testState.serverHost,
        port: testState.serverPort,
        iperfProtocol: testState.useUdp ? 'udp' : 'tcp',
      );

      LoggerService.info(
        'SpeedTestPopup: Auto-submitting result - passed=${testState.testPassed}, '
        'download=${testState.downloadSpeed}, upload=${testState.uploadSpeed}',
        tag: 'SpeedTestPopup',
      );

      widget.onResultSubmitted?.call(submitResult);
      _resultSubmitted = true;
    }
  }

  String _formatSpeed(double speed) {
    if (speed < 1000.0) {
      return '${speed.toStringAsFixed(2)} Mbps';
    } else {
      return '${(speed / 1000).toStringAsFixed(2)} Gbps';
    }
  }

  Color _getStatusColor(SpeedTestStatus status) {
    switch (status) {
      case SpeedTestStatus.running:
        return AppColors.primary;
      case SpeedTestStatus.completed:
        return AppColors.success;
      case SpeedTestStatus.error:
        return AppColors.error;
      default:
        return AppColors.gray500;
    }
  }

  IconData _getStatusIcon(SpeedTestStatus status) {
    switch (status) {
      case SpeedTestStatus.running:
        return Icons.speed;
      case SpeedTestStatus.completed:
        return Icons.check_circle;
      case SpeedTestStatus.error:
        return Icons.error;
      default:
        return Icons.network_check;
    }
  }

  Widget _buildSpeedIndicator(
      String label, double value, IconData icon, Color color,
      {double? minRequired}) {
    final fixedHeight = minRequired != null ? 130.0 : 110.0;
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: BoxConstraints(
        minHeight: fixedHeight,
        maxHeight: fixedHeight,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 110,
            child: Text(
              _formatSpeed(value),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: 110,
            child: Text(
              minRequired != null
                  ? 'Min: ${_formatSpeed(minRequired)}'
                  : 'Min: Not set',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 8,
                color: AppColors.gray400,
                fontStyle: FontStyle.italic,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatencyIndicator(double latency) {
    return Container(
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(
        minHeight: 110,
        maxHeight: 110,
      ),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, color: Colors.orange, size: 24),
          const SizedBox(height: 6),
          SizedBox(
            width: 110,
            child: Text(
              '${latency.toStringAsFixed(0)} ms',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Latency',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(speedTestRunNotifierProvider);
    final status = testState.executionStatus;
    final testPassed = testState.testPassed;

    // Auto-submit when test completes
    if (status == SpeedTestStatus.completed && !_resultSubmitted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleTestCompleted();
      });
    }

    return PopScope(
      canPop: status != SpeedTestStatus.running,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with status icon
                Row(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: status == SpeedTestStatus.running
                              ? _pulseAnimation.value
                              : 1.0,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getStatusColor(status).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getStatusIcon(status),
                              color: _getStatusColor(status),
                              size: 32,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Speed Test',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            testState.statusMessage ?? 'Ready to start',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (status != SpeedTestStatus.running)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          widget.onCompleted?.call();
                          Navigator.of(context).pop();
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                // Connection info
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.gray800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // Local IP row
                      Row(
                        children: [
                          Icon(
                            testState.localIpAddress != null
                                ? Icons.computer
                                : Icons.location_off,
                            size: 16,
                            color: testState.localIpAddress != null
                                ? AppColors.gray500
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Device: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray500,
                            ),
                          ),
                          if (testState.localIpAddress != null)
                            Text(
                              testState.localIpAddress!,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.gray300,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else
                            Text(
                              'Grant location permission',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Server row
                      Row(
                        children: [
                          Icon(Icons.dns, size: 16, color: AppColors.gray500),
                          const SizedBox(width: 8),
                          Text(
                            'Test Server: ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray500,
                            ),
                          ),
                          Text(
                            'Target',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (testState.serverHost.isNotEmpty) ...[
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '(${testState.serverHost})',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.gray500,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Requirements section (shown when config has thresholds)
                if (_effectiveConfig != null &&
                    (_getMinDownload() != null || _getMinUpload() != null)) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.assignment,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getConfigName() ?? 'Speed Test Requirements',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            // Download requirement
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.download,
                                    size: 14,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Min: ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.gray400,
                                    ),
                                  ),
                                  Text(
                                    _getMinDownload() != null
                                        ? _formatSpeed(_getMinDownload()!)
                                        : 'None',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gray300,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Upload requirement
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.upload,
                                    size: 14,
                                    color: AppColors.info,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Min: ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.gray400,
                                    ),
                                  ),
                                  Text(
                                    _getMinUpload() != null
                                        ? _formatSpeed(_getMinUpload()!)
                                        : 'None',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.gray300,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Server fallback info
                        if (_getConfigTarget() != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.swap_horiz,
                                size: 14,
                                color: AppColors.gray500,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Gateway first, then ${_getConfigTarget()}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.gray500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Speed indicators
                SizedBox(
                  height: 130,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSpeedIndicator(
                          'Download',
                          testState.downloadSpeed,
                          Icons.download,
                          AppColors.success,
                          minRequired: _getMinDownload(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSpeedIndicator(
                          'Upload',
                          testState.uploadSpeed,
                          Icons.upload,
                          AppColors.info,
                          minRequired: _getMinUpload(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Latency indicator
                SizedBox(
                  height: 110,
                  child: _buildLatencyIndicator(testState.latency),
                ),

                const SizedBox(height: 20),

                // Progress indicator
                if (status == SpeedTestStatus.running) ...[
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _getStatusColor(status)),
                            strokeWidth: 4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          testState.statusMessage ?? 'Testing...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Error message
                if (testState.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            testState.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Threshold failure alert
                if (status == SpeedTestStatus.completed &&
                    testPassed == false) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: AppColors.warning, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Speed Test Below Threshold',
                                style: TextStyle(
                                  color: AppColors.warning,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'This result does not meet the minimum speed requirements.',
                                style: TextStyle(
                                  color: AppColors.gray400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Action buttons
                const SizedBox(height: 16),

                if (status == SpeedTestStatus.idle) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _cancelTest,
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Cancel'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gray400,
                            side: BorderSide(color: AppColors.gray600),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _startTest,
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                if (status == SpeedTestStatus.running) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _cancelTest,
                      icon: const Icon(Icons.stop, size: 16),
                      label: const Text('Cancel Test'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                    ),
                  ),
                ],

                if (status == SpeedTestStatus.completed) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            widget.onCompleted?.call();
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Close'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gray400,
                            side: BorderSide(color: AppColors.gray600),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _resultSubmitted = false;
                            ref
                                .read(speedTestRunNotifierProvider.notifier)
                                .reset();
                            _startTest();
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Run Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                if (status == SpeedTestStatus.error) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Close'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.gray400,
                            side: BorderSide(color: AppColors.gray600),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _resultSubmitted = false;
                            ref
                                .read(speedTestRunNotifierProvider.notifier)
                                .reset();
                            _startTest();
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
