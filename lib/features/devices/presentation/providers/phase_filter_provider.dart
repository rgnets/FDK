import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/features/devices/domain/entities/device.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'phase_filter_provider.g.dart';

/// State for deployment phase filtering
class PhaseFilterState {
  const PhaseFilterState({
    this.selectedPhase = allPhases,
  });

  /// Special value indicating no filter (show all phases)
  static const String allPhases = 'All Phases';

  /// Special value for devices without an assigned phase
  static const String unassigned = 'Unassigned';

  /// Currently selected phase filter
  final String selectedPhase;

  /// Returns true if actively filtering (not showing all)
  bool get isFiltering => selectedPhase != allPhases;

  /// Check if a device's phase matches the current filter
  bool matchesFilter(String? devicePhase) {
    if (!isFiltering) {
      return true; // Show all when not filtering
    }

    // Handle null/empty phases as "Unassigned"
    if (devicePhase == null || devicePhase.isEmpty) {
      return selectedPhase == unassigned;
    }

    return devicePhase == selectedPhase;
  }

  /// Create a copy with updated values
  PhaseFilterState copyWith({
    String? selectedPhase,
  }) {
    return PhaseFilterState(
      selectedPhase: selectedPhase ?? this.selectedPhase,
    );
  }

  /// Extract unique phases from a list of devices
  /// Returns sorted list with "All Phases" as first option
  static List<String> getUniquePhasesFromDevices(List<Device> devices) {
    final Set<String> phases = {};

    for (final device in devices) {
      final phase = device.metadata?['phase'] as String?;
      if (phase != null && phase.isNotEmpty) {
        phases.add(phase);
      } else {
        phases.add(unassigned);
      }
    }

    // Sort and prepend "All Phases"
    final phaseList = phases.toList()..sort();
    return [allPhases, ...phaseList];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhaseFilterState &&
          runtimeType == other.runtimeType &&
          selectedPhase == other.selectedPhase;

  @override
  int get hashCode => selectedPhase.hashCode;
}

/// Notifier for managing phase filter state with persistence
@riverpod
class PhaseFilterNotifier extends _$PhaseFilterNotifier {
  StorageService? _storageService;

  @override
  PhaseFilterState build() {
    // Try to get storage service from provider
    try {
      _storageService = ref.watch(storageServiceProvider);
    } on Object {
      // Storage service not available yet (e.g., during tests without override)
      _storageService = null;
    }

    // Load saved phase synchronously from storage
    final savedPhase = _storageService?.phaseFilter;
    if (savedPhase != null && savedPhase.isNotEmpty) {
      return PhaseFilterState(selectedPhase: savedPhase);
    }
    return const PhaseFilterState();
  }

  /// Set the selected phase filter
  void setPhase(String phase) {
    if (state.selectedPhase == phase) {
      return;
    }
    state = state.copyWith(selectedPhase: phase);
    _savePhase(phase);
  }

  /// Clear the filter (set to All Phases)
  void clear() {
    setPhase(PhaseFilterState.allPhases);
  }

  /// Save current phase to storage
  Future<void> _savePhase(String phase) async {
    if (_storageService == null) {
      return;
    }
    if (phase == PhaseFilterState.allPhases) {
      // Remove the key when showing all phases
      await _storageService!.clearPhaseFilter();
    } else {
      await _storageService!.setPhaseFilter(phase);
    }
  }
}

/// Provider for available phases based on current devices
@riverpod
List<String> availablePhases(AvailablePhasesRef ref, List<Device> devices) {
  return PhaseFilterState.getUniquePhasesFromDevices(devices);
}
