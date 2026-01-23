import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  );
  
  void updateRoute(String route) {
    state = state.copyWith(
      currentRoute: route,
      pageTitle: _getTitleForRoute(route),
      showSearch: _shouldShowSearch(route),
    );
  }
  
  void updateConnectionStatus({required bool connected}) {
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