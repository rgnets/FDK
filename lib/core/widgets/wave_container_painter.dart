import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Custom painter for wave-shaped container with bezier curves
class WaveContainerPainter extends CustomPainter {
  WaveContainerPainter({required this.borderColor, this.strokeWidth = 1.0, this.animationValue = 0.0});

  final Color borderColor;
  final double strokeWidth;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Create wave path with bezier curves
    final path = _createWavePath(size);

    // Draw the wave border
    canvas.drawPath(path, paint);

    // Optional: Add subtle glow effect during pulse
    if (animationValue > 0) {
      final glowPaint = Paint()
        ..color = borderColor.withValues(alpha: 0.3 * animationValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + (2 * animationValue)
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, 3 * animationValue);

      canvas.drawPath(path, glowPaint);
    }
  }

  Path _createWavePath(Size size) {
    final path = Path();
    final height = size.height;
    final width = size.width;

    // Wave parameters - responsive to size
    final waveHeight = height * 0.15; // 15% of height for wave amplitude
    final cornerRadius = height * 0.4; // Rounded corners

    // Start from top-left with curve
    path.moveTo(cornerRadius, 0);

    // Top edge with subtle wave
    final topControlPoint1 = Offset(width * 0.25, -waveHeight * 0.3);
    final topControlPoint2 = Offset(width * 0.75, waveHeight * 0.3);

    path.cubicTo(
      topControlPoint1.dx,
      topControlPoint1.dy,
      topControlPoint2.dx,
      topControlPoint2.dy,
      width - cornerRadius,
      0,
    );

    // Top-right corner, right edge with wave, bottom-right corner
    final rightWaveOffset = math.sin(animationValue * 2 * math.pi) * 2;
    path
      ..quadraticBezierTo(width, 0, width, cornerRadius)
      ..quadraticBezierTo(width + waveHeight * 0.5 + rightWaveOffset, height / 2, width, height - cornerRadius)
      ..quadraticBezierTo(width, height, width - cornerRadius, height);

    // Bottom edge with subtle wave (inverse of top)
    final bottomControlPoint1 = Offset(width * 0.75, height + waveHeight * 0.3);
    final bottomControlPoint2 = Offset(width * 0.25, height - waveHeight * 0.3);

    path.cubicTo(
      bottomControlPoint1.dx,
      bottomControlPoint1.dy,
      bottomControlPoint2.dx,
      bottomControlPoint2.dy,
      cornerRadius,
      height,
    );

    // Bottom-left corner, left edge with wave, close path
    final leftWaveOffset = math.sin(animationValue * 2 * math.pi + math.pi) * 2;
    path
      ..quadraticBezierTo(0, height, 0, height - cornerRadius)
      ..quadraticBezierTo(-waveHeight * 0.5 + leftWaveOffset, height / 2, 0, cornerRadius)
      ..quadraticBezierTo(0, 0, cornerRadius, 0);

    return path;
  }

  @override
  bool shouldRepaint(WaveContainerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
