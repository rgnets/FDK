import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/utils/foldable_camera_wrapper.dart';
import 'package:rgnets_fdk/core/widgets/widgets.dart';
import 'package:rgnets_fdk/features/scanner/domain/entities/scanner_state.dart';
import 'package:rgnets_fdk/features/scanner/domain/usecases/process_auth_qr.dart';
import 'package:rgnets_fdk/features/scanner/presentation/providers/scanner_notifier_v2.dart';
import 'package:rgnets_fdk/features/scanner/presentation/widgets/scanner_registration_popup.dart';

/// Scanner screen using the new V2 notifier with auto-detection support.
///
/// This screen uses the freezed ScannerState and supports:
/// - Auto-detection of device type from serial patterns
/// - ScanMode selection (auto, AP, ONT, Switch)
/// - Integration with ScannerRegistrationPopup for room selection
class ScannerScreenV2 extends ConsumerStatefulWidget {
  const ScannerScreenV2({super.key, this.mode});

  /// Optional mode parameter for auth scanning
  final String? mode;

  @override
  ConsumerState<ScannerScreenV2> createState() => _ScannerScreenV2State();
}

class _ScannerScreenV2State extends ConsumerState<ScannerScreenV2>
    with TickerProviderStateMixin {
  static const String _tag = 'ScannerScreenV2';

  MobileScannerController? _controller;
  StreamSubscription<BarcodeCapture>? _barcodeSubscription;
  String? _lastScannedCode;
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
      LoggerService.debug('Initializing scanner controller...', tag: _tag);

      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
        formats: const [
          BarcodeFormat.qrCode,
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.dataMatrix,
        ],
      );

      // Subscribe directly to barcode stream
      _barcodeSubscription = _controller!.barcodes.listen(
        _handleBarcode,
        onError: (Object error) {
          LoggerService.error('Barcode stream error', error: error, tag: _tag);
        },
      );

      LoggerService.debug('Scanner controller initialized', tag: _tag);
    } on Exception catch (e) {
      LoggerService.error('Failed to initialize scanner', error: e, tag: _tag);
    }
  }

  @override
  void dispose() {
    _barcodeSubscription?.cancel();
    _barcodeSubscription = null;
    _controller?.dispose();
    _controller = null;
    _pulseController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    final scannerState = ref.read(scannerNotifierV2Provider);

    // Only process if scanning is active
    if (scannerState.uiState != ScannerUIState.scanning) {
      return;
    }

    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null && barcode.rawValue != _lastScannedCode) {
        LoggerService.debug('Barcode detected: ${barcode.rawValue}', tag: _tag);

        setState(() {
          _lastScannedCode = barcode.rawValue;
        });

        // Process through the new notifier
        ref.read(scannerNotifierV2Provider.notifier).processBarcode(barcode.rawValue!);

        // Check if scan is now complete
        final updatedState = ref.read(scannerNotifierV2Provider);
        if (updatedState.isScanComplete && !updatedState.isPopupShowing) {
          _showRegistrationPopup();
        }
      }
    }
  }

  Future<void> _startScanning() async {
    LoggerService.debug('Starting scanning...', tag: _tag);

    ref.read(scannerNotifierV2Provider.notifier).startScanning();

    if (_controller != null) {
      try {
        await _controller!.start();
        LoggerService.debug('Camera started', tag: _tag);
      } on Exception catch (e) {
        LoggerService.error('Failed to start camera', error: e, tag: _tag);
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
    LoggerService.debug('Stopping scanning...', tag: _tag);

    ref.read(scannerNotifierV2Provider.notifier).stopScanning();

    try {
      await _controller?.stop();
    } on Exception catch (e) {
      LoggerService.error('Error stopping camera', error: e, tag: _tag);
    }
  }

  void _showRegistrationPopup() {
    // Guard against showing multiple popups
    final currentState = ref.read(scannerNotifierV2Provider);
    if (currentState.isPopupShowing) {
      LoggerService.debug('Popup already showing, skipping', tag: _tag);
      return;
    }

    // Set flag BEFORE showing popup to prevent race conditions
    ref.read(scannerNotifierV2Provider.notifier).showRegistrationPopup();

    LoggerService.debug('Showing registration popup', tag: _tag);

    ScannerRegistrationPopup.show(context).then((result) {
      if (result == true) {
        // Registration successful - reset for next scan
        ref.read(scannerNotifierV2Provider.notifier).clearScanData();
      }
      // Always reset lastScannedCode so same barcode can be re-scanned if needed
      setState(() {
        _lastScannedCode = null;
      });
    });
  }

  void _showModeSelector() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => _ModeSelectorSheet(
        currentMode: ref.read(scannerNotifierV2Provider).scanMode,
        onModeSelected: (mode) {
          ref.read(scannerNotifierV2Provider.notifier).setScanMode(mode);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scannerState = ref.watch(scannerNotifierV2Provider);

    // Handle auth mode differently
    if (widget.mode == 'auth') {
      return _buildAuthScanner();
    }

    // On web platform, show a different UI
    if (kIsWeb) {
      return _buildWebScanner(scannerState);
    }

    return Scaffold(
      body: _buildScannerBody(scannerState),
    );
  }

  Widget _buildScannerBody(ScannerState state) {
    if (_controller == null) {
      return const Center(child: LoadingIndicator());
    }

    return Stack(
      children: [
        // Camera view
        FoldableCameraWrapper(
          controller: _controller,
          onDetect: _handleBarcode,
        ),

        // Mode selector chip
        Positioned(
          top: 50,
          left: 16,
          child: _buildModeChip(state),
        ),

        // Scan progress panel
        if (state.isScanning || state.isScanComplete) _buildProgressPanel(state),

        // Scanning overlay
        if (state.isScanning) _buildScanningOverlay(state),

        // Control buttons
        _buildControlButtons(state),
      ],
    );
  }

  Widget _buildModeChip(ScannerState state) {
    return GestureDetector(
      onTap: state.isScanning ? null : _showModeSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: state.isAutoLocked
              ? Colors.green.withValues(alpha: 0.9)
              : Colors.black87,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getModeIcon(state.scanMode),
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              state.isAutoLocked
                  ? '${state.scanMode.displayName} (Auto)'
                  : state.scanMode.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!state.isScanning) ...[
              const SizedBox(width: 4),
              const Icon(Icons.arrow_drop_down, color: Colors.white, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressPanel(ScannerState state) {
    return Positioned(
      top: 100,
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
                    _getModeIcon(state.scanMode),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${state.scanMode.displayName} Scanner',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (state.isScanning)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

              if (state.collectedFields.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Collected (${state.collectedFields.length}):',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                ...state.collectedFields.map((field) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Text(field, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                )),
              ],

              if (state.missingFields.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Missing:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 4),
                ...state.missingFields.map((field) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.radio_button_unchecked, color: Colors.orange, size: 16),
                      const SizedBox(width: 8),
                      Text(field, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                )),
              ],

              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: state.scanProgress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  state.isScanComplete ? Colors.green : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanningOverlay(ScannerState state) {
    return Stack(
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
                        color: Theme.of(context).colorScheme.primary,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),

          // Instructions
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  'Scanning ${state.scanMode.displayName}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  state.scanMode == ScanMode.auto
                      ? 'Scan any barcode - type will be auto-detected'
                      : 'Scan ${state.missingFields.join(" or ")}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
    );
  }

  Widget _buildControlButtons(ScannerState state) {
    return Positioned(
      bottom: 32,
      left: 16,
      right: 16,
      child: Column(
        children: [
          if (state.uiState == ScannerUIState.idle)
            AppButton(
              text: 'Start Scanning',
              icon: Icons.qr_code_scanner,
              onPressed: _startScanning,
            )
          else if (state.isScanning)
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
            )
          else if (state.isScanComplete)
            AppButton(
              text: 'Register Device',
              icon: Icons.cloud_upload,
              onPressed: _showRegistrationPopup,
              color: Colors.green,
            ),
        ],
      ),
    );
  }

  Widget _buildAuthScanner() {
    return Scaffold(
      body: Stack(
        children: [
          if (_controller != null)
            FoldableCameraWrapper(
              controller: _controller,
              onDetect: (capture) {
                for (final barcode in capture.barcodes) {
                  if (barcode.rawValue != null && barcode.rawValue != _lastScannedCode) {
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
        if (!mounted) return;
        Navigator.of(context).pop({
          'fqdn': credentials.fqdn,
          'login': credentials.login,
          'token': credentials.token,
          'siteName': credentials.siteName,
          'issuedAt': credentials.issuedAt.toIso8601String(),
          if (credentials.signature != null) 'signature': credentials.signature,
        });
      },
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
                              'Use the mobile app for camera scanning, or enter barcodes manually below.',
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

              // Mode selector
              _buildModeChip(state),
              const SizedBox(height: 24),

              // Manual barcode entry
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
                        ref.read(scannerNotifierV2Provider.notifier).processBarcode(barcode);
                        barcodeController.clear();

                        final updatedState = ref.read(scannerNotifierV2Provider);
                        if (updatedState.isScanComplete) {
                          _showRegistrationPopup();
                        }
                      }
                    },
                  ),
                ),
                onSubmitted: (barcode) {
                  if (barcode.trim().isNotEmpty) {
                    ref.read(scannerNotifierV2Provider.notifier).processBarcode(barcode.trim());
                    barcodeController.clear();

                    final updatedState = ref.read(scannerNotifierV2Provider);
                    if (updatedState.isScanComplete) {
                      _showRegistrationPopup();
                    }
                  }
                },
              ),
              const SizedBox(height: 16),

              // Progress
              if (state.collectedFields.isNotEmpty || state.missingFields.isNotEmpty)
                _buildProgressPanel(state),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getModeIcon(ScanMode mode) {
    switch (mode) {
      case ScanMode.auto:
        return Icons.auto_awesome;
      case ScanMode.rxg:
        return Icons.key;
      case ScanMode.accessPoint:
        return Icons.wifi;
      case ScanMode.ont:
        return Icons.cable;
      case ScanMode.switchDevice:
        return Icons.hub;
    }
  }
}

/// Mode selector bottom sheet
class _ModeSelectorSheet extends StatelessWidget {
  const _ModeSelectorSheet({
    required this.currentMode,
    required this.onModeSelected,
  });

  final ScanMode currentMode;
  final void Function(ScanMode) onModeSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Scan Mode',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a device type or use Auto to detect automatically',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...ScanMode.values.where((m) => m != ScanMode.rxg).map((mode) => ListTile(
            leading: Icon(_getModeIcon(mode)),
            title: Text(mode.displayName),
            subtitle: Text(_getModeDescription(mode)),
            selected: mode == currentMode,
            onTap: () => onModeSelected(mode),
            trailing: mode == currentMode
                ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                : null,
          )),
        ],
      ),
    );
  }

  IconData _getModeIcon(ScanMode mode) {
    switch (mode) {
      case ScanMode.auto:
        return Icons.auto_awesome;
      case ScanMode.rxg:
        return Icons.key;
      case ScanMode.accessPoint:
        return Icons.wifi;
      case ScanMode.ont:
        return Icons.cable;
      case ScanMode.switchDevice:
        return Icons.hub;
    }
  }

  String _getModeDescription(ScanMode mode) {
    switch (mode) {
      case ScanMode.auto:
        return 'Automatically detect device type from serial pattern';
      case ScanMode.rxg:
        return 'Scan RxG credentials QR code';
      case ScanMode.accessPoint:
        return 'Scan AP (1K9/1M3/1HN serial)';
      case ScanMode.ont:
        return 'Scan ONT (ALCL serial + part number)';
      case ScanMode.switchDevice:
        return 'Scan Switch (LL serial)';
    }
  }
}
