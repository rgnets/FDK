import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// A wrapper widget that corrects camera preview rotation on foldable devices
/// like the Pixel Fold when in unfolded (tablet) mode.
///
/// The issue: On foldable devices, when unfolded, the camera sensor orientation
/// doesn't match the inner display orientation, causing the preview to appear
/// rotated 90 degrees counterclockwise.
class FoldableCameraWrapper extends StatelessWidget {
  const FoldableCameraWrapper({
    required this.controller,
    required this.onDetect,
    super.key,
  });

  final MobileScannerController? controller;
  final void Function(BarcodeCapture)? onDetect;

  @override
  Widget build(BuildContext context) {
    if (controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final needsRotation = _needsRotationCorrection(context);

    if (!needsRotation) {
      return MobileScanner(
        controller: controller,
        onDetect: onDetect,
      );
    }

    // Apply 90 degree clockwise rotation to correct the counterclockwise offset
    return LayoutBuilder(
      builder: (context, constraints) {
        // When rotating 90 degrees, we need to swap width and height
        // and scale to fill the container properly
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return ClipRect(
          child: OverflowBox(
            maxWidth: height,
            maxHeight: width,
            child: Transform.rotate(
              angle: math.pi / 2, // 90 degrees clockwise
              child: SizedBox(
                width: height,
                height: width,
                child: MobileScanner(
                  controller: controller,
                  onDetect: onDetect,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Determines if the device needs camera rotation correction.
  ///
  /// This detects foldable devices in unfolded/tablet mode by checking:
  /// 1. Screen dimensions suggest a large inner display
  /// 2. Aspect ratio is more square (tablet-like) rather than phone-like
  ///
  /// Pixel Fold specs:
  /// - Folded (outer): ~5.8" display, ~17:9 aspect ratio
  /// - Unfolded (inner): ~7.6" display, ~6:5 aspect ratio
  bool _needsRotationCorrection(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final devicePixelRatio = mediaQuery.devicePixelRatio;

    // Get physical screen dimensions
    final physicalWidth = size.width * devicePixelRatio;
    final physicalHeight = size.height * devicePixelRatio;

    // Calculate aspect ratio (always use larger/smaller for consistency)
    final maxDimension = math.max(physicalWidth, physicalHeight);
    final minDimension = math.min(physicalWidth, physicalHeight);
    final aspectRatio = maxDimension / minDimension;

    // Pixel Fold unfolded characteristics:
    // - Physical resolution: 2208 x 1840 (inner display)
    // - Aspect ratio: ~1.2:1 (very square)
    // - Logical width in landscape or portrait will be large

    // Detect foldable in unfolded mode:
    // 1. Aspect ratio close to 1 (square-ish, < 1.4)
    // 2. Minimum dimension is large (> 1500 physical pixels suggests tablet/unfolded)
    // 3. Screen width in logical pixels > 600 (tablet-like width)

    final isSquareAspectRatio = aspectRatio < 1.4;
    final isLargeScreen = minDimension > 1500;
    final isWideLogicalScreen = size.shortestSide > 550;

    // Additional check: Pixel Fold has specific characteristics
    // Inner display: 2208x1840 physical, ~380 DPI
    // This gives roughly 580x484 logical pixels at standard scaling
    final isPotentiallyPixelFoldUnfolded =
        isSquareAspectRatio &&
        isLargeScreen &&
        isWideLogicalScreen &&
        devicePixelRatio >= 2.5; // High DPI display

    return isPotentiallyPixelFoldUnfolded;
  }
}

/// Extension to easily check if current device needs camera rotation
extension FoldableDetection on BuildContext {
  /// Returns true if the current device appears to be a foldable in unfolded mode
  bool get isFoldableUnfolded {
    final mediaQuery = MediaQuery.of(this);
    final size = mediaQuery.size;
    final devicePixelRatio = mediaQuery.devicePixelRatio;

    final physicalWidth = size.width * devicePixelRatio;
    final physicalHeight = size.height * devicePixelRatio;

    final maxDimension = math.max(physicalWidth, physicalHeight);
    final minDimension = math.min(physicalWidth, physicalHeight);
    final aspectRatio = maxDimension / minDimension;

    final isSquareAspectRatio = aspectRatio < 1.4;
    final isLargeScreen = minDimension > 1500;
    final isWideLogicalScreen = size.shortestSide > 550;

    return isSquareAspectRatio &&
           isLargeScreen &&
           isWideLogicalScreen &&
           devicePixelRatio >= 2.5;
  }
}
