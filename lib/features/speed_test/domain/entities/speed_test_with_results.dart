import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';

part 'speed_test_with_results.freezed.dart';

/// A joined entity containing a speed test configuration with its associated results.
/// Note: This is a view model created in code, not from JSON.
@Freezed(toJson: false, fromJson: false)
class SpeedTestWithResults with _$SpeedTestWithResults {
  const factory SpeedTestWithResults({
    required SpeedTestConfig config,
    @Default([]) List<SpeedTestResult> results,
  }) = _SpeedTestWithResults;

  const SpeedTestWithResults._();

  /// Get the most recent result
  SpeedTestResult? get latestResult {
    if (results.isEmpty) return null;
    return results.reduce((a, b) {
      final aTime = a.completedAt ?? a.createdAt ?? DateTime(1970);
      final bTime = b.completedAt ?? b.createdAt ?? DateTime(1970);
      return aTime.isAfter(bTime) ? a : b;
    });
  }

  /// Get the number of results
  int get resultCount => results.length;

  /// Check if there are any results
  bool get hasResults => results.isNotEmpty;

  /// Get passing results only
  List<SpeedTestResult> get passingResults =>
      results.where((r) => r.passed).toList();

  /// Get failing results only
  List<SpeedTestResult> get failingResults =>
      results.where((r) => !r.passed).toList();

  /// Calculate pass rate as percentage
  double get passRate {
    if (results.isEmpty) return 0.0;
    return (passingResults.length / results.length) * 100;
  }

  /// Check if the test is currently passing (based on latest result)
  bool get isCurrentlyPassing => latestResult?.passed ?? false;

  /// Check if meets minimum download requirement
  bool get meetsDownloadRequirement {
    final latest = latestResult;
    if (latest?.downloadMbps == null || config.minDownloadMbps == null) {
      return true;
    }
    return latest!.downloadMbps! >= config.minDownloadMbps!;
  }

  /// Check if meets minimum upload requirement
  bool get meetsUploadRequirement {
    final latest = latestResult;
    if (latest?.uploadMbps == null || config.minUploadMbps == null) {
      return true;
    }
    return latest!.uploadMbps! >= config.minUploadMbps!;
  }
}
