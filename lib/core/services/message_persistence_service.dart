import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/app_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting critical messages across app restarts.
///
/// Handles:
/// - Persisting error/critical messages (max 10)
/// - Last error tracking with timestamp
/// - Clean shutdown detection
/// - Message expiry (24 hours)
class MessagePersistenceService {
  MessagePersistenceService(this._prefs);

  final SharedPreferences _prefs;

  // Storage keys
  static const String _keyPersistedMessages = 'persisted_messages';
  static const String _keyLastError = 'last_error';
  static const String _keyLastErrorTime = 'last_error_time';
  static const String _keyCleanShutdown = 'clean_shutdown';
  static const String _keyLastShutdownTime = 'last_shutdown_time';

  // Configuration
  static const int maxPersistedMessages = 10;
  static const Duration messageExpiry = Duration(hours: 24);
  static const Duration crashDetectionWindow = Duration(minutes: 5);

  /// Persist a critical message
  Future<void> persistMessage(AppMessage message) async {
    if (!message.shouldPersist) return;

    final messages = await loadPersistedMessages();
    messages.add(message);

    // Keep only the most recent messages
    while (messages.length > maxPersistedMessages) {
      messages.removeAt(0);
    }

    await _saveMessages(messages);

    // Also track as last error if applicable
    if (message.type == MessageType.error ||
        message.type == MessageType.critical) {
      await _prefs.setString(_keyLastError, message.content);
      await _prefs.setString(
          _keyLastErrorTime, message.timestamp.toIso8601String());
    }
  }

  /// Load all persisted messages, filtering out expired ones
  Future<List<AppMessage>> loadPersistedMessages() async {
    final jsonString = _prefs.getString(_keyPersistedMessages);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      final now = DateTime.now();
      final messages = <AppMessage>[];

      for (final jsonMap in jsonList) {
        final message = _messageFromJson(jsonMap as Map<String, dynamic>);
        if (message != null && now.difference(message.timestamp) < messageExpiry) {
          messages.add(message);
        }
      }

      return messages;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[MessagePersistenceService] Error loading messages: $e');
      }
      return [];
    }
  }

  /// Clear all persisted messages
  Future<void> clearPersistedMessages() async {
    await _prefs.remove(_keyPersistedMessages);
    await _prefs.remove(_keyLastError);
    await _prefs.remove(_keyLastErrorTime);
  }

  /// Get the last error message
  String? getLastError() {
    return _prefs.getString(_keyLastError);
  }

  /// Get the last error timestamp
  DateTime? getLastErrorTime() {
    final timeString = _prefs.getString(_keyLastErrorTime);
    if (timeString == null) return null;
    return DateTime.tryParse(timeString);
  }

  /// Check if the app crashed recently (unclean shutdown within window)
  bool didCrashRecently() {
    final cleanShutdown = _prefs.getBool(_keyCleanShutdown) ?? true;
    if (cleanShutdown) return false;

    final lastShutdownString = _prefs.getString(_keyLastShutdownTime);
    if (lastShutdownString == null) return false;

    final lastShutdown = DateTime.tryParse(lastShutdownString);
    if (lastShutdown == null) return false;

    return DateTime.now().difference(lastShutdown) < crashDetectionWindow;
  }

  /// Mark the start of the app (potential crash detection)
  Future<void> markAppStart() async {
    await _prefs.setBool(_keyCleanShutdown, false);
    await _prefs.setString(_keyLastShutdownTime, DateTime.now().toIso8601String());
  }

  /// Mark clean shutdown
  Future<void> markCleanShutdown() async {
    await _prefs.setBool(_keyCleanShutdown, true);
    await _prefs.setString(_keyLastShutdownTime, DateTime.now().toIso8601String());
  }

  /// Clear persisted messages after normal shutdown (called during clean shutdown)
  Future<void> cleanupAfterNormalShutdown() async {
    // Keep last error for debugging, but clear the message list
    await _prefs.remove(_keyPersistedMessages);
  }

  Future<void> _saveMessages(List<AppMessage> messages) async {
    final jsonList = messages.map(_messageToJson).toList();
    final jsonString = json.encode(jsonList);
    await _prefs.setString(_keyPersistedMessages, jsonString);
  }

  Map<String, dynamic> _messageToJson(AppMessage message) {
    return {
      'id': message.id,
      'content': message.content,
      'type': message.type.name,
      'category': message.category.name,
      'priority': message.priority.name,
      'timestamp': message.timestamp.toIso8601String(),
      'isRead': message.isRead,
      'isDismissed': message.isDismissed,
      'sourceContext': message.sourceContext,
      'deduplicationKey': message.deduplicationKey,
      if (message.action != null)
        'action': {
          'label': message.action!.label,
          'actionKey': message.action!.actionKey,
          'data': message.action!.data,
        },
      if (message.metadata != null) 'metadata': message.metadata,
    };
  }

  AppMessage? _messageFromJson(Map<String, dynamic> json) {
    try {
      MessageAction? action;
      if (json['action'] != null) {
        final actionJson = json['action'] as Map<String, dynamic>;
        action = MessageAction(
          label: actionJson['label'] as String,
          actionKey: actionJson['actionKey'] as String,
          data: actionJson['data'] as Map<String, dynamic>?,
        );
      }

      return AppMessage(
        id: json['id'] as String,
        content: json['content'] as String,
        type: MessageType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => MessageType.error,
        ),
        category: MessageCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => MessageCategory.general,
        ),
        priority: MessagePriority.values.firstWhere(
          (e) => e.name == json['priority'],
          orElse: () => MessagePriority.normal,
        ),
        timestamp: DateTime.parse(json['timestamp'] as String),
        isRead: json['isRead'] as bool? ?? false,
        isDismissed: json['isDismissed'] as bool? ?? false,
        action: action,
        sourceContext: json['sourceContext'] as String?,
        deduplicationKey: json['deduplicationKey'] as String?,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[MessagePersistenceService] Error parsing message: $e');
      }
      return null;
    }
  }
}
