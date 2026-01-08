// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanner_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scannerNotifierHash() => r'c6c2b04bdf05ba480f2220c0a7e6199438a5aedf';

/// Scanner notifier with AT&T-style accumulation and auto-detection.
///
/// Key features:
/// - Auto-detect device type from serial patterns (AP/ONT/Switch)
/// - 6-second accumulation window for multi-barcode assembly
/// - 8-second auto-revert to Auto mode after inactivity
/// - Timer management with pause/resume for popups
///
/// Copied from [ScannerNotifier].
@ProviderFor(ScannerNotifier)
final scannerNotifierProvider =
    NotifierProvider<ScannerNotifier, ScannerState>.internal(
  ScannerNotifier.new,
  name: r'scannerNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scannerNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ScannerNotifier = Notifier<ScannerState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
