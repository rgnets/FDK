import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:rgnets_fdk/features/issues/domain/entities/health_counts.dart';
import 'package:rgnets_fdk/features/issues/presentation/providers/health_notices_provider.dart';

/// A circular gauge widget that displays the overall health score
class HealthGauge extends ConsumerWidget {
  const HealthGauge({
    this.size = 120,
    this.strokeWidth = 10,
    this.onTap,
    super.key,
  });

  final double size;
  final double strokeWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(aggregateHealthCountsProvider);
    final score = counts.healthScore;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: 1,
                strokeWidth: strokeWidth,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.grey.withValues(alpha: 0.2),
                ),
              ),
            ),
            // Progress circle
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: strokeWidth,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _colorForScore(score),
                ),
              ),
            ),
            // Center content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${score.toInt()}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _colorForScore(score),
                  ),
                ),
                Text(
                  'Health',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                if (counts.hasAny) ...[
                  const SizedBox(height: 4),
                  _buildIssueSummary(context, counts),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssueSummary(BuildContext context, HealthCounts counts) {
    final parts = <Widget>[];

    if (counts.fatal > 0) {
      parts.add(_buildCountBadge(context, counts.fatal, Colors.red));
    }
    if (counts.critical > 0) {
      parts.add(_buildCountBadge(context, counts.critical, Colors.orange));
    }
    if (counts.warning > 0) {
      parts.add(_buildCountBadge(context, counts.warning, Colors.yellow));
    }
    if (counts.notice > 0) {
      parts.add(_buildCountBadge(context, counts.notice, Colors.blue));
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: parts,
    );
  }

  Widget _buildCountBadge(BuildContext context, int count, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _colorForScore(double score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}

/// A compact version of the health gauge for use in app bars or smaller spaces
class CompactHealthGauge extends ConsumerWidget {
  const CompactHealthGauge({
    this.size = 36,
    this.onTap,
    super.key,
  });

  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(aggregateHealthCountsProvider);
    final score = counts.healthScore;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: score / 100,
                strokeWidth: 3,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _colorForScore(score),
                ),
              ),
            ),
            Text(
              '${score.toInt()}',
              style: TextStyle(
                fontSize: size * 0.3,
                fontWeight: FontWeight.bold,
                color: _colorForScore(score),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForScore(double score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }
}
