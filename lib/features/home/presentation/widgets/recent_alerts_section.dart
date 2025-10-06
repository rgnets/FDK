import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:rgnets_fdk/core/utils/date_time_formatter.dart';
import 'package:rgnets_fdk/features/notifications/presentation/mappers/notification_ui_mapper.dart';
import 'package:rgnets_fdk/features/notifications/presentation/providers/notifications_domain_provider.dart';

/// Recent alerts section showing latest notifications
class RecentAlertsSection extends ConsumerWidget {
  const RecentAlertsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsDomainNotifierProvider);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Alerts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () => context.go('/notifications'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text('No recent notifications'),
                  ),
                ),
              );
            }
            return Column(
              children: notifications.take(3).map((notification) =>
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/ui_elements/hud_box.png'),
                      fit: BoxFit.fill,
                      opacity: 0.1,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      NotificationUIMapper.getIcon(notification.type),
                      color: NotificationUIMapper.getColor(notification.priority),
                    ),
                    title: Text(
                      notification.title,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      notification.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    trailing: Text(
                      DateTimeFormatter.formatTime(notification.timestamp),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                    onTap: () => context.go('/notifications'),
                  ),
                ),
              ).toList(),
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (_, __) => const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text('Error loading notifications'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}