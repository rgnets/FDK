# Top Bar and Navigation Implementation Plan

## Overview
This document provides a comprehensive, step-by-step plan to replace individual screen app bars with a unified top bar design based on the mockup at `assets/images/mockups/fdk_top_bar_sample.png`, and enhance the bottom navigation with visual feedback for current page indication.

## Mockup Requirements
The target design shows:
- **Left**: RG Nets logo (red/white branding)
- **Center**: "fdk" text with stylized chain/link graphic
- **Right**: Notification bell and sync status icons in rounded containers
- **Style**: Dark background, professional appearance, ~60-70px height

## Current State Analysis

### Files That Currently Have App Bars (Must Be Modified)
1. `lib/features/home/presentation/screens/home_screen.dart` - Lines 41-101
2. `lib/features/devices/presentation/screens/devices_screen.dart` - Lines 42-101
3. `lib/features/scanner/presentation/screens/scanner_screen.dart` - Lines 393-398, 462-467, 1022-1025
4. `lib/features/notifications/presentation/screens/notifications_screen.dart`
5. `lib/features/rooms/presentation/screens/rooms_screen.dart`
6. `lib/features/rooms/presentation/screens/room_detail_screen.dart`
7. `lib/features/devices/presentation/screens/device_detail_screen.dart`
8. `lib/features/settings/presentation/screens/settings_screen.dart`
9. `lib/features/debug/debug_screen.dart`

### Key Files to Create/Modify
- **Create**: `lib/core/widgets/fdk_app_bar.dart`
- **Create**: `lib/core/providers/app_bar_provider.dart`
- **Modify**: `lib/core/widgets/main_scaffold.dart`
- **Modify**: `lib/core/theme/app_theme.dart`
- **Modify**: `lib/core/theme/app_colors.dart`

## Implementation Steps

### Step 1: Create App Bar State Provider
**File**: `lib/core/providers/app_bar_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppBarState {
  final String currentRoute;
  final String pageTitle;
  final bool showSearch;
  final bool isConnected;
  
  AppBarState({
    required this.currentRoute,
    required this.pageTitle,
    this.showSearch = false,
    this.isConnected = true,
  });
}

class AppBarNotifier extends StateNotifier<AppBarState> {
  AppBarNotifier() : super(AppBarState(currentRoute: '/home', pageTitle: 'Dashboard'));
  
  void updateRoute(String route) {
    state = AppBarState(
      currentRoute: route,
      pageTitle: _getTitleForRoute(route),
      showSearch: _shouldShowSearch(route),
      isConnected: state.isConnected,
    );
  }
  
  void updateConnectionStatus(bool connected) {
    state = AppBarState(
      currentRoute: state.currentRoute,
      pageTitle: state.pageTitle,
      showSearch: state.showSearch,
      isConnected: connected,
    );
  }
  
  String _getTitleForRoute(String route) {
    if (route.startsWith('/home')) return 'Dashboard';
    if (route.startsWith('/scanner')) return 'Scanner';
    if (route.startsWith('/devices')) return 'Devices';
    if (route.startsWith('/notifications')) return 'Notifications';
    if (route.startsWith('/rooms')) return 'Rooms';
    if (route.startsWith('/settings')) return 'Settings';
    return 'RG Nets FDK';
  }
  
  bool _shouldShowSearch(String route) {
    return route.startsWith('/devices') || route.startsWith('/rooms');
  }
}

final appBarProvider = StateNotifierProvider<AppBarNotifier, AppBarState>((ref) {
  return AppBarNotifier();
});
```

### Step 2: Create Custom App Bar Widget
**File**: `lib/core/widgets/fdk_app_bar.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/providers/app_bar_provider.dart';
import 'package:rgnets_fdk/features/notifications/presentation/providers/notifications_domain_provider.dart';

class FDKAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const FDKAppBar({super.key});
  
  @override
  Size get preferredSize => const Size.fromHeight(65);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBarState = ref.watch(appBarProvider);
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);
    final unreadCount = unreadCountAsync.when(
      data: (count) => count,
      loading: () => 0,
      error: (_, __) => 0,
    );
    
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // Left: RG Nets Logo
              _buildLogo(),
              
              // Center: FDK Title with chain graphic
              Expanded(
                child: _buildCenterSection(appBarState.pageTitle),
              ),
              
              // Right: Action buttons
              _buildActionButtons(context, unreadCount, appBarState.isConnected),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 40,
      padding: const EdgeInsets.only(right: 16),
      child: Image.asset(
        'assets/images/logos/2021_rgnets_logo_twotone_white.png',
        fit: BoxFit.contain,
      ),
    );
  }
  
  Widget _buildCenterSection(String subtitle) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Chain/link graphic (using icons for now)
            Icon(
              Icons.link,
              color: Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 8),
            // FDK logo/text
            Image.asset(
              'assets/images/logos/fdk_logo.png',
              height: 25,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.link,
              color: Colors.grey[400],
              size: 20,
            ),
            // Subtitle for context
            if (subtitle.isNotEmpty) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context, int unreadCount, bool isConnected) {
    return Row(
      children: [
        // Notification button
        _buildActionButton(
          icon: Icons.notifications_outlined,
          badge: unreadCount > 0 ? unreadCount.toString() : null,
          onTap: () => context.go('/notifications'),
          badgeColor: Colors.red,
        ),
        const SizedBox(width: 8),
        // Connection status
        _buildActionButton(
          icon: isConnected ? Icons.check_circle_outline : Icons.error_outline,
          onTap: () => _showConnectionStatus(context, isConnected),
          iconColor: isConnected ? Colors.green : Colors.orange,
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    String? badge,
    required VoidCallback onTap,
    Color? iconColor,
    Color? badgeColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: iconColor ?? Colors.white,
              size: 22,
            ),
            if (badge != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: badgeColor ?? Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  void _showConnectionStatus(BuildContext context, bool isConnected) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isConnected ? 'Connected to server' : 'Connection issues detected',
        ),
        backgroundColor: isConnected ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
```

### Step 3: Update Main Scaffold with Enhanced Bottom Navigation
**File**: `lib/core/widgets/main_scaffold.dart`

Replace the entire file with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/widgets/fdk_app_bar.dart';
import 'package:rgnets_fdk/core/providers/app_bar_provider.dart';

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({
    required this.child,
    super.key,
  });
  final Widget child;

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _lastIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    
    // Update app bar state when route changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = GoRouterState.of(context).uri.toString();
      ref.read(appBarProvider.notifier).updateRoute(location);
    });
    
    // Animate on tab change
    if (currentIndex != _lastIndex) {
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      _lastIndex = currentIndex;
    }
    
    return Scaffold(
      appBar: const FDKAppBar(),
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(index, context),
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          backgroundColor: const Color(0xFF1A1A1A),
          items: [
            _buildNavItem(Icons.home_rounded, 'Home', 0, currentIndex),
            _buildNavItem(Icons.qr_code_scanner_rounded, 'Scanner', 1, currentIndex),
            _buildNavItem(Icons.devices_rounded, 'Devices', 2, currentIndex),
            _buildNavItem(Icons.notifications_rounded, 'Alerts', 3, currentIndex),
            _buildNavItem(Icons.meeting_room_rounded, 'Rooms', 4, currentIndex),
            _buildNavItem(Icons.settings_rounded, 'Settings', 5, currentIndex),
          ],
        ),
      ),
    );
  }
  
  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
    int currentIndex,
  ) {
    final isSelected = index == currentIndex;
    
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isSelected ? 8 : 4),
        decoration: BoxDecoration(
          color: isSelected 
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedScale(
          scale: isSelected ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            icon,
            size: isSelected ? 26 : 24,
          ),
        ),
      ),
      label: label,
      backgroundColor: isSelected
        ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
        : null,
    );
  }
  
  static int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/scanner')) {
      return 1;
    }
    if (location.startsWith('/devices')) {
      return 2;
    }
    if (location.startsWith('/notifications')) {
      return 3;
    }
    if (location.startsWith('/rooms')) {
      return 4;
    }
    if (location.startsWith('/settings')) {
      return 5;
    }
    
    return 0;
  }
  
  void _onItemTapped(int index, BuildContext context) {
    // Add haptic feedback on mobile
    HapticFeedback.lightImpact();
    
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/scanner');
      case 2:
        context.go('/devices');
      case 3:
        context.go('/notifications');
      case 4:
        context.go('/rooms');
      case 5:
        context.go('/settings');
    }
  }
}
```

### Step 4: Update Theme Colors
**File**: `lib/core/theme/app_colors.dart`

Add these colors after line 52:

```dart
  // App Bar specific colors
  static const Color appBarBackground = Color(0xFF1A1A1A);
  static const Color appBarBorder = Color(0xFF333333);
  static const Color activeNavItem = primary;
  static const Color activeNavBackground = Color(0x1A4A90E2);
```

### Step 5: Remove Individual App Bars from Screens

For each screen file, remove the `appBar:` property from the Scaffold widget:

#### 5.1 Home Screen
**File**: `lib/features/home/presentation/screens/home_screen.dart`
- Remove lines 41-101 (entire appBar property)
- Change line 40 from `Scaffold(` to `return Scaffold(`
- Remove the closing `),` that was for the appBar

#### 5.2 Devices Screen
**File**: `lib/features/devices/presentation/screens/devices_screen.dart`
- Remove lines 42-101
- Preserve search functionality by moving it to a floating search bar or header widget

#### 5.3 Scanner Screen
**File**: `lib/features/scanner/presentation/screens/scanner_screen.dart`
- Remove lines 393-398 (first appBar)
- Remove lines 462-467 (second appBar)
- Remove lines 1022-1025 (third appBar)

#### 5.4 Other Screens
For each of these files, locate and remove the `appBar:` property:
- `lib/features/notifications/presentation/screens/notifications_screen.dart`
- `lib/features/rooms/presentation/screens/rooms_screen.dart`
- `lib/features/rooms/presentation/screens/room_detail_screen.dart`
- `lib/features/devices/presentation/screens/device_detail_screen.dart`
- `lib/features/settings/presentation/screens/settings_screen.dart`
- `lib/features/debug/debug_screen.dart`

### Step 6: Add Import Statements

For all modified screen files, ensure these imports are present:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/app_bar_provider.dart';
```

### Step 7: Testing Checklist

1. **Visual Testing**:
   - [ ] App bar appears consistently on all screens
   - [ ] RG Nets logo displays correctly
   - [ ] FDK logo/text is centered
   - [ ] Notification badge shows correct count
   - [ ] Connection status indicator works

2. **Navigation Testing**:
   - [ ] Bottom navigation shows current page with visual feedback
   - [ ] Selected item has background highlight
   - [ ] Selected item icon scales up slightly
   - [ ] Page title updates in app bar center section
   - [ ] Smooth animations between tab switches

3. **Functionality Testing**:
   - [ ] Notification button navigates to notifications screen
   - [ ] Connection status shows appropriate message
   - [ ] Search functionality preserved where needed
   - [ ] All screen-specific actions still accessible

4. **Responsive Testing**:
   - [ ] Test on different screen sizes
   - [ ] Test on iOS and Android
   - [ ] Test on web browser
   - [ ] Test landscape orientation

### Step 8: Cleanup and Optimization

1. Remove any unused imports from modified files
2. Run `flutter analyze` to check for issues
3. Run `flutter test` to ensure no tests are broken
4. Format all modified files with `flutter format`

## Migration Order

Execute in this order to minimize disruption:

1. Create new files (app_bar_provider.dart, fdk_app_bar.dart)
2. Update theme colors
3. Update MainScaffold with new app bar and enhanced bottom nav
4. Test on home screen first
5. Remove app bars from remaining screens one by one
6. Run full test suite

## Rollback Plan

If issues arise:
1. Keep original files in git history
2. Can temporarily disable global app bar by removing from MainScaffold
3. Individual screens will still function without their app bars removed

## Success Criteria

- [ ] Unified top bar matches mockup design
- [ ] All screens display consistent navigation
- [ ] Bottom navigation clearly indicates current page
- [ ] No loss of existing functionality
- [ ] Improved user experience with visual feedback
- [ ] Clean, maintainable code structure

## Notes for Implementation

- Use `HapticFeedback.lightImpact()` for mobile haptic feedback
- Ensure SafeArea is used appropriately for notches/status bars
- Consider adding search overlay for devices/rooms screens
- Monitor performance with DevTools after implementation
- Document any custom behaviors for future developers

## File References

Assets to use:
- Logo: `assets/images/logos/2021_rgnets_logo_twotone_white.png`
- FDK: `assets/images/logos/fdk_logo.png`
- Mockup: `assets/images/mockups/fdk_top_bar_sample.png`

This plan is complete and ready for unattended execution by an LLM.