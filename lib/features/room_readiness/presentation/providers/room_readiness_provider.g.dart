// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_readiness_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$roomReadinessByIdHash() => r'd32a1f819a3ca5aeee35855d37b60f3fc3c43b61';

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

/// Provider to get room readiness by ID.
///
/// Copied from [roomReadinessById].
@ProviderFor(roomReadinessById)
const roomReadinessByIdProvider = RoomReadinessByIdFamily();

/// Provider to get room readiness by ID.
///
/// Copied from [roomReadinessById].
class RoomReadinessByIdFamily
    extends Family<AsyncValue<RoomReadinessMetrics?>> {
  /// Provider to get room readiness by ID.
  ///
  /// Copied from [roomReadinessById].
  const RoomReadinessByIdFamily();

  /// Provider to get room readiness by ID.
  ///
  /// Copied from [roomReadinessById].
  RoomReadinessByIdProvider call(
    int roomId,
  ) {
    return RoomReadinessByIdProvider(
      roomId,
    );
  }

  @override
  RoomReadinessByIdProvider getProviderOverride(
    covariant RoomReadinessByIdProvider provider,
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
  String? get name => r'roomReadinessByIdProvider';
}

/// Provider to get room readiness by ID.
///
/// Copied from [roomReadinessById].
class RoomReadinessByIdProvider
    extends AutoDisposeFutureProvider<RoomReadinessMetrics?> {
  /// Provider to get room readiness by ID.
  ///
  /// Copied from [roomReadinessById].
  RoomReadinessByIdProvider(
    int roomId,
  ) : this._internal(
          (ref) => roomReadinessById(
            ref as RoomReadinessByIdRef,
            roomId,
          ),
          from: roomReadinessByIdProvider,
          name: r'roomReadinessByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$roomReadinessByIdHash,
          dependencies: RoomReadinessByIdFamily._dependencies,
          allTransitiveDependencies:
              RoomReadinessByIdFamily._allTransitiveDependencies,
          roomId: roomId,
        );

  RoomReadinessByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roomId,
  }) : super.internal();

  final int roomId;

  @override
  Override overrideWith(
    FutureOr<RoomReadinessMetrics?> Function(RoomReadinessByIdRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoomReadinessByIdProvider._internal(
        (ref) => create(ref as RoomReadinessByIdRef),
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
  AutoDisposeFutureProviderElement<RoomReadinessMetrics?> createElement() {
    return _RoomReadinessByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomReadinessByIdProvider && other.roomId == roomId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roomId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RoomReadinessByIdRef
    on AutoDisposeFutureProviderRef<RoomReadinessMetrics?> {
  /// The parameter `roomId` of this provider.
  int get roomId;
}

class _RoomReadinessByIdProviderElement
    extends AutoDisposeFutureProviderElement<RoomReadinessMetrics?>
    with RoomReadinessByIdRef {
  _RoomReadinessByIdProviderElement(super.provider);

  @override
  int get roomId => (origin as RoomReadinessByIdProvider).roomId;
}

String _$roomReadinessSummaryHash() =>
    r'71e304616c6070ded24d77674c479e0a49132922';

/// Provider for room readiness summary statistics.
///
/// Copied from [roomReadinessSummary].
@ProviderFor(roomReadinessSummary)
final roomReadinessSummaryProvider =
    AutoDisposeProvider<RoomReadinessSummary>.internal(
  roomReadinessSummary,
  name: r'roomReadinessSummaryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$roomReadinessSummaryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RoomReadinessSummaryRef = AutoDisposeProviderRef<RoomReadinessSummary>;
String _$roomsByStatusHash() => r'2761a0c6cac0037c4ff5776ee7a793175a352d02';

/// Provider for rooms filtered by status.
///
/// Copied from [roomsByStatus].
@ProviderFor(roomsByStatus)
const roomsByStatusProvider = RoomsByStatusFamily();

/// Provider for rooms filtered by status.
///
/// Copied from [roomsByStatus].
class RoomsByStatusFamily extends Family<List<RoomReadinessMetrics>> {
  /// Provider for rooms filtered by status.
  ///
  /// Copied from [roomsByStatus].
  const RoomsByStatusFamily();

  /// Provider for rooms filtered by status.
  ///
  /// Copied from [roomsByStatus].
  RoomsByStatusProvider call(
    RoomStatus status,
  ) {
    return RoomsByStatusProvider(
      status,
    );
  }

  @override
  RoomsByStatusProvider getProviderOverride(
    covariant RoomsByStatusProvider provider,
  ) {
    return call(
      provider.status,
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
  String? get name => r'roomsByStatusProvider';
}

/// Provider for rooms filtered by status.
///
/// Copied from [roomsByStatus].
class RoomsByStatusProvider
    extends AutoDisposeProvider<List<RoomReadinessMetrics>> {
  /// Provider for rooms filtered by status.
  ///
  /// Copied from [roomsByStatus].
  RoomsByStatusProvider(
    RoomStatus status,
  ) : this._internal(
          (ref) => roomsByStatus(
            ref as RoomsByStatusRef,
            status,
          ),
          from: roomsByStatusProvider,
          name: r'roomsByStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$roomsByStatusHash,
          dependencies: RoomsByStatusFamily._dependencies,
          allTransitiveDependencies:
              RoomsByStatusFamily._allTransitiveDependencies,
          status: status,
        );

  RoomsByStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.status,
  }) : super.internal();

  final RoomStatus status;

  @override
  Override overrideWith(
    List<RoomReadinessMetrics> Function(RoomsByStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoomsByStatusProvider._internal(
        (ref) => create(ref as RoomsByStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        status: status,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<RoomReadinessMetrics>> createElement() {
    return _RoomsByStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoomsByStatusProvider && other.status == status;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, status.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RoomsByStatusRef on AutoDisposeProviderRef<List<RoomReadinessMetrics>> {
  /// The parameter `status` of this provider.
  RoomStatus get status;
}

class _RoomsByStatusProviderElement
    extends AutoDisposeProviderElement<List<RoomReadinessMetrics>>
    with RoomsByStatusRef {
  _RoomsByStatusProviderElement(super.provider);

  @override
  RoomStatus get status => (origin as RoomsByStatusProvider).status;
}

String _$roomReadinessUpdatesHash() =>
    r'36b5326629c72d6d4a6dce97d7b06468f6c617aa';

/// Provider for stream of room readiness updates.
///
/// Copied from [roomReadinessUpdates].
@ProviderFor(roomReadinessUpdates)
final roomReadinessUpdatesProvider =
    AutoDisposeStreamProvider<RoomReadinessUpdate>.internal(
  roomReadinessUpdates,
  name: r'roomReadinessUpdatesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$roomReadinessUpdatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RoomReadinessUpdatesRef
    = AutoDisposeStreamProviderRef<RoomReadinessUpdate>;
String _$roomReadinessNotifierHash() =>
    r'ad7c6a306874a8f4f5efe2da6ea55677e3c15d3d';

/// Provider for room readiness metrics.
///
/// Copied from [RoomReadinessNotifier].
@ProviderFor(RoomReadinessNotifier)
final roomReadinessNotifierProvider = AsyncNotifierProvider<
    RoomReadinessNotifier, List<RoomReadinessMetrics>>.internal(
  RoomReadinessNotifier.new,
  name: r'roomReadinessNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$roomReadinessNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RoomReadinessNotifier = AsyncNotifier<List<RoomReadinessMetrics>>;
String _$overallReadinessNotifierHash() =>
    r'7f477f39bcfe3c99b47191fa7434539a50ec83b2';

/// Provider for overall readiness percentage.
///
/// Copied from [OverallReadinessNotifier].
@ProviderFor(OverallReadinessNotifier)
final overallReadinessNotifierProvider =
    AutoDisposeAsyncNotifierProvider<OverallReadinessNotifier, double>.internal(
  OverallReadinessNotifier.new,
  name: r'overallReadinessNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$overallReadinessNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OverallReadinessNotifier = AutoDisposeAsyncNotifier<double>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
