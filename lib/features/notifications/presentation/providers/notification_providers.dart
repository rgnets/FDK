import 'package:rgnets_fdk/features/notifications/domain/usecases/get_unread_count.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_providers.g.dart';

@riverpod
GetUnreadCount getUnreadCount(GetUnreadCountRef ref) {
  return ref.watch(getUnreadCountProvider);
}
