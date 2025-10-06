// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_domain_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$unreadNotificationCountHash() =>
    r'34beb5f833a909fd49be3735ade74ef56d14c55d';

/// Provider for unread notification count
///
/// Copied from [unreadNotificationCount].
@ProviderFor(unreadNotificationCount)
final unreadNotificationCountProvider = AutoDisposeFutureProvider<int>.internal(
  unreadNotificationCount,
  name: r'unreadNotificationCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadNotificationCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnreadNotificationCountRef = AutoDisposeFutureProviderRef<int>;
String _$notificationsDomainNotifierHash() =>
    r'742f2908128beb5ba48c6e0d4d99a71c65bf36a3';

/// Main notifications provider using domain layer
///
/// Copied from [NotificationsDomainNotifier].
@ProviderFor(NotificationsDomainNotifier)
final notificationsDomainNotifierProvider = AsyncNotifierProvider<
    NotificationsDomainNotifier, List<AppNotification>>.internal(
  NotificationsDomainNotifier.new,
  name: r'notificationsDomainNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationsDomainNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationsDomainNotifier = AsyncNotifier<List<AppNotification>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
