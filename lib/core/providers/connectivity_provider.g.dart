// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appConnectionStatusHash() =>
    r'5ce12ee7f55cba3eb26f84d491f9f9c3cfe5ef4d';

/// Provider that combines WebSocket connection state with device connectivity
/// to determine the overall app connection status.
///
/// Copied from [appConnectionStatus].
@ProviderFor(appConnectionStatus)
final appConnectionStatusProvider =
    AutoDisposeStreamProvider<AppConnectionStatus>.internal(
  appConnectionStatus,
  name: r'appConnectionStatusProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appConnectionStatusHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppConnectionStatusRef
    = AutoDisposeStreamProviderRef<AppConnectionStatus>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
