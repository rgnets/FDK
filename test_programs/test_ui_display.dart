#!/usr/bin/env dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/config/environment.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/providers/repository_providers.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/device_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=' * 80);
  print('UI DISPLAY TEST - What the app actually shows');
  print('=' * 80);
  
  // Set environment to development
  EnvironmentConfig.setEnvironment(Environment.development);
  print('\n1. Environment: ${EnvironmentConfig.environment}');
  print('   isDevelopment: ${EnvironmentConfig.isDevelopment}');
  
  // Initialize providers
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Create provider container
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );
  
  print('\n2. Fetching devices through provider...');
  
  try {
    // Get devices through the provider (as the UI would)
    final devicesAsync = await container.read(devicesProvider.future);
    
    print('\n3. Devices from provider:');
    print('   Total devices: ${devicesAsync.length}');
    
    // Show first few of each type
    final aps = devicesAsync.where((d) => d.type == 'access_point').take(5).toList();
    print('\n   Access Points (first 5):');
    for (final ap in aps) {
      print('     Name: ${ap.name.padRight(30)} Location: ${ap.location}');
    }
    
    final switches = devicesAsync.where((d) => d.type == 'switch').take(5).toList();
    print('\n   Switches (first 5):');
    for (final sw in switches) {
      print('     Name: ${sw.name.padRight(30)} Location: ${sw.location}');
    }
    
    final onts = devicesAsync.where((d) => d.type == 'ont').take(5).toList();
    print('\n   ONTs (first 5):');
    for (final ont in onts) {
      print('     Name: ${ont.name.padRight(30)} Location: ${ont.location}');
    }
    
    // Check format
    print('\n4. FORMAT ANALYSIS:');
    if (aps.isNotEmpty) {
      final name = aps.first.name;
      print('   First AP name: "$name"');
      
      // Check for production format (with optional suffix)
      if (name.contains('-') && name.startsWith('AP')) {
        final parts = name.split('-');
        if (parts.length >= 5) {
          print('   ✓ Has correct number of parts (${parts.length})');
          print('     Building: ${parts[0].substring(2)}');
          print('     Floor: ${parts[1]}');
          print('     Serial: ${parts[2]}');
          print('     Model: ${parts[3]}');
          print('     Room: ${parts[4]}');
        } else {
          print('   ✗ Wrong number of parts: ${parts.length}');
        }
      } else {
        print('   ✗ Does not follow production format');
      }
    }
    
  } catch (e, stackTrace) {
    print('\nERROR: $e');
    print('Stack trace:');
    print(stackTrace);
  }
  
  // Clean up
  container.dispose();
  
  print('\n' + '=' * 80);
  print('END OF TEST');
  print('=' * 80);
}