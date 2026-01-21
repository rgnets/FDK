import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/core/theme/app_colors.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:rgnets_fdk/features/speed_test/presentation/providers/speed_test_providers.dart';
import 'package:rgnets_fdk/features/speed_test/presentation/widgets/speed_test_popup.dart';

/// Helper class to group test configuration with its results
class SpeedTestWithResults {
  final SpeedTestConfig config;
  final List<SpeedTestResult> results;

  SpeedTestWithResults({
    required this.config,
    required this.results,
  });
}

/// Widget that displays speed test results for a PMS room with a dropdown selector.
///
/// Shows a card with a dropdown to select from available speed test results,
/// grouped by test configuration. Each result displays pass/fail status and metrics.
class RoomSpeedTestSelector extends ConsumerStatefulWidget {
  final int pmsRoomId;
  final String roomName;
  final String? roomType;
  final List<int> apIds;

  const RoomSpeedTestSelector({
    super.key,
    required this.pmsRoomId,
    required this.roomName,
    this.roomType,
    this.apIds = const [],
  });

  @override
  ConsumerState<RoomSpeedTestSelector> createState() =>
      _RoomSpeedTestSelectorState();
}

class _RoomSpeedTestSelectorState extends ConsumerState<RoomSpeedTestSelector> {
  List<SpeedTestWithResults> _speedTests = [];
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _errorMessage;
  SpeedTestResult? _selectedResult;

  @override
  void initState() {
    super.initState();
    _loadSpeedTests();
  }

  Future<void> _loadSpeedTests() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cacheIntegration = ref.read(webSocketCacheIntegrationProvider);

      // Get all speed test results from cache
      final allResults = cacheIntegration.getCachedSpeedTestResults();

      LoggerService.info(
        'Loading speed tests for room ${widget.pmsRoomId}: Found ${allResults.length} total results',
        tag: 'RoomSpeedTestSelector',
      );

      if (allResults.isEmpty) {
        setState(() {
          _speedTests = [];
          _selectedResult = null;
          _isLoading = false;
        });
        return;
      }

      // Filter results by pms_room_id and group by speed_test_id
      final Map<int, List<SpeedTestResult>> resultsByTestId = {};

      for (final result in allResults) {
        // Only include results for this room
        if (result.pmsRoomId != widget.pmsRoomId) continue;

        final speedTestId = result.speedTestId;
        if (speedTestId == null) continue;

        resultsByTestId.putIfAbsent(speedTestId, () => []);
        resultsByTestId[speedTestId]!.add(result);
      }

      LoggerService.info(
        'Filtered results for room ${widget.pmsRoomId}: ${resultsByTestId.length} unique tests',
        tag: 'RoomSpeedTestSelector',
      );

      if (resultsByTestId.isEmpty) {
        setState(() {
          _speedTests = [];
          _selectedResult = null;
          _isLoading = false;
        });
        return;
      }

      // Get speed test configurations
      final configs = cacheIntegration.getCachedSpeedTestConfigs();
      final Map<int, SpeedTestConfig> configsById = {};
      for (final config in configs) {
        if (config.id != null) {
          configsById[config.id!] = config;
        }
      }

      // Build SpeedTestWithResults for each speed_test_id
      final List<SpeedTestWithResults> speedTestsWithResults = [];

      for (final entry in resultsByTestId.entries) {
        final speedTestId = entry.key;
        final results = entry.value;

        // Sort results by timestamp (most recent first)
        results.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        // Get the config
        final config = configsById[speedTestId];
        if (config == null) continue;

        speedTestsWithResults.add(SpeedTestWithResults(
          config: config,
          results: results,
        ));
      }

      // Restore selection if possible
      SpeedTestResult? updatedSelection;
      if (_selectedResult != null) {
        for (final group in speedTestsWithResults) {
          for (final result in group.results) {
            if (result.id == _selectedResult!.id) {
              updatedSelection = result;
              break;
            }
          }
          if (updatedSelection != null) break;
        }
      }

      setState(() {
        _speedTests = speedTestsWithResults;
        if (updatedSelection != null) {
          _selectedResult = updatedSelection;
        } else if (speedTestsWithResults.isNotEmpty &&
            speedTestsWithResults.first.results.isNotEmpty) {
          _selectedResult = speedTestsWithResults.first.results.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      LoggerService.error(
        'Failed to load speed tests: $e',
        tag: 'RoomSpeedTestSelector',
      );
      setState(() {
        _errorMessage = 'Failed to load speed tests: $e';
        _speedTests = [];
        _selectedResult = null;
        _isLoading = false;
      });
    }
  }

  bool _metricMeetsThreshold(double? value, double? minRequired) {
    if (minRequired == null) return true;
    if (value == null) return false;
    return value >= minRequired;
  }

  bool _resultPassesForConfig(SpeedTestResult result, SpeedTestConfig config) {
    final downloadPass =
        _metricMeetsThreshold(result.downloadMbps, config.minDownloadMbps);
    final uploadPass =
        _metricMeetsThreshold(result.uploadMbps, config.minUploadMbps);

    return result.passed || (downloadPass && uploadPass);
  }

  Future<void> _toggleApplicable(SpeedTestResult result) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      // Create updated result with toggled isApplicable
      final updatedResult = result.copyWith(
        isApplicable: !result.isApplicable,
      );

      LoggerService.info(
        'Toggling isApplicable for result ${result.id}: '
        '${result.isApplicable} -> ${!result.isApplicable}',
        tag: 'RoomSpeedTestSelector',
      );

      // Update via provider
      final notifier = ref.read(
        speedTestResultsNotifierProvider(
          speedTestId: result.speedTestId,
        ).notifier,
      );

      final updated = await notifier.updateResult(updatedResult);

      if (updated != null) {
        // Update the cache so _loadSpeedTests sees the new value
        final cacheIntegration = ref.read(webSocketCacheIntegrationProvider);
        cacheIntegration.updateSpeedTestResultInCache(updated);

        // Update the selected result locally
        setState(() {
          _selectedResult = updated;
        });
        // Reload to get fresh data from cache
        await _loadSpeedTests();
      } else {
        LoggerService.error(
          'Failed to update result ${result.id}',
          tag: 'RoomSpeedTestSelector',
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update result'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      LoggerService.error(
        'Error toggling isApplicable: $e',
        tag: 'RoomSpeedTestSelector',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Card(
        margin: const EdgeInsets.all(16),
        color: AppColors.cardDark,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Loading speed tests...',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Card(
        margin: const EdgeInsets.all(16),
        color: AppColors.error.withValues(alpha: 0.15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error, color: AppColors.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_speedTests.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        color: AppColors.cardDark,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No speed test results for this room',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: AppColors.textSecondary),
                tooltip: 'Refresh',
                onPressed: _loadSpeedTests,
              ),
            ],
          ),
        ),
      );
    }

    return _buildUnifiedSpeedTestSelector();
  }

  Widget _buildUnifiedSpeedTestSelector() {
    // Collect all results with their config
    List<Map<String, dynamic>> allResultsWithConfig = [];

    for (final testWithResults in _speedTests) {
      for (final result in testWithResults.results) {
        final bool passed =
            _resultPassesForConfig(result, testWithResults.config);
        allResultsWithConfig.add({
          'result': result,
          'config': testWithResults.config,
          'passed': passed,
        });
      }
    }

    // Sort: passed first, then by most recent
    allResultsWithConfig.sort((a, b) {
      final bool aPassed = a['passed'] as bool? ?? false;
      final bool bPassed = b['passed'] as bool? ?? false;

      if (aPassed && !bPassed) return -1;
      if (!aPassed && bPassed) return 1;

      final aTime = (a['result'] as SpeedTestResult).timestamp;
      final bTime = (b['result'] as SpeedTestResult).timestamp;
      return bTime.compareTo(aTime);
    });

    final Map<String, dynamic> selectedEntry = (_selectedResult != null)
        ? allResultsWithConfig.firstWhere(
            (item) =>
                (item['result'] as SpeedTestResult).id == _selectedResult!.id,
            orElse: () => allResultsWithConfig.first,
          )
        : allResultsWithConfig.first;

    final currentResult = selectedEntry['result'] as SpeedTestResult;
    final selectedConfig = selectedEntry['config'] as SpeedTestConfig;
    final bool selectedPassed = selectedEntry['passed'] as bool? ??
        _resultPassesForConfig(currentResult, selectedConfig);
    final String resultLabel =
        (currentResult.roomType != null && currentResult.roomType!.isNotEmpty)
            ? currentResult.roomType!
            : 'Result #${currentResult.id?.toString() ?? "-"}';

    return Card(
      margin: const EdgeInsets.all(16),
      color: AppColors.cardDark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.speed, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Speed Test Results',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh, size: 20, color: AppColors.textSecondary),
                  tooltip: 'Refresh',
                  onPressed: _loadSpeedTests,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dropdown button
            OutlinedButton(
              onPressed: () async {
                final selected =
                    await _showAllResultsModal(allResultsWithConfig);
                if (selected != null) {
                  setState(() {
                    _selectedResult = selected;
                  });
                }
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                side: BorderSide(color: AppColors.gray600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Result (${allResultsWithConfig.length} total)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          resultLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    !currentResult.isApplicable
                        ? Icons.remove_circle_outline
                        : (selectedPassed ? Icons.check_circle : Icons.cancel),
                    size: 24,
                    color: !currentResult.isApplicable
                        ? AppColors.textSecondary
                        : (selectedPassed ? AppColors.success : AppColors.error),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _buildResultDetails(currentResult, selectedConfig),

            // Run test button (hidden when result is not applicable)
            if (currentResult.isApplicable) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    int? testedViaAccessPointId =
                        currentResult.testedViaAccessPointId;
                    if (testedViaAccessPointId == null &&
                        widget.apIds.isNotEmpty) {
                      testedViaAccessPointId = widget.apIds.first;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => SpeedTestPopup(
                        cachedTest: selectedConfig,
                        existingResult: currentResult,
                        onCompleted: () {
                          _loadSpeedTests();
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Run Test'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _capitalizeEachWord(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String? _getSpeedTestIcon(String testName) {
    final lowerName = testName.toLowerCase();

    if (lowerName.contains('coverage')) {
      return 'assets/speed_test_indicator_img/coverage.png';
    } else if (lowerName.contains('ont')) {
      return 'assets/speed_test_indicator_img/validation_ont.png';
    } else if (lowerName.contains('access point') || lowerName.contains('ap')) {
      return 'assets/speed_test_indicator_img/validation_ap.png';
    }

    return null;
  }

  Future<SpeedTestResult?> _showAllResultsModal(
      List<Map<String, dynamic>> allResults) async {
    // Group results by speed test config
    Map<int, List<Map<String, dynamic>>> groupedResults = {};
    for (final item in allResults) {
      final config = item['config'] as SpeedTestConfig;
      if (config.id == null) continue;
      groupedResults.putIfAbsent(config.id!, () => []);
      groupedResults[config.id!]!.add(item);
    }

    // Build list of widgets with headers
    List<Widget> listItems = [];

    groupedResults.forEach((speedTestId, items) {
      final config = items.first['config'] as SpeedTestConfig;
      final testName = config.name ?? 'Speed Test #$speedTestId';
      final iconPath = _getSpeedTestIcon(testName);

      // Section header
      listItems.add(
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              iconPath != null
                  ? Image.asset(
                      iconPath,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.speed,
                            size: 36, color: AppColors.textSecondary);
                      },
                    )
                  : Icon(Icons.speed, size: 36, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _capitalizeEachWord(testName),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (config.minDownloadMbps != null ||
                        config.minUploadMbps != null)
                      Text(
                        'Min: ${config.minDownloadMbps?.toStringAsFixed(0) ?? "?"} Mbps down / ${config.minUploadMbps?.toStringAsFixed(0) ?? "?"} Mbps up',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      // Result items
      for (final item in items) {
        final result = item['result'] as SpeedTestResult;
        final isSelected = result.id == _selectedResult?.id;
        final bool passed =
            item['passed'] as bool? ?? _resultPassesForConfig(result, config);

        String displayText = '';
        if (result.roomType != null && result.roomType!.isNotEmpty) {
          displayText = result.roomType!;
        } else {
          displayText = config.name ?? 'Result #${result.id}';
        }

        listItems.add(
          ListTile(
            selected: isSelected,
            selectedTileColor: AppColors.primary.withValues(alpha: 0.15),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !result.isApplicable
                    ? AppColors.gray500
                    : (passed ? AppColors.success : AppColors.error),
              ),
            ),
            title: Text(
              displayText,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: !result.isApplicable
                ? Text(
                    'Not Applicable',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : (result.downloadMbps != null
                    ? Text(
                        '↓ ${result.downloadMbps!.toStringAsFixed(1)} Mbps  ↑ ${result.uploadMbps?.toStringAsFixed(1) ?? "N/A"} Mbps',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : null),
            trailing: Icon(
              !result.isApplicable
                  ? Icons.remove_circle_outline
                  : (passed ? Icons.check_circle : Icons.cancel),
              size: 28,
              color: !result.isApplicable
                  ? AppColors.textSecondary
                  : (passed ? AppColors.success : AppColors.error),
            ),
            onTap: () {
              Navigator.pop(context, result);
            },
          ),
        );
      }

      // Separator
      listItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Divider(
            height: 1,
            thickness: 1.5,
            color: AppColors.gray700,
          ),
        ),
      );
    });

    return showModalBottomSheet<SpeedTestResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.gray600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.history, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Select Result (${allResults.length} total)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: AppColors.gray700),
                  // Results list
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: listItems.length,
                      itemBuilder: (context, index) => listItems[index],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResultDetails(SpeedTestResult result, SpeedTestConfig config) {
    final downloadPassed =
        _metricMeetsThreshold(result.downloadMbps, config.minDownloadMbps);
    final uploadPassed =
        _metricMeetsThreshold(result.uploadMbps, config.minUploadMbps);
    final bool passed = _resultPassesForConfig(result, config);

    final bgColor = !result.isApplicable
        ? AppColors.gray800
        : (passed ? AppColors.success.withValues(alpha: 0.15) : AppColors.error.withValues(alpha: 0.15));
    final borderColor = !result.isApplicable
        ? AppColors.gray700
        : (passed ? AppColors.success.withValues(alpha: 0.4) : AppColors.error.withValues(alpha: 0.4));
    final statusColor = !result.isApplicable
        ? AppColors.textSecondary
        : (passed ? AppColors.success : AppColors.error);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    !result.isApplicable
                        ? Icons.remove_circle_outline
                        : (passed ? Icons.check_circle : Icons.cancel),
                    color: statusColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    !result.isApplicable
                        ? 'Not Applicable'
                        : (passed ? 'Passed' : 'Failed'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              if (result.completedAt != null)
                Text(
                  _formatTimeSince(result.completedAt!),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Metrics row
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Download',
                  result.downloadMbps != null
                      ? '${result.downloadMbps!.toStringAsFixed(1)} Mbps'
                      : 'N/A',
                  Icons.download,
                  passed: result.isApplicable ? downloadPassed : null,
                  minRequired: config.minDownloadMbps,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetric(
                  'Upload',
                  result.uploadMbps != null
                      ? '${result.uploadMbps!.toStringAsFixed(1)} Mbps'
                      : 'N/A',
                  Icons.upload,
                  passed: result.isApplicable ? uploadPassed : null,
                  minRequired: config.minUploadMbps,
                ),
              ),
            ],
          ),

          // Latency row
          if (result.rtt != null || result.jitter != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (result.rtt != null)
                  Expanded(
                    child: _buildMetric(
                      'Latency',
                      '${result.rtt!.toStringAsFixed(1)} ms',
                      Icons.timer,
                    ),
                  ),
                if (result.rtt != null && result.jitter != null)
                  const SizedBox(width: 12),
                if (result.jitter != null)
                  Expanded(
                    child: _buildMetric(
                      'Jitter',
                      '${result.jitter!.toStringAsFixed(1)} ms',
                      Icons.show_chart,
                    ),
                  ),
              ],
            ),
          ],

          // Server info
          if (config.target != null) ...[
            const SizedBox(height: 8),
            Text(
              'Server: ${config.target}:${config.port ?? 5201}',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],

          // Toggle applicable button
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: _isUpdating ? null : () => _toggleApplicable(result),
                icon: _isUpdating
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : Icon(
                        result.isApplicable
                            ? Icons.block
                            : Icons.check_circle_outline,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                label: Text(
                  result.isApplicable
                      ? 'Mark as Not Applicable'
                      : 'Mark as Applicable',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: BorderSide(color: AppColors.gray600),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon,
      {bool? passed, double? minRequired}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
            if (passed != null) ...[
              const SizedBox(width: 4),
              Icon(
                passed ? Icons.check_circle : Icons.cancel,
                size: 14,
                color: passed ? AppColors.success : AppColors.error,
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (minRequired != null)
          Text(
            'Min: ${minRequired.toStringAsFixed(0)} Mbps',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  String _formatTimeSince(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
