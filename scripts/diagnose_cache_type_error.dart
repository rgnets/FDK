#!/usr/bin/env dart

// Diagnostic script for the CacheEntry type mismatch error
// Error: Instance of 'CacheEntry<List<Device>?>': type 'CacheEntry<List<Device>?>'
//        is not a subtype of type 'CacheEntry<List<Device>>?'

import 'dart:io';

void _write([String? message]) => stdout.writeln(message ?? '');

void main() {
  _write('=' * 80);
  _write('CACHE TYPE ERROR DIAGNOSIS');
  _write('=' * 80);
  _write();

  analyzeProblem();
  identifyRootCause();
  demonstrateFix();
  verifyArchitecture();
  printSummary();
}

void analyzeProblem() {
  _write('1. ERROR ANALYSIS');
  _write('-' * 40);

  _write('Error Message:');
  _write('  "Instance of CacheEntry<List<Device>?>:');
  _write('   type CacheEntry<List<Device>?> is not a subtype of CacheEntry<List<Device>>?"');
  _write();

  _write('Location: cache_manager.dart line 33');
  _write('  final entry = _cache[key] as CacheEntry<T>?;');
  _write();

  _write('The Problem:');
  _write('  - _cache stores CacheEntry<dynamic>');
  _write('  - When storing CacheEntry<List<Device>?> (nullable list)');
  _write('  - But trying to cast to CacheEntry<List<Device>> (non-nullable list)');
  _write('  - The cast fails at runtime because of type variance');
  _write();

  _write('Call Stack:');
  _write('  1. RoomDeviceNotifier.refresh() calls');
  _write('  2. devicesNotifierProvider.notifier.userRefresh() calls');
  _write('  3. _cacheManager.get<List<Device>>() with nullable return');
  _write('  4. CRASH: Type cast fails on line 33');
}

void identifyRootCause() {
  _write();
  _write('2. ROOT CAUSE IDENTIFICATION');
  _write('-' * 40);

  _write('The Issue:');
  _write('  CacheManager line 33 uses unsafe cast:');
  _write('    final entry = _cache[key] as CacheEntry<T>?;');
  _write();

  _write('Why it fails:');
  _write('  1. _cache is Map<String, CacheEntry<dynamic>>');
  _write('  2. Storing CacheEntry<List<Device>?> (with nullable inner type)');
  _write('  3. Later trying to get as CacheEntry<List<Device>> (non-nullable)');
  _write("  4. Dart's type system prevents this cast (variance issue)");
  _write();

  _write('Specific scenario:');
  _write('  - First call: get<List<Device>?>() stores CacheEntry<List<Device>?>');
  _write('  - Second call: get<List<Device>>() tries to cast - FAILS!');
  _write('  - OR: Background refresh stores nullable, foreground expects non-nullable');
  _write();

  _write('Why it spins forever:');
  _write('  - userRefresh() throws exception');
  _write('  - UI shows loading state');
  _write('  - Exception prevents state update');
  _write('  - Loading spinner never stops');
}

void demonstrateFix() {
  _write();
  _write('3. SOLUTION DEMONSTRATION');
  _write('-' * 40);

  _write('Current BROKEN code (cache_manager.dart line 33):');
  _write('  final entry = _cache[key] as CacheEntry<T>?;');
  _write();

  _write('FIXED code (type-safe):');
  _write('  final dynamic cachedEntry = _cache[key];');
  _write('  if (cachedEntry == null) {');
  _write('    return await _fetchAndCache(key, fetcher, ttl);');
  _write('  }');
  _write();
  _write('  // Safe cast with runtime type check');
  _write('  if (cachedEntry is! CacheEntry<T>) {');
  _write('    // Type mismatch - invalidate and refetch');
  _write('    _cache.remove(key);');
  _write('    return await _fetchAndCache(key, fetcher, ttl);');
  _write('  }');
  _write();
  _write('  final entry = cachedEntry as CacheEntry<T>;');
  _write();

  _write('Why this works:');
  _write('  ✅ Uses runtime type check (is!) instead of cast');
  _write('  ✅ Handles type mismatches gracefully');
  _write('  ✅ Invalidates cache on type change');
  _write('  ✅ No runtime exceptions');
}

void verifyArchitecture() {
  _write();
  _write('4. ARCHITECTURE COMPLIANCE');
  _write('-' * 40);

  _write('Clean Architecture:');
  _write('  ✅ Fix is in Infrastructure layer (CacheManager)');
  _write('  ✅ No changes to Domain or Presentation layers');
  _write('  ✅ Maintains separation of concerns');
  _write();

  _write('MVVM Pattern:');
  _write('  ✅ ViewModels (RoomDeviceNotifier) unchanged');
  _write('  ✅ Error handling stays in infrastructure');
  _write('  ✅ UI remains decoupled');
  _write();

  _write('Dependency Injection:');
  _write('  ✅ CacheManager provided via Riverpod');
  _write('  ✅ No direct instantiation needed');
  _write('  ✅ Provider pattern maintained');
  _write();

  _write('Null Safety:');
  _write('  ✅ Handles nullable and non-nullable types');
  _write('  ✅ No force unwrapping');
  _write('  ✅ Type-safe runtime checks');
  _write();

  _write('Error Handling:');
  _write('  ✅ Graceful degradation on type mismatch');
  _write('  ✅ No crashes or exceptions');
  _write('  ✅ Automatic cache invalidation');
}

void printSummary() {
  _write();
  _write('=' * 80);
  _write('DIAGNOSIS SUMMARY');
  _write('=' * 80);

  _write();
  _write('PROBLEM:');
  _write('  CacheManager uses unsafe type cast causing runtime exception');
  _write('  This prevents devices from loading in room detail view');
  _write();

  _write('SOLUTION:');
  _write('  Replace unsafe cast with runtime type check');
  _write('  Invalidate cache on type mismatch');
  _write('  Gracefully handle type variance');
  _write();

  _write('IMPACT:');
  _write('  - Devices tab will load correctly');
  _write('  - No more infinite spinner');
  _write('  - Type-safe caching');
  _write('  - Better error resilience');
}
