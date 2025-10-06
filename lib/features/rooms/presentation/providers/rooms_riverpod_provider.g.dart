// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rooms_riverpod_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$roomStatisticsHash() => r'16009c7965b05d31a8c231f853860c87823e85b3';

/// Provider for room statistics
///
/// Copied from [roomStatistics].
@ProviderFor(roomStatistics)
final roomStatisticsProvider = AutoDisposeProvider<RoomStatistics>.internal(
  roomStatistics,
  name: r'roomStatisticsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$roomStatisticsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RoomStatisticsRef = AutoDisposeProviderRef<RoomStatistics>;
String _$roomByIdHash() => r'abe9b0715dfdb52a01a783a95c8a75f2a90a5193';

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

/// Provider for getting a specific room by ID
///
/// Copied from [roomById].
@ProviderFor(roomById)
const roomByIdProvider = RoomByIdFamily();

/// Provider for getting a specific room by ID
///
/// Copied from [roomById].
class RoomByIdFamily extends Family<Room?> {
  /// Provider for getting a specific room by ID
  ///
  /// Copied from [roomById].
  const RoomByIdFamily();

  /// Provider for getting a specific room by ID
  ///
  /// Copied from [roomById].
  RoomByIdProvider call(
    String roomId,
  ) {
    return RoomByIdProvider(
      roomId,
    );
  }

  @override
  RoomByIdProvider getProviderOverride(
    covariant RoomByIdProvider provider,
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
  String? get name => r'roomByIdProvider';
}

/// Provider for getting a specific room by ID
///
/// Copied from [roomById].
class RoomByIdProvider extends AutoDisposeProvider<Room?> {
  /// Provider for getting a specific room by ID
  ///
  /// Copied from [roomById].
  RoomByIdProvider(
    String roomId,
  ) : this._internal(
          (ref) => roomById(
            ref as RoomByIdRef,
            roomId,
          ),
          from: roomByIdProvider,
          name: r'roomByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$roomByIdHash,
          dependencies: RoomByIdFamily._dependencies,
          allTransitiveDependencies: RoomByIdFamily._allTransitiveDependencies,
          roomId: roomId,
        );

  RoomByIdProvider._internal(
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
  Override overrideWith(
    Room? Function(RoomByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoomByIdProvider._internal(
        (ref) => create(ref as RoomByIdRef),
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
  AutoDisposeProviderElement<Room?> createElement() {
    return _RoomByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomByIdProvider && other.roomId == roomId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RoomByIdRef on AutoDisposeProviderRef<Room?> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _RoomByIdProviderElement extends AutoDisposeProviderElement<Room?>
    with RoomByIdRef {
  _RoomByIdProviderElement(super.provider);

  @override
  String get roomId => (origin as RoomByIdProvider).roomId;
}

String _$roomsNotifierHash() => r'd6dcc5d129c6b10dccd5388c4fc203b0a906370b';

/// See also [RoomsNotifier].
@ProviderFor(RoomsNotifier)
final roomsNotifierProvider =
    AsyncNotifierProvider<RoomsNotifier, List<Room>>.internal(
  RoomsNotifier.new,
  name: r'roomsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$roomsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RoomsNotifier = AsyncNotifier<List<Room>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
