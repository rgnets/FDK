import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/utils/foldable_camera_wrapper.dart';
import 'package:rgnets_fdk/core/widgets/widgets.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_result.dart'
    as scanner_entities;
import 'package:rgnets_fdk/features/scanner/domain/entities/scan_session.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/process_auth_qr.dart';
import 'package:rgnets_fdk/features/scanner/presentation/providers/scanner_notifier.dart';

/// QR/Barcode scanner screen
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key, this.mode});
  final String? mode;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with TickerProviderStateMixin {
  MobileScannerController? _controller;
  bool _isCameraActive = false;
  String? _lastScannedCode;
  Timer? _countdownTimer;
  int _remainingSeconds = 6;
  DeviceType? _selectedDeviceType;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  void _initializeScanner() {
    try {
      LoggerService.debug(
        '🎯 Initializing scanner controller...',
        tag: 'Scanner',
      );
      LoggerService.debug(
        '🌐 Platform: ${kIsWeb ? "Web" : "Native"}',
        tag: 'Scanner',
      );

      if (kIsWeb) {
        LoggerService.debug(
          '🌐 Web platform detected - checking camera support',
          tag: 'Scanner',
        );
        _checkWebCameraSupport();
      }

      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
      LoggerService.debug(
        '✅ Scanner controller initialized successfully',
        tag: 'Scanner',
      );
    } on Exception catch (e) {
      LoggerService.error(
        '❌ Failed to initialize scanner controller',
        error: e,
        tag: 'Scanner',
      );
      // On web or if camera fails, _controller will be null and handled in UI
    }
  }

  void _checkWebCameraSupport() {
    if (kIsWeb) {
      try {
        LoggerService.debug(
          '🔍 Checking browser camera support...',
          tag: 'Scanner',
        );

        // Basic web environment check without dart:html
        LoggerService.debug('🌐 Running in web environment', tag: 'Scanner');
        LoggerService.debug(
          '📱 Camera support will be tested during runtime',
          tag: 'Scanner',
        );

        // Note: Camera support detection will happen during mobile_scanner initialization
        LoggerService.debug(
          'ℹ️ Mobile scanner will handle camera detection',
          tag: 'Scanner',
        );
      } on Exception catch (e) {
        LoggerService.error(
          '❌ Error checking web camera support',
          error: e,
          tag: 'Scanner',
        );
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller?.dispose();
    _controller = null;
    _pulseController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    LoggerService.debug('📷 Barcode capture detected', tag: 'Scanner');

    final scannerState = ref.read(scannerNotifierProvider).valueOrNull;
    if (scannerState == null) {
      LoggerService.warning('⚠️ Scanner state is null', tag: 'Scanner');
      return;
    }

    if (!scannerState.isScanning) {
      LoggerService.debug(
        '🛑 Scanner is not in scanning state: ${scannerState.runtimeType}',
        tag: 'Scanner',
      );
      return;
    }

    final barcodes = capture.barcodes;
    LoggerService.debug('📊 Found ${barcodes.length} barcodes', tag: 'Scanner');

    for (final barcode in barcodes) {
      LoggerService.debug(
        '🔍 Processing barcode: ${barcode.rawValue}',
        tag: 'Scanner',
      );

      if (barcode.rawValue != null && barcode.rawValue != _lastScannedCode) {
        LoggerService.debug(
          '✅ New unique barcode: ${barcode.rawValue}',
          tag: 'Scanner',
        );

        setState(() {
          _lastScannedCode = barcode.rawValue;
        });

        // Process barcode through scanner notifier
        ref
            .read(scannerNotifierProvider.notifier)
            .processBarcode(barcode.rawValue!);
        LoggerService.debug(
          '📤 Barcode sent to scanner notifier',
          tag: 'Scanner',
        );
      } else {
        LoggerService.debug(
          '🔄 Duplicate or null barcode, skipping',
          tag: 'Scanner',
        );
      }
    }
  }

  Future<void> _startScanSession() async {
    LoggerService.debug('🚀 Starting scan session...', tag: 'Scanner');

    if (_selectedDeviceType == null) {
      LoggerService.debug(
        '❓ No device type selected, showing selection dialog',
        tag: 'Scanner',
      );
      _showDeviceTypeSelection();
      return;
    }

    LoggerService.debug(
      '📋 Selected device type: ${_selectedDeviceType!.name}',
      tag: 'Scanner',
    );

    try {
      LoggerService.debug(
        '🎯 Calling scanner notifier startScanning...',
        tag: 'Scanner',
      );
      await ref
          .read(scannerNotifierProvider.notifier)
          .startScanning(_selectedDeviceType!);
      LoggerService.debug(
        '✅ Scanner notifier startScanning completed',
        tag: 'Scanner',
      );
    } on Exception catch (e) {
      LoggerService.error(
        '❌ Error starting scanner notifier',
        error: e,
        tag: 'Scanner',
      );
      return;
    }

    setState(() {
      _isCameraActive = true;
      _remainingSeconds = 6;
    });

    LoggerService.debug(
      '⏰ Camera active: $_isCameraActive, Countdown: $_remainingSeconds',
      tag: 'Scanner',
    );

    // Try to start camera, with proper error handling for web and permission issues
    if (!kIsWeb && _controller != null) {
      try {
        LoggerService.debug('📱 Starting native camera...', tag: 'Scanner');
        await _controller!.start();
        LoggerService.debug(
          '✅ Native camera started successfully',
          tag: 'Scanner',
        );
      } on Exception catch (e) {
        LoggerService.error(
          '❌ Failed to start native camera',
          error: e,
          tag: 'Scanner',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Camera unavailable: $e'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } else if (kIsWeb) {
      LoggerService.debug(
        '🌐 Web platform detected - camera may have limitations',
        tag: 'Scanner',
      );
      if (_controller != null) {
        try {
          LoggerService.debug(
            '🌐 Attempting to start web camera...',
            tag: 'Scanner',
          );
          await _controller!.start();
          LoggerService.debug(
            '✅ Web camera started successfully',
            tag: 'Scanner',
          );
        } on Exception catch (e) {
          LoggerService.error(
            '❌ Web camera failed to start',
            error: e,
            tag: 'Scanner',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Web camera unavailable: $e\nUse manual input below.',
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      }
    }
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        await _handleSessionTimeout();
      }
    });
  }

  Future<void> _handleSessionTimeout() async {
    final scannerState = ref.read(scannerNotifierProvider).valueOrNull;
    if (scannerState?.session?.isComplete ?? false) {
      // Complete the session
      await ref
          .read(scannerNotifierProvider.notifier)
          .completeSession();
    }
    await _stopAndDisposeCamera();
  }

  Future<void> _stopAndDisposeCamera() async {
    setState(() {
      _isCameraActive = false;
      _remainingSeconds = 6;
    });
    _countdownTimer?.cancel();
    try {
      await _controller?.stop();
      LoggerService.debug('Camera stopped successfully', tag: 'Scanner');
    } on Exception catch (e) {
      LoggerService.error('Error stopping camera', error: e, tag: 'Scanner');
    }
    await _controller?.dispose();
    _controller = null;
  }


  void _showDeviceTypeSelection() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Device Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DeviceType.values
              .map(
                (type) => ListTile(
                  title: Text(type.displayName),
                  subtitle: Text(
                    '${type.abbreviation} - Requires ${_getRequiredBarcodesText(type)}',
                  ),
                  onTap: () {
                    setState(() {
                      _selectedDeviceType = type;
                    });
                    Navigator.of(context).pop();
                    _startScanSession();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  String _getRequiredBarcodesText(DeviceType type) {
    switch (type) {
      case DeviceType.accessPoint:
      case DeviceType.ont:
        return '2 barcodes (Serial + MAC)';
      case DeviceType.switchDevice:
        return '1 barcode (Serial)';
    }
  }

  Future<void> _processAuthCode(String code) async {
    final useCase = ProcessAuthQr();
    final result = await useCase(ProcessAuthQrParams(qrCode: code));

    await result.match(
      (failure) async {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.orange,
          ),
        );
      },
      (credentials) async {
        await _stopAndDisposeCamera();
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop({
          'fqdn': credentials.fqdn,
          'login': credentials.login,
          'apiKey': credentials.apiKey,
          'siteName': credentials.siteName,
          'issuedAt': credentials.issuedAt.toIso8601String(),
          if (credentials.signature != null) 'signature': credentials.signature,
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    LoggerService.debug('🏗️ Building scanner screen UI...', tag: 'Scanner');

    // Watch scanner state
    final scannerAsync = ref.watch(scannerNotifierProvider)
      // Log scanner state changes
      ..when(
        data: (state) => LoggerService.debug(
          '📊 Scanner state: ${state.runtimeType}',
          tag: 'Scanner',
        ),
        loading: () =>
            LoggerService.debug('⏳ Scanner state: Loading', tag: 'Scanner'),
        error: (error, stack) => LoggerService.error(
          '❌ Scanner state: Error - $error',
          tag: 'Scanner',
        ),
      );

    // On web platform, show a different UI since camera might not work
    if (kIsWeb) {
      LoggerService.debug('🌐 Rendering web scanner UI', tag: 'Scanner');
      return _buildWebScanner();
    }

    // Handle auth mode differently
    if (widget.mode == 'auth') {
      LoggerService.debug('🔐 Rendering auth scanner UI', tag: 'Scanner');
      return _buildAuthScanner();
    }

    LoggerService.debug('📱 Rendering native scanner UI', tag: 'Scanner');

    // AppBar removed from main scanner - torch and camera controls need relocation
    LoggerService.debug(
      'ScannerScreen: AppBar removed, camera controls preserved',
      tag: 'Scanner',
    );
    return Scaffold(
      body: scannerAsync.when(
        data: _buildScannerBody,
        loading: () {
          LoggerService.debug('⏳ Showing loading indicator', tag: 'Scanner');
          return const Center(child: LoadingIndicator());
        },
        error: (error, stack) {
          LoggerService.error('❌ Showing error UI for: $error', tag: 'Scanner');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Scanner Error',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: 'Retry',
                  onPressed: () {
                    LoggerService.debug(
                      '🔄 Retrying scanner initialization',
                      tag: 'Scanner',
                    );
                    ref.invalidate(scannerNotifierProvider);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthScanner() {
    // AppBar removed from auth scanner - torch control needs relocation
    LoggerService.debug(
      'AuthScanner: AppBar removed, torch control preserved',
      tag: 'Scanner',
    );
    return Scaffold(body: _buildAuthBody());
  }

  Widget _buildScannerBody(ScannerState state) {
    LoggerService.debug(
      '🏗️ Building scanner body for state: ${state.runtimeType}',
      tag: 'Scanner',
    );

    if (_controller == null) {
      LoggerService.warning(
        '⚠️ Scanner controller is null, showing loading',
        tag: 'Scanner',
      );
      return const Center(child: LoadingIndicator());
    }

    LoggerService.debug(
      '📷 Controller available, scanning active: ${state.isScanning}',
      tag: 'Scanner',
    );

    return Stack(
      children: [
        // Camera view (with foldable device rotation correction)
        FoldableCameraWrapper(
          controller: _controller,
          onDetect: state.isScanning ? _handleBarcode : null,
        ),

        // Debug overlay
        Positioned(
          top: 50,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DEBUG INFO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'State: ${state.runtimeType}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                Text(
                  'Camera: ${_controller != null ? "Active" : "Null"}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                Text(
                  'Scanning: ${state.isScanning}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                const Text(
                  'Platform: ${kIsWeb ? "Web" : "Native"}',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
                Text(
                  'Last Code: ${_lastScannedCode ?? "None"}',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        ),

        // Scanning overlay
        if (state.isScanning && _isCameraActive) _buildScanningOverlay(state),

        // Session info panel
        if (state.session != null) _buildSessionInfoPanel(state.session!),

        // Control buttons
        _buildControlButtons(state),

        // Completion panel
        if (state.isComplete) _buildCompletionPanel(state.session!),
      ],
    );
  }

  Widget _buildAuthBody() {
    if (_controller == null) {
      return const Center(child: LoadingIndicator());
    }

    return Stack(
      children: [
        // Camera view (with foldable device rotation correction)
        FoldableCameraWrapper(
          controller: _controller,
          onDetect: (capture) {
            final barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null &&
                  barcode.rawValue != _lastScannedCode) {
                setState(() {
                  _lastScannedCode = barcode.rawValue;
                });
                _processAuthCode(barcode.rawValue!);
                return;
              }
            }
          },
        ),

        // Auth scanning overlay
        DecoratedBox(
          decoration: const BoxDecoration(color: Colors.black54),
          child: Stack(
            children: [
              Center(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Text(
                  'Position authentication QR code within frame',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScanningOverlay(ScannerState state) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.black54),
      child: Stack(
        children: [
          // Scanning frame
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _remainingSeconds > 3
                            ? Theme.of(context).colorScheme.primary
                            : Colors.orange,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),

          // Countdown timer
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _remainingSeconds > 3
                      ? Theme.of(context).colorScheme.primary
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_remainingSeconds',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Scanning ${state.session?.deviceType.displayName ?? 'Device'}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep scanning until time runs out',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionInfoPanel(ScanSession session) {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.qr_code,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${session.deviceType.displayName} Scanner',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (session.status == ScanSessionStatus.scanning)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              if (session.scannedBarcodes.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Scanned Barcodes (${session.scannedBarcodes.length}):',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...session.scannedBarcodes.map(
                  (result) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getBarcodeTypeColor(result.type),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${result.type.displayName}: ${result.value}',
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _getCompletionProgress(session),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    session.isComplete
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.isComplete
                      ? 'Device scan complete!'
                      : _getProgressText(session),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: session.isComplete ? Colors.green : null,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons(ScannerState state) {
    return Positioned(
      bottom: 32,
      left: 16,
      right: 16,
      child: Column(
        children: [
          if (state.isIdle)
            AppButton(
              text: 'Start Device Scan',
              icon: Icons.qr_code_scanner,
              onPressed: _startScanSession,
            )
          else if (state.isScanning)
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Stop Scanning',
                    icon: Icons.stop,
                    onPressed: () async {
                      await ref
                          .read(scannerNotifierProvider.notifier)
                          .cancelSession();
                      await _stopAndDisposeCamera();
                    },
                    color: Colors.red,
                  ),
                ),
                if (state.session?.isComplete ?? false) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton(
                      text: 'Complete',
                      icon: Icons.check,
                      onPressed: () async {
                        await ref
                            .read(scannerNotifierProvider.notifier)
                            .completeSession();
                        await _stopAndDisposeCamera();
                      },
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            )
          else if (state.isComplete)
            AppButton(
              text: 'Register Device',
              icon: Icons.cloud_upload,
              onPressed: () {
                ref.read(scannerNotifierProvider.notifier).completeSession();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCompletionPanel(ScanSession session) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      child: ColoredBox(
        color: Colors.black87,
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  Text(
                    'Scan Complete!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${session.deviceType.displayName} ready for registration',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ...session.scannedBarcodes.map(
                    (result) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${result.type.displayName}:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            result.value,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Scan Another',
                          onPressed: () {
                            setState(() {
                              _selectedDeviceType = null;
                            });
                            _startScanSession();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppButton(
                          text: 'Register',
                          icon: Icons.cloud_upload,
                          onPressed: () {
                            ref
                                .read(scannerNotifierProvider.notifier)
                                .completeSession();
                          },
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBarcodeTypeColor(scanner_entities.BarcodeType type) {
    switch (type) {
      case scanner_entities.BarcodeType.serialNumber:
        return Colors.blue;
      case scanner_entities.BarcodeType.macAddress:
        return Colors.green;
      case scanner_entities.BarcodeType.partNumber:
        return Colors.orange;
      case scanner_entities.BarcodeType.assetTag:
        return Colors.purple;
      case scanner_entities.BarcodeType.qrCode:
        return Colors.indigo;
      case scanner_entities.BarcodeType.unknown:
        return Colors.grey;
    }
  }

  double _getCompletionProgress(ScanSession session) {
    switch (session.deviceType) {
      case DeviceType.accessPoint:
      case DeviceType.ont:
        var progress = 0.0;
        if (session.serialNumber != null) {
          progress += 0.5;
        }
        if (session.macAddress != null) {
          progress += 0.5;
        }
        return progress;
      case DeviceType.switchDevice:
        return session.serialNumber != null ? 1.0 : 0.0;
    }
  }

  String _getProgressText(ScanSession session) {
    switch (session.deviceType) {
      case DeviceType.accessPoint:
      case DeviceType.ont:
        final hasSerial = session.serialNumber != null;
        final hasMac = session.macAddress != null;
        if (!hasSerial && !hasMac) {
          return 'Scan serial number and MAC address';
        }
        if (hasSerial && !hasMac) {
          return 'Scan MAC address';
        }
        if (!hasSerial && hasMac) {
          return 'Scan serial number';
        }
        return 'All required barcodes scanned';
      case DeviceType.switchDevice:
        return session.serialNumber != null
            ? 'Serial number scanned'
            : 'Scan serial number';
    }
  }

  Widget _buildWebScanner() {
    final scannerAsync = ref.watch(scannerNotifierProvider);
    final barcodeController = TextEditingController();

    // AppBar removed from web scanner
    LoggerService.debug('WebScanner: AppBar removed', tag: 'Scanner');
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: scannerAsync.when(
            loading: () => const LoadingIndicator(),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(scannerNotifierProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (state) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Camera notice for web
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Camera Scanner Not Available on Web',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Please use the mobile app for camera scanning, or enter barcodes manually below.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Device type selection
                if (_selectedDeviceType == null) ...[
                  const Text(
                    'Select Device Type',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedDeviceType = DeviceType.accessPoint;
                          });
                          _startScanSession();
                        },
                        icon: const Icon(Icons.wifi),
                        label: const Text('Access Point'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedDeviceType = DeviceType.ont;
                          });
                          _startScanSession();
                        },
                        icon: const Icon(Icons.cable),
                        label: const Text('ONT'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedDeviceType = DeviceType.switchDevice;
                          });
                          _startScanSession();
                        },
                        icon: const Icon(Icons.hub),
                        label: const Text('Switch'),
                      ),
                    ],
                  ),
                ] else ...[
                  // Manual barcode entry
                  Text(
                    'Scanning ${_selectedDeviceType?.name ?? 'Device'}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getRequirementsText(_selectedDeviceType),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),

                  // Show accumulated barcodes
                  if (state.session != null &&
                      state.session!.scannedBarcodes.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Scanned Barcodes:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...state.session!.scannedBarcodes.map(
                              (barcode) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: Colors.green.shade600,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Barcode: $barcode',
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Manual input field
                  TextField(
                    controller: barcodeController,
                    decoration: InputDecoration(
                      labelText: 'Enter Barcode',
                      hintText: 'Type or paste barcode here',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          final barcode = barcodeController.text.trim();
                          if (barcode.isNotEmpty) {
                            ref
                                .read(scannerNotifierProvider.notifier)
                                .processBarcode(barcode);
                            barcodeController.clear();
                          }
                        },
                      ),
                    ),
                    onSubmitted: (barcode) {
                      if (barcode.trim().isNotEmpty) {
                        ref
                            .read(scannerNotifierProvider.notifier)
                            .processBarcode(barcode.trim());
                        barcodeController.clear();
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (state.session != null) ...[
                        ElevatedButton.icon(
                          onPressed: state.session!.isComplete
                              ? () async {
                                  await ref
                                      .read(scannerNotifierProvider.notifier)
                                      .completeSession();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Device registered successfully',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    setState(() {
                                      _selectedDeviceType = null;
                                    });
                                  }
                                }
                              : null,
                          icon: const Icon(Icons.check),
                          label: const Text('Complete Registration'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      OutlinedButton.icon(
                        onPressed: () async {
                          await ref
                              .read(scannerNotifierProvider.notifier)
                              .cancelSession();
                          setState(() {
                            _selectedDeviceType = null;
                          });
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancel'),
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

  String _getRequirementsText(DeviceType? type) {
    switch (type) {
      case DeviceType.accessPoint:
        return 'Requires 2 barcodes: Serial Number + MAC Address';
      case DeviceType.ont:
        return 'Requires 2-3 barcodes: Serial + MAC + (Optional) Power';
      case DeviceType.switchDevice:
        return 'Requires 1 barcode: Serial Number';
      case null:
        return '';
    }
  }
}
