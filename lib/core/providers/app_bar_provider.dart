import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';

/// State class for app bar
class AppBarState {
  
  AppBarState({
    required this.currentRoute,
    required this.pageTitle,
    this.showSearch = false,
    this.isConnected = true,
  });
  
  final String currentRoute;
  final String pageTitle;
  final bool showSearch;
  final bool isConnected;
  
  AppBarState copyWith({
    String? currentRoute,
    String? pageTitle,
    bool? showSearch,
    bool? isConnected,
  }) {
    return AppBarState(
      currentRoute: currentRoute ?? this.currentRoute,
      pageTitle: pageTitle ?? this.pageTitle,
      showSearch: showSearch ?? this.showSearch,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

/// Notifier for app bar state management
class AppBarNotifier extends StateNotifier<AppBarState> {
  AppBarNotifier() : super(
    AppBarState(
      currentRoute: '/home',
      pageTitle: 'Dashboard',
    ),
  ) {
    LoggerService.debug('AppBarNotifier initialized', tag: 'AppBar');
  }
  
  void updateRoute(String route) {
    LoggerService.debug('Updating route to: $route', tag: 'AppBar');
    
    state = state.copyWith(
      currentRoute: route,
      pageTitle: _getTitleForRoute(route),
      showSearch: _shouldShowSearch(route),
    );
    
    LoggerService.debug('Updated app bar state - Title: ${state.pageTitle}, Search: ${state.showSearch}', tag: 'AppBar');
  }
  
  void updateConnectionStatus({required bool connected}) {
    LoggerService.debug('Updating connection status to: $connected', tag: 'AppBar');
    
    state = state.copyWith(
      isConnected: connected,
    );
  }
  
  String _getTitleForRoute(String route) {
    // Remove query parameters and fragments
    final cleanRoute = route.split('?').first.split('#').first;
    
    if (cleanRoute.startsWith('/home')) {
      return 'Dashboard';
    }
    if (cleanRoute.startsWith('/scanner')) {
      return 'Scanner';
    }
    if (cleanRoute.startsWith('/devices')) {
      return 'Devices';
    }
    if (cleanRoute.startsWith('/notifications')) {
      return 'Notifications';
    }
    if (cleanRoute.startsWith('/rooms')) {
      return 'Rooms';
    }
    if (cleanRoute.startsWith('/settings')) {
      return 'Settings';
    }
    
    LoggerService.debug('Unknown route for title: $cleanRoute', tag: 'AppBar');
    return 'RG Nets FDK';
  }
  
  bool _shouldShowSearch(String route) {
    final cleanRoute = route.split('?').first.split('#').first;
    return cleanRoute.startsWith('/devices') || cleanRoute.startsWith('/rooms');
  }
}

/// Provider for app bar state
final appBarProvider = StateNotifierProvider<AppBarNotifier, AppBarState>((ref) {
  return AppBarNotifier();
});