// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deviceStatusesHash() => r'448412399e118fa7fa9fadb58dd7b63ad2a97f94';

/// Provider for available statuses based on all devices
///
/// Copied from [deviceStatuses].
@ProviderFor(deviceStatuses)
final deviceStatusesProvider = AutoDisposeProvider<List<String>>.internal(
  deviceStatuses,
  name: r'deviceStatusesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deviceStatusesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeviceStatusesRef = AutoDisposeProviderRef<List<String>>;
String _$statusFilterNotifierHash() =>
    r'651c75275feb97481d52df46b60e9205db17acd0';

/// Notifier for managing status filter state with persistence
///
/// Copied from [StatusFilterNotifier].
@ProviderFor(StatusFilterNotifier)
final statusFilterNotifierProvider = AutoDisposeNotifierProvider<
    StatusFilterNotifier, StatusFilterState>.internal(
  StatusFilterNotifier.new,
  name: r'statusFilterNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$statusFilterNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$StatusFilterNotifier = AutoDisposeNotifier<StatusFilterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
