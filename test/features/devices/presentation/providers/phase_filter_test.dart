import 'package:flutter_test/flutter_test.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:rgnets_fdk/features/devices/presentation/providers/phase_filter_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PhaseFilterState', () {
    test('should have allPhases as default selected phase', () {
      const state = PhaseFilterState();
      expect(state.selectedPhase, equals(PhaseFilterState.allPhases));
    });

    test('should correctly report isFiltering when a phase is selected', () {
      const stateAll = PhaseFilterState();
      expect(stateAll.isFiltering, isFalse);

      const statePhase1 = PhaseFilterState(selectedPhase: 'Phase 1');
      expect(statePhase1.isFiltering, isTrue);
    });

    test('should match all devices when not filtering', () {
      const state = PhaseFilterState();
      expect(state.matchesFilter(null), isTrue);
      expect(state.matchesFilter('Phase 1'), isTrue);
      expect(state.matchesFilter('Phase 2'), isTrue);
    });

    test('should match only devices with selected phase when filtering', () {
      const state = PhaseFilterState(selectedPhase: 'Phase 1');
      expect(state.matchesFilter('Phase 1'), isTrue);
      expect(state.matchesFilter('Phase 2'), isFalse);
      expect(state.matchesFilter(null), isFalse);
    });

    test('should match Unassigned for devices with null or empty phase', () {
      const state = PhaseFilterState(selectedPhase: 'Unassigned');
      expect(state.matchesFilter(null), isTrue);
      expect(state.matchesFilter(''), isTrue);
      expect(state.matchesFilter('Phase 1'), isFalse);
    });

    test('copyWith should create new state with updated values', () {
      const state = PhaseFilterState(selectedPhase: 'Phase 1');
      final newState = state.copyWith(selectedPhase: 'Phase 2');

      expect(state.selectedPhase, equals('Phase 1'));
      expect(newState.selectedPhase, equals('Phase 2'));
    });
  });

  group('Phase filter with Device entities', () {
    late List<Device> testDevices;

    setUp(() {
      testDevices = [
        const Device(
          id: '1',
          name: 'AP-1',
          type: 'access_point',
          status: 'online',
          metadata: {'phase': 'Phase 1'},
        ),
        const Device(
          id: '2',
          name: 'AP-2',
          type: 'access_point',
          status: 'online',
          metadata: {'phase': 'Phase 2'},
        ),
        const Device(
          id: '3',
          name: 'AP-3',
          type: 'access_point',
          status: 'offline',
          metadata: {'phase': 'Phase 1'},
        ),
        const Device(
          id: '4',
          name: 'Switch-1',
          type: 'switch',
          status: 'online',
          metadata: null, // No phase assigned
        ),
      ];
    });

    test('should filter devices by phase using metadata', () {
      const state = PhaseFilterState(selectedPhase: 'Phase 1');

      final filtered = testDevices.where((device) {
        final phase = device.metadata?['phase'] as String?;
        return state.matchesFilter(phase);
      }).toList();

      expect(filtered.length, equals(2));
      expect(filtered.map((d) => d.name), containsAll(['AP-1', 'AP-3']));
    });

    test('should show unassigned devices when Unassigned filter selected', () {
      const state = PhaseFilterState(selectedPhase: 'Unassigned');

      final filtered = testDevices.where((device) {
        final phase = device.metadata?['phase'] as String?;
        return state.matchesFilter(phase);
      }).toList();

      expect(filtered.length, equals(1));
      expect(filtered.first.name, equals('Switch-1'));
    });
  });

  group('getUniquePhases', () {
    test('should extract unique phases from devices', () {
      final devices = [
        const Device(
          id: '1',
          name: 'AP-1',
          type: 'access_point',
          status: 'online',
          metadata: {'phase': 'Phase 1'},
        ),
        const Device(
          id: '2',
          name: 'AP-2',
          type: 'access_point',
          status: 'online',
          metadata: {'phase': 'Phase 2'},
        ),
        const Device(
          id: '3',
          name: 'AP-3',
          type: 'access_point',
          status: 'online',
          metadata: {'phase': 'Phase 1'}, // Duplicate
        ),
        const Device(
          id: '4',
          name: 'Switch-1',
          type: 'switch',
          status: 'online',
          metadata: null,
        ),
      ];

      final phases = PhaseFilterState.getUniquePhasesFromDevices(devices);

      expect(phases.first, equals(PhaseFilterState.allPhases));
      expect(phases, contains('Phase 1'));
      expect(phases, contains('Phase 2'));
      expect(phases, contains('Unassigned'));
      expect(phases.length, equals(4)); // All Phases + Phase 1 + Phase 2 + Unassigned
    });

    test('should return only All Phases when no devices', () {
      final phases = PhaseFilterState.getUniquePhasesFromDevices([]);
      expect(phases.length, equals(1));
      expect(phases.first, equals(PhaseFilterState.allPhases));
    });
  });

  group('Phase filter persistence', () {
    late SharedPreferences prefs;
    late StorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      storageService = StorageService(prefs);
    });

    test('should save selected phase to storage', () async {
      await storageService.setString(
        StorageService.keyPhaseFilter,
        'Phase 1',
      );

      final saved = storageService.getString(StorageService.keyPhaseFilter);
      expect(saved, equals('Phase 1'));
    });

    test('should load saved phase from storage', () async {
      await prefs.setString(StorageService.keyPhaseFilter, 'Phase 2');

      final storageService2 = StorageService(prefs);
      final loaded = storageService2.getString(StorageService.keyPhaseFilter);
      expect(loaded, equals('Phase 2'));
    });

    test('should return null when no phase saved', () {
      final loaded = storageService.getString(StorageService.keyPhaseFilter);
      expect(loaded, isNull);
    });

    test('should clear saved phase', () async {
      await storageService.setString(StorageService.keyPhaseFilter, 'Phase 1');
      await storageService.remove(StorageService.keyPhaseFilter);

      final loaded = storageService.getString(StorageService.keyPhaseFilter);
      expect(loaded, isNull);
    });
  });
}
