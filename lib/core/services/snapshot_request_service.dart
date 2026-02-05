import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:rgnets_fdk/core/services/websocket_service.dart';

/// Service responsible for sending WebSocket subscription and snapshot requests.
///
/// This service encapsulates the logic for subscribing to resource types
/// and requesting data snapshots via WebSocket.
class SnapshotRequestService {
  SnapshotRequestService({
    required WebSocketService webSocketService,
    Logger? logger,
  })  : _webSocketService = webSocketService,
        _logger = logger ?? Logger();

  static const String _channelName = 'RxgChannel';

  final WebSocketService _webSocketService;
  final Logger _logger;

  /// Get the channel identifier for WebSocket messages
  String get channelIdentifier => jsonEncode(const {'channel': _channelName});

  /// Send a subscription request for a resource type
  void sendSubscribe(String resourceType) {
    final payload = jsonEncode({
      'action': 'subscribe_to_resource',
      'resource_type': resourceType,
    });
    try {
      _webSocketService.send({
        'command': 'message',
        'identifier': channelIdentifier,
        'data': payload,
      });
    } on StateError catch (e) {
      _logger.w(
        'SnapshotRequestService: Subscribe send failed (connection closed): $e',
      );
    }
  }

  /// Send a snapshot request for a resource type
  void sendSnapshotRequest(String resourceType, {int pageSize = 10000}) {
    final requestId =
        'snapshot-$resourceType-${DateTime.now().millisecondsSinceEpoch}';
    final payload = jsonEncode({
      'action': 'resource_action',
      'resource_type': resourceType,
      'crud_action': 'index',
      'page': 1,
      'page_size': pageSize,
      'request_id': requestId,
    });
    try {
      _webSocketService.send({
        'command': 'message',
        'identifier': channelIdentifier,
        'data': payload,
      });
    } on StateError catch (e) {
      _logger.w(
        'SnapshotRequestService: Snapshot request failed (connection closed): $e',
      );
    }
  }
}
