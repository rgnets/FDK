import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/services/inventory_reseed_service.dart';

/// Status of a single resource row in the startup loader checklist.
enum SeedItemStatus { pending, loading, done, failed }

/// One row in the startup loader checklist (e.g. "Switches"). Mirrors a REST
/// reseed resource type, with a human label for display.
class SeedItem {
  const SeedItem({
    required this.resourceType,
    required this.label,
    this.status = SeedItemStatus.pending,
    this.count = 0,
  });

  final String resourceType;
  final String label;
  final SeedItemStatus status;

  /// Item count once [status] is [SeedItemStatus.done].
  final int count;

  SeedItem copyWith({SeedItemStatus? status, int? count}) => SeedItem(
        resourceType: resourceType,
        label: label,
        status: status ?? this.status,
        count: count ?? this.count,
      );
}

/// Canonical resource types shown in the loader, in display order. AP first
/// (the UI binds device counts off it), then switches/ONTs/WLAN, rooms last —
/// matching [InventoryRestSeederService]'s seed set.
const Map<String, String> _seedItemLabels = {
  'access_points': 'Access Points',
  'switch_devices': 'Switches',
  'media_converters': 'ONTs',
  'wlan_devices': 'WLAN Controllers',
  'pms_rooms': 'Rooms',
};

/// Tracks the per-resource progress of the startup inventory seed so the
/// [InitializationOverlay] can render a live checklist that gates app access
/// until the seed finishes.
class SeedChecklistNotifier extends Notifier<List<SeedItem>> {
  @override
  List<SeedItem> build() => _pendingItems();

  static List<SeedItem> _pendingItems() => [
        for (final entry in _seedItemLabels.entries)
          SeedItem(resourceType: entry.key, label: entry.value),
      ];

  /// Reset all rows to pending. Call when (re)starting initialization.
  void reset() => state = _pendingItems();

  /// Mark every row as actively loading (call when the seed begins, so the
  /// checklist shows spinners even before the first resource resolves).
  void startLoading() {
    state = [
      for (final item in state) item.copyWith(status: SeedItemStatus.loading),
    ];
  }

  /// Apply a live progress event from [InventoryReseedService.progress].
  void apply(ReseedProgress event) {
    final next = switch (event.status) {
      ReseedResourceStatus.done => SeedItemStatus.done,
      ReseedResourceStatus.failed => SeedItemStatus.failed,
    };
    state = [
      for (final item in state)
        if (item.resourceType == event.resourceType)
          // A late `failed` must not clobber a row that already loaded.
          if (item.status == SeedItemStatus.done)
            item
          else
            item.copyWith(status: next, count: event.count)
        else
          item,
    ];
  }
}

final seedChecklistProvider =
    NotifierProvider<SeedChecklistNotifier, List<SeedItem>>(
  SeedChecklistNotifier.new,
);
