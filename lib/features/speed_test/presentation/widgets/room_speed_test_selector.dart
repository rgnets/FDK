import 'package:att_fe_tool/models/speed_test_model.dart';
import 'package:att_fe_tool/models/speed_test_result_model.dart';
import 'package:att_fe_tool/rxg_api/rxg_api.dart';
import 'package:att_fe_tool/services/logger_service.dart';
import 'package:att_fe_tool/widgets/speed_test_popup.dart';
import 'package:flutter/material.dart';

/// Widget that displays individual speed test cards for a PMS room
///
/// Shows a card for each unique speed_test_id that has results for this room.
/// Each card displays the test configuration and allows running the test.
class RoomSpeedTestSelector extends StatefulWidget {
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
  State<RoomSpeedTestSelector> createState() => _RoomSpeedTestSelectorState();
}

/// Helper class to group test configuration with its results
class SpeedTestWithResults {
  final SpeedTest config;
  final List<SpeedTestResultModel> results;

  SpeedTestWithResults({
    required this.config,
    required this.results,
  });
}

class _RoomSpeedTestSelectorState extends State<RoomSpeedTestSelector> {
  List<SpeedTestWithResults> _speedTests = [];
  bool _isLoading = true;
  String? _errorMessage;
  SpeedTestResultModel? _selectedResult;  // Track selected result across all tests

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

      // Step 1: Get speed test RESULTS (refresh from API if needed)
      final speedTestResultsData =
          await RxgApiClient.getAllSpeedTestResults(forceRefresh: forceRefresh);

      if (!mounted) return;

      Logger.info(
        'Loading speed tests for room ${widget.pmsRoomId}: Found ${speedTestResultsData?.length ?? 0} total results',
        'RoomSpeedTestSelector'
      );

      if (speedTestResultsData == null || speedTestResultsData.isEmpty) {
        Logger.warning(
          'No speed test results available for room ${widget.pmsRoomId}',
          'RoomSpeedTestSelector'
        );
        setState(() {
          _speedTests = [];
          _selectedResult = null;
          _isLoading = false;
        });
        return;
      }

      // Step 2: Filter results by pms_room_id and group by speed_test_id
      final Map<int, List<SpeedTestResultModel>> resultsByTestId = {};
      int skippedCount = 0;
      int matchedCount = 0;

      for (final resultData in speedTestResultsData) {
        try {
          // Extract pms_room_id from nested object or direct field
          dynamic pmsRoomId;
          if (resultData['pms_room'] is Map) {
            pmsRoomId = (resultData['pms_room'] as Map)['id'];
          } else {
            pmsRoomId = resultData['pms_room_id'];
          }

          // Extract speed_test_id from nested object or direct field
          dynamic speedTestId;
          if (resultData['speed_test'] is Map) {
            speedTestId = (resultData['speed_test'] as Map)['id'];
          } else {
            speedTestId = resultData['speed_test_id'];
          }

          // Parse pms_room_id
          int? parsedRoomId;
          if (pmsRoomId is int) {
            parsedRoomId = pmsRoomId;
          } else if (pmsRoomId is String) {
            parsedRoomId = int.tryParse(pmsRoomId);
          }

          // Parse speed_test_id
          int? parsedSpeedTestId;
          if (speedTestId is int) {
            parsedSpeedTestId = speedTestId;
          } else if (speedTestId is String) {
            parsedSpeedTestId = int.tryParse(speedTestId);
          }

          // Only process results for this room
          if (parsedRoomId != widget.pmsRoomId || parsedSpeedTestId == null) {
            skippedCount++;
            continue;
          }

          matchedCount++;

          // Debug: Log raw JSON from API to see what fields are actually returned (both flat and nested)
          final testedViaApFlat = resultData['tested_via_access_point_id'];
          final testedViaApNested = resultData['tested_via_access_point'] is Map
              ? (resultData['tested_via_access_point'] as Map)['id']
              : null;
          Logger.info(
            'RAW API DATA for result ${resultData['id']} (test_id=$parsedSpeedTestId): '
            'tested_via_access_point_id(flat)=$testedViaApFlat, '
            'tested_via_access_point.id(nested)=$testedViaApNested, '
            'access_point_id=${resultData['access_point_id']}, '
            'access_point.id=${resultData['access_point'] is Map ? (resultData['access_point'] as Map)['id'] : null}',
            'RoomSpeedTestSelector'
          );

          // Parse the result model
          final result = SpeedTestResultModel.fromJson(resultData);

          // Add to map - group ALL results by speed_test_id for this room
          resultsByTestId.putIfAbsent(parsedSpeedTestId, () => []);
          resultsByTestId[parsedSpeedTestId]!.add(result);
        } catch (e) {
          Logger.error(
            'Failed to process speed test result: $e',
            'RoomSpeedTestSelector'
          );
        }
      }

      Logger.info(
        'Filtered results for room ${widget.pmsRoomId}: $matchedCount matched, $skippedCount skipped, ${resultsByTestId.length} unique tests',
        'RoomSpeedTestSelector'
      );

      if (resultsByTestId.isEmpty) {
        // Log which room IDs were actually found
        final foundRoomIds = <int>{};
        for (final resultData in speedTestResultsData) {
          dynamic pmsRoomId;
          if (resultData['pms_room'] is Map) {
            pmsRoomId = (resultData['pms_room'] as Map)['id'];
          } else {
            pmsRoomId = resultData['pms_room_id'];
          }

          if (pmsRoomId is int) {
            foundRoomIds.add(pmsRoomId);
          } else if (pmsRoomId is String) {
            final parsed = int.tryParse(pmsRoomId);
            if (parsed != null) foundRoomIds.add(parsed);
          }
        }

        Logger.warning(
          'No speed test results matched room ${widget.pmsRoomId} (checked ${speedTestResultsData.length} total results). '
          'Found results for rooms: ${foundRoomIds.toList()..sort()}',
          'RoomSpeedTestSelector'
        );
        setState(() {
          _speedTests = [];
          _isLoading = false;
        });
        return;
      }

      // Step 3: Get speed test configurations from cache (already loaded during app startup)
      final speedTestsData =
          await RxgApiClient.getAllSpeedTests(forceRefresh: forceRefresh);

      if (!mounted) return;

      // Build a map of speed_test_id -> SpeedTest for quick lookup
      final Map<int, SpeedTest> configsById = {};
      if (speedTestsData != null) {
        for (final testData in speedTestsData) {
          try {
            final testId = testData['id'];
            int? parsedTestId;
            if (testId is int) {
              parsedTestId = testId;
            } else if (testId is String) {
              parsedTestId = int.tryParse(testId);
            }

            if (parsedTestId != null) {
              configsById[parsedTestId] = SpeedTest.fromJson(testData);
            }
          } catch (e) {
            Logger.error('Failed to parse speed test config: $e', 'RoomSpeedTestSelector');
          }
        }
      }

      // Step 4: Build SpeedTestWithResults for EACH speed_test_id in results
      final List<SpeedTestWithResults> speedTestsWithResults = [];

      for (final entry in resultsByTestId.entries) {
        final speedTestId = entry.key;
        final results = entry.value;

        // Try to get the config from speed_tests table
        SpeedTest? config = configsById[speedTestId];

        // If no config found, create a placeholder
        if (config == null) {
          // Create a minimal SpeedTest from the first result
          final firstResult = results.first;

          config = SpeedTest(
            id: speedTestId,
            name: 'Speed Test #$speedTestId',
            target: firstResult.destination ?? 'Unknown',
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

      SpeedTestResultModel? updatedSelection;
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
      Logger.error('Failed to load speed tests: $e', 'RoomSpeedTestSelector');
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

  bool _resultPassesForConfig(
      SpeedTestResultModel result, SpeedTest config) {
    final downloadPass =
        _metricMeetsThreshold(result.downloadMbps, config.minDownloadMbps);
    final uploadPass =
        _metricMeetsThreshold(result.uploadMbps, config.minUploadMbps);

    return result.passed || (downloadPass && uploadPass);
  }

  @override
  Widget build(BuildContext context) {
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
      final aTime =
          (a['result'] as SpeedTestResultModel).completedAt;
      final bTime =
          (b['result'] as SpeedTestResultModel).completedAt;
      if (aTime != null && bTime != null) {
        return bTime.compareTo(aTime);
      }

      return 0;
    });

    final Map<String, dynamic> selectedEntry = (_selectedResult != null)
        ? allResultsWithConfig.firstWhere(
            (item) => (item['result'] as SpeedTestResultModel).id ==
                _selectedResult!.id,
            orElse: () => allResultsWithConfig.first,
          )
        : allResultsWithConfig.first;

    final currentResult =
        selectedEntry['result'] as SpeedTestResultModel;
    final selectedConfig = selectedEntry['config'] as SpeedTest;
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
                final selected = await _showAllResultsModal(allResultsWithConfig);
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
                final isDisabled = !currentResult.isApplicable && isCoverageTest;

                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isDisabled ? null : () {
                      Logger.info(
                        '🎯 Running speed test: ${selectedConfig.name} for room ${widget.roomName}, room_type: "${currentResult.roomType}"',
                        'RoomSpeedTestSelector'
                      );

                      // Determine which AP to use for the test
                      // Priority: 1) Use existing testedViaAccessPointId from result
                      //           2) Use first AP in room if available
                      //           3) Otherwise null (for coverage tests)
                      int? testedViaAccessPointId = currentResult.testedViaAccessPointId;
                      if (testedViaAccessPointId == null && widget.apIds.isNotEmpty) {
                        testedViaAccessPointId = widget.apIds.first;
                        Logger.info(
                          'Using AP ID ${widget.apIds.first} for validation test',
                          'RoomSpeedTestSelector'
                        );
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => SpeedTestPopup(
                          cachedTest: selectedConfig,
                          existingResult: currentResult,
                          pmsRoomId: widget.pmsRoomId,
                          roomType: currentResult.roomType,
                          testedViaAccessPointId: testedViaAccessPointId,
                          onCompleted: () {
                            // Refresh the test list to update results
                            _loadSpeedTests(forceRefresh: true);
                          },
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

    return null; // Return null if no match, will use default icon
  }

  Future<SpeedTestResultModel?> _showAllResultsModal(List<Map<String, dynamic>> allResults) async {
    // Group results by speed test config
    Map<int, List<Map<String, dynamic>>> groupedResults = {};
    for (final item in allResults) {
      final config = item['config'] as SpeedTest;
      groupedResults.putIfAbsent(config.id!, () => []);
      groupedResults[config.id!]!.add(item);
    }

    // Build list of widgets with headers
    List<Widget> listItems = [];

    groupedResults.forEach((speedTestId, items) {
      final config = items.first['config'] as SpeedTest;
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
                        return Icon(Icons.speed, size: 36, color: Colors.grey[600]);
                      },
                    )
                  : Icon(Icons.speed, size: 36, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _capitalizeEachWord(testName),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (config.minDownloadMbps != null || config.minUploadMbps != null)
                      Text(
                        '≥ ${config.minDownloadMbps?.toStringAsFixed(0) ?? "?"} Mbps',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
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
        final result = item['result'] as SpeedTestResultModel;
        final isSelected = result.id == _selectedResult?.id;
        final bool passed = item['passed'] as bool? ??
            _resultPassesForConfig(result, config);

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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              width: 8,
              height: 8,
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
                fontSize: 14,
              ),
            ),
            subtitle: !result.isApplicable
                ? Text(
                    'Not Applicable',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : (result.downloadMbps != null
                    ? Text(
                        '↓ ${result.downloadMbps!.toStringAsFixed(1)} Mbps  ↑ ${result.uploadMbps?.toStringAsFixed(1) ?? "N/A"} Mbps',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
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

      // Add separator after each speed test type group
      listItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Divider(
            height: 1,
            thickness: 1.5,
            color: Colors.grey[300],
          ),
        ),
      );
    });

    return showModalBottomSheet<SpeedTestResultModel>(
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

  Widget _buildResultDetails(SpeedTestResultModel result, SpeedTest config) {
    // Debug logging to see field values
    Logger.info(
      'Test: ${config.name} | '
      'testedViaAP: ${result.testedViaAccessPointId} | '
      'testedViaMediaConv: ${result.testedViaMediaConverterId} | '
      'accessPointId: ${result.accessPointId} | '
      'uplinkId: ${result.uplinkId}',
      'RoomSpeedTestSelector'
    );

    // If marked as not applicable (coverage tests only), show simplified view
    // Coverage tests have no device associations or tested-via records
    final isCoverageTest =
        result.testedViaAccessPointId == null &&
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
        result.downloadMbps, config.minDownloadMbps);
    final uploadPassed = _metricMeetsThreshold(
        result.uploadMbps, config.minUploadMbps);
    final bool passed =
        _resultPassesForConfig(result, config);
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
                    color: Colors.grey[600],
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
                color: Colors.grey[600],
              ),
            ),
          ],
          // Actions section (only for coverage speed tests that are still applicable)
          // Coverage tests have no device associations or tested-via records
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

  void _showNotApplicableConfirmation(SpeedTestResultModel result) {
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

  Future<void> _markResultNotApplicable(SpeedTestResultModel result) async {
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final resultId = await RxgApiClient.putSpeedTestResult(
        speedTestId: result.speedTestId!,
        existingResultId: result.id,
        isApplicable: false,
      );

      if (mounted) {
        Navigator.pop(context);

        if (resultId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speed test marked as not applicable'),
              backgroundColor: Colors.green,
            ),
          );

          await _loadSpeedTests();
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update speed test'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      Logger.error('Failed to mark result as not applicable: $e', 'RoomSpeedTestSelector');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showMarkApplicableConfirmation(SpeedTestResultModel result) {
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

  Future<void> _markResultApplicable(SpeedTestResultModel result) async {
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final resultId = await RxgApiClient.putSpeedTestResult(
        speedTestId: result.speedTestId!,
        existingResultId: result.id,
        isApplicable: true,
      );

      if (mounted) {
        Navigator.pop(context);

        if (resultId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Speed test marked as applicable'),
              backgroundColor: Colors.green,
            ),
          );

          await _loadSpeedTests();
          setState(() {});
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update speed test'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      Logger.error('Failed to mark result as applicable: $e', 'RoomSpeedTestSelector');
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
