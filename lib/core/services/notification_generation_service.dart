import 'dart:async';

import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification.dart';

/// Service for generating device-status-based notifications
/// Generates notifications automatically based on device status during refresh
class NotificationGenerationService {
  NotificationGenerationService();

  // Stream controllers for notification events
  final _notificationController = StreamController<AppNotification>.broadcast();
  final _notificationListController =
      StreamController<List<AppNotification>>.broadcast();

  Stream<AppNotification> get notificationStream =>
      _notificationController.stream;
  Stream<List<AppNotification>> get notificationListStream =>
      _notificationListController.stream;

  // Track previous device states to detect transitions
  final Map<String, _DeviceState> _previousDeviceStates = {};

  // Store generated notifications locally
  final List<AppNotification> _notifications = [];

  // Retention policy constants
  static const int _maxNotifications = 500;
  static const Duration _notificationTtl = Duration(hours: 24);
  
  /// Generate notifications from device status changes
  List<AppNotification> generateFromDevices(List<Device> devices) {
    final newNotifications = <AppNotification>[];
    final now = DateTime.now();

    // Prune old notifications first (retention policy)
    _pruneNotifications(now);

    for (final device in devices) {
      final previousState = _previousDeviceStates[device.id];
      final currentState = _DeviceState(
        isOnline: device.isOnline,
        hasNote: device.note != null && device.note!.isNotEmpty,
        hasImages: device.images != null && device.images!.isNotEmpty,
      );

      // Generate notifications only on state TRANSITIONS
      final deviceNotifications = _generateDeviceNotifications(
        device,
        now,
        previousState,
        currentState,
      );
      newNotifications.addAll(deviceNotifications);

      // Update tracked state
      _previousDeviceStates[device.id] = currentState;
    }

    // Add new notifications to our local store
    _notifications.addAll(newNotifications);

    // Emit new notifications
    for (final notification in newNotifications) {
      _notificationController.add(notification);
    }

    // Emit updated notification list
    _notificationListController.add(List.from(_notifications));

    return newNotifications;
  }

  /// Prune notifications based on TTL and max count
  void _pruneNotifications(DateTime now) {
    // Remove notifications older than TTL
    _notifications.removeWhere(
      (n) => now.difference(n.timestamp) > _notificationTtl,
    );

    // If still over max, remove oldest (already sorted by timestamp)
    if (_notifications.length > _maxNotifications) {
      // Sort by timestamp descending (newest first)
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      // Keep only the newest _maxNotifications
      _notifications.removeRange(_maxNotifications, _notifications.length);
    }
  }
  
  /// Generate notifications for a specific device based on STATE TRANSITIONS
  /// Only generates notifications when state changes, not on every refresh.
  /// - URGENT (Red): online -> offline transition
  /// - MEDIUM (Orange): no note -> has note transition
  /// - LOW (Green): has images -> no images transition
  List<AppNotification> _generateDeviceNotifications(
    Device device,
    DateTime timestamp,
    _DeviceState? previousState,
    _DeviceState currentState,
  ) {
    final notifications = <AppNotification>[];

    // First time seeing this device? Only notify for problem states
    final isFirstSeen = previousState == null;

    // 1. URGENT priority - Device went offline (online -> offline transition)
    if (!currentState.isOnline) {
      // Only notify if: first time seen offline, OR was online before
      final wentOffline = isFirstSeen || previousState.isOnline;
      if (wentOffline) {
        notifications.add(AppNotification(
          id: 'offline-${device.id}-${timestamp.millisecondsSinceEpoch}',
          title: 'Device Offline',
          message: '${device.name} is offline',
          type: NotificationType.deviceOffline,
          priority: NotificationPriority.urgent,
          timestamp: timestamp,
          isRead: false,
          deviceId: device.id,
          location: device.location,
          metadata: {
            'device_name': device.name,
            'device_type': device.type,
            'location': device.location,
            'last_seen': device.lastSeen?.toIso8601String(),
          },
        ));
      }
    }

    // 2. MEDIUM priority - Device has new note (no note -> has note transition)
    if (currentState.hasNote) {
      // Only notify if: first time seen with note, OR didn't have note before
      final noteAppeared = isFirstSeen || !previousState.hasNote;
      if (noteAppeared) {
        notifications.add(AppNotification(
          id: 'note-${device.id}-${timestamp.millisecondsSinceEpoch}',
          title: 'Device Has Note',
          message: '${device.name}: ${device.note}',
          type: NotificationType.deviceNote,
          priority: NotificationPriority.medium,
          timestamp: timestamp,
          isRead: false,
          deviceId: device.id,
          location: device.location,
          metadata: {
            'device_name': device.name,
            'device_type': device.type,
            'location': device.location,
            'note': device.note,
          },
        ));
      }
    }

    // 3. LOW priority - Images removed (had images -> no images transition)
    if (!currentState.hasImages) {
      // Only notify if: first time seen without images, OR had images before
      final imagesRemoved = isFirstSeen || previousState.hasImages;
      if (imagesRemoved) {
        notifications.add(AppNotification(
          id: 'image-${device.id}-${timestamp.millisecondsSinceEpoch}',
          title: 'Missing Images',
          message: '${device.name} is missing images',
          type: NotificationType.missingImage,
          priority: NotificationPriority.low,
          timestamp: timestamp,
          isRead: false,
          deviceId: device.id,
          location: device.location,
          metadata: {
            'device_name': device.name,
            'device_type': device.type,
            'location': device.location,
          },
        ));
      }
    }

    return notifications;
  }
  
  /// Get all stored notifications
  List<AppNotification> getAllNotifications() {
    return List.from(_notifications);
  }
  
  /// Get unread notifications count
  int getUnreadCount() {
    return _notifications.where((n) => !n.isRead).length;
  }
  
  /// Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _notificationListController.add(List.from(_notifications));
    }
  }
  
  /// Mark all notifications as read
  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    _notificationListController.add(List.from(_notifications));
  }
  
  /// Delete a notification
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _notificationListController.add(List.from(_notifications));
  }
  
  /// Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
    _notificationListController.add(<AppNotification>[]);
  }
  
  /// Dispose resources
  void dispose() {
    _notificationController.close();
    _notificationListController.close();
  }

  /// Reset state on sign-out
  void reset() {
    _notifications.clear();
    _previousDeviceStates.clear();
    _notificationListController.add(<AppNotification>[]);
  }
}

/// Tracks previous device state for transition detection
class _DeviceState {
  _DeviceState({
    required this.isOnline,
    required this.hasNote,
    required this.hasImages,
  });

  final bool isOnline;
  final bool hasNote;
  final bool hasImages;
}