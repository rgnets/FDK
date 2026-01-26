import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:rgnets_fdk/features/messages/data/models/message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for messages using SharedPreferences
abstract interface class MessageLocalDataSource {
  /// Get all stored messages
  Future<List<MessageModel>> getMessages();

  /// Save messages to local storage
  Future<void> saveMessages(List<MessageModel> messages);

  /// Add a single message
  Future<void> addMessage(MessageModel message);

  /// Update a message
  Future<void> updateMessage(MessageModel message);

  /// Delete a message by ID
  Future<void> deleteMessage(String id);

  /// Clear all messages
  Future<void> clearMessages();
}

/// Implementation of MessageLocalDataSource using SharedPreferences
class MessageLocalDataSourceImpl implements MessageLocalDataSource {
  MessageLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const String _messagesKey = 'messages_list';
  static const int _maxMessages = 100;

  @override
  Future<List<MessageModel>> getMessages() async {
    final jsonString = _prefs.getString(_messagesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((j) => MessageModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[MessageLocalDataSource] Error loading messages: $e');
      }
      return [];
    }
  }

  @override
  Future<void> saveMessages(List<MessageModel> messages) async {
    // Limit the number of stored messages
    var messagesToSave = messages;
    if (messages.length > _maxMessages) {
      messagesToSave = messages.sublist(messages.length - _maxMessages);
    }

    final jsonList = messagesToSave.map((m) => m.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await _prefs.setString(_messagesKey, jsonString);
  }

  @override
  Future<void> addMessage(MessageModel message) async {
    final messages = await getMessages();
    messages.add(message);
    await saveMessages(messages);
  }

  @override
  Future<void> updateMessage(MessageModel message) async {
    final messages = await getMessages();
    final index = messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      messages[index] = message;
      await saveMessages(messages);
    }
  }

  @override
  Future<void> deleteMessage(String id) async {
    final messages = await getMessages();
    messages.removeWhere((m) => m.id == id);
    await saveMessages(messages);
  }

  @override
  Future<void> clearMessages() async {
    await _prefs.remove(_messagesKey);
  }
}
