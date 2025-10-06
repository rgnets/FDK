import 'package:flutter/material.dart';

/// Custom loading indicator with optional message
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message, this.isOverlay = false, this.size = 40});
  final String? message;
  final bool isOverlay;
  final double size;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(message!, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ],
    );

    if (isOverlay) {
      return ColoredBox(
        color: Colors.black54,
        child: Center(child: content),
      );
    }

    return Center(child: content);
  }
}

/// Full screen loading overlay
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({required this.child, required this.isLoading, super.key, this.message});
  final Widget child;
  final bool isLoading;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading) Positioned.fill(child: LoadingIndicator(message: message, isOverlay: true)),
      ],
    );
  }
}
