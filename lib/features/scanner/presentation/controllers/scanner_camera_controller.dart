import 'dart:async';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';

/// Controller for managing scanner camera operations
class ScannerCameraController {
  ScannerCameraController({
    required this.onBarcodeDetected,
    this.scanDelay = const Duration(milliseconds: 500),
  });

  final void Function(String barcode) onBarcodeDetected;
  final Duration scanDelay;
  
  MobileScannerController? _controller;
  Timer? _scanDelayTimer;
  bool _canScan = true;
  bool _isProcessing = false;
  
  MobileScannerController? get controller => _controller;
  bool get isActive => _controller != null;
  
  /// Initialize the camera controller
  Future<void> initialize() async {
    try {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
        returnImage: false,
      );
      
      await _controller!.start();
      LoggerService.debug('Camera controller initialized', tag: 'ScannerCamera');
    } on Exception catch (e) {
      LoggerService.error('Failed to initialize camera', error: e, tag: 'ScannerCamera');
      rethrow;
    }
  }
  
  /// Handle barcode detection
  void handleBarcodeCapture(BarcodeCapture capture) {
    if (!_canScan || _isProcessing) {
      return;
    }
    
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) {
      return;
    }
    
    final barcode = barcodes.first;
    final code = barcode.rawValue;
    
    if (code == null || code.isEmpty) {
      return;
    }
    
    _isProcessing = true;
    _canScan = false;
    
    LoggerService.debug('Barcode detected: $code', tag: 'ScannerCamera');
    
    // Notify listener
    onBarcodeDetected(code);
    
    // Apply scan delay
    _scanDelayTimer?.cancel();
    _scanDelayTimer = Timer(scanDelay, () {
      _canScan = true;
      _isProcessing = false;
    });
  }
  
  /// Toggle torch/flashlight
  Future<void> toggleTorch() async {
    try {
      await _controller?.toggleTorch();
      LoggerService.debug('Torch toggled', tag: 'ScannerCamera');
    } on Exception catch (e) {
      LoggerService.error('Failed to toggle torch', error: e, tag: 'ScannerCamera');
    }
  }
  
  /// Switch camera facing
  Future<void> switchCamera() async {
    try {
      await _controller?.switchCamera();
      LoggerService.debug('Camera switched', tag: 'ScannerCamera');
    } on Exception catch (e) {
      LoggerService.error('Failed to switch camera', error: e, tag: 'ScannerCamera');
    }
  }
  
  /// Stop the camera
  Future<void> stop() async {
    _scanDelayTimer?.cancel();
    try {
      await _controller?.stop();
      LoggerService.debug('Camera stopped', tag: 'ScannerCamera');
    } on Exception catch (e) {
      LoggerService.error('Failed to stop camera', error: e, tag: 'ScannerCamera');
    }
  }
  
  /// Dispose of resources
  Future<void> dispose() async {
    _scanDelayTimer?.cancel();
    await _controller?.dispose();
    _controller = null;
    LoggerService.debug('Camera controller disposed', tag: 'ScannerCamera');
  }
}