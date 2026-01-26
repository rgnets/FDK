import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rgnets_fdk/core/providers/core_providers.dart';
import 'package:rgnets_fdk/core/services/message_center_service.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/app_message.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/message_metrics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'message_center_provider.g.dart';

/// Provider for the MessageCenterService singleton
@Riverpod(keepAlive: true)
MessageCenterService messageCenterService(Ref ref) {
  final service = MessageCenterService();
  service.initialize();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

/// State for the message center notifier
class MessageCenterState {
  const MessageCenterState({
    this.messages = const [],
    this.metrics = const MessageMetrics(),
    this.isInitialized = false,
  });

  final List<AppMessage> messages;
  final MessageMetrics metrics;
  final bool isInitialized;

  MessageCenterState copyWith({
    List<AppMessage>? messages,
    MessageMetrics? metrics,
    bool? isInitialized,
  }) {
    return MessageCenterState(
      messages: messages ?? this.messages,
      metrics: metrics ?? this.metrics,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Main provider for the message center UI
@Riverpod(keepAlive: true)
class MessageCenterNotifier extends _$MessageCenterNotifier {
  StreamSubscription<AppMessage>? _messageSubscription;
  StreamSubscription<MessageMetrics>? _metricsSubscription;

  @override
  MessageCenterState build() {
    final service = ref.watch(messageCenterServiceProvider);

    // Listen to message stream
    _messageSubscription?.cancel();
    _messageSubscription = service.messageStream.listen((message) {
      final currentMessages = state.messages;
      state = state.copyWith(
        messages: [message, ...currentMessages].take(50).toList(),
      );
    });

    // Listen to metrics stream
    _metricsSubscription?.cancel();
    _metricsSubscription = service.metricsStream.listen((metrics) {
      state = state.copyWith(metrics: metrics);
    });

    ref.onDispose(() {
      _messageSubscription?.cancel();
      _metricsSubscription?.cancel();
    });

    return MessageCenterState(
      metrics: service.getMetrics(),
      isInitialized: true,
    );
  }

  /// Show an info message
  void showInfo(
    String content, {
    String? actionLabel,
    String? actionKey,
    Map<String, dynamic>? actionData,
    String? sourceContext,
  }) {
    final service = ref.read(messageCenterServiceProvider);
    service.showInfo(
      content,
      actionLabel: actionLabel,
      actionKey: actionKey,
      actionData: actionData,
      sourceContext: sourceContext,
    );
  }

  /// Show a success message
  void showSuccess(
    String content, {
    String? actionLabel,
    String? actionKey,
    Map<String, dynamic>? actionData,
    String? sourceContext,
  }) {
    final service = ref.read(messageCenterServiceProvider);
    service.showSuccess(
      content,
      actionLabel: actionLabel,
      actionKey: actionKey,
      actionData: actionData,
      sourceContext: sourceContext,
    );
  }

  /// Show a warning message
  void showWarning(
    String content, {
    MessageCategory category = MessageCategory.general,
    String? actionLabel,
    String? actionKey,
    Map<String, dynamic>? actionData,
    String? sourceContext,
  }) {
    final service = ref.read(messageCenterServiceProvider);
    service.showWarning(
      content,
      category: category,
      actionLabel: actionLabel,
      actionKey: actionKey,
      actionData: actionData,
      sourceContext: sourceContext,
    );
  }

  /// Show an error message
  void showError(
    String content, {
    MessageCategory category = MessageCategory.general,
    String? actionLabel,
    String? actionKey,
    Map<String, dynamic>? actionData,
    String? sourceContext,
  }) {
    final service = ref.read(messageCenterServiceProvider);
    service.showError(
      content,
      category: category,
      actionLabel: actionLabel,
      actionKey: actionKey,
      actionData: actionData,
      sourceContext: sourceContext,
    );
  }

  /// Show a critical message
  void showCritical(
    String content, {
    MessageCategory category = MessageCategory.system,
    String? actionLabel,
    String? actionKey,
    Map<String, dynamic>? actionData,
    String? sourceContext,
  }) {
    final service = ref.read(messageCenterServiceProvider);
    service.showCritical(
      content,
      category: category,
      actionLabel: actionLabel,
      actionKey: actionKey,
      actionData: actionData,
      sourceContext: sourceContext,
    );
  }

  /// Register an action callback
  void registerAction(String actionKey, MessageActionCallback callback) {
    final service = ref.read(messageCenterServiceProvider);
    service.registerAction(actionKey, callback);
  }

  /// Unregister an action callback
  void unregisterAction(String actionKey) {
    final service = ref.read(messageCenterServiceProvider);
    service.unregisterAction(actionKey);
  }

  /// Execute a registered action
  void executeAction(String actionKey, {Map<String, dynamic>? data}) {
    final service = ref.read(messageCenterServiceProvider);
    service.executeAction(actionKey, data: data);
  }

  /// Clear all messages
  void clear() {
    final service = ref.read(messageCenterServiceProvider);
    service.clear();
    state = const MessageCenterState(isInitialized: true);
  }

  /// Get current metrics
  MessageMetrics getMetrics() {
    final service = ref.read(messageCenterServiceProvider);
    return service.getMetrics();
  }
}

/// Provider for unread message count
@riverpod
int unreadMessageCount(Ref ref) {
  final state = ref.watch(messageCenterNotifierProvider);
  return state.messages.where((m) => !m.isRead).length;
}

/// Provider for recent messages (last 10)
@riverpod
List<AppMessage> recentMessages(Ref ref) {
  final state = ref.watch(messageCenterNotifierProvider);
  return state.messages.take(10).toList();
}

/// Provider for message metrics
@riverpod
MessageMetrics messageMetrics(Ref ref) {
  final state = ref.watch(messageCenterNotifierProvider);
  return state.metrics;
}
