# Design System - RG Nets Field Deployment Kit

**Created**: 2025-08-17
**Purpose**: Complete design system specification for consistent UI

## Brand Colors

### Primary Palette
```dart
class BrandColors {
  // RG Nets Dark Theme Primary
  static const Color primary = Color(0xFF1A1A1A);      // Dark background
  static const Color primaryLight = Color(0xFF2D2D2D); // Lighter dark
  static const Color primaryDark = Color(0xFF000000);  // Pure black
  
  // RG Nets Blue Accent
  static const Color accent = Color(0xFF4A90E2);       // Blue accent
  static const Color accentLight = Color(0xFF6BA3E5);  // Lighter blue
  static const Color accentDark = Color(0xFF2E7CD6);   // Darker blue
  
  // RG Nets Orange (Secondary)
  static const Color secondary = Color(0xFFFF6B00);    // RG Nets orange
  static const Color secondaryLight = Color(0xFFFF9A4D);
  static const Color secondaryDark = Color(0xFFCC5500);
  
  // Neutral Grays
  static const Color gray900 = Color(0xFF1A1A1A);     // Almost black
  static const Color gray800 = Color(0xFF2D2D2D);
  static const Color gray700 = Color(0xFF404040);
  static const Color gray600 = Color(0xFF525252);
  static const Color gray500 = Color(0xFF737373);
  static const Color gray400 = Color(0xFF9E9E9E);
  static const Color gray300 = Color(0xFFBDBDBD);
  static const Color gray200 = Color(0xFFE0E0E0);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray50 = Color(0xFFFAFAFA);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);     // Green
  static const Color warning = Color(0xFFFF9800);     // Orange
  static const Color error = Color(0xFFF44336);       // Red
  static const Color info = Color(0xFF2196F3);        // Blue
  
  // Device Status Colors
  static const Color online = Color(0xFF4CAF50);      // Green
  static const Color offline = Color(0xFFF44336);     // Red
  static const Color partial = Color(0xFFFF9800);     // Orange
  static const Color unknown = Color(0xFF9E9E9E);     // Gray
}
```

## Typography

### Font Family
```dart
class AppTypography {
  static const String fontFamily = 'Inter'; // Or RG Nets custom font
  
  // Display
  static const TextStyle display1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  // Headlines
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.3,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.4,
  );
  
  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.5,
  );
  
  // Labels
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  // Buttons
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1,
  );
  
  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.3,
  );
  
  // Monospace (for codes/IDs)
  static const TextStyle mono = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    fontFamily: 'Courier New',
    letterSpacing: 0,
    height: 1.4,
  );
}
```

## Spacing System (8px Grid)

```dart
class Spacing {
  static const double xxs = 2.0;   // 2px
  static const double xs = 4.0;    // 4px
  static const double sm = 8.0;    // 8px - Base unit
  static const double md = 16.0;   // 16px
  static const double lg = 24.0;   // 24px
  static const double xl = 32.0;   // 32px
  static const double xxl = 40.0;  // 40px
  static const double xxxl = 48.0; // 48px
  
  // Page margins
  static const double pagePadding = 16.0;
  static const double pageMargin = 20.0;
  
  // Component spacing
  static const double componentGap = 8.0;
  static const double sectionGap = 24.0;
  
  // List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
  );
  
  // Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(16.0);
}
```

## Border Radius

```dart
class BorderRadius {
  static const double none = 0.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double round = 999.0; // Pill shape
  
  // Component specific
  static const double button = 8.0;
  static const double card = 12.0;
  static const double dialog = 16.0;
  static const double bottomSheet = 20.0;
  static const double chip = 999.0;
  static const double avatar = 999.0;
}
```

## Elevation & Shadows

```dart
class Elevations {
  static const List<BoxShadow> none = [];
  
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];
  
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];
  
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 4),
      blurRadius: 8,
    ),
  ];
  
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 8),
      blurRadius: 16,
    ),
  ];
  
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1A000000),
      offset: Offset(0, 12),
      blurRadius: 24,
    ),
  ];
}
```

## Component Specifications

### Buttons

```dart
class ButtonStyles {
  // Primary Button
  static final primary = ElevatedButton.styleFrom(
    backgroundColor: BrandColors.primary,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BorderRadius.button),
    ),
    elevation: 2,
    textStyle: AppTypography.button,
  );
  
  // Secondary Button
  static final secondary = OutlinedButton.styleFrom(
    foregroundColor: BrandColors.primary,
    side: BorderSide(color: BrandColors.primary, width: 2),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BorderRadius.button),
    ),
    textStyle: AppTypography.button,
  );
  
  // Text Button
  static final text = TextButton.styleFrom(
    foregroundColor: BrandColors.primary,
    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    textStyle: AppTypography.button,
  );
  
  // Danger Button
  static final danger = ElevatedButton.styleFrom(
    backgroundColor: BrandColors.error,
    foregroundColor: Colors.white,
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BorderRadius.button),
    ),
    textStyle: AppTypography.button,
  );
}
```

### Cards

```dart
class CardStyles {
  static final standard = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(BorderRadius.card),
    boxShadow: Elevations.sm,
  );
  
  static final elevated = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(BorderRadius.card),
    boxShadow: Elevations.md,
  );
  
  static final outlined = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(BorderRadius.card),
    border: Border.all(color: BrandColors.gray200),
  );
}
```

### Input Fields

```dart
class InputStyles {
  static final standard = InputDecoration(
    filled: true,
    fillColor: BrandColors.gray50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: BrandColors.gray300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: BrandColors.gray300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: BrandColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: BrandColors.error),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    labelStyle: AppTypography.label,
    hintStyle: AppTypography.body.copyWith(color: BrandColors.gray400),
  );
}
```

## Icons

### Icon Set
```dart
class AppIcons {
  // Navigation
  static const IconData home = Icons.home_rounded;
  static const IconData rooms = Icons.meeting_room_rounded;
  static const IconData devices = Icons.devices_rounded;
  static const IconData scanner = Icons.qr_code_scanner_rounded;
  static const IconData notifications = Icons.notifications_rounded;
  static const IconData settings = Icons.settings_rounded;
  
  // Device Types
  static const IconData accessPoint = Icons.wifi_rounded;
  static const IconData switchDevice = Icons.hub_rounded;
  static const IconData ont = Icons.router_rounded;
  
  // Status
  static const IconData online = Icons.check_circle_rounded;
  static const IconData offline = Icons.error_rounded;
  static const IconData warning = Icons.warning_rounded;
  static const IconData info = Icons.info_rounded;
  
  // Actions
  static const IconData add = Icons.add_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_rounded;
  static const IconData refresh = Icons.refresh_rounded;
  static const IconData filter = Icons.filter_list_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData forward = Icons.arrow_forward_rounded;
  static const IconData expand = Icons.expand_more_rounded;
  static const IconData collapse = Icons.expand_less_rounded;
  
  // Sizes
  static const double sizeSmall = 16.0;
  static const double sizeMedium = 24.0;
  static const double sizeLarge = 32.0;
  static const double sizeXLarge = 48.0;
}
```

## Loading States

```dart
class LoadingIndicators {
  static Widget circular({Color? color}) => CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation(color ?? BrandColors.primary),
    strokeWidth: 3,
  );
  
  static Widget linear({Color? color}) => LinearProgressIndicator(
    valueColor: AlwaysStoppedAnimation(color ?? BrandColors.primary),
    backgroundColor: BrandColors.gray200,
  );
  
  static Widget shimmer() => Shimmer.fromColors(
    baseColor: BrandColors.gray200,
    highlightColor: BrandColors.gray100,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
  
  static Widget skeleton({
    double? width,
    double height = 20,
    double radius = 4,
  }) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: BrandColors.gray200,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}
```

## Empty States

```dart
class EmptyStates {
  static Widget standard({
    required IconData icon,
    required String title,
    String? message,
    Widget? action,
  }) => Center(
    child: Padding(
      padding: EdgeInsets.all(Spacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: BrandColors.gray400,
          ),
          SizedBox(height: Spacing.md),
          Text(
            title,
            style: AppTypography.h3,
            textAlign: TextAlign.center,
          ),
          if (message != null) ...[
            SizedBox(height: Spacing.sm),
            Text(
              message,
              style: AppTypography.body.copyWith(
                color: BrandColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            SizedBox(height: Spacing.lg),
            action,
          ],
        ],
      ),
    ),
  );
}
```

## Error States

```dart
class ErrorStates {
  static Widget standard({
    required String error,
    VoidCallback? onRetry,
  }) => Center(
    child: Padding(
      padding: EdgeInsets.all(Spacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: BrandColors.error,
          ),
          SizedBox(height: Spacing.md),
          Text(
            'Something went wrong',
            style: AppTypography.h3,
          ),
          SizedBox(height: Spacing.sm),
          Text(
            error,
            style: AppTypography.body.copyWith(
              color: BrandColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            SizedBox(height: Spacing.lg),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: Icon(Icons.refresh),
              label: Text('Try Again'),
              style: ButtonStyles.primary,
            ),
          ],
        ],
      ),
    ),
  );
}
```

## Theme Configuration

### Light Theme
```dart
final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  
  // Colors
  primaryColor: BrandColors.primary,
  colorScheme: ColorScheme.dark(
    primary: BrandColors.primary,
    secondary: BrandColors.secondary,
    error: BrandColors.error,
    surface: Colors.white,
    background: BrandColors.gray50,
  ),
  
  // Typography
  fontFamily: AppTypography.fontFamily,
  textTheme: TextTheme(
    displayLarge: AppTypography.display1,
    headlineLarge: AppTypography.h1,
    headlineMedium: AppTypography.h2,
    headlineSmall: AppTypography.h3,
    titleLarge: AppTypography.h4,
    bodyLarge: AppTypography.bodyLarge,
    bodyMedium: AppTypography.body,
    bodySmall: AppTypography.bodySmall,
    labelLarge: AppTypography.label,
    labelSmall: AppTypography.labelSmall,
  ),
  
  // Components
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: BrandColors.gray900,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: AppTypography.h4.copyWith(
      color: BrandColors.gray900,
    ),
  ),
  
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BorderRadius.card),
    ),
  ),
  
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyles.primary,
  ),
  
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyles.secondary,
  ),
  
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: BrandColors.gray50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);
```

### Light Theme (Optional/Secondary)
```dart
final lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  
  // Colors
  primaryColor: BrandColors.accent,
  colorScheme: ColorScheme.light(
    primary: BrandColors.accent,
    secondary: BrandColors.secondary,
    error: BrandColors.error,
    surface: Colors.white,
    background: BrandColors.gray50,
  ),
  
  // Typography (same structure, different colors)
  fontFamily: AppTypography.fontFamily,
  
  // Components adapted for dark mode
  appBarTheme: AppBarTheme(
    backgroundColor: BrandColors.gray900,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  
  cardTheme: CardTheme(
    color: BrandColors.gray800,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BorderRadius.card),
      side: BorderSide(color: BrandColors.gray700),
    ),
  ),
);
```

## Animations

```dart
class AppAnimations {
  // Durations
  static const Duration instant = Duration(milliseconds: 0);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 1000);
  
  // Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve enterCurve = Curves.easeOut;
  static const Curve exitCurve = Curves.easeIn;
  static const Curve bounceCurve = Curves.elasticOut;
  
  // Page transitions
  static const PageTransitionsTheme pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );
}
```

## Responsive Breakpoints

```dart
class Breakpoints {
  static const double mobile = 600;   // < 600px
  static const double tablet = 900;   // 600-900px
  static const double desktop = 1200; // > 900px
  
  static bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < mobile;
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }
  
  static bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= tablet;
}
```

## Usage Examples

```dart
// Using the design system
class ExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Example', style: AppTypography.h4),
      ),
      body: Padding(
        padding: EdgeInsets.all(Spacing.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Headline
            Text(
              'Dashboard',
              style: AppTypography.h1.copyWith(
                color: BrandColors.gray900,
              ),
            ),
            
            SizedBox(height: Spacing.md),
            
            // Card
            Container(
              padding: Spacing.cardPadding,
              decoration: CardStyles.standard,
              child: Column(
                children: [
                  // Status indicator
                  Row(
                    children: [
                      Icon(
                        AppIcons.online,
                        color: BrandColors.online,
                        size: AppIcons.sizeMedium,
                      ),
                      SizedBox(width: Spacing.sm),
                      Text(
                        'All Systems Operational',
                        style: AppTypography.body,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: Spacing.lg),
            
            // Button
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyles.primary,
              child: Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Summary

This design system provides:
- **Consistent colors** based on RG Nets brand
- **Typography scale** for all text styles
- **8px spacing grid** for consistent layout
- **Component specifications** for all UI elements
- **Loading/empty/error states** for all scenarios
- **Light and dark themes** with proper contrast
- **Responsive breakpoints** for all screen sizes