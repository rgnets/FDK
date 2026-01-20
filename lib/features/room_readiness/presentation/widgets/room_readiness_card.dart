import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/features/room_readiness/presentation/providers/room_readiness_provider.dart';

/// Dashboard card widget showing room readiness summary.
class RoomReadinessCard extends ConsumerWidget {
  const RoomReadinessCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(roomReadinessSummaryProvider);
    final nonEmptyTotal = summary.totalRooms - summary.emptyRooms;

    return InkWell(
      onTap: () => context.push('/room-readiness'),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: const DecorationImage(
            image: AssetImage('assets/images/ui_elements/hud_box.png'),
            fit: BoxFit.fill,
            opacity: 0.15,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.meeting_room,
                  size: 20,
                  color: AppColors.info,
                ),
                const SizedBox(width: 8),
                Text(
                  'Room Readiness',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.grey[400],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status counts row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                  context,
                  icon: Icons.check_circle,
                  label: 'Ready',
                  count: summary.readyRooms,
                  color: AppColors.success,
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.grey[700],
                ),
                _buildStatusItem(
                  context,
                  icon: Icons.warning,
                  label: 'Partial',
                  count: summary.partialRooms,
                  color: AppColors.warning,
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.grey[700],
                ),
                _buildStatusItem(
                  context,
                  icon: Icons.error,
                  label: 'Down',
                  count: summary.downRooms,
                  color: AppColors.error,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: nonEmptyTotal > 0
                        ? summary.overallReadinessPercentage / 100
                        : 0,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(summary.overallReadinessPercentage),
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${summary.overallReadinessPercentage.toStringAsFixed(1)}% ready',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[400],
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return AppColors.success;
    if (percentage >= 60) return AppColors.warning;
    return AppColors.error;
  }
}
