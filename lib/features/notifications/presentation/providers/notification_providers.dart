import 'package:rgnets_fdk/features/notifications/domain/usecases/get_unread_count.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_providers.g.dart';

// Note: These providers are already defined in core/providers/use_case_providers.dart
// and core/providers/repository_providers.dart
// No need to re-export them here as they can be imported directly

@riverpod
GetUnreadCount getUnreadCount(GetUnreadCountRef ref) {
  return ref.watch(getUnreadCountProvider);
}