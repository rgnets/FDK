// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'initialization_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$showInitializationOverlayHash() =>
    r'13fd4d3ef3e1330753c2d6d20ce0338a91db625b';

/// Computed provider that returns whether the overlay should be shown.
///
/// Copied from [showInitializationOverlay].
@ProviderFor(showInitializationOverlay)
final showInitializationOverlayProvider = AutoDisposeProvider<bool>.internal(
  showInitializationOverlay,
  name: r'showInitializationOverlayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$showInitializationOverlayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ShowInitializationOverlayRef = AutoDisposeProviderRef<bool>;
String _$initializationNotifierHash() =>
    r'ad19d0699d76b22de9f634312fe6c7ab41ad6757';

/// Manages the app initialization state and progress.
///
/// This notifier tracks the initialization flow through several states:
/// - [InitializationState.uninitialized] - Initial state
/// - [InitializationState.checkingConnection] - Verifying WebSocket
/// - [InitializationState.validatingCredentials] - Checking auth
/// - [InitializationState.loadingData] - Loading data with progress
/// - [InitializationState.ready] - App is ready
/// - [InitializationState.error] - Error occurred
///
/// Copied from [InitializationNotifier].
@ProviderFor(InitializationNotifier)
final initializationNotifierProvider =
    NotifierProvider<InitializationNotifier, InitializationState>.internal(
  InitializationNotifier.new,
  name: r'initializationNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initializationNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$InitializationNotifier = Notifier<InitializationState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
