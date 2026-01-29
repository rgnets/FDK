// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speed_test_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$speedTestDataSourceHash() =>
    r'457c875a89d71de8210eb4bb9bba3bee39b1a74f';

/// See also [speedTestDataSource].
@ProviderFor(speedTestDataSource)
final speedTestDataSourceProvider = Provider<SpeedTestDataSource>.internal(
  speedTestDataSource,
  name: r'speedTestDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$speedTestDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SpeedTestDataSourceRef = ProviderRef<SpeedTestDataSource>;
String _$speedTestRepositoryHash() =>
    r'cde0557446726a402f54bb9844ea9ed62cd9b74f';

/// See also [speedTestRepository].
@ProviderFor(speedTestRepository)
final speedTestRepositoryProvider = Provider<SpeedTestRepository>.internal(
  speedTestRepository,
  name: r'speedTestRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$speedTestRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SpeedTestRepositoryRef = ProviderRef<SpeedTestRepository>;
String _$speedTestConfigsNotifierHash() =>
    r'99fe29c99e231a1a2bf70e065b22c02a5a2806a4';

/// See also [SpeedTestConfigsNotifier].
@ProviderFor(SpeedTestConfigsNotifier)
final speedTestConfigsNotifierProvider = AsyncNotifierProvider<
    SpeedTestConfigsNotifier, List<SpeedTestConfig>>.internal(
  SpeedTestConfigsNotifier.new,
  name: r'speedTestConfigsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$speedTestConfigsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SpeedTestConfigsNotifier = AsyncNotifier<List<SpeedTestConfig>>;
String _$speedTestResultsNotifierHash() =>
    r'1e035a7a5d6105cc2577309ba1a1469642de508d';

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

abstract class _$SpeedTestResultsNotifier
    extends BuildlessAsyncNotifier<List<SpeedTestResult>> {
  late final int? speedTestId;
  late final int? accessPointId;

  FutureOr<List<SpeedTestResult>> build({
    int? speedTestId,
    int? accessPointId,
  });
}

/// See also [SpeedTestResultsNotifier].
@ProviderFor(SpeedTestResultsNotifier)
const speedTestResultsNotifierProvider = SpeedTestResultsNotifierFamily();

/// See also [SpeedTestResultsNotifier].
class SpeedTestResultsNotifierFamily
    extends Family<AsyncValue<List<SpeedTestResult>>> {
  /// See also [SpeedTestResultsNotifier].
  const SpeedTestResultsNotifierFamily();

  /// See also [SpeedTestResultsNotifier].
  SpeedTestResultsNotifierProvider call({
    int? speedTestId,
    int? accessPointId,
  }) {
    return SpeedTestResultsNotifierProvider(
      speedTestId: speedTestId,
      accessPointId: accessPointId,
    );
  }

  @override
  SpeedTestResultsNotifierProvider getProviderOverride(
    covariant SpeedTestResultsNotifierProvider provider,
  ) {
    return call(
      speedTestId: provider.speedTestId,
      accessPointId: provider.accessPointId,
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
  String? get name => r'speedTestResultsNotifierProvider';
}

/// See also [SpeedTestResultsNotifier].
class SpeedTestResultsNotifierProvider extends AsyncNotifierProviderImpl<
    SpeedTestResultsNotifier, List<SpeedTestResult>> {
  /// See also [SpeedTestResultsNotifier].
  SpeedTestResultsNotifierProvider({
    int? speedTestId,
    int? accessPointId,
  }) : this._internal(
          () => SpeedTestResultsNotifier()
            ..speedTestId = speedTestId
            ..accessPointId = accessPointId,
          from: speedTestResultsNotifierProvider,
          name: r'speedTestResultsNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$speedTestResultsNotifierHash,
          dependencies: SpeedTestResultsNotifierFamily._dependencies,
          allTransitiveDependencies:
              SpeedTestResultsNotifierFamily._allTransitiveDependencies,
          speedTestId: speedTestId,
          accessPointId: accessPointId,
        );

  SpeedTestResultsNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.speedTestId,
    required this.accessPointId,
  }) : super.internal();

  final int? speedTestId;
  final int? accessPointId;

  @override
  FutureOr<List<SpeedTestResult>> runNotifierBuild(
    covariant SpeedTestResultsNotifier notifier,
  ) {
    return notifier.build(
      speedTestId: speedTestId,
      accessPointId: accessPointId,
    );
  }

  @override
  Override overrideWith(SpeedTestResultsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: SpeedTestResultsNotifierProvider._internal(
        () => create()
          ..speedTestId = speedTestId
          ..accessPointId = accessPointId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        speedTestId: speedTestId,
        accessPointId: accessPointId,
      ),
    );
  }

  @override
  AsyncNotifierProviderElement<SpeedTestResultsNotifier, List<SpeedTestResult>>
      createElement() {
    return _SpeedTestResultsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SpeedTestResultsNotifierProvider &&
        other.speedTestId == speedTestId &&
        other.accessPointId == accessPointId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, speedTestId.hashCode);
    hash = _SystemHash.combine(hash, accessPointId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin SpeedTestResultsNotifierRef
    on AsyncNotifierProviderRef<List<SpeedTestResult>> {
  /// The parameter `speedTestId` of this provider.
  int? get speedTestId;

  /// The parameter `accessPointId` of this provider.
  int? get accessPointId;
}

class _SpeedTestResultsNotifierProviderElement
    extends AsyncNotifierProviderElement<SpeedTestResultsNotifier,
        List<SpeedTestResult>> with SpeedTestResultsNotifierRef {
  _SpeedTestResultsNotifierProviderElement(super.provider);

  @override
  int? get speedTestId =>
      (origin as SpeedTestResultsNotifierProvider).speedTestId;
  @override
  int? get accessPointId =>
      (origin as SpeedTestResultsNotifierProvider).accessPointId;
}

String _$speedTestRunNotifierHash() =>
    r'9b0eea3189731390396dd7c4fbd573e6f34596ad';

/// See also [SpeedTestRunNotifier].
@ProviderFor(SpeedTestRunNotifier)
final speedTestRunNotifierProvider =
    NotifierProvider<SpeedTestRunNotifier, SpeedTestRunState>.internal(
  SpeedTestRunNotifier.new,
  name: r'speedTestRunNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$speedTestRunNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SpeedTestRunNotifier = Notifier<SpeedTestRunState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
