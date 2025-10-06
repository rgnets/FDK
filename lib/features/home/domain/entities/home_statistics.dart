import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_statistics.freezed.dart';

/// Domain entity for home screen statistics
@freezed
class HomeStatistics with _$HomeStatistics {
  const factory HomeStatistics({
    required int totalDevices,
    required int onlineDevices,
    required int offlineDevices,
    required String offlineBreakdown,
    required int missingDocs,
    required String missingDocsText,
  }) = _HomeStatistics;
  
  const HomeStatistics._();
  
  /// Create loading state
  factory HomeStatistics.loading() => const HomeStatistics(
    totalDevices: 0,
    onlineDevices: 0,
    offlineDevices: 0,
    offlineBreakdown: 'Loading...',
    missingDocs: 0,
    missingDocsText: 'Loading...',
  );
  
  /// Create error state
  factory HomeStatistics.error(String message) => HomeStatistics(
    totalDevices: 0,
    onlineDevices: 0,
    offlineDevices: 0,
    offlineBreakdown: message,
    missingDocs: 0,
    missingDocsText: message,
  );
}