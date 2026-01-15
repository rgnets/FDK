import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/providers/app_bar_provider.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/widgets/fdk_app_bar.dart';
import 'package:rgnets_fdk/features/issues/presentation/providers/health_notices_provider.dart';

/// Main app scaffold with top app bar and enhanced bottom navigation
class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  int _lastIndex = 0;
  int _previousCriticalCount = 0;

  @override
  void initState() {
    super.initState();
    LoggerService.debug('MainScaffold initialized', tag: 'Navigation');

    _animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);
    final criticalCount = ref.watch(criticalIssueCountProvider);

    // Update app bar state when route changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = GoRouterState.of(context).uri.toString();
      ref.read(appBarProvider.notifier).updateRoute(location);
      LoggerService.debug('Route changed to: $location, Index: $currentIndex', tag: 'Navigation');
    });

    // Trigger pulse animation when critical count increases
    if (criticalCount > _previousCriticalCount && _previousCriticalCount >= 0) {
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
    _previousCriticalCount = criticalCount;

    // Animate on tab change
    if (currentIndex != _lastIndex) {
      LoggerService.debug('Tab changed from $_lastIndex to $currentIndex', tag: 'Navigation');
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      _lastIndex = currentIndex;
    }

    return Scaffold(
      appBar: const FDKAppBar(),
      body: widget.child,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, -2)),
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
            _buildNavItemWithBadge(
              Icons.notifications_rounded,
              'Alerts',
              3,
              currentIndex,
              criticalCount,
            ),
            _buildNavItem(Icons.meeting_room_rounded, 'Locations', 4, currentIndex),
            _buildNavItem(Icons.settings_rounded, 'Settings', 5, currentIndex),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label, int index, int currentIndex) {
    final isSelected = index == currentIndex;

    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isSelected ? 8 : 4),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedScale(
          scale: isSelected ? 1.1 : 1,
          duration: const Duration(milliseconds: 200),
          child: Icon(icon, size: isSelected ? 26 : 24),
        ),
      ),
      label: label,
      backgroundColor: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05) : null,
    );
  }

  BottomNavigationBarItem _buildNavItemWithBadge(
    IconData icon,
    String label,
    int index,
    int currentIndex,
    int badgeCount,
  ) {
    final isSelected = index == currentIndex;

    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isSelected ? 8 : 4),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.1 : 1,
              duration: const Duration(milliseconds: 200),
              child: Icon(icon, size: isSelected ? 26 : 24),
            ),
            if (badgeCount > 0)
              Positioned(
                right: -6,
                top: -4,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.3),
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      label: label,
      backgroundColor: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05) : null,
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
    LoggerService.debug('Navigation item tapped: $index', tag: 'Navigation');

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
