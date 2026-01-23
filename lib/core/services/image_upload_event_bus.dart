/// Global event bus for image upload notifications.
///
/// Enables cross-view communication to update list views when images are uploaded.
/// This service ensures that room detail views update automatically
/// when images are uploaded in device detail views.
library;

import 'dart:async';

import 'package:rgnets_fdk/core/services/logger_service.dart';

/// Status of an upload operation
enum UploadStatus {
  /// Upload is pending
  pending,

  /// Upload is in progress
  uploading,

  /// Upload completed successfully
  completed,

  /// Upload failed
  failed,
}

/// Singleton event bus for image upload events
class ImageUploadEventBus {
  static ImageUploadEventBus? _instance;

  factory ImageUploadEventBus() {
    _instance ??= ImageUploadEventBus._internal();
    return _instance!;
  }

  ImageUploadEventBus._internal() {
    LoggerService.info('Initializing ImageUploadEventBus', tag: 'ImageUploadEventBus');
  }

  /// Reset singleton for testing purposes only
  static void resetForTesting() {
    _instance?.dispose();
    _instance = null;
  }

  // Event streams
  final _imageUploadedController =
      StreamController<ImageUploadEvent>.broadcast();
  final _cacheInvalidatedController =
      StreamController<CacheInvalidationEvent>.broadcast();
  final _uploadProgressController =
      StreamController<UploadProgressEvent>.broadcast();

  // Public streams
  Stream<ImageUploadEvent> get imageUploaded => _imageUploadedController.stream;
  Stream<CacheInvalidationEvent> get cacheInvalidated =>
      _cacheInvalidatedController.stream;
  Stream<UploadProgressEvent> get uploadProgress =>
      _uploadProgressController.stream;

  // Recent events for debugging (max 20)
  final List<dynamic> _recentEvents = [];
  List<dynamic> get recentEvents => List.unmodifiable(_recentEvents);

  /// Notify that an image has been uploaded
  void notifyImageUploaded({
    required String deviceType,
    required String deviceId,
    required String? roomId,
    required int newImageCount,
  }) {
    final event = ImageUploadEvent(
      deviceType: deviceType,
      deviceId: deviceId,
      roomId: roomId,
      newImageCount: newImageCount,
      timestamp: DateTime.now(),
    );

    _addToHistory(event);
    _imageUploadedController.add(event);

    LoggerService.info(
      'Image uploaded: $deviceType-$deviceId in room $roomId (count: $newImageCount)',
      tag: 'ImageUploadEventBus',
    );
  }

  /// Notify that cache should be invalidated for a device
  void notifyCacheInvalidated({
    required String deviceType,
    required String deviceId,
  }) {
    final event = CacheInvalidationEvent(
      deviceType: deviceType,
      deviceId: deviceId,
      timestamp: DateTime.now(),
    );

    _addToHistory(event);
    _cacheInvalidatedController.add(event);

    LoggerService.debug(
      'Cache invalidated: $deviceType-$deviceId',
      tag: 'ImageUploadEventBus',
    );
  }

  /// Notify upload progress update
  void notifyUploadProgress({
    required String deviceId,
    required int current,
    required int total,
    required UploadStatus status,
  }) {
    final event = UploadProgressEvent(
      deviceId: deviceId,
      current: current,
      total: total,
      status: status,
      timestamp: DateTime.now(),
    );

    _addToHistory(event);
    _uploadProgressController.add(event);

    LoggerService.debug(
      'Upload progress: $deviceId - $current/$total ($status)',
      tag: 'ImageUploadEventBus',
    );
  }

  /// Add event to history (maintain max 20 entries)
  void _addToHistory(dynamic event) {
    _recentEvents.add(event);
    if (_recentEvents.length > 20) {
      _recentEvents.removeAt(0);
    }
  }

  /// Clear event history
  void clearHistory() {
    _recentEvents.clear();
    LoggerService.debug('Event history cleared', tag: 'ImageUploadEventBus');
  }

  /// Get event statistics
  Map<String, dynamic> getStats() {
    final stats = <String, int>{};

    for (final event in _recentEvents) {
      final eventType = event.runtimeType.toString();
      stats[eventType] = (stats[eventType] ?? 0) + 1;
    }

    return {
      'totalEvents': _recentEvents.length,
      'eventTypes': stats,
      'oldestEvent':
          _recentEvents.isEmpty ? null : _recentEvents.first.timestamp,
      'newestEvent':
          _recentEvents.isEmpty ? null : _recentEvents.last.timestamp,
    };
  }

  /// Dispose of resources
  void dispose() {
    _imageUploadedController.close();
    _cacheInvalidatedController.close();
    _uploadProgressController.close();
    LoggerService.info('Disposing ImageUploadEventBus', tag: 'ImageUploadEventBus');
  }
}

/// Event fired when an image is uploaded
class ImageUploadEvent {
  final String deviceType;
  final String deviceId;
  final String? roomId;
  final int newImageCount;
  final DateTime timestamp;

  ImageUploadEvent({
    required this.deviceType,
    required this.deviceId,
    required this.roomId,
    required this.newImageCount,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'ImageUploadEvent($deviceType-$deviceId, room: $roomId, count: $newImageCount)';
  }
}

/// Event fired when cache should be invalidated
class CacheInvalidationEvent {
  final String deviceType;
  final String deviceId;
  final DateTime timestamp;

  CacheInvalidationEvent({
    required this.deviceType,
    required this.deviceId,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'CacheInvalidationEvent($deviceType-$deviceId)';
  }
}

/// Event fired for upload progress updates
class UploadProgressEvent {
  final String deviceId;
  final int current;
  final int total;
  final UploadStatus status;
  final DateTime timestamp;

  UploadProgressEvent({
    required this.deviceId,
    required this.current,
    required this.total,
    required this.status,
    required this.timestamp,
  });

  @override
  String toString() {
    return 'UploadProgressEvent($deviceId: $current/$total, $status)';
  }
}
