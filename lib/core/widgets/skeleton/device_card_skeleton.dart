import 'package:flutter/material.dart';
import 'package:rgnets_fdk/core/widgets/skeleton/skeleton_base.dart';

/// Skeleton placeholder matching DeviceCard layout
class DeviceCardSkeleton extends StatelessWidget {
  const DeviceCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Device icon placeholder
              const SkeletonCircle(size: 48),
              const SizedBox(width: 16),
              // Text content
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(width: 120, height: 16), // Device name
                    SizedBox(height: 8),
                    SkeletonBox(width: 180, height: 12), // MAC address
                    SizedBox(height: 4),
                    SkeletonBox(width: 80, height: 12), // Status
                  ],
                ),
              ),
              // Status indicator
              const SkeletonCircle(size: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// List of device card skeletons
class DeviceListSkeleton extends StatelessWidget {
  const DeviceListSkeleton({super.key, this.itemCount = 6});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: DeviceCardSkeleton(),
      ),
    );
  }
}
