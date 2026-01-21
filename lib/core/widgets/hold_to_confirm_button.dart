import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';

/// A button that requires the user to hold it down for a specified duration
/// before the action is confirmed. Used for destructive actions like
/// sign out, clear cache, delete, reboot, etc.
class HoldToConfirmButton extends StatefulWidget {
  const HoldToConfirmButton({
    required this.onConfirmed,
    required this.text,
    super.key,
    this.holdDuration = const Duration(seconds: 2),
    this.backgroundColor,
    this.progressColor,
    this.textColor,
    this.icon,
    this.enabled = true,
    this.width,
    this.height = 48,
  });

  /// Callback fired when user has held for the full duration
  final VoidCallback onConfirmed;

  /// Text displayed on the button
  final String text;

  /// Duration user must hold to confirm (default: 2 seconds)
  final Duration holdDuration;

  /// Background color of the button (default: error color)
  final Color? backgroundColor;

  /// Color of the progress indicator (default: white with opacity)
  final Color? progressColor;

  /// Color of the text (default: white)
  final Color? textColor;

  /// Optional icon to display before text
  final IconData? icon;

  /// Whether the button is enabled
  final bool enabled;

  /// Optional fixed width (default: expands to fill parent)
  final double? width;

  /// Height of the button (default: 48)
  final double height;

  @override
  State<HoldToConfirmButton> createState() => _HoldToConfirmButtonState();
}

class _HoldToConfirmButtonState extends State<HoldToConfirmButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  bool _isHolding = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    _animationController.addStatusListener(_onAnimationStatusChange);
  }

  @override
  void didUpdateWidget(HoldToConfirmButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.holdDuration != widget.holdDuration) {
      _animationController.duration = widget.holdDuration;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onAnimationStatusChange(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_isCompleted) {
      _isCompleted = true;
      // Haptic feedback on completion
      HapticFeedback.heavyImpact();
      widget.onConfirmed();
    }
  }

  void _startHold() {
    if (!widget.enabled || _isCompleted) {
      return;
    }

    setState(() {
      _isHolding = true;
    });

    // Light haptic feedback on press start
    HapticFeedback.lightImpact();
    _animationController.forward();
  }

  void _cancelHold() {
    if (_isCompleted) {
      return;
    }

    setState(() {
      _isHolding = false;
    });

    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? AppColors.error;
    final progressColor =
        widget.progressColor ?? AppColors.white.withValues(alpha: 0.3);
    final textColor = widget.textColor ?? AppColors.white;
    final disabledColor = bgColor.withValues(alpha: 0.5);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Listener(
        onPointerDown: widget.enabled ? (_) => _startHold() : null,
        onPointerUp: widget.enabled ? (_) => _cancelHold() : null,
        onPointerCancel: widget.enabled ? (_) => _cancelHold() : null,
        child: AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: widget.enabled ? bgColor : disabledColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Progress indicator (fills from left to right)
                  if (_isHolding || _animationController.value > 0)
                    Positioned.fill(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: progressColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                  // Button content
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: 20,
                            color: widget.enabled
                                ? textColor
                                : textColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          _isHolding ? 'Hold to confirm...' : widget.text,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: widget.enabled
                                        ? textColor
                                        : textColor.withValues(alpha: 0.5),
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
