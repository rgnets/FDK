// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_device_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$roomDeviceNotifierHash() =>
    r'798eaa562d8d8dac1f9b0cb0fb3d4ca705640ae0';

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

abstract class _$RoomDeviceNotifier extends BuildlessNotifier<RoomDeviceState> {
  late final String roomId;

  RoomDeviceState build(
    String roomId,
  );
}

/// Room device view model provider
///
/// Provides device filtering and statistics for a specific room.
/// Follows Clean Architecture and MVVM patterns.
///
/// Copied from [RoomDeviceNotifier].
@ProviderFor(RoomDeviceNotifier)
const roomDeviceNotifierProvider = RoomDeviceNotifierFamily();

/// Room device view model provider
///
/// Provides device filtering and statistics for a specific room.
/// Follows Clean Architecture and MVVM patterns.
///
/// Copied from [RoomDeviceNotifier].
class RoomDeviceNotifierFamily extends Family<RoomDeviceState> {
  /// Room device view model provider
  ///
  /// Provides device filtering and statistics for a specific room.
  /// Follows Clean Architecture and MVVM patterns.
  ///
  /// Copied from [RoomDeviceNotifier].
  const RoomDeviceNotifierFamily();

  /// Room device view model provider
  ///
  /// Provides device filtering and statistics for a specific room.
  /// Follows Clean Architecture and MVVM patterns.
  ///
  /// Copied from [RoomDeviceNotifier].
  RoomDeviceNotifierProvider call(
    String roomId,
  ) {
    return RoomDeviceNotifierProvider(
      roomId,
    );
  }

  @override
  RoomDeviceNotifierProvider getProviderOverride(
    covariant RoomDeviceNotifierProvider provider,
  ) {
    return call(
      provider.roomId,
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
  String? get name => r'roomDeviceNotifierProvider';
}

/// Room device view model provider
///
/// Provides device filtering and statistics for a specific room.
/// Follows Clean Architecture and MVVM patterns.
///
/// Copied from [RoomDeviceNotifier].
class RoomDeviceNotifierProvider
    extends NotifierProviderImpl<RoomDeviceNotifier, RoomDeviceState> {
  /// Room device view model provider
  ///
  /// Provides device filtering and statistics for a specific room.
  /// Follows Clean Architecture and MVVM patterns.
  ///
  /// Copied from [RoomDeviceNotifier].
  RoomDeviceNotifierProvider(
    String roomId,
  ) : this._internal(
          () => RoomDeviceNotifier()..roomId = roomId,
          from: roomDeviceNotifierProvider,
          name: r'roomDeviceNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$roomDeviceNotifierHash,
          dependencies: RoomDeviceNotifierFamily._dependencies,
          allTransitiveDependencies:
              RoomDeviceNotifierFamily._allTransitiveDependencies,
          roomId: roomId,
        );

  RoomDeviceNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomId,
  }) : super.internal();

  final String roomId;

  @override
  RoomDeviceState runNotifierBuild(
    covariant RoomDeviceNotifier notifier,
  ) {
    return notifier.build(
      roomId,
    );
  }

  @override
  Override overrideWith(RoomDeviceNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: RoomDeviceNotifierProvider._internal(
        () => create()..roomId = roomId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roomId: roomId,
      ),
    );
  }

  @override
  NotifierProviderElement<RoomDeviceNotifier, RoomDeviceState> createElement() {
    return _RoomDeviceNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomDeviceNotifierProvider && other.roomId == roomId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RoomDeviceNotifierRef on NotifierProviderRef<RoomDeviceState> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _RoomDeviceNotifierProviderElement
    extends NotifierProviderElement<RoomDeviceNotifier, RoomDeviceState>
    with RoomDeviceNotifierRef {
  _RoomDeviceNotifierProviderElement(super.provider);

  @override
  String get roomId => (origin as RoomDeviceNotifierProvider).roomId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
