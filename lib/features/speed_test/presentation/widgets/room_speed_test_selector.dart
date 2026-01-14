import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/websocket_providers.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';
import 'package:rgnets_fdk/features/speed_test/presentation/providers/speed_test_provider.dart';
import 'package:rgnets_fdk/features/speed_test/presentation/widgets/speed_test_popup.dart';

/// Widget that displays individual speed test cards for a PMS room
///
/// Shows a card for each unique speed_test_id that has results for this room.
/// Each card displays the test configuration and allows running the test.
class RoomSpeedTestSelector extends ConsumerStatefulWidget {
  final int pmsRoomId;
  final String roomName;
  final String? roomType;
  final List<int> apIds; // List of AP IDs in this room
  final void Function(SpeedTestResult result)? onResultSubmitted;

  const RoomSpeedTestSelector({
    super.key,
    required this.pmsRoomId,
    required this.roomName,
    this.roomType,
    this.apIds = const [],
    this.onResultSubmitted,
  });

  @override
  ConsumerState<RoomSpeedTestSelector> createState() =>
      _RoomSpeedTestSelectorState();
}

/// Helper class to group test configuration with its results
class SpeedTestWithResults {
  final SpeedTestConfig config;
  final List<SpeedTestResult> results;

  SpeedTestWithResults({
    required this.config,
    required this.results,
  });
}

class _RoomSpeedTestSelectorState extends ConsumerState<RoomSpeedTestSelector> {
  List<SpeedTestWithResults> _speedTests = [];
  bool _isLoading = true;
  String? _errorMessage;
  SpeedTestResult? _selectedResult; // Track selected result across all tests

  @override
  void initState() {
    super.initState();
    _loadSpeedTests();
  }

  Future<void> _loadSpeedTests({bool forceRefresh = false}) async {
    if (!mounted) return;
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Invalidate providers if force refresh (this triggers rebuild)
      if (forceRefresh) {
        ref.invalidate(speedTestResultsByRoomNameProvider(widget.roomName));
        ref.invalidate(speedTestConfigsProvider);
      }

      // Get speed test results for this room by room name (now synchronous)
      final results = ref.read(speedTestResultsByRoomNameProvider(widget.roomName));
      final configs = ref.read(speedTestConfigsProvider);

      if (!mounted) return;

      LoggerService.info(
        'Loading speed tests for room "${widget.roomName}": Found ${results.length} results',
        tag: 'RoomSpeedTestSelector',
      );

      if (results.isEmpty) {
        LoggerService.warning(
          'No speed test results available for room "${widget.roomName}"',
          tag: 'RoomSpeedTestSelector',
        );
        setState(() {
          _speedTests = [];
          _selectedResult = null;
          _isLoading = false;
        });
        return;
      }

      // Group results by speed_test_id (use 0 as default for null speedTestId)
      final resultsByTestId = <int, List<SpeedTestResult>>{};
      var nullSpeedTestCount = 0;
      for (final result in results) {
        final testId = result.speedTestId ?? 0; // Use 0 for results without speedTestId
        if (result.speedTestId == null) {
          nullSpeedTestCount++;
        }
        resultsByTestId.putIfAbsent(testId, () => []);
        resultsByTestId[testId]!.add(result);
      }

      LoggerService.info(
        'Grouped results for room "${widget.roomName}": ${resultsByTestId.length} unique tests, $nullSpeedTestCount with null speedTestId',
        tag: 'RoomSpeedTestSelector',
      );

      if (resultsByTestId.isEmpty) {
        setState(() {
          _speedTests = [];
          _isLoading = false;
        });
        return;
      }

      // Build a map of speed_test_id -> SpeedTestConfig for quick lookup
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

        // Try to get the config from speed_tests
        SpeedTestConfig? config = configsById[speedTestId];

        // If no config found, create a placeholder
        if (config == null) {
          final firstResult = results.first;
          config = SpeedTestConfig(
            id: speedTestId,
            name: 'Speed Test #$speedTestId',
            target: firstResult.serverHost ?? 'Unknown',
            port: 5201,
            iperfProtocol: 'tcp',
            passing: firstResult.passed ?? false,
          );
        }

        speedTestsWithResults.add(SpeedTestWithResults(
          config: config,
          results: results,
        ));
      }

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
    } on Exception catch (e) {
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
        _metricMeetsThreshold(result.downloadSpeed, config.minDownloadMbps);
    final uploadPass =
        _metricMeetsThreshold(result.uploadSpeed, config.minUploadMbps);

    return (result.passed ?? false) || (downloadPass && uploadPass);
  }

  @override
  Widget build(BuildContext context) {
    // Watch for cache updates to reload when speed test data arrives
    ref.listen<AsyncValue<DateTime?>>(webSocketLastUpdateProvider, (previous, next) {
      // Reload when cache updates (data arrived from WebSocket)
      if (next.hasValue && next.value != null) {
        if (_speedTests.isEmpty && !_isLoading) {
          LoggerService.info(
            'Cache updated, reloading speed tests for room "${widget.roomName}"',
            tag: 'RoomSpeedTestSelector',
          );
          _loadSpeedTests();
        }
      }
    });

    if (_isLoading) {
      return Card(
        margin: const EdgeInsets.all(16),
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
        margin: const EdgeInsets.all(16),
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
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
        margin: const EdgeInsets.all(16),
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
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh speed tests',
                onPressed: _isLoading
                    ? null
                    : () => _loadSpeedTests(forceRefresh: true),
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
    final String resultLabel = (currentResult.roomType != null &&
            currentResult.roomType!.isNotEmpty)
        ? currentResult.roomType!
        : 'Result #${currentResult.id?.toString() ?? "-"}';

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.speed, color: Colors.blue),
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
                side: const BorderSide(color: Colors.grey),
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
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          resultLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
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
                        ? Colors.grey[600]
                        : (selectedPassed ? Colors.green : Colors.red),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey[700],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            _buildResultDetails(currentResult, selectedConfig),

            const SizedBox(height: 16),

            // Run test button (disabled if marked as not applicable)
            Builder(
              builder: (context) {
                // Check if this is a coverage test (no device associations)
                final isCoverageTest =
                    currentResult.testedViaAccessPointId == null &&
                        currentResult.testedViaMediaConverterId == null &&
                        currentResult.accessPointId == null &&
                        currentResult.uplinkId == null;

                // Disable button if marked as not applicable for coverage tests
                final isDisabled =
                    !currentResult.isApplicable && isCoverageTest;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isDisabled
                        ? null
                        : () {
                            LoggerService.info(
                              'Running speed test: ${selectedConfig.name} for room ${widget.roomName}, room_type: "${currentResult.roomType}"',
                              tag: 'RoomSpeedTestSelector',
                            );

                            // Determine which AP to use for the test
                            int? testedViaAccessPointId =
                                currentResult.testedViaAccessPointId;
                            if (testedViaAccessPointId == null &&
                                widget.apIds.isNotEmpty) {
                              testedViaAccessPointId = widget.apIds.first;
                              LoggerService.info(
                                'Using AP ID ${widget.apIds.first} for validation test',
                                tag: 'RoomSpeedTestSelector',
                              );
                            }

                            showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => SpeedTestPopup(
                                cachedTest: selectedConfig,
                                existingResult: currentResult,
                                pmsRoomId: widget.pmsRoomId,
                                roomType: currentResult.roomType,
                                testedViaAccessPointId: testedViaAccessPointId,
                                onCompleted: () {
                                  _loadSpeedTests(forceRefresh: true);
                                },
                                onResultSubmitted: widget.onResultSubmitted,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Run Test'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Determine test category from result's device associations
  String _getTestCategory(SpeedTestResult result) {
    // ONT validation: has media converter or uplink association
    if (result.testedViaMediaConverterId != null || result.uplinkId != null) {
      return 'ont';
    }
    // AP validation: has access point association
    if (result.accessPointId != null || result.testedViaAccessPointId != null) {
      return 'ap';
    }
    // Coverage: no device associations (room-level test)
    return 'coverage';
  }

  Future<SpeedTestResult?> _showAllResultsModal(
      List<Map<String, dynamic>> allResults) async {
    // Group results by category (ONT, AP, Coverage)
    final Map<String, List<Map<String, dynamic>>> categorizedResults = {
      'ont': [],
      'ap': [],
      'coverage': [],
    };

    for (final item in allResults) {
      final result = item['result'] as SpeedTestResult;
      final category = _getTestCategory(result);
      categorizedResults[category]!.add(item);
    }

    // Build list of widgets with category headers
    List<Widget> listItems = [];

    // Helper to build a category section
    void buildCategorySection(
      String categoryKey,
      String categoryTitle,
      String iconPath,
      IconData fallbackIcon,
    ) {
      final items = categorizedResults[categoryKey]!;
      if (items.isEmpty) return;

      // Add category header
      listItems.add(
        Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          color: Colors.grey[100],
          child: Row(
            children: [
              Image.asset(
                iconPath,
                width: 44,
                height: 44,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(fallbackIcon, size: 40, color: Colors.blue[700]);
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  categoryTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      // Add result items for this category
      for (final item in items) {
        final result = item['result'] as SpeedTestResult;
        final config = item['config'] as SpeedTestConfig;
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
            selectedTileColor: Colors.blue[50],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !result.isApplicable
                    ? Colors.grey[400]
                    : (passed ? Colors.green : Colors.red),
              ),
            ),
            title: Text(
              displayText,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            subtitle: !result.isApplicable
                ? Text(
                    'Not Applicable',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : (result.downloadSpeed > 0
                    ? Text(
                        '↓ ${result.downloadSpeed.toStringAsFixed(1)} Mbps  ↑ ${result.uploadSpeed.toStringAsFixed(1)} Mbps',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      )
                    : null),
            trailing: Icon(
              !result.isApplicable
                  ? Icons.remove_circle_outline
                  : (passed ? Icons.check_circle : Icons.cancel),
              size: 28,
              color: !result.isApplicable
                  ? Colors.grey[600]
                  : (passed ? Colors.green : Colors.red),
            ),
            onTap: () {
              Navigator.pop(context, result);
            },
          ),
        );
      }

      // Add separator after category
      listItems.add(const SizedBox(height: 8));
    }

    // Build sections in order: ONT Validation, AP Validation, Coverage
    buildCategorySection(
      'ont',
      'ONT Validation',
      'assets/speed_test_indicator_img/validation_ont.png',
      Icons.router,
    );
    buildCategorySection(
      'ap',
      'AP Validation',
      'assets/speed_test_indicator_img/validation_ap.png',
      Icons.wifi,
    );
    buildCategorySection(
      'coverage',
      'Coverage',
      'assets/speed_test_indicator_img/coverage.png',
      Icons.signal_cellular_alt,
    );

    // Draggable bottom sheet (matches ATT-FE-Tool style)
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
                color: Colors.white,
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
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.history, color: Colors.blue),
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
    final isCoverageTest = result.testedViaAccessPointId == null &&
        result.testedViaMediaConverterId == null &&
        result.accessPointId == null &&
        result.uplinkId == null;

    if (!result.isApplicable && isCoverageTest) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.block, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  'Not Applicable',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                if (result.completedAt != null)
                  Text(
                    _formatTimeSince(result.completedAt!),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'This speed test has been marked as not applicable for coverage testing.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Mark as Applicable'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue[700],
                  side: BorderSide(color: Colors.blue[300]!),
                ),
                onPressed: () => _showMarkApplicableConfirmation(result),
              ),
            ),
          ],
        ),
      );
    }

    final downloadPassed = _metricMeetsThreshold(
        result.downloadSpeed, config.minDownloadMbps);
    final uploadPassed =
        _metricMeetsThreshold(result.uploadSpeed, config.minUploadMbps);
    final bool passed = _resultPassesForConfig(result, config);
    final bgColor = passed ? Colors.green[50] : Colors.red[50];
    final borderColor = passed ? Colors.green[200]! : Colors.red[200]!;
    final statusColor = passed ? Colors.green : Colors.red;

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
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetric(
                  'Download',
                  '${result.downloadSpeed.toStringAsFixed(1)} Mbps',
                  Icons.download,
                  passed: downloadPassed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetric(
                  'Upload',
                  '${result.uploadSpeed.toStringAsFixed(1)} Mbps',
                  Icons.upload,
                  passed: uploadPassed,
                ),
              ),
            ],
          ),
          // Latency row (if available)
          if (result.latency > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    'Latency',
                    '${result.latency.toStringAsFixed(1)} ms',
                    Icons.speed,
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
                color: Colors.grey[600],
              ),
            ),
          ],
          // Actions section (only for coverage speed tests that are still applicable)
          if (isCoverageTest && result.isApplicable) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.block, size: 18),
                label: const Text('Mark Not Applicable'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orange[700],
                  side: BorderSide(color: Colors.orange[300]!),
                ),
                onPressed: () => _showNotApplicableConfirmation(result),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon,
      {bool? passed}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
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
            color: passed ? Colors.green : Colors.red,
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

  void _showNotApplicableConfirmation(SpeedTestResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Not Applicable?'),
        content: const Text(
          'This speed test will be marked as not applicable for coverage testing. '
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
              backgroundColor: Colors.orange[700],
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _markResultNotApplicable(SpeedTestResult result) async {
    if (result.id == null || result.speedTestId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to update: Missing result information'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Update locally - the isApplicable field change will be sent via websocket
    final updatedResult = result.copyWith(isApplicable: false);

    // Notify parent via callback
    widget.onResultSubmitted?.call(updatedResult);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speed test marked as not applicable'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadSpeedTests();
      setState(() {});
    }
  }

  void _showMarkApplicableConfirmation(SpeedTestResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Applicable?'),
        content: const Text(
          'This speed test will be marked as applicable for coverage testing. '
          'The result will be included in readiness calculations.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _markResultApplicable(result);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _markResultApplicable(SpeedTestResult result) async {
    if (result.id == null || result.speedTestId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to update: Missing result information'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Update locally - the isApplicable field change will be sent via websocket
    final updatedResult = result.copyWith(isApplicable: true);

    // Notify parent via callback
    widget.onResultSubmitted?.call(updatedResult);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Speed test marked as applicable'),
          backgroundColor: Colors.green,
        ),
      );

      await _loadSpeedTests();
      setState(() {});
    }
  }
}
