import 'package:flutter/material.dart';
import 'package:rgnets_fdk/core/widgets/skeleton/skeleton_base.dart';

/// Skeleton placeholder for device detail screen
class DeviceDetailSkeleton extends StatelessWidget {
  const DeviceDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with image
            const _DeviceHeaderSkeleton(),
            const SizedBox(height: 24),
            // Info section
            const _SectionSkeleton(titleWidth: 100, rows: 4),
            const SizedBox(height: 24),
            // Status section
            const _SectionSkeleton(titleWidth: 80, rows: 3),
            const SizedBox(height: 24),
            // Actions
            const _ActionButtonsSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _DeviceHeaderSkeleton extends StatelessWidget {
  const _DeviceHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Image placeholder
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.grey[700],
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 180, height: 24),
                SizedBox(height: 8),
                SkeletonBox(width: 140, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton({required this.titleWidth, required this.rows});
  final double titleWidth;
  final int rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: titleWidth, height: 18),
            const SizedBox(height: 16),
            ...List.generate(
              rows,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonBox(width: 80 + (index * 10), height: 14),
                    const SkeletonBox(width: 100, height: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButtonsSkeleton extends StatelessWidget {
  const _ActionButtonsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: SkeletonBox(height: 48, borderRadius: 8)),
        SizedBox(width: 12),
        Expanded(child: SkeletonBox(height: 48, borderRadius: 8)),
      ],
    );
  }
}
