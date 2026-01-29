import 'package:flutter/material.dart';

/// A widget that automatically scales text down to fit within its parent.
///
/// Use this for text that must fit in a constrained space but should
/// remain readable at larger system font sizes.
class ScalableText extends StatelessWidget {
  const ScalableText(
    this.text, {
    required this.style,
    this.maxLines = 1,
    this.textAlign,
    this.alignment = Alignment.centerLeft,
    super.key,
  });

  final String text;
  final TextStyle style;
  final int maxLines;
  final TextAlign? textAlign;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: alignment,
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
      ),
    );
  }
}

/// Extension for convenient text overflow handling.
extension TextOverflowX on Text {
  /// Wraps this Text widget in a FittedBox that scales down to fit.
  Widget scalable({Alignment alignment = Alignment.centerLeft}) => FittedBox(
        fit: BoxFit.scaleDown,
        alignment: alignment,
        child: this,
      );
}

/// Maximum text scale factor allowed in the app.
///
/// This provides a balance between accessibility (allowing some scaling)
/// and preventing layout overflow issues.
const double maxTextScaleFactor = 1.3;

/// Clamps the text scale factor to the allowed maximum.
///
/// Use this in MediaQuery to limit system font scaling:
/// ```dart
/// MediaQuery(
///   data: MediaQuery.of(context).copyWith(
///     textScaler: clampedTextScaler(context),
///   ),
///   child: // ...
/// )
/// ```
TextScaler clampedTextScaler(BuildContext context) {
  final currentScale = MediaQuery.textScalerOf(context).scale(1);
  // Only clamp the upper bound - allow users to use smaller text if desired
  final clampedScale = currentScale > maxTextScaleFactor ? maxTextScaleFactor : currentScale;
  return TextScaler.linear(clampedScale);
}
