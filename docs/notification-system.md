# Notification System - RG Nets FDK

**Created**: 2025-08-18
**Status**: CLIENT-SIDE ONLY (No API Endpoint)
**Purpose**: Documentation of actual notification implementation

## Overview

**IMPORTANT**: The notification system is **100% client-side**. There is no `/api/notifications.json` endpoint (returns 404). Notifications are generated locally from device data during refresh cycles.

## Notification Types

### Three Priority Levels

1. **Urgent (Red)** 🔴
   - Device is offline
   - Critical issues requiring immediate attention
   - Example: "Switch SW-101 is offline"

2. **Medium (Orange)** 🟠
   - Device has notes/warnings
   - Non-critical issues
   - Example: "AP AP-203: Needs firmware update"
   - Can be cleared by removing the note

3. **Low (Green)** 🟢
   - Missing data/images
   - Documentation issues
   - Example: "ONT ONT-405 is missing images"

## Notification Generation Logic (CLIENT-SIDE ONLY)

**No API Endpoint**: `/api/notifications.json` returns 404

Notifications are generated locally from device data fetched from working endpoints:

```dart
class NotificationGenerationService {
  // Generated from these API endpoints:
  // - /api/access_points.json (✅ Working)
  // - /api/media_converters.json (✅ Working)
  // - /api/switch_devices.json (✅ Working)
  
  List<Notification> generateFromDeviceData() {
    List<Notification> notifications = [];
    
    // Fetch data from WORKING endpoints
    final accessPoints = await api.get('/api/access_points.json');
    final mediaConverters = await api.get('/api/media_converters.json');
    final switches = await api.get('/api/switch_devices.json');
    
    // Process paginated results
    _processDevices(accessPoints['results'], notifications);
    _processDevices(mediaConverters['results'], notifications);
    _processDevices(switches['results'], notifications);
    
    return notifications;
  }
  
  void _processDevices(List devices, List notifications) {
    for (device in devices) {
      // URGENT: Device offline (red)
      if (device['online'] == false) {
        notifications.add(urgent);
      }
      
      // MEDIUM: Has note (orange)
      if (device['note'] != null) {
        notifications.add(medium);
      }
      
      // LOW: Missing images (green)
      if (device['images'] == null) {
        notifications.add(low);
      }
    }
  }
}
```

## Data Model

### Notification Class
```dart
@freezed
class DeviceNotification with _$DeviceNotification {
  const factory DeviceNotification({
    required int deviceId,
    required DeviceType deviceType,
    required String message,
    required NotificationPriority priority,
    required DateTime timestamp,
    @Default(false) bool isRead,
    String? actionUrl,
  }) = _DeviceNotification;
  
  factory DeviceNotification.fromJson(Map<String, dynamic> json) =>
      _$DeviceNotificationFromJson(json);
}

enum NotificationPriority {
  urgent,  // Red - Offline devices
  medium,  // Orange - Notes/warnings
  low,     // Green - Missing data
}

enum DeviceType {
  switchType,  // Network switches
  ap,          // Access points
  ont,         // Optical network terminals
}
```

## Notification Management

### State Management (CLIENT-SIDE GENERATION)
```dart
@riverpod
class NotificationController extends _$NotificationController {
  // NO SERVER ENDPOINT - Generated locally
  
  Future<void> refreshNotifications() async {
    // Fetch from WORKING endpoints only
    try {
      // These endpoints exist and return paginated data
      final apResponse = await api.get('/api/access_points.json');
      final ontResponse = await api.get('/api/media_converters.json');
      final switchResponse = await api.get('/api/switch_devices.json');
      
      // Extract results from pagination wrapper
      final aps = apResponse['results'] as List;
      final onts = ontResponse['results'] as List;
      final switches = switchResponse['results'] as List;
      
      // Generate notifications client-side
      final notifications = NotificationGenerationService()
        .generateFromDevices([
          ...aps,
          ...onts,
          ...switches,
        ]);
      
      // Group by priority
      state = NotificationState(
        urgent: notifications.where((n) => n.priority == 'urgent'),
        medium: notifications.where((n) => n.priority == 'medium'),
        low: notifications.where((n) => n.priority == 'low'),
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      // Handle 404 for non-existent notification endpoint
      print('Generating notifications client-side');
    }
  }
  
  void clearNote(int deviceId, DeviceType type) {
    // Remove medium priority notifications for this device
    state = state.copyWith(
      medium: state.medium.where((n) => 
        n.deviceId != deviceId || n.deviceType != type
      ).toList(),
    );
  }
  
  int get totalCount => 
    state.urgent.length + state.medium.length + state.low.length;
  
  int get urgentCount => state.urgent.length;
}
```

## UI Implementation

### Notification Badge
```dart
class NotificationBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(
      notificationControllerProvider.select((state) => 
        state.urgent.length + state.medium.length + state.low.length
      )
    );
    
    if (count == 0) return Icon(Icons.notifications_outlined);
    
    return Badge(
      label: Text('$count'),
      backgroundColor: count > 0 ? Colors.red : null,
      child: Icon(Icons.notifications),
    );
  }
}
```

### Notification List View
```dart
class NotificationListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationControllerProvider);
    
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(notificationControllerProvider.notifier)
          .refreshNotifications();
      },
      child: ListView(
        children: [
          // Filter buttons
          NotificationFilters(),
          
          // Notification sections
          if (notifications.urgent.isNotEmpty) ...[
            SectionHeader('Urgent', Colors.red),
            ...notifications.urgent.map((n) => 
              NotificationTile(notification: n)
            ),
          ],
          
          if (notifications.medium.isNotEmpty) ...[
            SectionHeader('Medium', Colors.orange),
            ...notifications.medium.map((n) => 
              NotificationTile(notification: n)
            ),
          ],
          
          if (notifications.low.isNotEmpty) ...[
            SectionHeader('Low', Colors.green),
            ...notifications.low.map((n) => 
              NotificationTile(notification: n)
            ),
          ],
          
          if (notifications.isEmpty)
            EmptyState('No notifications'),
        ],
      ),
    );
  }
}
```

### Notification Tile
```dart
class NotificationTile extends ConsumerWidget {
  final DeviceNotification notification;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: _buildIcon(notification.priority),
      title: Text(notification.message),
      subtitle: Text(
        timeago.format(notification.timestamp),
      ),
      trailing: notification.priority == NotificationPriority.medium
        ? IconButton(
            icon: Icon(Icons.clear),
            onPressed: () => _clearNote(ref),
          )
        : null,
      onTap: () => _navigateToDevice(context),
    );
  }
  
  Widget _buildIcon(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.urgent:
        return Icon(Icons.error, color: Colors.red);
      case NotificationPriority.medium:
        return Icon(Icons.warning, color: Colors.orange);
      case NotificationPriority.low:
        return Icon(Icons.info, color: Colors.green);
    }
  }
  
  void _navigateToDevice(BuildContext context) {
    context.push('/device/${notification.deviceType}/${notification.deviceId}');
  }
  
  void _clearNote(WidgetRef ref) async {
    await ref.read(deviceServiceProvider)
      .clearNote(notification.deviceId, notification.deviceType);
    
    ref.read(notificationControllerProvider.notifier)
      .clearNote(notification.deviceId, notification.deviceType);
  }
}
```

## Filtering System

### Filter Options
```dart
class NotificationFilters extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceFilter = ref.watch(deviceFilterProvider);
    final priorityFilter = ref.watch(priorityFilterProvider);
    
    return Column(
      children: [
        // Device type filter
        SegmentedButton<DeviceType?>(
          segments: [
            ButtonSegment(value: null, label: Text('All')),
            ButtonSegment(value: DeviceType.switchType, label: Text('Switch')),
            ButtonSegment(value: DeviceType.ap, label: Text('AP')),
            ButtonSegment(value: DeviceType.ont, label: Text('ONT')),
          ],
          selected: {deviceFilter},
          onSelectionChanged: (value) {
            ref.read(deviceFilterProvider.notifier).state = value.first;
          },
        ),
        
        // Priority filter
        SegmentedButton<NotificationPriority?>(
          segments: [
            ButtonSegment(value: null, label: Text('All')),
            ButtonSegment(
              value: NotificationPriority.urgent,
              label: Text('Urgent'),
              icon: Icon(Icons.error, color: Colors.red),
            ),
            ButtonSegment(
              value: NotificationPriority.medium,
              label: Text('Medium'),
              icon: Icon(Icons.warning, color: Colors.orange),
            ),
            ButtonSegment(
              value: NotificationPriority.low,
              label: Text('Low'),
              icon: Icon(Icons.info, color: Colors.green),
            ),
          ],
          selected: {priorityFilter},
          onSelectionChanged: (value) {
            ref.read(priorityFilterProvider.notifier).state = value.first;
          },
        ),
      ],
    );
  }
}
```

## Actions and Navigation

### Notification Actions

1. **Tap Notification** → Navigate to device detail page
2. **Clear Note** (Medium only) → Remove note from device via API
3. **Pull to Refresh** → Refresh all device data and regenerate notifications

### Deep Linking
```dart
// Route configuration
GoRoute(
  path: '/notifications',
  builder: (context, state) => NotificationScreen(),
),
GoRoute(
  path: '/device/:type/:id',
  builder: (context, state) => DeviceDetailScreen(
    deviceType: DeviceType.values.byName(state.pathParameters['type']!),
    deviceId: int.parse(state.pathParameters['id']!),
  ),
),
```

## Refresh Strategy

### Refresh Strategy (Background Processing)
- **On app launch**: Generate from initial device fetch
- **Background refresh**: Re-generate during device polling
- **After device updates**: Regenerate notifications
- **Pull-to-refresh**: Fetch devices, then generate
- **No server polling**: Notifications not fetched from API

### Manual Refresh
```dart
Future<void> refreshNotifications() async {
  // Fetch fresh data from API
  await Future.wait([
    ref.refresh(switchesProvider.future),
    ref.refresh(accessPointsProvider.future),
    ref.refresh(ontsProvider.future),
  ]);
  
  // Regenerate notifications
  await ref.read(notificationControllerProvider.notifier)
    .refreshNotifications();
}
```

## Performance Considerations

### Caching
- Cache notifications in memory
- Only regenerate when device data changes
- Use computed properties for counts

### Optimization
```dart
// Use select to avoid unnecessary rebuilds
final urgentCount = ref.watch(
  notificationControllerProvider.select((state) => state.urgent.length)
);

// Batch API calls
final results = await Future.wait([
  api.getSwitches(),
  api.getAccessPoints(),
  api.getONTs(),
]);
```

## Testing Strategy

### Unit Tests
```dart
test('generates urgent notification for offline device', () {
  final device = Device(
    id: 1,
    name: 'SW-101',
    online: false,
  );
  
  final notifications = NotificationGenerator.generate([device]);
  
  expect(notifications.urgent.length, 1);
  expect(notifications.urgent.first.message, contains('offline'));
});
```

### Widget Tests
```dart
testWidgets('displays notification count badge', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        notificationControllerProvider.overrideWith(() =>
          MockNotificationController(urgentCount: 5)
        ),
      ],
      child: MaterialApp(home: NotificationBadge()),
    ),
  );
  
  expect(find.text('5'), findsOneWidget);
  expect(find.byIcon(Icons.notifications), findsOneWidget);
});
```

## Current Implementation Status

### What's Working ✅
1. **Client-side generation**: From device online/note/image status
2. **Three priority levels**: Urgent/Medium/Low
3. **Device data sources**: access_points, media_converters, switch_devices
4. **State management**: Riverpod AsyncNotifier

### What's NOT Working ❌
1. **Server notifications**: `/api/notifications.json` doesn't exist (404)
2. **Push notifications**: Not implemented
3. **Persistence**: Notifications lost on app restart
4. **History**: No notification history tracking

### Feature Parity
- ✅ Three priority levels
- ✅ Device type filtering  
- ✅ Priority filtering
- ✅ Navigate to device details
- ✅ Clear notes action
- ✅ Pull to refresh
- ✅ Notification count badge

## Implementation Reality Check

### Actual Implementation
- **Data Source**: Device status from 3 working API endpoints
- **Generation**: 100% client-side during refresh cycles
- **Storage**: In-memory only (not persisted)
- **API Endpoint**: DOES NOT EXIST (`/api/notifications.json` returns 404)

### Priority Logic (Confirmed)
1. **Urgent (Red)**: `device.online === false`
2. **Medium (Orange)**: `device.note !== null`
3. **Low (Green)**: `device.images === null || empty`

### Critical Notes
- No server-side notification system exists
- All notifications generated locally from device data
- Must handle paginated responses from device endpoints
- Notifications regenerated on each device data refresh