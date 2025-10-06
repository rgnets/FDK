import 'package:flutter/material.dart';

/// Info about a pulse including position and intensity
class PulseInfo {
  PulseInfo({required this.position, required this.intensity});
  
  final double position;
  final double intensity; // 0.0 to 1.0
}

/// Custom painter for a horizontal line that dips under the FDK logo
/// with a traveling pulse effect
class WaveLinePainter extends CustomPainter {
  WaveLinePainter({
    required this.lineColor,
    this.baseThickness = 1.0,
    this.pulseInfos = const [],
    this.animationValue = 0.0,
  });
  
  final Color lineColor;
  final double baseThickness;
  final List<PulseInfo> pulseInfos; // Pulse positions with intensity
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Create the path for the line
    final path = _createWavePath(size);

    // Draw the main line
    paint.strokeWidth = baseThickness;
    canvas.drawPath(path, paint);

    // Draw multiple traveling pulse effects for morse code with varying intensity
    for (final pulse in pulseInfos) {
      if (pulse.position >= 0 && pulse.position <= 1.2) {
        // Allow slight overflow
        _drawPulse(canvas, size, path, pulse.position, pulse.intensity);
      }
    }
  }

  Path _createWavePath(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;

    // Line positioned VERY CLOSE TO TOP - 5% from top
    final lineY = height * 0.05;

    // Dip parameters - VERY deep dip to go well under logo, WIDER center
    final dipStartX = width * 0.25; // Start dipping at 25% width (was 35%)
    final dipEndX = width * 0.75; // End dipping at 75% width (was 65%)
    final dipDepth = height * 0.90; // Dip down to 95% of height (5% + 90% = 95%)

    // Start from left edge NEAR THE TOP and draw straight line to dip start
    path
      ..moveTo(0, lineY)
      ..lineTo(dipStartX, lineY);

    // Create smooth dip under logo using cubic bezier
    // Bottom points at 35% and 65%
    final bottomStartX = width * 0.35;
    final bottomEndX = width * 0.65;

    // Slightly smoother, consistent corner radius matching mockup
    // All four corners have the same subtle rounding
    const cornerSmoothing = 0.15; // Subtle rounding factor for all corners
    
    // First corner (top-left of dip) - slightly rounded transition
    final cp1 = Offset(dipStartX + (bottomStartX - dipStartX) * cornerSmoothing, lineY + dipDepth * 0.1);
    final cp2 = Offset(bottomStartX - (bottomStartX - dipStartX) * (cornerSmoothing * 0.5), lineY + dipDepth * 0.9);
    final dipBottomLeft = Offset(bottomStartX, lineY + dipDepth);
    
    // First part: smooth transition from top to bottom left
    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, dipBottomLeft.dx, dipBottomLeft.dy);
    
    // Bottom part: flat section
    final dipBottomRight = Offset(bottomEndX, lineY + dipDepth);
    path.lineTo(dipBottomRight.dx, dipBottomRight.dy);
    
    // Second corner (bottom-right of dip) - matching radius
    final cp3 = Offset(bottomEndX + (dipEndX - bottomEndX) * (cornerSmoothing * 0.5), lineY + dipDepth * 0.9);
    final cp4 = Offset(dipEndX - (dipEndX - bottomEndX) * cornerSmoothing, lineY + dipDepth * 0.1);
    
    path
      ..cubicTo(cp3.dx, cp3.dy, cp4.dx, cp4.dy, dipEndX, lineY)
      // Continue straight NEAR THE TOP to right edge
      ..lineTo(width, lineY);

    return path;
  }

  void _drawPulse(Canvas canvas, Size size, Path path, double pulsePosition, double intensity) {
    // Calculate pulse width (about 10% of screen width)
    final pulseWidth = size.width * 0.1;
    final pulseCenter = size.width * pulsePosition;

    // Create gradient for pulse effect with intensity-based brightness
    final pulseGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        lineColor.withValues(alpha: 0), 
        lineColor.withValues(alpha: intensity), // Use intensity for brightness
        lineColor.withValues(alpha: 0)
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    // Create a clipping region for the pulse
    final pulseRect = Rect.fromLTWH(pulseCenter - pulseWidth / 2, 0, pulseWidth, size.height);

    // Draw thicker line in pulse area
    final pulsePaint = Paint()
      ..shader = pulseGradient.createShader(pulseRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          baseThickness *
          2.0 // Double thickness for pulse visibility with ultra-thin line
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.3);

    // Save canvas state, clip to pulse area and draw the pulse
    canvas
      ..save()
      ..clipRect(pulseRect)
      ..drawPath(path, pulsePaint);

    // Add glow effect proportional to intensity
    final glowPaint = Paint()
      ..color = lineColor.withValues(alpha: intensity * 0.3) // Glow intensity varies with pulse
      ..style = PaintingStyle.stroke
      ..strokeWidth = baseThickness * 3  // Slightly wider glow for visibility
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 1.5);

    canvas
      ..drawPath(path, glowPaint)
      // Restore canvas state
      ..restore();
  }

  @override
  bool shouldRepaint(WaveLinePainter oldDelegate) {
    return oldDelegate.pulseInfos != pulseInfos ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.baseThickness != baseThickness;
  }
}
