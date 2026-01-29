import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rgnets_fdk/features/devices/domain/entities/room.dart';
import 'package:rgnets_fdk/features/issues/domain/entities/health_notice.dart';
import 'package:rgnets_fdk/features/issues/presentation/providers/health_notices_provider.dart';
import 'package:rgnets_fdk/features/issues/presentation/widgets/health_notice_card.dart';
import 'package:rgnets_fdk/features/rooms/presentation/providers/rooms_riverpod_provider.dart';

/// Screen for viewing and filtering health notices
class HealthNoticesScreen extends ConsumerStatefulWidget {
  const HealthNoticesScreen({super.key});

  @override
  ConsumerState<HealthNoticesScreen> createState() => _HealthNoticesScreenState();
}

class _HealthNoticesScreenState extends ConsumerState<HealthNoticesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notices = ref.watch(filteredHealthNoticesProvider);
    final allNotices = ref.watch(healthNoticesListProvider);
    final filter = ref.watch(healthNoticeFilterStateProvider);
    final roomsAsync = ref.watch(roomsNotifierProvider);
    final rooms = roomsAsync.valueOrNull ?? [];

    // Calculate severity counts from actual notices (not hn_counts which may be stale)
    final fatalCount = allNotices.countBySeverity(HealthNoticeSeverity.fatal);
    final criticalCount = allNotices.countBySeverity(HealthNoticeSeverity.critical);
    final warningCount = allNotices.countBySeverity(HealthNoticeSeverity.warning);
    final noticeCount = allNotices.countBySeverity(HealthNoticeSeverity.notice);

    // Calculate device type counts
    final apCount = allNotices.where((n) => n.deviceType == 'access_point').length;
    final switchCount = allNotices.where((n) => n.deviceType == 'switch').length;
    final ontCount = allNotices.where((n) => n.deviceType == 'ont').length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Health Notices (${allNotices.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(context),
            tooltip: 'Sort',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notices...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(healthNoticeFilterStateProvider.notifier)
                              .updateSearchQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                ref
                    .read(healthNoticeFilterStateProvider.notifier)
                    .updateSearchQuery(value);
              },
            ),
          ),

          // Device type filter row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildCompactFilterButton(
                  label: 'All',
                  isSelected: filter.deviceType == DeviceTypeFilter.all,
                  color: Theme.of(context).colorScheme.primary,
                  count: allNotices.length,
                  onPressed: () => ref.read(healthNoticeFilterStateProvider.notifier)
                      .setDeviceType(DeviceTypeFilter.all),
                ),
                _buildCompactFilterButton(
                  label: 'AP',
                  isSelected: filter.deviceType == DeviceTypeFilter.accessPoint,
                  color: Colors.blue,
                  count: apCount,
                  onPressed: () => ref.read(healthNoticeFilterStateProvider.notifier)
                      .setDeviceType(DeviceTypeFilter.accessPoint),
                ),
                _buildCompactFilterButton(
                  label: 'Switch',
                  isSelected: filter.deviceType == DeviceTypeFilter.networkSwitch,
                  color: Colors.green,
                  count: switchCount,
                  onPressed: () => ref.read(healthNoticeFilterStateProvider.notifier)
                      .setDeviceType(DeviceTypeFilter.networkSwitch),
                ),
                _buildCompactFilterButton(
                  label: 'ONT',
                  isSelected: filter.deviceType == DeviceTypeFilter.ont,
                  color: Colors.orange,
                  count: ontCount,
                  onPressed: () => ref.read(healthNoticeFilterStateProvider.notifier)
                      .setDeviceType(DeviceTypeFilter.ont),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Severity filter row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildCompactFilterButton(
                  label: 'Fatal',
                  isSelected: filter.severities.contains(HealthNoticeSeverity.fatal),
                  color: Colors.red,
                  count: fatalCount,
                  onPressed: () => ref.read(healthNoticeFilterStateProvider.notifier)
                      .toggleSeverity(HealthNoticeSeverity.fatal),
                ),
                _buildCompactFilterButton(
                  label: 'Critical',
                  isSelected: filter.severities.contains(HealthNoticeSeverity.critical),
                  color: Colors.deepOrange,
                  count: criticalCount,
                  onPressed: () => ref.read(healthNoticeFilterStateProvider.notifier)
                      .toggleSeverity(HealthNoticeSeverity.critical),
                ),
                _buildCompactFilterButton(
                  label: 'Warning',
                  isSelected: filter.severities.contains(HealthNoticeSeverity.warning),
                  color: Colors.amber,
                  count: warningCount,
                  onPressed: () => ref.read(healthNoticeFilterStateProvider.notifier)
                      .toggleSeverity(HealthNoticeSeverity.warning),
                ),
                _buildCompactFilterButton(
                  label: 'Notice',
                  isSelected: filter.severities.contains(HealthNoticeSeverity.notice),
                  color: Colors.lightBlue,
                  count: noticeCount,
                  onPressed: () => ref.read(healthNoticeFilterStateProvider.notifier)
                      .toggleSeverity(HealthNoticeSeverity.notice),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Notices list
          Expanded(
            child: notices.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: notices.length,
                    itemBuilder: (context, index) {
                      final notice = notices[index];
                      final hasNavigationTarget = _hasNavigationTarget(notice, rooms, roomsAsync.isLoading);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: HealthNoticeCard(
                          notice: notice,
                          onTap: hasNavigationTarget
                              ? () => _handleNoticeTap(context, notice, rooms, roomsAsync.isLoading)
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// Builds a compact filter button that fits within Expanded constraints
  Widget _buildCompactFilterButton({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onPressed,
    int? count,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: TextButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              isSelected ? color.withValues(alpha: 0.3) : Colors.grey[800],
            ),
            foregroundColor: WidgetStateProperty.all(
              isSelected ? Colors.white : Colors.grey[400],
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? color : Colors.grey[700]!,
                  width: 1,
                ),
              ),
            ),
            padding: WidgetStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            ),
            minimumSize: WidgetStateProperty.all(const Size(0, 32)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              if (count != null && count > 0) ...[
                const SizedBox(width: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white24 : color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.green.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No health notices',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'All systems are healthy',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white54,
                ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context) {
    final filter = ref.read(healthNoticeFilterStateProvider);

    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.warning,
                color: filter.sortBy == HealthNoticeSortBy.severity
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: const Text('Sort by Severity'),
              trailing: filter.sortBy == HealthNoticeSortBy.severity
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                ref
                    .read(healthNoticeFilterStateProvider.notifier)
                    .updateSortBy(HealthNoticeSortBy.severity);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.access_time,
                color: filter.sortBy == HealthNoticeSortBy.time
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: const Text('Sort by Time'),
              trailing: filter.sortBy == HealthNoticeSortBy.time
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                ref
                    .read(healthNoticeFilterStateProvider.notifier)
                    .updateSortBy(HealthNoticeSortBy.time);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.devices,
                color: filter.sortBy == HealthNoticeSortBy.device
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: const Text('Sort by Device'),
              trailing: filter.sortBy == HealthNoticeSortBy.device
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                ref
                    .read(healthNoticeFilterStateProvider.notifier)
                    .updateSortBy(HealthNoticeSortBy.device);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Checks if a health notice has a valid navigation target
  bool _hasNavigationTarget(HealthNotice notice, List<Room> rooms, bool roomsLoading) {
    // Has device ID - can navigate
    final deviceId = notice.deviceId?.trim();
    if (deviceId != null && deviceId.isNotEmpty) {
      return true;
    }

    // Has room name and rooms are loaded - check if resolvable
    if (notice.roomName != null && notice.roomName!.trim().isNotEmpty) {
      // If rooms are still loading, assume we might have a target
      if (roomsLoading) {
        return true;
      }
      // Check if room can be resolved
      return _resolveRoomId(notice.roomName, rooms) != null;
    }

    return false;
  }

  /// Handles tap on a health notice card - navigates to device or room detail
  void _handleNoticeTap(BuildContext context, HealthNotice notice, List<Room> rooms, bool roomsLoading) {
    // Priority 1: Navigate to device if deviceId is available
    final deviceId = notice.deviceId?.trim();
    if (deviceId != null && deviceId.isNotEmpty) {
      context.push('/devices/${Uri.encodeComponent(deviceId)}');
      return;
    }

    // Priority 2: Fallback to room navigation if roomName can be resolved
    if (roomsLoading) {
      // Rooms still loading - show appropriate message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading room data...'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final roomId = _resolveRoomId(notice.roomName, rooms);
    if (roomId != null) {
      context.push('/rooms/$roomId');
      return;
    }

    // No navigation target available (shouldn't reach here if _hasNavigationTarget is accurate)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to find device or room'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Resolves a room name from health notice to a room ID
  /// Uses normalized string matching to handle format differences
  int? _resolveRoomId(String? roomName, List<Room> rooms) {
    if (roomName == null || roomName.trim().isEmpty) {
      return null;
    }

    final normalizedName = roomName.trim().toLowerCase();
    final digitPattern = RegExp('[^0-9]');

    for (final room in rooms) {
      // Try exact match on room name
      if (room.name.toLowerCase() == normalizedName) {
        return room.id;
      }

      // Try match on room number field
      if (room.number != null && room.number!.toLowerCase() == normalizedName) {
        return room.id;
      }

      // Try match on extracted number (handles "(Building) 101" format)
      final extractedNum = room.extractedNumber;
      if (extractedNum != null && extractedNum.toLowerCase() == normalizedName) {
        return room.id;
      }

      // Try extracting digits and matching
      final nameDigits = normalizedName.replaceAll(digitPattern, '');
      if (nameDigits.isNotEmpty) {
        if (room.number == nameDigits) {
          return room.id;
        }
        // Match against room name containing the same digits
        final roomDigits = room.name.replaceAll(digitPattern, '');
        if (roomDigits == nameDigits) {
          return room.id;
        }
      }
    }

    return null; // No match found
  }
}
