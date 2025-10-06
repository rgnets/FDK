import 'package:flutter/material.dart';

/// Application color palette
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();
  
  // Primary colors - RG Nets Blue
  static const Color primary = Color(0xFF4A90E2);
  static const Color primaryLight = Color(0xFF6BA3E5);
  static const Color primaryDark = Color(0xFF2E7CD6);
  
  // Secondary colors - RG Nets Orange
  static const Color secondary = Color(0xFFFF6B00);
  static const Color secondaryLight = Color(0xFFFF8A33);
  static const Color secondaryDark = Color(0xFFCC5500);
  
  // Background colors
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color surfaceDark = Color(0xFF2D2D2D);
  static const Color cardDark = Color(0xFF242424);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Device type colors
  static const Color deviceAP = Color(0xFF4CAF50);
  static const Color deviceONT = Color(0xFF2196F3);
  static const Color deviceSwitch = Color(0xFF9C27B0);
  
  // Grayscale
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);
  static const Color black = Color(0xFF000000);
  
  // Semantic colors for dark theme
  static const Color textPrimary = white;
  static const Color textSecondary = gray400;
  static const Color textDisabled = gray600;
  static const Color divider = gray800;
  static const Color border = gray700;
  
  // App Bar specific colors
  static const Color appBarBackground = Color(0xFF1A1A1A);
  static const Color appBarBorder = Color(0xFF333333);
  static const Color activeNavItem = primary;
  static const Color activeNavBackground = Color(0x1A4A90E2);
}