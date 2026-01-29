import 'package:flutter/material.dart';
import 'package:rgnets_fdk/core/widgets/skeleton/skeleton_base.dart';

/// Skeleton placeholder matching RoomCard layout
class RoomCardSkeleton extends StatelessWidget {
  const RoomCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SkeletonCircle(size: 40), // Room icon
                  const SizedBox(width: 12),
                  const Expanded(
                    child: SkeletonBox(width: 100, height: 18), // Room name
                  ),
                  const SkeletonBox(
                    width: 60,
                    height: 24,
                    borderRadius: 12,
                  ), // Badge
                ],
              ),
              const SizedBox(height: 12),
              const SkeletonBox(height: 12), // Device count
            ],
          ),
        ),
      ),
    );
  }
}

/// List of room card skeletons
class RoomListSkeleton extends StatelessWidget {
  const RoomListSkeleton({super.key, this.itemCount = 8});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: RoomCardSkeleton(),
      ),
    );
  }
}
