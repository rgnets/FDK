// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_notification_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationGenerationServiceHash() =>
    r'a540aad8c46aed84dcec17d0ce868f4497dbcd48';

/// Notification generation service provider (re-export from core providers)
///
/// Copied from [notificationGenerationService].
@ProviderFor(notificationGenerationService)
final notificationGenerationServiceProvider =
    AutoDisposeProvider<NotificationGenerationService>.internal(
  notificationGenerationService,
  name: r'notificationGenerationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationGenerationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NotificationGenerationServiceRef
    = AutoDisposeProviderRef<NotificationGenerationService>;
String _$domainNotificationRepositoryHash() =>
    r'63e5995a3b54660b3b82b0faad4db4bd8f2bf9b2';

/// Domain notification repository provider (re-export from core providers)
///
/// Copied from [domainNotificationRepository].
@ProviderFor(domainNotificationRepository)
final domainNotificationRepositoryProvider =
    AutoDisposeProvider<NotificationRepository>.internal(
  domainNotificationRepository,
  name: r'domainNotificationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$domainNotificationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DomainNotificationRepositoryRef
    = AutoDisposeProviderRef<NotificationRepository>;
String _$unreadDeviceNotificationsHash() =>
    r'cb86e968422ee0931ef0522399f3eefd3b13c01d';

/// Provider for unread device notifications
///
/// Copied from [unreadDeviceNotifications].
@ProviderFor(unreadDeviceNotifications)
final unreadDeviceNotificationsProvider =
    AutoDisposeProvider<List<AppNotification>>.internal(
  unreadDeviceNotifications,
  name: r'unreadDeviceNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadDeviceNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnreadDeviceNotificationsRef
    = AutoDisposeProviderRef<List<AppNotification>>;
String _$unreadDeviceNotificationCountHash() =>
    r'1a04a0553d2a74350e319a665bc07431b70a8b9b';

/// Provider for unread device notifications count
///
/// Copied from [unreadDeviceNotificationCount].
@ProviderFor(unreadDeviceNotificationCount)
final unreadDeviceNotificationCountProvider = AutoDisposeProvider<int>.internal(
  unreadDeviceNotificationCount,
  name: r'unreadDeviceNotificationCountProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$unreadDeviceNotificationCountHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UnreadDeviceNotificationCountRef = AutoDisposeProviderRef<int>;
String _$hasUnreadDeviceNotificationsHash() =>
    r'89464fb778f64577923f95b59feb54f90dfb079d';

/// Provider to check if there are unread device notifications
///
/// Copied from [hasUnreadDeviceNotifications].
@ProviderFor(hasUnreadDeviceNotifications)
final hasUnreadDeviceNotificationsProvider = AutoDisposeProvider<bool>.internal(
  hasUnreadDeviceNotifications,
  name: r'hasUnreadDeviceNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasUnreadDeviceNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HasUnreadDeviceNotificationsRef = AutoDisposeProviderRef<bool>;
String _$notificationsByPriorityHash() =>
    r'2feb7ee8caa2f98cc260323095f1f836d3d37438';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for notifications filtered by priority
///
/// Copied from [notificationsByPriority].
@ProviderFor(notificationsByPriority)
const notificationsByPriorityProvider = NotificationsByPriorityFamily();

/// Provider for notifications filtered by priority
///
/// Copied from [notificationsByPriority].
class NotificationsByPriorityFamily extends Family<List<AppNotification>> {
  /// Provider for notifications filtered by priority
  ///
  /// Copied from [notificationsByPriority].
  const NotificationsByPriorityFamily();

  /// Provider for notifications filtered by priority
  ///
  /// Copied from [notificationsByPriority].
  NotificationsByPriorityProvider call(
    NotificationPriority priority,
  ) {
    return NotificationsByPriorityProvider(
      priority,
    );
  }

  @override
  NotificationsByPriorityProvider getProviderOverride(
    covariant NotificationsByPriorityProvider provider,
  ) {
    return call(
      provider.priority,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'notificationsByPriorityProvider';
}

/// Provider for notifications filtered by priority
///
/// Copied from [notificationsByPriority].
class NotificationsByPriorityProvider
    extends AutoDisposeProvider<List<AppNotification>> {
  /// Provider for notifications filtered by priority
  ///
  /// Copied from [notificationsByPriority].
  NotificationsByPriorityProvider(
    NotificationPriority priority,
  ) : this._internal(
          (ref) => notificationsByPriority(
            ref as NotificationsByPriorityRef,
            priority,
          ),
          from: notificationsByPriorityProvider,
          name: r'notificationsByPriorityProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$notificationsByPriorityHash,
          dependencies: NotificationsByPriorityFamily._dependencies,
          allTransitiveDependencies:
              NotificationsByPriorityFamily._allTransitiveDependencies,
          priority: priority,
        );

  NotificationsByPriorityProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.priority,
  }) : super.internal();

  final NotificationPriority priority;

  @override
  Override overrideWith(
    List<AppNotification> Function(NotificationsByPriorityRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NotificationsByPriorityProvider._internal(
        (ref) => create(ref as NotificationsByPriorityRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        priority: priority,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<AppNotification>> createElement() {
    return _NotificationsByPriorityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NotificationsByPriorityProvider &&
        other.priority == priority;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, priority.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin NotificationsByPriorityRef
    on AutoDisposeProviderRef<List<AppNotification>> {
  /// The parameter `priority` of this provider.
  NotificationPriority get priority;
}

class _NotificationsByPriorityProviderElement
    extends AutoDisposeProviderElement<List<AppNotification>>
    with NotificationsByPriorityRef {
  _NotificationsByPriorityProviderElement(super.provider);

  @override
  NotificationPriority get priority =>
      (origin as NotificationsByPriorityProvider).priority;
}

String _$deviceNotificationsByTypeHash() =>
    r'5ea9b6f15f87a0673233cd0e7e7584db69015e61';

/// Provider for notifications filtered by type
///
/// Copied from [deviceNotificationsByType].
@ProviderFor(deviceNotificationsByType)
const deviceNotificationsByTypeProvider = DeviceNotificationsByTypeFamily();

/// Provider for notifications filtered by type
///
/// Copied from [deviceNotificationsByType].
class DeviceNotificationsByTypeFamily extends Family<List<AppNotification>> {
  /// Provider for notifications filtered by type
  ///
  /// Copied from [deviceNotificationsByType].
  const DeviceNotificationsByTypeFamily();

  /// Provider for notifications filtered by type
  ///
  /// Copied from [deviceNotificationsByType].
  DeviceNotificationsByTypeProvider call(
    NotificationType type,
  ) {
    return DeviceNotificationsByTypeProvider(
      type,
    );
  }

  @override
  DeviceNotificationsByTypeProvider getProviderOverride(
    covariant DeviceNotificationsByTypeProvider provider,
  ) {
    return call(
      provider.type,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deviceNotificationsByTypeProvider';
}

/// Provider for notifications filtered by type
///
/// Copied from [deviceNotificationsByType].
class DeviceNotificationsByTypeProvider
    extends AutoDisposeProvider<List<AppNotification>> {
  /// Provider for notifications filtered by type
  ///
  /// Copied from [deviceNotificationsByType].
  DeviceNotificationsByTypeProvider(
    NotificationType type,
  ) : this._internal(
          (ref) => deviceNotificationsByType(
            ref as DeviceNotificationsByTypeRef,
            type,
          ),
          from: deviceNotificationsByTypeProvider,
          name: r'deviceNotificationsByTypeProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deviceNotificationsByTypeHash,
          dependencies: DeviceNotificationsByTypeFamily._dependencies,
          allTransitiveDependencies:
              DeviceNotificationsByTypeFamily._allTransitiveDependencies,
          type: type,
        );

  DeviceNotificationsByTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
  }) : super.internal();

  final NotificationType type;

  @override
  Override overrideWith(
    List<AppNotification> Function(DeviceNotificationsByTypeRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeviceNotificationsByTypeProvider._internal(
        (ref) => create(ref as DeviceNotificationsByTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<AppNotification>> createElement() {
    return _DeviceNotificationsByTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceNotificationsByTypeProvider && other.type == type;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DeviceNotificationsByTypeRef
    on AutoDisposeProviderRef<List<AppNotification>> {
  /// The parameter `type` of this provider.
  NotificationType get type;
}

class _DeviceNotificationsByTypeProviderElement
    extends AutoDisposeProviderElement<List<AppNotification>>
    with DeviceNotificationsByTypeRef {
  _DeviceNotificationsByTypeProviderElement(super.provider);

  @override
  NotificationType get type =>
      (origin as DeviceNotificationsByTypeProvider).type;
}

String _$urgentNotificationsHash() =>
    r'b7a954179b2fd9301d43ddb206d66ca222d7a9b7';

/// Provider for URGENT priority notifications (offline devices)
///
/// Copied from [urgentNotifications].
@ProviderFor(urgentNotifications)
final urgentNotificationsProvider =
    AutoDisposeProvider<List<AppNotification>>.internal(
  urgentNotifications,
  name: r'urgentNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$urgentNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UrgentNotificationsRef = AutoDisposeProviderRef<List<AppNotification>>;
String _$mediumNotificationsHash() =>
    r'5345e569edef2bd111267acbc0c0fe39f15da6ff';

/// Provider for MEDIUM priority notifications (device notes)
///
/// Copied from [mediumNotifications].
@ProviderFor(mediumNotifications)
final mediumNotificationsProvider =
    AutoDisposeProvider<List<AppNotification>>.internal(
  mediumNotifications,
  name: r'mediumNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mediumNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef MediumNotificationsRef = AutoDisposeProviderRef<List<AppNotification>>;
String _$lowNotificationsHash() => r'9622b7de084b4a9ed47824198a8a7d481dcbd2f4';

/// Provider for LOW priority notifications (missing images)
///
/// Copied from [lowNotifications].
@ProviderFor(lowNotifications)
final lowNotificationsProvider =
    AutoDisposeProvider<List<AppNotification>>.internal(
  lowNotifications,
  name: r'lowNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lowNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LowNotificationsRef = AutoDisposeProviderRef<List<AppNotification>>;
String _$deviceNotificationsHash() =>
    r'07fbd5027a79fe7636085abedcf79b032eb6335d';

/// Provider for notifications related to a specific device
///
/// Copied from [deviceNotifications].
@ProviderFor(deviceNotifications)
const deviceNotificationsProvider = DeviceNotificationsFamily();

/// Provider for notifications related to a specific device
///
/// Copied from [deviceNotifications].
class DeviceNotificationsFamily extends Family<List<AppNotification>> {
  /// Provider for notifications related to a specific device
  ///
  /// Copied from [deviceNotifications].
  const DeviceNotificationsFamily();

  /// Provider for notifications related to a specific device
  ///
  /// Copied from [deviceNotifications].
  DeviceNotificationsProvider call(
    String deviceId,
  ) {
    return DeviceNotificationsProvider(
      deviceId,
    );
  }

  @override
  DeviceNotificationsProvider getProviderOverride(
    covariant DeviceNotificationsProvider provider,
  ) {
    return call(
      provider.deviceId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'deviceNotificationsProvider';
}

/// Provider for notifications related to a specific device
///
/// Copied from [deviceNotifications].
class DeviceNotificationsProvider
    extends AutoDisposeProvider<List<AppNotification>> {
  /// Provider for notifications related to a specific device
  ///
  /// Copied from [deviceNotifications].
  DeviceNotificationsProvider(
    String deviceId,
  ) : this._internal(
          (ref) => deviceNotifications(
            ref as DeviceNotificationsRef,
            deviceId,
          ),
          from: deviceNotificationsProvider,
          name: r'deviceNotificationsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deviceNotificationsHash,
          dependencies: DeviceNotificationsFamily._dependencies,
          allTransitiveDependencies:
              DeviceNotificationsFamily._allTransitiveDependencies,
          deviceId: deviceId,
        );

  DeviceNotificationsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.deviceId,
  }) : super.internal();

  final String deviceId;

  @override
  Override overrideWith(
    List<AppNotification> Function(DeviceNotificationsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DeviceNotificationsProvider._internal(
        (ref) => create(ref as DeviceNotificationsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        deviceId: deviceId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<AppNotification>> createElement() {
    return _DeviceNotificationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceNotificationsProvider && other.deviceId == deviceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deviceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin DeviceNotificationsRef on AutoDisposeProviderRef<List<AppNotification>> {
  /// The parameter `deviceId` of this provider.
  String get deviceId;
}

class _DeviceNotificationsProviderElement
    extends AutoDisposeProviderElement<List<AppNotification>>
    with DeviceNotificationsRef {
  _DeviceNotificationsProviderElement(super.provider);

  @override
  String get deviceId => (origin as DeviceNotificationsProvider).deviceId;
}

String _$roomNotificationsHash() => r'c29268abac088e5a50a4479545f0ebc55d1b251d';

/// Provider for notifications related to a specific room
///
/// Copied from [roomNotifications].
@ProviderFor(roomNotifications)
const roomNotificationsProvider = RoomNotificationsFamily();

/// Provider for notifications related to a specific room
///
/// Copied from [roomNotifications].
class RoomNotificationsFamily extends Family<List<AppNotification>> {
  /// Provider for notifications related to a specific room
  ///
  /// Copied from [roomNotifications].
  const RoomNotificationsFamily();

  /// Provider for notifications related to a specific room
  ///
  /// Copied from [roomNotifications].
  RoomNotificationsProvider call(
    String location,
  ) {
    return RoomNotificationsProvider(
      location,
    );
  }

  @override
  RoomNotificationsProvider getProviderOverride(
    covariant RoomNotificationsProvider provider,
  ) {
    return call(
      provider.location,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'roomNotificationsProvider';
}

/// Provider for notifications related to a specific room
///
/// Copied from [roomNotifications].
class RoomNotificationsProvider
    extends AutoDisposeProvider<List<AppNotification>> {
  /// Provider for notifications related to a specific room
  ///
  /// Copied from [roomNotifications].
  RoomNotificationsProvider(
    String location,
  ) : this._internal(
          (ref) => roomNotifications(
            ref as RoomNotificationsRef,
            location,
          ),
          from: roomNotificationsProvider,
          name: r'roomNotificationsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$roomNotificationsHash,
          dependencies: RoomNotificationsFamily._dependencies,
          allTransitiveDependencies:
              RoomNotificationsFamily._allTransitiveDependencies,
          location: location,
        );

  RoomNotificationsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.location,
  }) : super.internal();

  final String location;

  @override
  Override overrideWith(
    List<AppNotification> Function(RoomNotificationsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoomNotificationsProvider._internal(
        (ref) => create(ref as RoomNotificationsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        location: location,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<AppNotification>> createElement() {
    return _RoomNotificationsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomNotificationsProvider && other.location == location;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, location.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RoomNotificationsRef on AutoDisposeProviderRef<List<AppNotification>> {
  /// The parameter `location` of this provider.
  String get location;
}

class _RoomNotificationsProviderElement
    extends AutoDisposeProviderElement<List<AppNotification>>
    with RoomNotificationsRef {
  _RoomNotificationsProviderElement(super.provider);

  @override
  String get location => (origin as RoomNotificationsProvider).location;
}

String _$deviceNotificationsNotifierHash() =>
    r'10cb334e24db3f59151e1147dd5a580bfc0665b2';

/// Main device-based notifications provider
///
/// Copied from [DeviceNotificationsNotifier].
@ProviderFor(DeviceNotificationsNotifier)
final deviceNotificationsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    DeviceNotificationsNotifier, List<AppNotification>>.internal(
  DeviceNotificationsNotifier.new,
  name: r'deviceNotificationsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceNotificationsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DeviceNotificationsNotifier
    = AutoDisposeAsyncNotifier<List<AppNotification>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
