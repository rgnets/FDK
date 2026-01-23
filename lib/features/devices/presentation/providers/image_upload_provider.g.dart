// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_upload_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$imageUploadEventBusHash() =>
    r'2e6e7d79fe0e5d3b19579e29992a682e0ce80a06';

/// Provider for the ImageUploadEventBus singleton
///
/// Copied from [imageUploadEventBus].
@ProviderFor(imageUploadEventBus)
final imageUploadEventBusProvider = Provider<ImageUploadEventBus>.internal(
  imageUploadEventBus,
  name: r'imageUploadEventBusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$imageUploadEventBusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ImageUploadEventBusRef = ProviderRef<ImageUploadEventBus>;
String _$imageUploadVerifierHash() =>
    r'8711968aab149edc65f3dd18151271053d8c13f4';

/// Provider for ImageUploadVerifier
///
/// Copied from [imageUploadVerifier].
@ProviderFor(imageUploadVerifier)
final imageUploadVerifierProvider =
    AutoDisposeProvider<ImageUploadVerifier>.internal(
  imageUploadVerifier,
  name: r'imageUploadVerifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$imageUploadVerifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ImageUploadVerifierRef = AutoDisposeProviderRef<ImageUploadVerifier>;
String _$restImageUploadServiceHash() =>
    r'ae944432b957b5c5b28d0f3d1b3d2bfc83e8d8b7';

/// Provider for RestImageUploadService
///
/// Uses [SecureHttpClient] internally for certificate validation,
/// so no external HTTP client is needed.
///
/// Copied from [restImageUploadService].
@ProviderFor(restImageUploadService)
final restImageUploadServiceProvider =
    AutoDisposeProvider<RestImageUploadService>.internal(
  restImageUploadService,
  name: r'restImageUploadServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$restImageUploadServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RestImageUploadServiceRef
    = AutoDisposeProviderRef<RestImageUploadService>;
String _$imageUploadServiceHash() =>
    r'a0115e6fb6263c044c6119d5ee65b179c36fcc99';

/// Provider for ImageUploadService
///
/// Uses REST API (HTTP PUT) for uploading images instead of WebSocket.
/// This provides better reliability for large base64 payloads.
/// After upload, requests updated device data via WebSocket to ensure
/// the UI automatically updates with the new images.
///
/// Copied from [imageUploadService].
@ProviderFor(imageUploadService)
final imageUploadServiceProvider =
    AutoDisposeProvider<ImageUploadService>.internal(
  imageUploadService,
  name: r'imageUploadServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$imageUploadServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ImageUploadServiceRef = AutoDisposeProviderRef<ImageUploadService>;
String _$imageUploadEventsHash() => r'2b903f602f78530ec57b63f7b76fda4bfd3eebd2';

/// Stream provider for image upload events
///
/// Copied from [imageUploadEvents].
@ProviderFor(imageUploadEvents)
final imageUploadEventsProvider = StreamProvider<ImageUploadEvent>.internal(
  imageUploadEvents,
  name: r'imageUploadEventsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$imageUploadEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ImageUploadEventsRef = StreamProviderRef<ImageUploadEvent>;
String _$cacheInvalidationEventsHash() =>
    r'3b1290173e5ba5e8d209e428134aae6d7421994d';

/// Stream provider for cache invalidation events
///
/// Copied from [cacheInvalidationEvents].
@ProviderFor(cacheInvalidationEvents)
final cacheInvalidationEventsProvider =
    StreamProvider<CacheInvalidationEvent>.internal(
  cacheInvalidationEvents,
  name: r'cacheInvalidationEventsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cacheInvalidationEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CacheInvalidationEventsRef = StreamProviderRef<CacheInvalidationEvent>;
String _$imageUploadNotifierHash() =>
    r'b4d97f88ba1795dcf46224e3bd850a146f5427cf';

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

abstract class _$ImageUploadNotifier
    extends BuildlessAutoDisposeNotifier<ImageUploadViewState> {
  late final String deviceId;

  ImageUploadViewState build(
    String deviceId,
  );
}

/// Notifier for image upload state per device
///
/// Copied from [ImageUploadNotifier].
@ProviderFor(ImageUploadNotifier)
const imageUploadNotifierProvider = ImageUploadNotifierFamily();

/// Notifier for image upload state per device
///
/// Copied from [ImageUploadNotifier].
class ImageUploadNotifierFamily extends Family<ImageUploadViewState> {
  /// Notifier for image upload state per device
  ///
  /// Copied from [ImageUploadNotifier].
  const ImageUploadNotifierFamily();

  /// Notifier for image upload state per device
  ///
  /// Copied from [ImageUploadNotifier].
  ImageUploadNotifierProvider call(
    String deviceId,
  ) {
    return ImageUploadNotifierProvider(
      deviceId,
    );
  }

  @override
  ImageUploadNotifierProvider getProviderOverride(
    covariant ImageUploadNotifierProvider provider,
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
  String? get name => r'imageUploadNotifierProvider';
}

/// Notifier for image upload state per device
///
/// Copied from [ImageUploadNotifier].
class ImageUploadNotifierProvider extends AutoDisposeNotifierProviderImpl<
    ImageUploadNotifier, ImageUploadViewState> {
  /// Notifier for image upload state per device
  ///
  /// Copied from [ImageUploadNotifier].
  ImageUploadNotifierProvider(
    String deviceId,
  ) : this._internal(
          () => ImageUploadNotifier()..deviceId = deviceId,
          from: imageUploadNotifierProvider,
          name: r'imageUploadNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$imageUploadNotifierHash,
          dependencies: ImageUploadNotifierFamily._dependencies,
          allTransitiveDependencies:
              ImageUploadNotifierFamily._allTransitiveDependencies,
          deviceId: deviceId,
        );

  ImageUploadNotifierProvider._internal(
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
  ImageUploadViewState runNotifierBuild(
    covariant ImageUploadNotifier notifier,
  ) {
    return notifier.build(
      deviceId,
    );
  }

  @override
  Override overrideWith(ImageUploadNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ImageUploadNotifierProvider._internal(
        () => create()..deviceId = deviceId,
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
  AutoDisposeNotifierProviderElement<ImageUploadNotifier, ImageUploadViewState>
      createElement() {
    return _ImageUploadNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ImageUploadNotifierProvider && other.deviceId == deviceId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, deviceId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ImageUploadNotifierRef
    on AutoDisposeNotifierProviderRef<ImageUploadViewState> {
  /// The parameter `deviceId` of this provider.
  String get deviceId;
}

class _ImageUploadNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<ImageUploadNotifier,
        ImageUploadViewState> with ImageUploadNotifierRef {
  _ImageUploadNotifierProviderElement(super.provider);

  @override
  String get deviceId => (origin as ImageUploadNotifierProvider).deviceId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
