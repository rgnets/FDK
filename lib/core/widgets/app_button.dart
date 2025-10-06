import 'package:flutter/material.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';

/// Custom button widget with consistent styling
class AppButton extends StatelessWidget {
  const AppButton({
    required this.text,
    super.key,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.isSmall = false,
    this.color,
  });
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool isSmall;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Theme.of(context).colorScheme.primary;

    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: buttonColor,
            side: BorderSide(color: buttonColor),
            padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 24, vertical: isSmall ? 8 : 12),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            foregroundColor: AppColors.white,
            padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 24, vertical: isSmall ? 8 : 12),
          );

    final child = isLoading
        ? SizedBox(
            width: isSmall ? 16 : 20,
            height: isSmall ? 16 : 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(isOutlined ? buttonColor : AppColors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: isSmall ? 18 : 20), const SizedBox(width: 8)],
              Text(text, style: TextStyle(fontSize: isSmall ? 14 : 16)),
            ],
          );

    if (isOutlined) {
      return OutlinedButton(onPressed: isLoading ? null : onPressed, style: buttonStyle, child: child);
    }

    return ElevatedButton(onPressed: isLoading ? null : onPressed, style: buttonStyle, child: child);
  }
}
