import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/devices_provider.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  String _debugInfo = 'Loading...';
  
  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }
  
  Future<void> _runDiagnostics() async {
    final buffer = StringBuffer()
      // Environment check
      ..writeln('=== ENVIRONMENT ===')
      ..writeln('Current: ${EnvironmentConfig.name}')
      ..writeln('isDevelopment: ${EnvironmentConfig.isDevelopment}')
      ..writeln('isStaging: ${EnvironmentConfig.isStaging}')
      ..writeln('isProduction: ${EnvironmentConfig.isProduction}')
      ..writeln('useSyntheticData: ${EnvironmentConfig.useSyntheticData}')
      ..writeln('API URL: ${EnvironmentConfig.apiBaseUrl}')
      ..writeln('')
      // Provider check
      ..writeln('=== RIVERPOD PROVIDERS ===');
    
    try {
      final deviceRepo = ref.read(deviceRepositoryProvider);
      buffer.writeln('DeviceRepository: ${deviceRepo.runtimeType}');
      
      final roomRepo = ref.read(roomRepositoryProvider);
      buffer.writeln('RoomRepository: ${roomRepo.runtimeType}');
    } on Exception catch (e) {
      buffer.writeln('Error getting from providers: $e');
    }
    buffer
      ..writeln('')
      // Direct repository test
      ..writeln('=== DIRECT REPOSITORY TEST ===');
    try {
      final deviceRepo = ref.read(deviceRepositoryProvider);
      buffer.writeln('Calling deviceRepo.getDevices()...');
      final deviceResult = await deviceRepo.getDevices();
      deviceResult.fold(
        (failure) => buffer.writeln('ERROR: ${failure.message}'),
        (devices) => buffer.writeln('SUCCESS: ${devices.length} devices'),
      );
    } on Exception catch (e) {
      buffer.writeln('Exception: $e');
    }
    buffer.writeln('');
    
    try {
      final roomRepo = ref.read(roomRepositoryProvider);
      buffer.writeln('Calling roomRepo.getRooms()...');
      final roomResult = await roomRepo.getRooms();
      roomResult.fold(
        (failure) => buffer.writeln('ERROR: ${failure.message}'),
        (rooms) => buffer.writeln('SUCCESS: ${rooms.length} rooms'),
      );
    } on Exception catch (e) {
      buffer.writeln('Exception: $e');
    }
    buffer
      ..writeln('')
      // Provider test
      ..writeln('=== PROVIDER TEST ===');
    try {
      final devicesAsync = ref.read(devicesNotifierProvider);
      buffer.writeln('devicesNotifierProvider state: ${devicesAsync.runtimeType}');
      devicesAsync.when(
        data: (devices) => buffer.writeln('Devices from provider: ${devices.length}'),
        error: (e, s) => buffer.writeln('Provider error: $e'),
        loading: () => buffer.writeln('Provider is loading'),
      );
    } on Exception catch (e) {
      buffer.writeln('Exception reading provider: $e');
    }
    buffer.writeln('');
    
    try {
      final roomsAsync = ref.read(roomsNotifierProvider);
      buffer.writeln('roomsNotifierProvider state: ${roomsAsync.runtimeType}');
      roomsAsync.when(
        data: (rooms) => buffer.writeln('Rooms from provider: ${rooms.length}'),
        error: (e, s) => buffer.writeln('Provider error: $e'),
        loading: () => buffer.writeln('Provider is loading'),
      );
    } on Exception catch (e) {
      buffer.writeln('Exception reading provider: $e');
    }
    
    setState(() {
      _debugInfo = buffer.toString();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    // AppBar removed from DebugScreen - refresh functionality preserved
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(
          _debugInfo,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
    );
  }
}