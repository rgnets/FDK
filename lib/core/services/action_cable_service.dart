/// ActionCable WebSocket service for Rails server communication.
///
/// ## Usage
///
/// ```dart
/// final cable = ActionCableService();
///
/// // Connect using stored credentials
/// await cable.connect();
///
/// // Subscribe to RxgChannel
/// final subscription = cable.subscribe('RxgChannel');
///
/// // Listen for messages
/// subscription.messages.listen((msg) {
///   print('Action: ${msg.action}, Data: ${msg.data}');
/// });
///
/// // Perform actions after subscription confirmed
/// cable.eventBus.channelSubscribed.listen((event) {
///   cable.perform('RxgChannel', 'subscribe_to_resource', {
///     'resource_type': 'access_points',
///   });
/// });
/// ```
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';

/// WebSocket connection states for ActionCable.
enum ActionCableConnectionState {
  /// Not connected - initial state or after connection dropped
  disconnected,

  /// Attempting to establish connection
  connecting,

  /// Successfully connected to ActionCable server
  connected,

  /// Connection lost unexpectedly, will attempt reconnect
  reconnecting,

  /// Connection failed permanently (auth error, max retries, etc)
  failed,

  /// Intentionally disconnected by calling disconnect()
  closed,
}

/// Extension methods for ActionCableConnectionState
extension ActionCableConnectionStateExtension on ActionCableConnectionState {
  /// Whether the WebSocket is open and can send messages
  bool get isConnected => this == ActionCableConnectionState.connected;

  /// Whether we can call send() on the WebSocket
  bool get canSendMessages => this == ActionCableConnectionState.connected;

  /// Whether reconnection is in progress
  bool get isReconnecting => this == ActionCableConnectionState.reconnecting;

  /// Whether the connection is in progress (connecting or reconnecting)
  bool get isConnecting =>
      this == ActionCableConnectionState.connecting ||
      this == ActionCableConnectionState.reconnecting;

  /// Human-readable status message
  String get message {
    switch (this) {
      case ActionCableConnectionState.disconnected:
        return 'Disconnected';
      case ActionCableConnectionState.connecting:
        return 'Connecting...';
      case ActionCableConnectionState.connected:
        return 'Connected';
      case ActionCableConnectionState.reconnecting:
        return 'Reconnecting...';
      case ActionCableConnectionState.failed:
        return 'Connection failed';
      case ActionCableConnectionState.closed:
        return 'Closed';
    }
  }
}

/// Detailed connection status with metadata
class ActionCableConnectionStatus {
  /// Current connection state
  final ActionCableConnectionState state;

  /// When this status was recorded
  final DateTime timestamp;

  /// Error details if connection failed
  final String? errorDetails;

  /// Number of reconnection attempts made
  final int reconnectAttempts;

  /// Last measured round-trip latency (ping/pong)
  final Duration? lastLatency;

  const ActionCableConnectionStatus({
    required this.state,
    required this.timestamp,
    this.errorDetails,
    this.reconnectAttempts = 0,
    this.lastLatency,
  });

  /// Create a disconnected status
  factory ActionCableConnectionStatus.disconnected() =>
      ActionCableConnectionStatus(
        state: ActionCableConnectionState.disconnected,
        timestamp: DateTime.now(),
      );

  /// Create a connecting status
  factory ActionCableConnectionStatus.connecting() =>
      ActionCableConnectionStatus(
        state: ActionCableConnectionState.connecting,
        timestamp: DateTime.now(),
      );

  /// Create a connected status
  factory ActionCableConnectionStatus.connected({Duration? latency}) =>
      ActionCableConnectionStatus(
        state: ActionCableConnectionState.connected,
        timestamp: DateTime.now(),
        lastLatency: latency,
      );

  /// Create a failed status with error details
  factory ActionCableConnectionStatus.failed(
    String error, {
    int reconnectAttempts = 0,
  }) =>
      ActionCableConnectionStatus(
        state: ActionCableConnectionState.failed,
        timestamp: DateTime.now(),
        errorDetails: error,
        reconnectAttempts: reconnectAttempts,
      );

  /// Create a copy with updated values
  ActionCableConnectionStatus copyWith({
    ActionCableConnectionState? state,
    DateTime? timestamp,
    String? errorDetails,
    int? reconnectAttempts,
    Duration? lastLatency,
  }) {
    return ActionCableConnectionStatus(
      state: state ?? this.state,
      timestamp: timestamp ?? this.timestamp,
      errorDetails: errorDetails ?? this.errorDetails,
      reconnectAttempts: reconnectAttempts ?? this.reconnectAttempts,
      lastLatency: lastLatency ?? this.lastLatency,
    );
  }

  @override
  String toString() {
    return 'ActionCableConnectionStatus(state: ${state.message}, '
        'attempts: $reconnectAttempts, error: $errorDetails)';
  }
}

/// ActionCable service for WebSocket communication with Rails server
class ActionCableService {
  // Factory constructor for production (singleton)
  static ActionCableService? _instance;

  /// Get the singleton instance. Creates one if it doesn't exist.
  factory ActionCableService() {
    _instance ??= ActionCableService._internal();
    return _instance!;
  }

  /// Create a new, isolated instance for testing.
  /// This bypasses the singleton pattern and creates a fresh instance.
  @visibleForTesting
  factory ActionCableService.forTesting() {
    return ActionCableService._internal();
  }

  /// Reset the singleton instance (for testing only).
  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  ActionCableService._internal();

  // Connection State (ValueNotifiers for reactive UI)

  /// Detailed connection status with metadata
  final ValueNotifier<ActionCableConnectionStatus> status =
      ValueNotifier(ActionCableConnectionStatus.disconnected());

  /// Simple connection state enum
  final ValueNotifier<ActionCableConnectionState> state =
      ValueNotifier(ActionCableConnectionState.disconnected);

  // Channel Subscriptions

  /// Map of channel name -> subscription
  final Map<String, ChannelSubscription> _subscriptions = {};

  // Event Bus

  /// Event bus for broadcasting WebSocket events
  final ActionCableEventBus _eventBus = ActionCableEventBus();

  /// Public access to event bus for listeners
  ActionCableEventBus get eventBus => _eventBus;

  // Public Getters

  /// Whether WebSocket is connected
  bool get isConnected => state.value == ActionCableConnectionState.connected;

  /// List of subscribed channel names
  List<String> get activeChannels => _subscriptions.keys.toList();

  /// Get subscription by channel name
  ChannelSubscription? getSubscription(String channelName) =>
      _subscriptions[channelName];

  // Channel Subscription Methods

  /// Subscribe to a channel
  ///
  /// Returns a ChannelSubscription object with a messages stream you can listen to.
  ChannelSubscription subscribe(
    String channelName, {
    Map<String, dynamic>? params,
  }) {
    LoggerService.info(
      'Subscribing to channel: $channelName',
      tag: 'ActionCableService',
    );

    // Return existing subscription if already subscribed
    if (_subscriptions.containsKey(channelName)) {
      LoggerService.debug(
        'Already subscribed to $channelName',
        tag: 'ActionCableService',
      );
      return _subscriptions[channelName]!;
    }

    // Create new subscription object
    final subscription = ChannelSubscription(
      channelName: channelName,
      channelParams: params,
    );
    _subscriptions[channelName] = subscription;

    return subscription;
  }

  /// Unsubscribe from a channel
  void unsubscribe(String channelName) {
    LoggerService.info(
      'Unsubscribing from: $channelName',
      tag: 'ActionCableService',
    );

    final subscription = _subscriptions.remove(channelName);
    if (subscription != null) {
      subscription.markUnsubscribed();
      subscription.dispose();
    }
  }

  /// Disconnect from server
  void disconnect() {
    LoggerService.info(
      'Disconnecting from ActionCable',
      tag: 'ActionCableService',
    );

    // Clean up all channel subscriptions
    for (final sub in _subscriptions.values) {
      sub.markUnsubscribed();
      sub.dispose();
    }
    _subscriptions.clear();

    _updateState(ActionCableConnectionState.closed);
  }

  /// Update connection state and notify listeners
  void _updateState(ActionCableConnectionState newState, {String? error}) {
    if (state.value != newState) {
      LoggerService.debug(
        'ActionCable state: ${state.value.message} -> ${newState.message}',
        tag: 'ActionCableService',
      );
    }

    state.value = newState;
    status.value = ActionCableConnectionStatus(
      state: newState,
      timestamp: DateTime.now(),
      errorDetails: error,
    );

    // Broadcast to event bus
    _eventBus.emitConnectionChanged(newState, error: error);
  }

  /// Releases resources. Call when the service is no longer needed.
  void dispose() {
    LoggerService.info(
      'Disposing ActionCableService',
      tag: 'ActionCableService',
    );
    disconnect();
    status.dispose();
    state.dispose();
    _eventBus.dispose();
  }
}

/// Represents a subscription to an ActionCable channel
class ChannelSubscription {
  /// The channel name (e.g., 'RxgChannel')
  final String channelName;

  /// Optional parameters sent when subscribing
  final Map<String, dynamic>? channelParams;

  /// When this subscription was created
  final DateTime subscribedAt;

  /// Stream controller for messages on THIS channel only
  final StreamController<ChannelMessage> _messageController =
      StreamController<ChannelMessage>.broadcast();

  /// Listen to messages from this channel
  Stream<ChannelMessage> get messages => _messageController.stream;

  /// Whether the server has confirmed this subscription
  bool _isSubscribed = false;
  bool get isSubscribed => _isSubscribed;

  ChannelSubscription({
    required this.channelName,
    this.channelParams,
  }) : subscribedAt = DateTime.now();

  /// Mark as subscribed (called when server confirms)
  void markSubscribed() => _isSubscribed = true;

  /// Mark as unsubscribed
  void markUnsubscribed() => _isSubscribed = false;

  /// Push a message to listeners
  void pushMessage(ChannelMessage message) {
    if (!_messageController.isClosed) {
      _messageController.add(message);
    }
  }

  /// Clean up resources
  void dispose() {
    _messageController.close();
  }
}

/// Message received from a channel
class ChannelMessage {
  /// The action name (e.g., 'resource_updated', 'created', 'deleted')
  final String? action;

  /// The full message data as a Map
  final Map<String, dynamic> data;

  /// When this message was received client-side
  final DateTime receivedAt;

  /// Optional request_id if you sent one with perform()
  final String? requestId;

  ChannelMessage({
    this.action,
    required this.data,
    this.requestId,
  }) : receivedAt = DateTime.now();

  /// Parse a message from the raw JSON data
  factory ChannelMessage.fromJson(Map<String, dynamic> json) {
    return ChannelMessage(
      action: json['action'] as String?,
      data: json,
      requestId: json['request_id'] as String?,
    );
  }

  @override
  String toString() {
    return 'ChannelMessage(action: $action, requestId: $requestId, data: $data)';
  }
}

/// Singleton event bus for WebSocket events
class ActionCableEventBus {
  // Event Streams (broadcast = multiple listeners allowed)

  /// Fires when WebSocket connection state changes
  final _connectionChangedController =
      StreamController<ActionCableConnectionEvent>.broadcast();

  /// Fires when channel subscription is confirmed by server
  final _channelSubscribedController =
      StreamController<ChannelSubscribedEvent>.broadcast();

  /// Fires when message received from server
  final _channelMessageController =
      StreamController<ChannelMessageEvent>.broadcast();

  /// Fires when WebSocket error occurs
  final _errorController = StreamController<ActionCableErrorEvent>.broadcast();

  /// Fires when channel subscription fails (timeout, rejected, disconnected)
  final _channelSubscriptionFailedController =
      StreamController<ChannelSubscriptionFailedEvent>.broadcast();

  // Public Streams (listeners subscribe to these)

  /// Connection state changes (connected, disconnected, reconnecting, etc.)
  Stream<ActionCableConnectionEvent> get connectionChanged =>
      _connectionChangedController.stream;

  /// Channel subscription confirmations
  Stream<ChannelSubscribedEvent> get channelSubscribed =>
      _channelSubscribedController.stream;

  /// Messages from server (AP updated, resource created, etc.)
  Stream<ChannelMessageEvent> get channelMessage =>
      _channelMessageController.stream;

  /// WebSocket errors
  Stream<ActionCableErrorEvent> get errors => _errorController.stream;

  /// Channel subscription failures (timeout, rejected, disconnected)
  Stream<ChannelSubscriptionFailedEvent> get channelSubscriptionFailed =>
      _channelSubscriptionFailedController.stream;

  // Emit Methods

  /// Broadcast connection state change
  void emitConnectionChanged(ActionCableConnectionState state, {String? error}) {
    if (!_connectionChangedController.isClosed) {
      _connectionChangedController.add(ActionCableConnectionEvent(
        state: state,
        errorDetails: error,
        timestamp: DateTime.now(),
      ));
      LoggerService.debug(
        'Emitted connection changed: ${state.message}',
        tag: 'ActionCableEventBus',
      );
    }
  }

  /// Broadcast channel subscribed
  void emitChannelSubscribed(String channelName) {
    if (!_channelSubscribedController.isClosed) {
      _channelSubscribedController.add(ChannelSubscribedEvent(
        channelName: channelName,
        timestamp: DateTime.now(),
      ));
      LoggerService.debug(
        'Emitted channel subscribed: $channelName',
        tag: 'ActionCableEventBus',
      );
    }
  }

  /// Broadcast message from server
  void emitChannelMessage(String channelName, Map<String, dynamic> data) {
    if (!_channelMessageController.isClosed) {
      _channelMessageController.add(ChannelMessageEvent(
        channelName: channelName,
        data: data,
        timestamp: DateTime.now(),
      ));
      LoggerService.debug(
        'Emitted channel message: $channelName -> ${data['action'] ?? 'no action'}',
        tag: 'ActionCableEventBus',
      );
    }
  }

  /// Broadcast error
  void emitError(String message, {Object? error}) {
    if (!_errorController.isClosed) {
      _errorController.add(ActionCableErrorEvent(
        message: message,
        error: error,
        timestamp: DateTime.now(),
      ));
      LoggerService.warning(
        'Emitted error: $message',
        tag: 'ActionCableEventBus',
      );
    }
  }

  /// Broadcast channel subscription failure
  void emitChannelSubscriptionFailed(
    String channelName,
    SubscriptionFailureReason reason, {
    String? errorDetails,
  }) {
    if (!_channelSubscriptionFailedController.isClosed) {
      _channelSubscriptionFailedController.add(ChannelSubscriptionFailedEvent(
        channelName: channelName,
        reason: reason,
        errorDetails: errorDetails,
        timestamp: DateTime.now(),
      ));
      LoggerService.warning(
        'Emitted subscription failed: $channelName (${reason.name})',
        tag: 'ActionCableEventBus',
      );
    }
  }

  /// Clean up all streams
  void dispose() {
    _connectionChangedController.close();
    _channelSubscribedController.close();
    _channelMessageController.close();
    _errorController.close();
    _channelSubscriptionFailedController.close();
    LoggerService.info(
      'Disposed ActionCableEventBus',
      tag: 'ActionCableEventBus',
    );
  }
}

// Event Classes

/// Event: WebSocket connection state changed
class ActionCableConnectionEvent {
  final ActionCableConnectionState state;
  final String? errorDetails;
  final DateTime timestamp;

  ActionCableConnectionEvent({
    required this.state,
    this.errorDetails,
    required this.timestamp,
  });

  @override
  String toString() =>
      'ActionCableConnectionEvent(${state.message}, error: $errorDetails)';
}

/// Event: Channel subscription confirmed
class ChannelSubscribedEvent {
  final String channelName;
  final DateTime timestamp;

  ChannelSubscribedEvent({
    required this.channelName,
    required this.timestamp,
  });

  @override
  String toString() => 'ChannelSubscribedEvent($channelName)';
}

/// Event: Message received from server
class ChannelMessageEvent {
  final String channelName;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  ChannelMessageEvent({
    required this.channelName,
    required this.data,
    required this.timestamp,
  });

  /// Get the action from the message (e.g., 'resource_updated')
  String? get action => data['action'] as String?;

  /// Get the resource type (e.g., 'access_points')
  String? get resourceType => data['resource_type'] as String?;

  @override
  String toString() => 'ChannelMessageEvent($channelName, action: $action)';
}

/// Event: WebSocket error occurred
class ActionCableErrorEvent {
  final String message;
  final Object? error;
  final DateTime timestamp;

  ActionCableErrorEvent({
    required this.message,
    this.error,
    required this.timestamp,
  });

  @override
  String toString() => 'ActionCableErrorEvent($message)';
}

/// Reason why a channel subscription failed
enum SubscriptionFailureReason {
  /// Server didn't confirm subscription within timeout.
  timeout,

  /// Server explicitly rejected the subscription.
  rejected,

  /// Channel was disconnected unexpectedly
  disconnected,
}

/// Event: Channel subscription failed
class ChannelSubscriptionFailedEvent {
  final String channelName;
  final SubscriptionFailureReason reason;
  final String? errorDetails;
  final DateTime timestamp;

  ChannelSubscriptionFailedEvent({
    required this.channelName,
    required this.reason,
    this.errorDetails,
    required this.timestamp,
  });

  @override
  String toString() =>
      'ChannelSubscriptionFailedEvent($channelName, reason: ${reason.name})';
}
