// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_view_models.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$roomViewModelsHash() => r'b7e0a03c80849034d8fe3ca9765b2277d6aea340';

/// Provider for room view models with display information
///
/// Copied from [roomViewModels].
@ProviderFor(roomViewModels)
final roomViewModelsProvider =
    AutoDisposeProvider<List<RoomViewModel>>.internal(
  roomViewModels,
  name: r'roomViewModelsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$roomViewModelsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RoomViewModelsRef = AutoDisposeProviderRef<List<RoomViewModel>>;
String _$roomViewModelByIdHash() => r'8012fe7e22eda49f45c9998b6ac93e6e857ac339';

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

/// Provider for a single room view model by ID
///
/// Copied from [roomViewModelById].
@ProviderFor(roomViewModelById)
const roomViewModelByIdProvider = RoomViewModelByIdFamily();

/// Provider for a single room view model by ID
///
/// Copied from [roomViewModelById].
class RoomViewModelByIdFamily extends Family<RoomViewModel?> {
  /// Provider for a single room view model by ID
  ///
  /// Copied from [roomViewModelById].
  const RoomViewModelByIdFamily();

  /// Provider for a single room view model by ID
  ///
  /// Copied from [roomViewModelById].
  RoomViewModelByIdProvider call(
    String roomId,
  ) {
    return RoomViewModelByIdProvider(
      roomId,
    );
  }

  @override
  RoomViewModelByIdProvider getProviderOverride(
    covariant RoomViewModelByIdProvider provider,
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
  String? get name => r'roomViewModelByIdProvider';
}

/// Provider for a single room view model by ID
///
/// Copied from [roomViewModelById].
class RoomViewModelByIdProvider extends AutoDisposeProvider<RoomViewModel?> {
  /// Provider for a single room view model by ID
  ///
  /// Copied from [roomViewModelById].
  RoomViewModelByIdProvider(
    String roomId,
  ) : this._internal(
          (ref) => roomViewModelById(
            ref as RoomViewModelByIdRef,
            roomId,
          ),
          from: roomViewModelByIdProvider,
          name: r'roomViewModelByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$roomViewModelByIdHash,
          dependencies: RoomViewModelByIdFamily._dependencies,
          allTransitiveDependencies:
              RoomViewModelByIdFamily._allTransitiveDependencies,
          roomId: roomId,
        );

  RoomViewModelByIdProvider._internal(
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
    RoomViewModel? Function(RoomViewModelByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoomViewModelByIdProvider._internal(
        (ref) => create(ref as RoomViewModelByIdRef),
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
  AutoDisposeProviderElement<RoomViewModel?> createElement() {
    return _RoomViewModelByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomViewModelByIdProvider && other.roomId == roomId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RoomViewModelByIdRef on AutoDisposeProviderRef<RoomViewModel?> {
  /// The parameter `roomId` of this provider.
  String get roomId;
}

class _RoomViewModelByIdProviderElement
    extends AutoDisposeProviderElement<RoomViewModel?>
    with RoomViewModelByIdRef {
  _RoomViewModelByIdProviderElement(super.provider);

  @override
  String get roomId => (origin as RoomViewModelByIdProvider).roomId;
}

String _$filteredRoomViewModelsHash() =>
    r'c9bd9f594a3f2a9b8ce2e68441bea1d8a3dba712';

/// Provider for filtered room view models
///
/// Copied from [filteredRoomViewModels].
@ProviderFor(filteredRoomViewModels)
const filteredRoomViewModelsProvider = FilteredRoomViewModelsFamily();

/// Provider for filtered room view models
///
/// Copied from [filteredRoomViewModels].
class FilteredRoomViewModelsFamily extends Family<List<RoomViewModel>> {
  /// Provider for filtered room view models
  ///
  /// Copied from [filteredRoomViewModels].
  const FilteredRoomViewModelsFamily();

  /// Provider for filtered room view models
  ///
  /// Copied from [filteredRoomViewModels].
  FilteredRoomViewModelsProvider call(
    String filter,
  ) {
    return FilteredRoomViewModelsProvider(
      filter,
    );
  }

  @override
  FilteredRoomViewModelsProvider getProviderOverride(
    covariant FilteredRoomViewModelsProvider provider,
  ) {
    return call(
      provider.filter,
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
  String? get name => r'filteredRoomViewModelsProvider';
}

/// Provider for filtered room view models
///
/// Copied from [filteredRoomViewModels].
class FilteredRoomViewModelsProvider
    extends AutoDisposeProvider<List<RoomViewModel>> {
  /// Provider for filtered room view models
  ///
  /// Copied from [filteredRoomViewModels].
  FilteredRoomViewModelsProvider(
    String filter,
  ) : this._internal(
          (ref) => filteredRoomViewModels(
            ref as FilteredRoomViewModelsRef,
            filter,
          ),
          from: filteredRoomViewModelsProvider,
          name: r'filteredRoomViewModelsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredRoomViewModelsHash,
          dependencies: FilteredRoomViewModelsFamily._dependencies,
          allTransitiveDependencies:
              FilteredRoomViewModelsFamily._allTransitiveDependencies,
          filter: filter,
        );

  FilteredRoomViewModelsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.filter,
  }) : super.internal();

  final String filter;

  @override
  Override overrideWith(
    List<RoomViewModel> Function(FilteredRoomViewModelsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FilteredRoomViewModelsProvider._internal(
        (ref) => create(ref as FilteredRoomViewModelsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        filter: filter,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<RoomViewModel>> createElement() {
    return _FilteredRoomViewModelsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredRoomViewModelsProvider && other.filter == filter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, filter.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin FilteredRoomViewModelsRef on AutoDisposeProviderRef<List<RoomViewModel>> {
  /// The parameter `filter` of this provider.
  String get filter;
}

class _FilteredRoomViewModelsProviderElement
    extends AutoDisposeProviderElement<List<RoomViewModel>>
    with FilteredRoomViewModelsRef {
  _FilteredRoomViewModelsProviderElement(super.provider);

  @override
  String get filter => (origin as FilteredRoomViewModelsProvider).filter;
}

String _$roomStatsHash() => r'7f467560bee67242ddcb2db39fc21691fdc98823';

/// Provider for room statistics based on view models
///
/// Copied from [roomStats].
@ProviderFor(roomStats)
final roomStatsProvider = AutoDisposeProvider<RoomStats>.internal(
  roomStats,
  name: r'roomStatsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$roomStatsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RoomStatsRef = AutoDisposeProviderRef<RoomStats>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
