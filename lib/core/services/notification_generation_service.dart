import 'dart:async';

import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification.dart';

/// Service for generating device-status-based notifications
/// Generates notifications automatically based on device status during refresh
class NotificationGenerationService {
  NotificationGenerationService();

  // Stream controllers for notification events
  final _notificationController = StreamController<AppNotification>.broadcast();
  final _notificationListController = StreamController<List<AppNotification>>.broadcast();
  
  Stream<AppNotification> get notificationStream => _notificationController.stream;
  Stream<List<AppNotification>> get notificationListStream => _notificationListController.stream;
  
  // Track previous device states to detect changes
  final Map<String, String> _previousDeviceStates = {};
  
  // Store generated notifications locally
  final List<AppNotification> _notifications = [];
  
  /// Generate notifications from device status changes
  List<AppNotification> generateFromDevices(List<Device> devices) {
    final newNotifications = <AppNotification>[];
    final now = DateTime.now();
    
    for (final device in devices) {
      final previousStatus = _previousDeviceStates[device.id];
      final currentStatus = device.status.toLowerCase();
      
      // Track status change
      _previousDeviceStates[device.id] = currentStatus;
      
      // Generate notifications based on current device status
      final deviceNotifications = _generateDeviceNotifications(device, now, previousStatus);
      newNotifications.addAll(deviceNotifications);
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
  
  /// Generate notifications for a specific device based on its status
  /// Following the rules from docs/notification-system.md exactly:
  /// - URGENT (Red): device.online == false
  /// - MEDIUM (Orange): device.note != null  
  /// - LOW (Green): device.images == null or empty
  List<AppNotification> _generateDeviceNotifications(Device device, DateTime timestamp, String? previousStatus) {
    final notifications = <AppNotification>[];
    
    // 1. URGENT priority - Device offline (red)
    // Rule: device['online'] == false
    if (!device.isOnline) {
      // Check if we already have an unread offline notification for this device
      final existingOfflineNotification = _notifications.any((n) => 
        n.type == NotificationType.deviceOffline && 
        n.deviceId == device.id &&
        !n.isRead
      );
      
      if (!existingOfflineNotification) {
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
    
    // 2. MEDIUM priority - Device has notes (orange)
    // Rule: device['note'] != null
    if (device.note != null && device.note!.isNotEmpty) {
      final existingNoteNotification = _notifications.any((n) => 
        n.type == NotificationType.deviceNote && 
        n.deviceId == device.id &&
        !n.isRead
      );
      
      // Only generate if we don't already have an unread note notification for this device
      if (!existingNoteNotification) {
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
    
    // 3. LOW priority - Missing images (green)
    // Rule: device['images'] == null or empty
    if (device.images == null || device.images!.isEmpty) {
      final existingImageNotification = _notifications.any((n) => 
        n.type == NotificationType.missingImage && 
        n.deviceId == device.id &&
        !n.isRead
      );
      
      // Only generate if we don't already have an unread image notification for this device
      if (!existingImageNotification) {
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
}