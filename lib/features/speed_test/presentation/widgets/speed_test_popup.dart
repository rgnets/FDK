import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/speed_test/data/services/speed_test_service.dart';
import 'package:rgnets_fdk/features/speed_test/data/services/network_gateway_service.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_status.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';

class SpeedTestPopup extends StatefulWidget {
  final SpeedTestConfig? cachedTest;
  final SpeedTestResult? existingResult;
  final int? pmsRoomId;
  final String? roomType;
  final int? testedViaAccessPointId;
  final int? testedViaMediaConverterId;
  final VoidCallback? onCompleted;
  final void Function(SpeedTestResult result)? onResultSubmitted;

  const SpeedTestPopup({
    super.key,
    this.cachedTest,
    this.existingResult,
    this.pmsRoomId,
    this.roomType,
    this.testedViaAccessPointId,
    this.testedViaMediaConverterId,
    this.onCompleted,
    this.onResultSubmitted,
  });

  @override
  State<SpeedTestPopup> createState() => _SpeedTestPopupState();
}

class _SpeedTestPopupState extends State<SpeedTestPopup>
    with SingleTickerProviderStateMixin {
  final SpeedTestService _speedTestService = SpeedTestService();

  SpeedTestStatus _status = SpeedTestStatus.idle;
  double _downloadSpeed = 0.0;
  double _uploadSpeed = 0.0;
  double _latency = 0.0;
  double _progress = 0.0;
  String _currentPhase = 'Ready to start';
  String? _localIp;
  String? _gatewayIp;
  String? _serverHost;
  String _serverLabel = 'Gateway';
  String? _errorMessage;
  bool _testPassed = false;

  StreamSubscription<SpeedTestStatus>? _statusSubscription;
  StreamSubscription<SpeedTestResult>? _resultSubscription;
  StreamSubscription<double>? _progressSubscription;
  StreamSubscription<String>? _statusMessageSubscription;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializePulseAnimation();
    _initializeService();
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

  Future<void> _initializeService() async {
    await _speedTestService.initialize();

    _status = SpeedTestStatus.idle;

    final gatewayService = NetworkGatewayService();
    _localIp = await gatewayService.getWifiIP();

    _gatewayIp = await gatewayService.getWifiGateway();
    _serverHost = _gatewayIp;
    _serverLabel = 'Gateway';

    if (_localIp == null) {
      LoggerService.warning(
          'Could not get device IP - location permission may be required on iOS',
          tag: 'SpeedTestPopup');
    }

    if (mounted) {
      setState(() {});
    }

    _statusSubscription = _speedTestService.statusStream.listen((status) {
      if (!mounted) return;
      setState(() {
        _status = status;
        _updatePhase();
      });
    });

    _resultSubscription = _speedTestService.resultStream.listen((result) {
      if (!mounted) return;
      setState(() {
        final serviceStatus = _speedTestService.status;

        if (result.hasError) {
          _errorMessage = result.errorMessage;
          _currentPhase = 'Test failed';
        } else {
          // Update speeds (either live or final)
          if (result.downloadSpeed > 0) _downloadSpeed = result.downloadSpeed;
          if (result.uploadSpeed > 0) _uploadSpeed = result.uploadSpeed;
          if (result.latency > 0) _latency = result.latency;

          // Only update connection info if it's a final result
          if (result.localIpAddress != null) _localIp = result.localIpAddress;
          if (result.serverHost != null) _serverHost = result.serverHost;

          // If the service finished but our local status hasn't updated yet, sync it
          if (serviceStatus == SpeedTestStatus.completed &&
              _status != SpeedTestStatus.completed) {
            _status = SpeedTestStatus.completed;
          }

          // Check if this is a complete result
          if (result.localIpAddress != null ||
              _status == SpeedTestStatus.completed ||
              serviceStatus == SpeedTestStatus.completed) {
            _validateTestResults();
            _currentPhase =
                _testPassed ? 'Test completed - PASSED!' : 'Test completed';
          }
        }
      });
    });

    _progressSubscription = _speedTestService.progressStream.listen((progress) {
      if (!mounted) return;
      setState(() {
        _progress = progress;
        _updatePhase();
      });
    });

    _statusMessageSubscription =
        _speedTestService.statusMessageStream.listen((message) {
      if (!mounted) return;
      setState(() {
        _currentPhase = message;

        // Extract server info from fallback attempt messages
        if (message.contains('Default gateway')) {
          _serverLabel = 'Gateway';
          final match = RegExp(r'\(([^)]+)\)').firstMatch(message);
          if (match != null) {
            _serverHost = match.group(1);
          }
        } else if (message.contains('test configuration') ||
            message.contains('Test configuration')) {
          _serverLabel = 'Target';
          final match = RegExp(r'\(([^)]+)\)').firstMatch(message);
          if (match != null) {
            _serverHost = match.group(1);
          }
        } else if (message.contains('external server') ||
            message.contains('External server')) {
          _serverLabel = 'External';
          final match = RegExp(r'\(([^)]+)\)').firstMatch(message);
          if (match != null) {
            _serverHost = match.group(1);
          }
        } else if (message.contains('Testing download speed to') ||
            message.contains('Testing upload speed to')) {
          final match = RegExp(r'to ([\w\.\-]+)').firstMatch(message);
          if (match != null) {
            _serverHost = match.group(1);
            _serverLabel = (_serverHost == _gatewayIp) ? 'Gateway' : 'Target';
          }
        }
      });
    });
  }

  void _updatePhase() {
    if (_status == SpeedTestStatus.running &&
        _currentPhase == 'Ready to start') {
      if (_progress < 50) {
        _currentPhase = 'Testing download speed...';
      } else {
        _currentPhase = 'Testing upload speed...';
      }
    } else if (_status == SpeedTestStatus.completed &&
        _currentPhase != 'Test completed!') {
      _currentPhase = 'Test completed!';
    } else if (_status == SpeedTestStatus.error &&
        _currentPhase != 'Test failed') {
      _currentPhase = 'Test failed';
    }
  }

  Future<void> _startTest() async {
    final gatewayService = NetworkGatewayService();
    final gatewayIp = await gatewayService.getWifiGateway();

    setState(() {
      _currentPhase = 'Starting test...';
      _serverLabel = 'Gateway';
      _serverHost = gatewayIp ?? 'Detecting...';
    });

    String? configTarget;
    final cachedTest = widget.cachedTest;
    if (cachedTest != null) {
      configTarget = cachedTest.target;
    }

    await _speedTestService.runSpeedTestWithFallback(configTarget: configTarget);
  }

  void _cancelTest() async {
    await _speedTestService.cancelTest();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  double? _getMinDownload() {
    return widget.cachedTest?.minDownloadMbps;
  }

  double? _getMinUpload() {
    return widget.cachedTest?.minUploadMbps;
  }

  void _validateTestResults() {
    final cachedTest = widget.cachedTest;

    if (cachedTest == null) {
      _testPassed = true;
      return;
    }

    final minDownload = _getMinDownload();
    final minUpload = _getMinUpload();

    final downloadPassed = minDownload == null || _downloadSpeed >= minDownload;
    final uploadPassed = minUpload == null || _uploadSpeed >= minUpload;

    _testPassed = downloadPassed && uploadPassed;

    // Auto-submit result if passed and callback provided
    if (_testPassed && widget.onResultSubmitted != null) {
      _submitResult();
    }
  }

  void _submitResult() {
    final result = SpeedTestResult(
      downloadSpeed: _downloadSpeed,
      uploadSpeed: _uploadSpeed,
      latency: _latency,
      timestamp: DateTime.now(),
      localIpAddress: _localIp,
      serverHost: _serverHost,
      // PMS Room fields
      id: widget.existingResult?.id,
      speedTestId: widget.cachedTest?.id,
      pmsRoomId: widget.pmsRoomId,
      roomType: widget.roomType,
      testedViaAccessPointId: widget.testedViaAccessPointId,
      testedViaMediaConverterId: widget.testedViaMediaConverterId,
      passed: _testPassed,
      completedAt: DateTime.now(),
    );

    widget.onResultSubmitted?.call(result);
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _resultSubscription?.cancel();
    _progressSubscription?.cancel();
    _statusMessageSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatSpeed(double speed) {
    if (speed < 1000.0) {
      return '${speed.toStringAsFixed(2)} Mbps';
    } else {
      return '${(speed / 1000).toStringAsFixed(2)} Gbps';
    }
  }

  Color _getStatusColor() {
    switch (_status) {
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

  IconData _getStatusIcon() {
    switch (_status) {
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
          if (minRequired != null) ...[
            const SizedBox(height: 2),
            SizedBox(
              width: 110,
              child: Text(
                'Min: ${_formatSpeed(minRequired)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  color: AppColors.gray400,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLatencyIndicator() {
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
              '${_latency.toStringAsFixed(0)} ms',
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
    return PopScope(
      canPop: _status != SpeedTestStatus.running,
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
                          scale: _status == SpeedTestStatus.running
                              ? _pulseAnimation.value
                              : 1.0,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getStatusIcon(),
                              color: _getStatusColor(),
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
                            _currentPhase,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.gray500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_status != SpeedTestStatus.running)
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
                            _localIp != null
                                ? Icons.computer
                                : Icons.location_off,
                            size: 16,
                            color: _localIp != null
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
                          if (_localIp != null)
                            Text(
                              _localIp!,
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
                            _serverLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_serverHost != null) ...[
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '($_serverHost)',
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

                const SizedBox(height: 20),

                // Speed indicators
                SizedBox(
                  height: 130,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSpeedIndicator(
                          'Download',
                          _downloadSpeed,
                          Icons.download,
                          AppColors.success,
                          minRequired: _getMinDownload(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSpeedIndicator(
                          'Upload',
                          _uploadSpeed,
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
                  child: _buildLatencyIndicator(),
                ),

                const SizedBox(height: 20),

                // Progress indicator
                if (_status == SpeedTestStatus.running) ...[
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_getStatusColor()),
                            strokeWidth: 4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _currentPhase,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
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
                if (_status == SpeedTestStatus.completed && !_testPassed) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.warning.withOpacity(0.3)),
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

                if (_status == SpeedTestStatus.idle) ...[
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

                if (_status == SpeedTestStatus.running) ...[
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

                if (_status == SpeedTestStatus.completed) ...[
                  // Show submit button if test failed and callback provided
                  if (!_testPassed && widget.onResultSubmitted != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitResult,
                        icon: const Icon(Icons.save, size: 16),
                        label: const Text('Submit Failed Result'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
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
                            setState(() {
                              _downloadSpeed = 0.0;
                              _uploadSpeed = 0.0;
                              _latency = 0.0;
                              _progress = 0.0;
                              _errorMessage = null;
                              _testPassed = false;
                            });
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

                if (_status == SpeedTestStatus.error) ...[
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
                            setState(() {
                              _errorMessage = null;
                              _downloadSpeed = 0.0;
                              _uploadSpeed = 0.0;
                              _latency = 0.0;
                              _progress = 0.0;
                            });
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
