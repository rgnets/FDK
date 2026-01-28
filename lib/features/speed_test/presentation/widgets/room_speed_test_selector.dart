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

/// Widget that displays individual speed test cards for a PMS room.
///
/// Shows a card for each unique speed_test_id that has results for this room.
/// Each card displays the test configuration and allows running the test.
class RoomSpeedTestSelector extends ConsumerStatefulWidget {
  final int pmsRoomId;
  final String roomName;
  final String? roomType;
  final List<int> apIds; // List of AP IDs in this room

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
  String? _errorMessage;
  SpeedTestResult? _selectedResult;

  @override
  void initState() {
    super.initState();
    _loadSpeedTests();
  }

  Future<void> _loadSpeedTests() async {
    if (!mounted) return;
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      LoggerService.info(
        'RoomSpeedTestSelector: Loading for pmsRoomId=${widget.pmsRoomId}, '
        'roomName="${widget.roomName}", apIds=${widget.apIds}',
        tag: 'RoomSpeedTestSelector',
      );

      final cacheIntegration = ref.read(webSocketCacheIntegrationProvider);

      // Get all speed test results from cache
      final allResults = cacheIntegration.getCachedSpeedTestResults();

      LoggerService.info(
        'RoomSpeedTestSelector: Found ${allResults.length} total cached results',
        tag: 'RoomSpeedTestSelector',
      );

      // Log first few results for debugging
      if (allResults.isNotEmpty) {
        for (var i = 0; i < allResults.length && i < 5; i++) {
          final r = allResults[i];
          LoggerService.info(
            'RoomSpeedTestSelector: Result[$i]: id=${r.id}, speedTestId=${r.speedTestId}, '
            'pmsRoomId=${r.pmsRoomId}, accessPointId=${r.accessPointId}, '
            'testedViaAccessPointId=${r.testedViaAccessPointId}',
            tag: 'RoomSpeedTestSelector',
          );
        }
      }

      if (allResults.isEmpty) {
        LoggerService.warning(
          'No speed test results available for room ${widget.pmsRoomId}',
          tag: 'RoomSpeedTestSelector',
        );
        setState(() {
          _speedTests = [];
          _selectedResult = null;
          _isLoading = false;
        });
        return;
      }

      // Filter results by pms_room_id OR by AP IDs in this room, then group by speed_test_id
      final Map<int, List<SpeedTestResult>> resultsByTestId = {};

      // Convert apIds to a Set for faster lookup
      final apIdSet = widget.apIds.toSet();

      LoggerService.info(
        'RoomSpeedTestSelector: Filtering with pmsRoomId=${widget.pmsRoomId}, apIdSet=$apIdSet',
        tag: 'RoomSpeedTestSelector',
      );

      var matchedCount = 0;
      var skippedNoSpeedTestId = 0;
      var skippedNoMatch = 0;

      for (final result in allResults) {
        if (result.speedTestId == null) {
          skippedNoSpeedTestId++;
          continue;
        }

        // Check if this result belongs to this room:
        // 1. Direct pms_room_id match
        // 2. accessPointId matches one of the APs in this room
        // 3. testedViaAccessPointId matches one of the APs in this room
        final matchesPmsRoom = result.pmsRoomId == widget.pmsRoomId;
        final matchesAccessPoint = result.accessPointId != null &&
            apIdSet.contains(result.accessPointId);
        final matchesTestedViaAp = result.testedViaAccessPointId != null &&
            apIdSet.contains(result.testedViaAccessPointId);

        if (!matchesPmsRoom && !matchesAccessPoint && !matchesTestedViaAp) {
          skippedNoMatch++;
          continue;
        }

        matchedCount++;
        LoggerService.info(
          'RoomSpeedTestSelector: MATCHED result id=${result.id}, '
          'matchesPmsRoom=$matchesPmsRoom, matchesAccessPoint=$matchesAccessPoint, '
          'matchesTestedViaAp=$matchesTestedViaAp',
          tag: 'RoomSpeedTestSelector',
        );

        // Add to map - group ALL results by speed_test_id for this room
        resultsByTestId.putIfAbsent(result.speedTestId!, () => []);
        resultsByTestId[result.speedTestId!]!.add(result);
      }

      LoggerService.info(
        'RoomSpeedTestSelector: Filter summary - matched=$matchedCount, '
        'skippedNoSpeedTestId=$skippedNoSpeedTestId, skippedNoMatch=$skippedNoMatch, '
        'uniqueTests=${resultsByTestId.length}',
        tag: 'RoomSpeedTestSelector',
      );

      if (resultsByTestId.isEmpty) {
        setState(() {
          _speedTests = [];
          _isLoading = false;
        });
        return;
      }

      // Get speed test configurations from cache
      final configs = cacheIntegration.getCachedSpeedTestConfigs();
      final Map<int, SpeedTestConfig> configsById = {};
      for (final config in configs) {
        if (config.id != null) {
          configsById[config.id!] = config;
        }
      }

      // Build SpeedTestWithResults for EACH speed_test_id in results
      final List<SpeedTestWithResults> speedTestsWithResults = [];

      for (final entry in resultsByTestId.entries) {
        final speedTestId = entry.key;
        final results = entry.value;

        // Try to get the config from speed_tests table
        SpeedTestConfig? config = configsById[speedTestId];

        // If no config found, create a placeholder
        if (config == null) {
          final firstResult = results.first;
          config = SpeedTestConfig(
            id: speedTestId,
            name: 'Speed Test #$speedTestId',
            target: firstResult.destination,
            port: firstResult.port ?? 5201,
            iperfProtocol: firstResult.iperfProtocol ?? 'tcp',
            passing: firstResult.passed,
          );
        }

        speedTestsWithResults.add(SpeedTestWithResults(
          config: config,
          results: results,
        ));
      }

      // Update selected result if it still exists
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
        } else if (speedTestsWithResults.isEmpty) {
          _selectedResult = null;
        } else if (speedTestsWithResults.first.results.isNotEmpty) {
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

  /// Update existing speed test result with new test data.
  /// This is used for coverage/validation tests in room selector.
  Future<void> _submitCoverageResult(SpeedTestResult newTestResult) async {
    if (newTestResult.hasError) {
      return;
    }

    // We need the existing result's ID to update it
    if (_selectedResult == null || _selectedResult!.id == null) {
      LoggerService.warning(
        'RoomSpeedTestSelector: Cannot update - no existing result selected',
        tag: 'RoomSpeedTestSelector',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No existing result to update'),
            backgroundColor: AppColors.warning,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    try {
      LoggerService.info(
        'RoomSpeedTestSelector: Updating existing result id=${_selectedResult!.id} '
        'for pmsRoomId=${widget.pmsRoomId}, '
        'download=${newTestResult.downloadMbps}, upload=${newTestResult.uploadMbps}',
        tag: 'RoomSpeedTestSelector',
      );

      // Create updated result combining existing ID with new test data
      final updatedResult = _selectedResult!.copyWith(
        downloadMbps: newTestResult.downloadMbps,
        uploadMbps: newTestResult.uploadMbps,
        rtt: newTestResult.rtt,
        jitter: newTestResult.jitter,
        passed: newTestResult.passed,
        source: newTestResult.source,
        destination: newTestResult.destination,
        port: newTestResult.port,
        iperfProtocol: newTestResult.iperfProtocol,
        initiatedAt: newTestResult.initiatedAt,
        completedAt: newTestResult.completedAt,
        pmsRoomId: widget.pmsRoomId,
        roomType: widget.roomType,
      );

      // Update via repository (which updates cache immediately)
      final response = await ref
          .read(speedTestRepositoryProvider)
          .updateSpeedTestResult(updatedResult);

      response.fold(
        (failure) {
          LoggerService.warning(
            'RoomSpeedTestSelector: Coverage result update failed: ${failure.message}',
            tag: 'RoomSpeedTestSelector',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Update failed: ${failure.message}'),
                backgroundColor: AppColors.error,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        (updated) {
          LoggerService.info(
            'RoomSpeedTestSelector: Coverage result updated successfully',
            tag: 'RoomSpeedTestSelector',
          );
          // Update local state with the updated result
          setState(() {
            _selectedResult = updated;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Speed test result updated successfully'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
      );
    } catch (e) {
      LoggerService.error(
        'RoomSpeedTestSelector: Error updating coverage result',
        error: e,
        tag: 'RoomSpeedTestSelector',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating speed test result'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _showMarkNotApplicableConfirmation(SpeedTestResult result) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('Mark as Not Applicable?'),
        content: const Text(
          'This speed test will be marked as not applicable. '
          'The result will be excluded from readiness calculations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _markResultNotApplicable(result);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _markResultNotApplicable(SpeedTestResult result) async {
    if (result.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot update result without ID')),
      );
      return;
    }

    try {
      final updated = result.copyWith(isApplicable: false);
      await ref.read(speedTestRepositoryProvider).updateSpeedTestResult(updated);

      if (mounted) {
        // Update local state immediately for responsive UI
        setState(() {
          _selectedResult = updated;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speed test marked as not applicable'),
            backgroundColor: AppColors.success,
          ),
        );
        await _loadSpeedTests();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _markResultApplicable(SpeedTestResult result) async {
    if (result.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot update result without ID')),
      );
      return;
    }

    try {
      final updated = result.copyWith(isApplicable: true);
      await ref.read(speedTestRepositoryProvider).updateSpeedTestResult(updated);

      if (mounted) {
        // Update local state immediately for responsive UI
        setState(() {
          _selectedResult = updated;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speed test marked as applicable'),
            backgroundColor: AppColors.success,
          ),
        );
        await _loadSpeedTests();
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Card(
                child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: const [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Loading speed tests...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Card(
                color: AppColors.error.withValues(alpha: 0.1),
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

    // Show loading placeholder when no tests are available yet
    if (_speedTests.isEmpty) {
      return Card(
                child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Waiting for speed test results...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh speed tests',
                onPressed: _isLoading ? null : _loadSpeedTests,
              ),
            ],
          ),
        ),
      );
    }

    // Build single unified selector for all speed tests
    return _buildUnifiedSpeedTestSelector();
  }

  Widget _buildUnifiedSpeedTestSelector() {
    // Collect all results from all tests with their test config
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

    // Sort by completed tests first (passed), then uncompleted (failed), then by most recent
    allResultsWithConfig.sort((a, b) {
      final bool aPassed = a['passed'] as bool? ?? false;
      final bool bPassed = b['passed'] as bool? ?? false;

      // Completed (passed) tests first
      if (aPassed == true && bPassed != true) return -1;
      if (aPassed != true && bPassed == true) return 1;

      // Then by most recent within each group
      final aTime = (a['result'] as SpeedTestResult).completedAt;
      final bTime = (b['result'] as SpeedTestResult).completedAt;
      if (aTime != null && bTime != null) {
        return bTime.compareTo(aTime);
      }

      return 0;
    });

    final selectedEntry = (_selectedResult != null)
        ? allResultsWithConfig.firstWhere(
            (item) =>
                (item['result'] as SpeedTestResult).id == _selectedResult!.id,
            orElse: () => allResultsWithConfig.first,
          )
        : allResultsWithConfig.first;

    // Use _selectedResult directly if available (for optimistic UI updates)
    // Otherwise fall back to the result from the list
    final currentResult = _selectedResult ?? selectedEntry['result'] as SpeedTestResult;
    final selectedConfig = selectedEntry['config'] as SpeedTestConfig;
    final selectedPassed = selectedEntry['passed'] as bool? ??
        _resultPassesForConfig(currentResult, selectedConfig);
    final String resultLabel =
        (currentResult.roomType != null && currentResult.roomType!.isNotEmpty)
            ? currentResult.roomType!
            : 'Result #${currentResult.id?.toString() ?? "-"}';

    return Card(
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
                      ),
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
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Show different icon for not applicable tests
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

            // Run test button - only show if result is applicable
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
                    showDialog<void>(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => SpeedTestPopup(
                        cachedTest: selectedConfig,
                        onCompleted: () {
                          _loadSpeedTests();
                        },
                        onResultSubmitted: (result) async {
                          if (!result.hasError) {
                            await _submitCoverageResult(result);
                          }
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
    } else if (lowerName.contains('access point') ||
        lowerName.contains('ap')) {
      return 'assets/speed_test_indicator_img/validation_ap.png';
    }

    return null; // Return null if no match, will use default icon
  }

  Future<SpeedTestResult?> _showAllResultsModal(
      List<Map<String, dynamic>> allResults) async {
    // Group results by speed test config
    Map<int, List<Map<String, dynamic>>> groupedResults = {};
    for (final item in allResults) {
      final config = item['config'] as SpeedTestConfig;
      groupedResults.putIfAbsent(config.id!, () => []);
      groupedResults[config.id!]!.add(item);
    }

    // Build list of widgets with headers
    List<Widget> listItems = [];

    groupedResults.forEach((speedTestId, items) {
      final config = items.first['config'] as SpeedTestConfig;
      final testName = config.name ?? 'Speed Test #$speedTestId';
      final iconPath = _getSpeedTestIcon(testName);

      // Add section header
      listItems.add(
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              // Use custom image if available, otherwise use default icon
              iconPath != null
                  ? Image.asset(
                      iconPath,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image fails to load
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
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (config.minDownloadMbps != null ||
                        config.minUploadMbps != null)
                      Text(
                        '>= ${config.minDownloadMbps?.toStringAsFixed(0) ?? "?"} Mbps',
                        style: TextStyle(
                          fontSize: 14,
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

      // Add result items for this speed test
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
            selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !result.isApplicable
                    ? AppColors.gray400
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
                        '\u2193 ${result.downloadMbps!.toStringAsFixed(1)} Mbps  \u2191 ${result.uploadMbps?.toStringAsFixed(1) ?? "N/A"} Mbps',
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

      // Add separator after each speed test type group
      listItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Divider(
            height: 1,
            thickness: 1.5,
            color: AppColors.gray300,
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
              decoration: const BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.gray300,
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
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Results list with grouped sections
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
    final bgColor = passed
        ? AppColors.success.withValues(alpha: 0.1)
        : AppColors.error.withValues(alpha: 0.1);
    final borderColor = passed
        ? AppColors.success.withValues(alpha: 0.3)
        : AppColors.error.withValues(alpha: 0.3);
    final statusColor = passed ? AppColors.success : AppColors.error;

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
          // Header row with pass/fail and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    passed ? Icons.check_circle : Icons.cancel,
                    color: statusColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    passed ? 'Passed' : 'Failed',
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
          // Download and Upload row
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Download',
                  result.downloadMbps != null
                      ? '${result.downloadMbps!.toStringAsFixed(1)} Mbps'
                      : 'N/A',
                  Icons.download,
                  passed: downloadPassed,
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
                  passed: uploadPassed,
                ),
              ),
            ],
          ),
          // Latency and Jitter row (if available)
          if (result.rtt != null || result.jitter != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (result.rtt != null)
                  Expanded(
                    child: _buildMetric(
                      'Latency',
                      '${result.rtt!.toStringAsFixed(1)} ms',
                      Icons.speed,
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
          // Mark as Not Applicable / Applicable button
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => result.isApplicable
                  ? _showMarkNotApplicableConfirmation(result)
                  : _markResultApplicable(result),
              icon: Icon(
                result.isApplicable
                    ? Icons.remove_circle_outline
                    : Icons.check_circle_outline,
                size: 16,
              ),
              label: Text(
                result.isApplicable
                    ? 'Mark as Not Applicable'
                    : 'Mark as Applicable',
                style: const TextStyle(fontSize: 12),
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon,
      {bool? passed}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (passed != null) ...[
          const SizedBox(width: 6),
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: passed ? AppColors.success : AppColors.error,
          ),
        ],
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
