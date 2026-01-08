import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/widgets/widgets.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scanner_state.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/process_auth_qr.dart';
import 'package:rgnets_fdk/features/scanner/presentation/providers/scanner_notifier.dart';
import 'package:rgnets_fdk/features/scanner/presentation/widgets/scanner_device_selector.dart';
import 'package:rgnets_fdk/features/scanner/presentation/widgets/scanner_registration_popup.dart';
import 'package:rgnets_fdk/features/scanner/presentation/widgets/scanner_requirements_display.dart';

/// QR/Barcode scanner screen with AT&T-style auto-detection.
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key, this.mode});
  final String? mode;

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with TickerProviderStateMixin {
  MobileScannerController? _controller;
  String? _lastScannedCode;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _hasShownRegistrationPopup = false;

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
      LoggerService.debug('Initializing scanner controller...', tag: 'Scanner');

      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
        autoStart: false,
      );

      LoggerService.debug('Scanner controller initialized', tag: 'Scanner');
    } on Exception catch (e) {
      LoggerService.error('Failed to initialize scanner', error: e, tag: 'Scanner');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _pulseController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    final scannerState = ref.read(scannerNotifierProvider);

    if (!scannerState.canProcessBarcode) {
      return;
    }

    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null && barcode.rawValue != _lastScannedCode) {
        LoggerService.debug('New barcode: ${barcode.rawValue}', tag: 'Scanner');

        setState(() {
          _lastScannedCode = barcode.rawValue;
        });

        ref.read(scannerNotifierProvider.notifier).processBarcode(barcode.rawValue!);
      }
    }
  }

  Future<void> _startScanning() async {
    LoggerService.debug('Starting scanner...', tag: 'Scanner');

    ref.read(scannerNotifierProvider.notifier).startScanning();

    if (!kIsWeb && _controller != null) {
      try {
        await _controller!.start();
        LoggerService.debug('Camera started', tag: 'Scanner');
      } on Exception catch (e) {
        LoggerService.error('Failed to start camera', error: e, tag: 'Scanner');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Camera unavailable: $e'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  }

  Future<void> _stopScanning() async {
    LoggerService.debug('Stopping scanner...', tag: 'Scanner');

    ref.read(scannerNotifierProvider.notifier).stopScanning();

    try {
      await _controller?.stop();
    } on Exception catch (e) {
      LoggerService.error('Error stopping camera', error: e, tag: 'Scanner');
    }
  }

  Future<void> _showRegistrationPopup() async {
    if (_hasShownRegistrationPopup) {
      return;
    }
    _hasShownRegistrationPopup = true;

    final result = await ScannerRegistrationPopup.show(context);

    _hasShownRegistrationPopup = false;

    if (result == true) {
      // Registration successful - reset and potentially navigate
      ref.read(scannerNotifierProvider.notifier).reset();
      await _stopScanning();
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
        await _stopScanning();
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
    // Watch scanner state and check for completion
    final scannerState = ref.watch(scannerNotifierProvider);

    // Check if we need to show registration popup
    if (scannerState.isScanComplete &&
        scannerState.uiState == ScannerUIState.success &&
        !_hasShownRegistrationPopup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showRegistrationPopup();
      });
    }

    // Check for auto-revert notification
    if (ref.read(scannerNotifierProvider.notifier).takeAutoRevertedFlag()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reverted to Auto mode (no serial detected)'),
            duration: Duration(seconds: 2),
          ),
        );
      });
    }

    // On web platform, show manual input UI
    if (kIsWeb) {
      return _buildWebScanner(scannerState);
    }

    // Handle auth mode
    if (widget.mode == 'auth') {
      return _buildAuthScanner();
    }

    return Scaffold(
      body: _buildScannerBody(scannerState),
    );
  }

  Widget _buildScannerBody(ScannerState state) {
    if (_controller == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingIndicator(),
            SizedBox(height: 16),
            Text('Initializing camera...'),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Camera view - show placeholder when not scanning
        if (state.isScanning)
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          )
        else
          Container(
            color: Colors.black87,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap "Start Scanning" to begin',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),
          ),

        // Top bar with device selector
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 0,
          right: 0,
          child: const ScannerDeviceSelector(),
        ),

        // Camera controls (torch, switch camera)
        Positioned(
          top: MediaQuery.of(context).padding.top + 60,
          right: 16,
          child: Column(
            children: [
              _buildCameraControl(
                icon: Icons.flash_on,
                onPressed: () => _controller?.toggleTorch(),
              ),
              const SizedBox(height: 8),
              _buildCameraControl(
                icon: Icons.cameraswitch,
                onPressed: () => _controller?.switchCamera(),
              ),
            ],
          ),
        ),

        // Scanning overlay with frame
        if (state.isScanning) Positioned.fill(child: _buildScanningOverlay(state)),

        // Requirements display (center-bottom)
        if (state.isInDeviceMode)
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const ScannerRequirementsDisplay(),
                const SizedBox(height: 8),
                const ScannerDataDisplay(),
              ],
            ),
          ),

        // Control buttons (bottom)
        _buildControlButtons(state),

        // Auto-locked indicator
        if (state.isAutoLocked)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock,
                    size: 14,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Auto-locked',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCameraControl({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildScanningOverlay(ScannerState state) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.black38),
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
                        color: state.isScanComplete
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),

          // Mode indicator
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  state.scanMode.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            child: Text(
              state.scanMode == ScanMode.auto
                  ? 'Scan any device barcode to auto-detect type'
                  : 'Scan ${state.scanMode.displayName} barcodes',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(ScannerState state) {
    return Positioned(
      bottom: 32,
      left: 16,
      right: 16,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!state.isScanning)
              AppButton(
                text: 'Start Scanning',
                icon: Icons.qr_code_scanner,
                onPressed: _startScanning,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: 'Stop',
                      icon: Icons.stop,
                      onPressed: _stopScanning,
                      color: Colors.red,
                    ),
                  ),
                  if (state.isScanComplete) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        text: 'Register',
                        icon: Icons.check,
                        onPressed: _showRegistrationPopup,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthScanner() {
    if (_controller == null) {
      return const Scaffold(body: Center(child: LoadingIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              for (final barcode in capture.barcodes) {
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
          DecoratedBox(
            decoration: const BoxDecoration(color: Colors.black54),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
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
                  const SizedBox(height: 24),
                  Text(
                    'Scan authentication QR code',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebScanner(ScannerState state) {
    final barcodeController = TextEditingController();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Web notice
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
                              'Camera Not Available on Web',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Use the mobile app for camera scanning, or enter barcodes manually.',
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
              const SizedBox(height: 24),

              // Device selector
              const ScannerDeviceSelector(),
              const SizedBox(height: 24),

              // Requirements display
              if (state.isInDeviceMode) ...[
                const ScannerRequirementsDisplay(),
                const SizedBox(height: 16),
                const ScannerDataDisplay(),
                const SizedBox(height: 24),
              ],

              // Manual input
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
              if (state.isScanComplete)
                ElevatedButton.icon(
                  onPressed: _showRegistrationPopup,
                  icon: const Icon(Icons.check),
                  label: const Text('Register Device'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
