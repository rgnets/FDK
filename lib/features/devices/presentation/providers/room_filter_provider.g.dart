// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$deviceRoomsHash() => r'08138c439dc565738a0e6be8ed04001124c338da';

/// Provider for available rooms based on rooms data (not devices)
///
/// Copied from [deviceRooms].
@ProviderFor(deviceRooms)
final deviceRoomsProvider = AutoDisposeProvider<List<String>>.internal(
  deviceRooms,
  name: r'deviceRoomsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$deviceRoomsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeviceRoomsRef = AutoDisposeProviderRef<List<String>>;
String _$roomFilterNotifierHash() =>
    r'b8a6ed24b4cbca068f5850a400bdf54c03862776';

/// Notifier for managing room filter state with persistence
///
/// Copied from [RoomFilterNotifier].
@ProviderFor(RoomFilterNotifier)
final roomFilterNotifierProvider =
    AutoDisposeNotifierProvider<RoomFilterNotifier, RoomFilterState>.internal(
  RoomFilterNotifier.new,
  name: r'roomFilterNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$roomFilterNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RoomFilterNotifier = AutoDisposeNotifier<RoomFilterState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
