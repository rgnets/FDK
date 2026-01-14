import 'dart:convert';

import 'package:rgnets_fdk/core/config/logger_config.dart';
import 'package:rgnets_fdk/core/services/storage_service.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_config.dart';
import 'package:rgnets_fdk/features/speed_test/domain/entities/speed_test_result.dart';

abstract class SpeedTestLocalDataSource {
  // Speed Test Configs
  Future<List<SpeedTestConfig>> getCachedConfigs({bool allowStale = false});
  Future<void> cacheConfigs(List<SpeedTestConfig> configs);
  Future<SpeedTestConfig?> getCachedConfig(int id);
  Future<void> cacheConfig(SpeedTestConfig config);
  Future<bool> isConfigCacheValid();

  // Speed Test Results
  Future<List<SpeedTestResult>> getCachedResults({bool allowStale = false});
  Future<void> cacheResults(List<SpeedTestResult> results);
  Future<List<SpeedTestResult>> getResultsForRoom(int pmsRoomId);
  Future<List<SpeedTestResult>> getResultsForConfig(int speedTestId);
  Future<void> cacheResult(SpeedTestResult result);
  Future<bool> isResultCacheValid();

  // General
  Future<void> clearCache();
}

class SpeedTestLocalDataSourceImpl implements SpeedTestLocalDataSource {
  const SpeedTestLocalDataSourceImpl({
    required this.storageService,
  });

  final StorageService storageService;
  static final _logger = LoggerConfig.getLogger();

  // Config cache keys
  static const String _configsKey = 'cached_speed_test_configs';
  static const String _configKeyPrefix = 'cached_speed_test_config_';
  static const String _configIndexKey = 'speed_test_config_index';
  static const String _configCacheTimestampKey = 'speed_test_configs_cache_timestamp';

  // Result cache keys
  static const String _resultsKey = 'cached_speed_test_results';
  static const String _resultKeyPrefix = 'cached_speed_test_result_';
  static const String _resultIndexKey = 'speed_test_result_index';
  static const String _resultCacheTimestampKey = 'speed_test_results_cache_timestamp';
  static const String _resultsByRoomKeyPrefix = 'speed_test_results_room_';
  static const String _resultsByConfigKeyPrefix = 'speed_test_results_config_';
  static const String _resultsByRoomIndexKey = 'speed_test_results_room_index';
  static const String _resultsByConfigIndexKey = 'speed_test_results_config_index';

  static const Duration _cacheValidityDuration = Duration(minutes: 30);

  // ============== Config Methods ==============

  @override
  Future<bool> isConfigCacheValid() async {
    try {
      final timestampStr = storageService.getString(_configCacheTimestampKey);
      if (timestampStr == null) {
        return false;
      }

      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      return difference < _cacheValidityDuration;
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  Future<List<SpeedTestConfig>> getCachedConfigs({bool allowStale = false}) async {
    try {
      if (!allowStale && !await isConfigCacheValid()) {
        _logger.d('SpeedTest config cache expired or invalid');
        return [];
      }

      // Try indexed cache first
      final indexJson = storageService.getString(_configIndexKey);
      if (indexJson != null) {
        final index = json.decode(indexJson) as List<dynamic>;
        final configs = <SpeedTestConfig>[];

        for (final id in index) {
          final configJson = storageService.getString('$_configKeyPrefix$id');
          if (configJson != null) {
            configs.add(SpeedTestConfig.fromJson(
              json.decode(configJson) as Map<String, dynamic>,
            ));
          }
        }

        _logger.d('Loaded ${configs.length} speed test configs from indexed cache');
        return configs;
      }

      // Fallback to old format
      final configsJson = storageService.getString(_configsKey);
      if (configsJson != null) {
        final configsList = json.decode(configsJson) as List<dynamic>;
        return configsList
            .map((j) => SpeedTestConfig.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on Exception catch (e) {
      _logger.e('Failed to get cached speed test configs: $e');
      return [];
    }
  }

  @override
  Future<void> cacheConfigs(List<SpeedTestConfig> configs) async {
    try {
      // Update timestamp
      await storageService.setString(
        _configCacheTimestampKey,
        DateTime.now().toIso8601String(),
      );

      // Store index
      final index = configs.map((c) => c.id).whereType<int>().toList();
      await storageService.setString(_configIndexKey, json.encode(index));

      // Store configs individually
      for (final config in configs) {
        if (config.id != null) {
          final configJson = json.encode(config.toJson());
          await storageService.setString(
            '$_configKeyPrefix${config.id}',
            configJson,
          );
        }
      }

      _logger.d('Cached ${configs.length} speed test configs');
    } on Exception catch (e) {
      _logger.e('Failed to cache speed test configs: $e');
    }
  }

  @override
  Future<SpeedTestConfig?> getCachedConfig(int id) async {
    try {
      final configJson = storageService.getString('$_configKeyPrefix$id');
      if (configJson != null) {
        return SpeedTestConfig.fromJson(
          json.decode(configJson) as Map<String, dynamic>,
        );
      }
      return null;
    } on Exception catch (e) {
      _logger.e('Failed to get cached speed test config: $e');
      return null;
    }
  }

  @override
  Future<void> cacheConfig(SpeedTestConfig config) async {
    try {
      if (config.id == null) {
        return;
      }

      final configJson = json.encode(config.toJson());
      await storageService.setString('$_configKeyPrefix${config.id}', configJson);

      // Update index
      final indexJson = storageService.getString(_configIndexKey);
      if (indexJson != null) {
        final index = (json.decode(indexJson) as List<dynamic>).cast<int>();
        if (!index.contains(config.id)) {
          index.add(config.id!);
          await storageService.setString(_configIndexKey, json.encode(index));
        }
      }
    } on Exception catch (e) {
      _logger.e('Failed to cache speed test config: $e');
    }
  }

  // ============== Result Methods ==============

  @override
  Future<bool> isResultCacheValid() async {
    try {
      final timestampStr = storageService.getString(_resultCacheTimestampKey);
      if (timestampStr == null) {
        return false;
      }

      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      return difference < _cacheValidityDuration;
    } on Exception catch (_) {
      return false;
    }
  }

  @override
  Future<List<SpeedTestResult>> getCachedResults({bool allowStale = false}) async {
    try {
      if (!allowStale && !await isResultCacheValid()) {
        _logger.d('SpeedTest result cache expired or invalid');
        return [];
      }

      // Try indexed cache first
      final indexJson = storageService.getString(_resultIndexKey);
      if (indexJson != null) {
        final index = json.decode(indexJson) as List<dynamic>;
        final results = <SpeedTestResult>[];

        for (final id in index) {
          final resultJson = storageService.getString('$_resultKeyPrefix$id');
          if (resultJson != null) {
            results.add(SpeedTestResult.fromJson(
              json.decode(resultJson) as Map<String, dynamic>,
            ));
          }
        }

        _logger.d('Loaded ${results.length} speed test results from indexed cache');
        return results;
      }

      // Fallback to old format
      final resultsJson = storageService.getString(_resultsKey);
      if (resultsJson != null) {
        final resultsList = json.decode(resultsJson) as List<dynamic>;
        return resultsList
            .map((j) => SpeedTestResult.fromJson(j as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on Exception catch (e) {
      _logger.e('Failed to get cached speed test results: $e');
      return [];
    }
  }

  @override
  Future<void> cacheResults(List<SpeedTestResult> results) async {
    try {
      final previousResultIds =
          _decodeIndex(storageService.getString(_resultIndexKey));
      final roomIdsToClear =
          _decodeIndex(storageService.getString(_resultsByRoomIndexKey)).toSet();
      final configIdsToClear =
          _decodeIndex(storageService.getString(_resultsByConfigIndexKey))
              .toSet();

      if (previousResultIds.isNotEmpty) {
        for (final id in previousResultIds) {
          final resultJson = storageService.getString('$_resultKeyPrefix$id');
          if (resultJson == null) {
            continue;
          }
          try {
            final cachedResult = SpeedTestResult.fromJson(
              json.decode(resultJson) as Map<String, dynamic>,
            );
            if (cachedResult.pmsRoomId != null) {
              roomIdsToClear.add(cachedResult.pmsRoomId!);
            }
            if (cachedResult.speedTestId != null) {
              configIdsToClear.add(cachedResult.speedTestId!);
            }
          } on Exception catch (_) {}
        }
      }

      for (final roomId in roomIdsToClear) {
        await storageService.remove('$_resultsByRoomKeyPrefix$roomId');
      }
      for (final configId in configIdsToClear) {
        await storageService.remove('$_resultsByConfigKeyPrefix$configId');
      }
      for (final id in previousResultIds) {
        await storageService.remove('$_resultKeyPrefix$id');
      }

      // Update timestamp
      await storageService.setString(
        _resultCacheTimestampKey,
        DateTime.now().toIso8601String(),
      );

      // Store index
      final index = results.map((r) => r.id).whereType<int>().toList();
      await storageService.setString(_resultIndexKey, json.encode(index));

      // Store results individually and build room/config indices
      final roomIndex = <int, List<int>>{};
      final configIndex = <int, List<int>>{};

      for (final result in results) {
        if (result.id != null) {
          final resultJson = json.encode(result.toJson());
          await storageService.setString(
            '$_resultKeyPrefix${result.id}',
            resultJson,
          );

          // Build room index
          if (result.pmsRoomId != null) {
            roomIndex.putIfAbsent(result.pmsRoomId!, () => []).add(result.id!);
          }

          // Build config index
          if (result.speedTestId != null) {
            configIndex.putIfAbsent(result.speedTestId!, () => []).add(result.id!);
          }
        }
      }

      // Store room indices
      for (final entry in roomIndex.entries) {
        await storageService.setString(
          '$_resultsByRoomKeyPrefix${entry.key}',
          json.encode(entry.value),
        );
      }
      await storageService.setString(
        _resultsByRoomIndexKey,
        json.encode(roomIndex.keys.toList()),
      );

      // Store config indices
      for (final entry in configIndex.entries) {
        await storageService.setString(
          '$_resultsByConfigKeyPrefix${entry.key}',
          json.encode(entry.value),
        );
      }
      await storageService.setString(
        _resultsByConfigIndexKey,
        json.encode(configIndex.keys.toList()),
      );

      _logger.d('Cached ${results.length} speed test results');
    } on Exception catch (e) {
      _logger.e('Failed to cache speed test results: $e');
    }
  }

  @override
  Future<List<SpeedTestResult>> getResultsForRoom(int pmsRoomId) async {
    try {
      final indexJson = storageService.getString('$_resultsByRoomKeyPrefix$pmsRoomId');
      if (indexJson == null) {
        return [];
      }

      final resultIds = (json.decode(indexJson) as List<dynamic>).cast<int>();
      final results = <SpeedTestResult>[];

      for (final id in resultIds) {
        final resultJson = storageService.getString('$_resultKeyPrefix$id');
        if (resultJson != null) {
          results.add(SpeedTestResult.fromJson(
            json.decode(resultJson) as Map<String, dynamic>,
          ));
        }
      }

      return results;
    } on Exception catch (e) {
      _logger.e('Failed to get speed test results for room $pmsRoomId: $e');
      return [];
    }
  }

  @override
  Future<List<SpeedTestResult>> getResultsForConfig(int speedTestId) async {
    try {
      final indexJson = storageService.getString('$_resultsByConfigKeyPrefix$speedTestId');
      if (indexJson == null) {
        return [];
      }

      final resultIds = (json.decode(indexJson) as List<dynamic>).cast<int>();
      final results = <SpeedTestResult>[];

      for (final id in resultIds) {
        final resultJson = storageService.getString('$_resultKeyPrefix$id');
        if (resultJson != null) {
          results.add(SpeedTestResult.fromJson(
            json.decode(resultJson) as Map<String, dynamic>,
          ));
        }
      }

      return results;
    } on Exception catch (e) {
      _logger.e('Failed to get speed test results for config $speedTestId: $e');
      return [];
    }
  }

  @override
  Future<void> cacheResult(SpeedTestResult result) async {
    try {
      if (result.id == null) {
        return;
      }

      final resultJson = json.encode(result.toJson());
      await storageService.setString('$_resultKeyPrefix${result.id}', resultJson);

      // Update main index
      final indexJson = storageService.getString(_resultIndexKey);
      if (indexJson != null) {
        final index = (json.decode(indexJson) as List<dynamic>).cast<int>();
        if (!index.contains(result.id)) {
          index.add(result.id!);
          await storageService.setString(_resultIndexKey, json.encode(index));
        }
      }

      // Update room index
      if (result.pmsRoomId != null) {
        final roomIndexJson = storageService.getString(
          '$_resultsByRoomKeyPrefix${result.pmsRoomId}',
        );
        final roomIndex = roomIndexJson != null
            ? (json.decode(roomIndexJson) as List<dynamic>).cast<int>()
            : <int>[];
        if (!roomIndex.contains(result.id)) {
          roomIndex.add(result.id!);
          await storageService.setString(
            '$_resultsByRoomKeyPrefix${result.pmsRoomId}',
            json.encode(roomIndex),
          );
        }
        await _appendIndexId(_resultsByRoomIndexKey, result.pmsRoomId!);
      }

      // Update config index
      if (result.speedTestId != null) {
        final configIndexJson = storageService.getString(
          '$_resultsByConfigKeyPrefix${result.speedTestId}',
        );
        final configIndex = configIndexJson != null
            ? (json.decode(configIndexJson) as List<dynamic>).cast<int>()
            : <int>[];
        if (!configIndex.contains(result.id)) {
          configIndex.add(result.id!);
          await storageService.setString(
            '$_resultsByConfigKeyPrefix${result.speedTestId}',
            json.encode(configIndex),
          );
        }
        await _appendIndexId(_resultsByConfigIndexKey, result.speedTestId!);
      }
    } on Exception catch (e) {
      _logger.e('Failed to cache speed test result: $e');
    }
  }

  List<int> _decodeIndex(String? indexJson) {
    if (indexJson == null) {
      return <int>[];
    }
    try {
      return (json.decode(indexJson) as List<dynamic>).cast<int>();
    } on Exception catch (_) {
      return <int>[];
    }
  }

  Future<void> _appendIndexId(String indexKey, int id) async {
    final index = _decodeIndex(storageService.getString(indexKey));
    if (index.contains(id)) {
      return;
    }
    index.add(id);
    await storageService.setString(indexKey, json.encode(index));
  }

  // ============== General Methods ==============

  @override
  Future<void> clearCache() async {
    try {
      // Clear config cache
      final configIndex = _decodeIndex(storageService.getString(_configIndexKey));
      for (final id in configIndex) {
        await storageService.remove('$_configKeyPrefix$id');
      }
      await storageService.remove(_configsKey);
      await storageService.remove(_configCacheTimestampKey);
      await storageService.remove(_configIndexKey);

      // Clear result cache
      final resultIndex = _decodeIndex(storageService.getString(_resultIndexKey));
      for (final id in resultIndex) {
        await storageService.remove('$_resultKeyPrefix$id');
      }
      final roomIndex =
          _decodeIndex(storageService.getString(_resultsByRoomIndexKey));
      for (final roomId in roomIndex) {
        await storageService.remove('$_resultsByRoomKeyPrefix$roomId');
      }
      final configIndexResults =
          _decodeIndex(storageService.getString(_resultsByConfigIndexKey));
      for (final configId in configIndexResults) {
        await storageService.remove('$_resultsByConfigKeyPrefix$configId');
      }
      await storageService.remove(_resultsKey);
      await storageService.remove(_resultCacheTimestampKey);
      await storageService.remove(_resultIndexKey);
      await storageService.remove(_resultsByRoomIndexKey);
      await storageService.remove(_resultsByConfigIndexKey);

      _logger.i('Speed test cache cleared');
    } on Exception catch (e) {
      _logger.e('Failed to clear speed test cache: $e');
    }
  }
}
