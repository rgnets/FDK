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
  String? _lastScannedCode;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Flash toggle state
  bool _isFlashOn = false;
  CameraFacing _currentCameraFacing = CameraFacing.back;

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
        ],
      );

      LoggerService.debug('Scanner controller initialized', tag: _tag);
    } on Exception catch (e) {
      LoggerService.error('Failed to initialize scanner', error: e, tag: _tag);
    }
  }

  @override
  void dispose() {
    // Turn off flash if it's on before disposing
    if (_isFlashOn && _controller != null) {
      _controller!.toggleTorch();
    }
    _controller?.dispose();
    _controller = null;
    _pulseController.dispose();
    super.dispose();
  }

  /// Toggle the flashlight/torch
  void _toggleFlash() {
    if (!mounted || _controller == null) return;
    if (_currentCameraFacing != CameraFacing.back) return;

    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    _controller!.toggleTorch();
    LoggerService.debug('Flash toggled: $_isFlashOn', tag: _tag);
  }

  /// Switch between front and back camera
  Future<void> _switchCamera() async {
    if (!mounted || _controller == null) return;

    try {
      await _controller!.switchCamera();
      setState(() {
        _currentCameraFacing = _currentCameraFacing == CameraFacing.back
            ? CameraFacing.front
            : CameraFacing.back;

        // Turn off flash if switching to front camera (no flash available)
        if (_currentCameraFacing == CameraFacing.front && _isFlashOn) {
          _isFlashOn = false;
          _controller!.toggleTorch();
        }
      });
      LoggerService.debug('Camera switched to: $_currentCameraFacing', tag: _tag);
    } on Exception catch (e) {
      LoggerService.error('Failed to switch camera', error: e, tag: _tag);
    }
  }

  /// Build the flash toggle button widget
  Widget _buildFlashButton() {
    final isBackCamera = _currentCameraFacing == CameraFacing.back;

    // ignore: use_decorated_box
    return Container(
      decoration: BoxDecoration(
        color: _isFlashOn ? Colors.white24 : Colors.black54,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _isFlashOn
              ? Colors.white.withAlpha(128)
              : Colors.white.withAlpha(51),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: isBackCamera ? _toggleFlash : null,
        icon: Icon(
          _isFlashOn ? Icons.flashlight_on : Icons.flashlight_off,
          color: isBackCamera
              ? (_isFlashOn ? Colors.yellow : Colors.white)
              : Colors.grey,
          size: 22,
        ),
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(10),
        ),
      ),
    );
  }

  /// Build the camera switch button widget
  Widget _buildCameraSwitchButton() {
    // ignore: use_decorated_box
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withAlpha(51),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: _switchCamera,
        icon: Icon(
          _currentCameraFacing == CameraFacing.back
              ? Icons.camera_front
              : Icons.camera_rear,
          color: Colors.white,
          size: 22,
        ),
        style: IconButton.styleFrom(
          padding: const EdgeInsets.all(10),
        ),
      ),
    );
  }

  void _handleBarcode(BarcodeCapture capture) {
    final scannerState = ref.read(scannerNotifierV2Provider);

    // Only process if scanning is active
    if (scannerState.uiState != ScannerUIState.scanning) {
      return;
    }

    // Collect all new barcodes from this frame
    final frameBarcodes = <String>[];
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null && barcode.rawValue != _lastScannedCode) {
        frameBarcodes.add(barcode.rawValue!);
      }
    }

    if (frameBarcodes.isEmpty) {
      return;
    }

    // Update last scanned code to prevent re-processing same frame
    setState(() {
      _lastScannedCode = frameBarcodes.last;
    });

    LoggerService.debug(
      'Frame detected ${frameBarcodes.length} barcode(s): $frameBarcodes',
      tag: _tag,
    );

    // Process entire frame as a batch for correct ONT disambiguation
    ref.read(scannerNotifierV2Provider.notifier).processBarcodeFrame(frameBarcodes);

    // Check if scan is now complete
    final updatedState = ref.read(scannerNotifierV2Provider);
    if (updatedState.isScanComplete && !updatedState.isPopupShowing) {
      _showRegistrationPopup();
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
      // Always clear scan data and reset state when popup is dismissed
      ref.read(scannerNotifierV2Provider.notifier).clearScanData();
      ref.read(scannerNotifierV2Provider.notifier).hideRegistrationPopup();

      // Reset lastScannedCode so same barcode can be re-scanned
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

        // Compact top bar with device type and collected items
        _buildTopBar(state),

        // Camera controls (flash and switch) - top right
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 16,
          child: Row(
            children: [
              _buildFlashButton(),
              const SizedBox(width: 8),
              _buildCameraSwitchButton(),
            ],
          ),
        ),

        // Scanning overlay (frame only, no dimming)
        if (state.isScanning) _buildScanningOverlay(state),

        // Control buttons
        _buildControlButtons(state),
      ],
    );
  }

  /// Compact top bar showing device type and collected items as chips.
  Widget _buildTopBar(ScannerState state) {
    final hasData = state.collectedFields.isNotEmpty || state.isScanning;

    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device type selector
          Row(
            children: [
              GestureDetector(
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
              ),
              const Spacer(),
              // Scanning indicator
              if (state.isScanning)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'SCANNING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Collected items as compact chips
          if (hasData && state.collectedFields.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: state.collectedFields.map((field) => ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          field,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ],

          // Missing items as subtle indicators
          if (hasData && state.missingFields.isNotEmpty) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: state.missingFields.map((field) => ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange, width: 1),
                  ),
                  child: Text(
                    field,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
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
                // Camera controls for auth scanner
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  right: 16,
                  child: Row(
                    children: [
                      _buildFlashButton(),
                      const SizedBox(width: 8),
                      _buildCameraSwitchButton(),
                    ],
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
        if (!mounted) return;
        // Clear any existing SnackBars before showing new error
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: Colors.orange,
          ),
        );
        // Reset so the same QR can be rescanned
        setState(() {
          _lastScannedCode = null;
        });
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

              // Mode selector (inline for web)
              GestureDetector(
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
              ),
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

              // Progress (compact chips for web)
              if (state.collectedFields.isNotEmpty || state.missingFields.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (state.collectedFields.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: state.collectedFields.map((field) => Chip(
                          avatar: const Icon(Icons.check, color: Colors.white, size: 16),
                          label: Text(field, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.green,
                          labelStyle: const TextStyle(color: Colors.white),
                        )).toList(),
                      ),
                    if (state.missingFields.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: state.missingFields.map((field) => Chip(
                          label: Text(field, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.orange.shade100,
                          side: const BorderSide(color: Colors.orange),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
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
    final modes = ScanMode.values.where((m) => m != ScanMode.rxg).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      // Constrain height to avoid overflow, allow scrolling
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
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
          // Scrollable list of modes
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: modes.length,
              itemBuilder: (context, index) {
                final mode = modes[index];
                return ListTile(
                  leading: Icon(_getModeIcon(mode)),
                  title: Text(mode.displayName),
                  subtitle: Text(_getModeDescription(mode)),
                  selected: mode == currentMode,
                  onTap: () => onModeSelected(mode),
                  trailing: mode == currentMode
                      ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                      : null,
                );
              },
            ),
          ),
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
        return 'Scan AP (1K9/1M3/1HN/EC2 serial)';
      case ScanMode.ont:
        return 'Scan ONT (ALCL serial + part number)';
      case ScanMode.switchDevice:
        return 'Scan Switch (LL/EC2 serial)';
    }
  }
}
