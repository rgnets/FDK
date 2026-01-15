import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rgnets_fdk/features/issues/domain/entities/health_notice.dart';
import 'package:rgnets_fdk/features/issues/presentation/providers/health_notices_provider.dart';
import 'package:rgnets_fdk/features/issues/presentation/widgets/health_notice_card.dart';

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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: HealthNoticeCard(notice: notices[index]),
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
}
