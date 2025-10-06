import 'package:go_router/go_router.dart';

/// Centralized navigation service following Clean Architecture
class NavigationService {
  const NavigationService();
  
  /// Navigate to devices screen
  void navigateToDevices(GoRouter router) {
    router.go('/devices');
  }
  
  /// Navigate to rooms/locations screen
  void navigateToRooms(GoRouter router) {
    router.go('/rooms');
  }
  
  /// Navigate to notifications with specific tab
  void navigateToNotifications(GoRouter router, {NotificationTab? tab}) {
    if (tab != null) {
      router.go('/notifications?tab=${tab.tabIndex}');
    } else {
      router.go('/notifications');
    }
  }
  
  /// Navigate to specific device detail
  void navigateToDeviceDetail(GoRouter router, String deviceId) {
    router.push('/devices/$deviceId');
  }
  
  /// Navigate to specific room detail
  void navigateToRoomDetail(GoRouter router, String roomId) {
    router.push('/rooms/$roomId');
  }
  
  /// Navigate to scanner with optional mode
  void navigateToScanner(GoRouter router, {String? mode}) {
    if (mode != null) {
      router.go('/scanner?mode=$mode');
    } else {
      router.go('/scanner');
    }
  }
  
  /// Navigate to settings
  void navigateToSettings(GoRouter router) {
    router.go('/settings');
  }
  
  /// Navigate to home
  void navigateToHome(GoRouter router) {
    router.go('/home');
  }
  
  /// Navigate back
  void navigateBack(GoRouter router) {
    if (router.canPop()) {
      router.pop();
    } else {
      navigateToHome(router);
    }
  }
}

/// Enum for notification tabs
enum NotificationTab {
  all,
  offline,
  docsMissing;
  
  int get tabIndex {
    switch (this) {
      case NotificationTab.all:
        return 0;
      case NotificationTab.offline:
        return 1;
      case NotificationTab.docsMissing:
        return 2;
    }
  }
}