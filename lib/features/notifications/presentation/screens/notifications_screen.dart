import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/utils/list_item_helpers.dart';
import 'package:rgnets_fdk/core/widgets/hud_tab_bar.dart';
import 'package:rgnets_fdk/core/widgets/unified_list/unified_list_item.dart';
import 'package:rgnets_fdk/core/widgets/widgets.dart';
import 'package:rgnets_fdk/features/notifications/domain/entities/notification.dart';
import 'package:rgnets_fdk/features/notifications/presentation/providers/device_notification_provider.dart';

/// Notifications/Alerts screen
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key, this.initialTab});
  
  final String? initialTab;

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  
  String _formatNotificationTitle(AppNotification notification) {
    final baseTitle = notification.title;
    final location = notification.location;
    
    // Location-first format: "location notificationType"
    if (location != null && location.isNotEmpty && location.trim().isNotEmpty) {
      var displayLocation = location.trim();
      
      // Use 25 character limit for balanced approach (preserves readability)
      const maxLocationLength = 25;
      if (displayLocation.length > maxLocationLength) {
        displayLocation = '${displayLocation.substring(0, maxLocationLength)}...';
      }
      
      return '$displayLocation $baseTitle';
    }
    
    return baseTitle;
  }
  
  @override
  void initState() {
    super.initState();
    // Initialize tab controller with initial tab if provided
    final initialIndex = int.tryParse(widget.initialTab ?? '0') ?? 0;
    _tabController = TabController(
      length: 3, 
      vsync: this,
      initialIndex: initialIndex.clamp(0, 2),
    );
    
    // Add listener to sync TabController with state
    _tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    
    // Load notifications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deviceNotificationsNotifierProvider.notifier).refresh();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // AppBar removed from NotificationsScreen - badge and menu functionality preserved in state
    return Scaffold(
      body: Consumer(
        builder: (context, ref, child) {
          final notificationsAsync = ref.watch(deviceNotificationsNotifierProvider);
          
          return notificationsAsync.when(
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, stackTrace) => Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: 'Error loading notifications',
                subtitle: error.toString(),
                actionLabel: 'Retry',
                onAction: () => ref.read(deviceNotificationsNotifierProvider.notifier).refresh(),
              ),
            ),
            data: (notifications) {
          
          return Column(
            children: [
              // HUD Tab Bar - taller with full data
              HUDTabBar(
                height: 80,
                showFullCount: true,
                tabs: [
                  HUDTab(
                    label: 'All Alerts',
                    icon: Icons.notifications,
                    count: notifications.length,
                    filterValue: 'all',
                  ),
                  HUDTab(
                    label: 'Offline',
                    icon: Icons.wifi_off,
                    iconColor: Colors.red,
                    count: notifications.where((n) => n.priority == NotificationPriority.urgent).length,
                    filterValue: 'urgent',
                  ),
                  HUDTab(
                    label: 'Docs Missing',
                    icon: Icons.image_not_supported,
                    iconColor: Colors.blue,
                    count: notifications.where((n) => n.priority == NotificationPriority.low).length,
                    filterValue: 'low',
                  ),
                ],
                selectedIndex: _tabController.index,
                onTabSelected: (index) {
                  _tabController.animateTo(index);
                },
                onActiveTabTapped: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
              ),
              
              // Notification list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.read(deviceNotificationsNotifierProvider.notifier).refresh(),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // All notifications
                      _buildNotificationList(notifications, ref),
                      // Offline (Urgent) notifications only
                      _buildNotificationList(
                        notifications.where((n) => 
                          n.priority == NotificationPriority.urgent
                        ).toList(),
                        ref,
                      ),
                      // Documentation (Low priority) notifications only
                      _buildNotificationList(
                        notifications.where((n) => 
                          n.priority == NotificationPriority.low
                        ).toList(),
                        ref,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
            },
          );
        },
      ),
    );
  }
  
  Widget _buildNotificationList(
    List<AppNotification> notifications,
    WidgetRef ref,
  ) {
    if (notifications.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_none,
        title: 'No notifications',
        subtitle: 'You\'re all caught up!',
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        
        // Build subtitle lines - only message, no timestamp
        final subtitleLines = <UnifiedInfoLine>[
          UnifiedInfoLine(
            text: notification.message,
            maxLines: 2,  // Allow more room since no timestamp
          ),
        ];
        
        return UnifiedListItem(
          title: _formatNotificationTitle(notification),
          icon: ListItemHelpers.getNotificationIcon(notification.type.name),
          iconColorOverride: ListItemHelpers.getNotificationColor(notification.type.name),
          status: ListItemHelpers.mapNotificationStatus(notification.priority),
          subtitleLines: subtitleLines,
          isUnread: !notification.isRead,
          showChevron: notification.deviceId != null || notification.metadata != null,
          onTap: () async {
            if (!notification.isRead) {
              await ref.read(deviceNotificationsNotifierProvider.notifier).markAsRead(notification.id);
            }
            if (context.mounted) {
              _showNotificationDetails(context, notification);
            }
          },
        );
      },
    );
  }
  
  void _showNotificationDetails(
    BuildContext context,
    AppNotification notification,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            _getNotificationIcon(notification.type.name),
            const SizedBox(width: 8),
            Expanded(child: Text(notification.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 16),
            Text(
              ListItemHelpers.formatTimestamp(notification.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              final deviceId = notification.deviceId;
              if (deviceId == null || deviceId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No device linked to this alert')),
                );
                return;
              }
              context.go('/devices/$deviceId');
            },
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }
  
  Widget _getNotificationIcon(String type) {
    // Map notification types to appropriate icons based on their nature
    final iconData = ListItemHelpers.getNotificationIcon(type);
    final color = ListItemHelpers.getNotificationColor(type);
    return Icon(iconData, color: color, size: 20);
  }
}
