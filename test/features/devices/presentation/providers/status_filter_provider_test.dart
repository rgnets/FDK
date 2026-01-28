import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/status_filter_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('StatusFilterState', () {
    group('matchesFilter', () {
      test('returns true for any status when not filtering', () {
        const state = StatusFilterState();
        expect(state.isFiltering, isFalse);
        expect(state.matchesFilter('online'), isTrue);
        expect(state.matchesFilter('offline'), isTrue);
        expect(state.matchesFilter('warning'), isTrue);
        expect(state.matchesFilter('error'), isTrue);
        expect(state.matchesFilter(null), isTrue);
        expect(state.matchesFilter(''), isTrue);
      });

      test('returns true only for matching status when filtering', () {
        const state = StatusFilterState(selectedStatus: 'online');
        expect(state.isFiltering, isTrue);
        expect(state.matchesFilter('online'), isTrue);
        expect(state.matchesFilter('Online'), isTrue); // Case insensitive
        expect(state.matchesFilter('ONLINE'), isTrue); // Case insensitive
        expect(state.matchesFilter('offline'), isFalse);
        expect(state.matchesFilter('warning'), isFalse);
        expect(state.matchesFilter('error'), isFalse);
      });

      test('returns false for null/empty status when filtering', () {
        const state = StatusFilterState(selectedStatus: 'online');
        expect(state.matchesFilter(null), isFalse);
        expect(state.matchesFilter(''), isFalse);
      });

      test('handles different status values correctly', () {
        const offlineState = StatusFilterState(selectedStatus: 'offline');
        expect(offlineState.matchesFilter('offline'), isTrue);
        expect(offlineState.matchesFilter('online'), isFalse);

        const warningState = StatusFilterState(selectedStatus: 'warning');
        expect(warningState.matchesFilter('warning'), isTrue);
        expect(warningState.matchesFilter('online'), isFalse);

        const errorState = StatusFilterState(selectedStatus: 'error');
        expect(errorState.matchesFilter('error'), isTrue);
        expect(errorState.matchesFilter('online'), isFalse);
      });
    });

    group('copyWith', () {
      test('creates a copy with updated selectedStatus', () {
        const state = StatusFilterState();
        final updated = state.copyWith(selectedStatus: 'offline');
        expect(updated.selectedStatus, equals('offline'));
        expect(state.selectedStatus, equals(StatusFilterState.allStatuses));
      });

      test('preserves selectedStatus when not provided', () {
        const state = StatusFilterState(selectedStatus: 'online');
        final updated = state.copyWith();
        expect(updated.selectedStatus, equals('online'));
      });
    });

    group('equality', () {
      test('two states with same selectedStatus are equal', () {
        const state1 = StatusFilterState(selectedStatus: 'online');
        const state2 = StatusFilterState(selectedStatus: 'online');
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('two states with different selectedStatus are not equal', () {
        const state1 = StatusFilterState(selectedStatus: 'online');
        const state2 = StatusFilterState(selectedStatus: 'offline');
        expect(state1, isNot(equals(state2)));
      });
    });

    group('getUniqueStatusesFromDevices', () {
      test('returns only All Statuses for empty device list', () {
        final statuses = StatusFilterState.getUniqueStatusesFromDevices([]);
        expect(statuses, equals([StatusFilterState.allStatuses]));
      });

      test('extracts unique statuses and sorts in priority order', () {
        final devices = [
          _createDevice('1', status: 'error'),
          _createDevice('2', status: 'online'),
          _createDevice('3', status: 'warning'),
          _createDevice('4', status: 'offline'),
          _createDevice('5', status: 'online'), // Duplicate
        ];

        final statuses =
            StatusFilterState.getUniqueStatusesFromDevices(devices);

        expect(
          statuses,
          equals([
            StatusFilterState.allStatuses,
            'online',
            'offline',
            'warning',
            'error',
          ]),
        );
      });

      test('handles mixed case statuses', () {
        final devices = [
          _createDevice('1', status: 'Online'),
          _createDevice('2', status: 'OFFLINE'),
          _createDevice('3', status: 'Warning'),
        ];

        final statuses =
            StatusFilterState.getUniqueStatusesFromDevices(devices);

        expect(
          statuses,
          equals([
            StatusFilterState.allStatuses,
            'online',
            'offline',
            'warning',
          ]),
        );
      });

      test('excludes empty status values', () {
        final devices = [
          _createDevice('1', status: 'online'),
          _createDevice('2', status: ''),
          _createDevice('3', status: 'offline'),
        ];

        final statuses =
            StatusFilterState.getUniqueStatusesFromDevices(devices);

        expect(
          statuses,
          equals([
            StatusFilterState.allStatuses,
            'online',
            'offline',
          ]),
        );
      });

      test('handles unknown statuses alphabetically after known ones', () {
        final devices = [
          _createDevice('1', status: 'online'),
          _createDevice('2', status: 'custom_status'),
          _createDevice('3', status: 'another_status'),
        ];

        final statuses =
            StatusFilterState.getUniqueStatusesFromDevices(devices);

        expect(
          statuses,
          equals([
            StatusFilterState.allStatuses,
            'online',
            'another_status',
            'custom_status',
          ]),
        );
      });
    });
  });

  group('StatusFilterNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storageService = StorageService(prefs);

      container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initializes with All Statuses by default', () {
      final state = container.read(statusFilterNotifierProvider);
      expect(state.selectedStatus, equals(StatusFilterState.allStatuses));
      expect(state.isFiltering, isFalse);
    });

    test('setStatus updates the state', () {
      container
          .read(statusFilterNotifierProvider.notifier)
          .setStatus('online');

      final state = container.read(statusFilterNotifierProvider);
      expect(state.selectedStatus, equals('online'));
      expect(state.isFiltering, isTrue);
    });

    test('setStatus does nothing when setting same value', () {
      container
          .read(statusFilterNotifierProvider.notifier)
          .setStatus('online');

      final state1 = container.read(statusFilterNotifierProvider);

      container
          .read(statusFilterNotifierProvider.notifier)
          .setStatus('online');

      final state2 = container.read(statusFilterNotifierProvider);

      // States should be equal (no change)
      expect(state1, equals(state2));
    });

    test('clear resets to All Statuses', () {
      container
          .read(statusFilterNotifierProvider.notifier)
          .setStatus('offline');

      container.read(statusFilterNotifierProvider.notifier).clear();

      final state = container.read(statusFilterNotifierProvider);
      expect(state.selectedStatus, equals(StatusFilterState.allStatuses));
      expect(state.isFiltering, isFalse);
    });

    group('persistence', () {
      test('persists status to storage', () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storageService = StorageService(prefs);

        final testContainer = ProviderContainer(
          overrides: [
            storageServiceProvider.overrideWithValue(storageService),
          ],
        );

        testContainer
            .read(statusFilterNotifierProvider.notifier)
            .setStatus('online');

        // Wait for async storage operation
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(storageService.statusFilter, equals('online'));

        testContainer.dispose();
      });

      test('clears storage when setting All Statuses', () async {
        SharedPreferences.setMockInitialValues({
          StorageService.keyStatusFilter: 'online',
        });
        final prefs = await SharedPreferences.getInstance();
        final storageService = StorageService(prefs);

        final testContainer = ProviderContainer(
          overrides: [
            storageServiceProvider.overrideWithValue(storageService),
          ],
        );

        testContainer.read(statusFilterNotifierProvider.notifier).clear();

        // Wait for async storage operation
        await Future<void>.delayed(const Duration(milliseconds: 100));

        expect(storageService.statusFilter, isNull);

        testContainer.dispose();
      });

      test('restores status from storage on initialization', () async {
        SharedPreferences.setMockInitialValues({
          StorageService.keyStatusFilter: 'offline',
        });
        final prefs = await SharedPreferences.getInstance();
        final storageService = StorageService(prefs);

        final testContainer = ProviderContainer(
          overrides: [
            storageServiceProvider.overrideWithValue(storageService),
          ],
        );

        final state = testContainer.read(statusFilterNotifierProvider);
        expect(state.selectedStatus, equals('offline'));
        expect(state.isFiltering, isTrue);

        testContainer.dispose();
      });
    });
  });
}

/// Helper to create a Device for testing
Device _createDevice(
  String id, {
  String name = 'Test Device',
  String status = 'online',
  String type = 'access_point',
}) {
  return Device(
    id: id,
    name: name,
    status: status,
    type: type,
    ipAddress: '192.168.1.1',
    macAddress: '00:11:22:33:44:55',
  );
}
