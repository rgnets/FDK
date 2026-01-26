// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_center_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageCenterServiceHash() =>
    r'4c9f0a3e76ef767cf8c1497ba88b345783a2df46';

/// Provider for the MessageCenterService singleton
///
/// Copied from [messageCenterService].
@ProviderFor(messageCenterService)
final messageCenterServiceProvider = Provider<MessageCenterService>.internal(
  messageCenterService,
  name: r'messageCenterServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$messageCenterServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MessageCenterServiceRef = ProviderRef<MessageCenterService>;
String _$unreadMessageCountHash() =>
    r'f40a749a4b17b913c009ea834f73aef03a73ac5e';

/// Provider for unread message count
///
/// Copied from [unreadMessageCount].
@ProviderFor(unreadMessageCount)
final unreadMessageCountProvider = AutoDisposeProvider<int>.internal(
  unreadMessageCount,
  name: r'unreadMessageCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadMessageCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnreadMessageCountRef = AutoDisposeProviderRef<int>;
String _$recentMessagesHash() => r'50c8f8bfc32ddd2b7a36006271b2573cf803292a';

/// Provider for recent messages (last 10)
///
/// Copied from [recentMessages].
@ProviderFor(recentMessages)
final recentMessagesProvider = AutoDisposeProvider<List<AppMessage>>.internal(
  recentMessages,
  name: r'recentMessagesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$recentMessagesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RecentMessagesRef = AutoDisposeProviderRef<List<AppMessage>>;
String _$messageMetricsHash() => r'7a7ad5342903d403961b2bb826053b8a615bee6d';

/// Provider for message metrics
///
/// Copied from [messageMetrics].
@ProviderFor(messageMetrics)
final messageMetricsProvider = AutoDisposeProvider<MessageMetrics>.internal(
  messageMetrics,
  name: r'messageMetricsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$messageMetricsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MessageMetricsRef = AutoDisposeProviderRef<MessageMetrics>;
String _$messageCenterNotifierHash() =>
    r'd53646e3c3dd6f675f59ed3befc6dbf8f59f9529';

/// Main provider for the message center UI
///
/// Copied from [MessageCenterNotifier].
@ProviderFor(MessageCenterNotifier)
final messageCenterNotifierProvider =
    NotifierProvider<MessageCenterNotifier, MessageCenterState>.internal(
  MessageCenterNotifier.new,
  name: r'messageCenterNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$messageCenterNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$MessageCenterNotifier = Notifier<MessageCenterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
