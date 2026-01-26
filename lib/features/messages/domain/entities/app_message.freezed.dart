// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MessageAction {
  /// Display label for the action button
  String get label => throw _privateConstructorUsedError;

  /// Unique key identifying this action (used for callback lookup)
  String get actionKey => throw _privateConstructorUsedError;

  /// Optional data to pass to the action callback
  Map<String, dynamic>? get data => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String label, String actionKey, Map<String, dynamic>? data)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String label, String actionKey, Map<String, dynamic>? data)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String label, String actionKey, Map<String, dynamic>? data)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MessageAction value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MessageAction value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MessageAction value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $MessageActionCopyWith<MessageAction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageActionCopyWith<$Res> {
  factory $MessageActionCopyWith(
          MessageAction value, $Res Function(MessageAction) then) =
      _$MessageActionCopyWithImpl<$Res, MessageAction>;
  @useResult
  $Res call({String label, String actionKey, Map<String, dynamic>? data});
}

/// @nodoc
class _$MessageActionCopyWithImpl<$Res, $Val extends MessageAction>
    implements $MessageActionCopyWith<$Res> {
  _$MessageActionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? actionKey = null,
    Object? data = freezed,
  }) {
    return _then(_value.copyWith(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      actionKey: null == actionKey
          ? _value.actionKey
          : actionKey // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageActionImplCopyWith<$Res>
    implements $MessageActionCopyWith<$Res> {
  factory _$$MessageActionImplCopyWith(
          _$MessageActionImpl value, $Res Function(_$MessageActionImpl) then) =
      __$$MessageActionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, String actionKey, Map<String, dynamic>? data});
}

/// @nodoc
class __$$MessageActionImplCopyWithImpl<$Res>
    extends _$MessageActionCopyWithImpl<$Res, _$MessageActionImpl>
    implements _$$MessageActionImplCopyWith<$Res> {
  __$$MessageActionImplCopyWithImpl(
      _$MessageActionImpl _value, $Res Function(_$MessageActionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? actionKey = null,
    Object? data = freezed,
  }) {
    return _then(_$MessageActionImpl(
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      actionKey: null == actionKey
          ? _value.actionKey
          : actionKey // ignore: cast_nullable_to_non_nullable
              as String,
      data: freezed == data
          ? _value._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$MessageActionImpl extends _MessageAction {
  const _$MessageActionImpl(
      {required this.label,
      required this.actionKey,
      final Map<String, dynamic>? data})
      : _data = data,
        super._();

  /// Display label for the action button
  @override
  final String label;

  /// Unique key identifying this action (used for callback lookup)
  @override
  final String actionKey;

  /// Optional data to pass to the action callback
  final Map<String, dynamic>? _data;

  /// Optional data to pass to the action callback
  @override
  Map<String, dynamic>? get data {
    final value = _data;
    if (value == null) return null;
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'MessageAction(label: $label, actionKey: $actionKey, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageActionImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.actionKey, actionKey) ||
                other.actionKey == actionKey) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @override
  int get hashCode => Object.hash(runtimeType, label, actionKey,
      const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageActionImplCopyWith<_$MessageActionImpl> get copyWith =>
      __$$MessageActionImplCopyWithImpl<_$MessageActionImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(String label, String actionKey, Map<String, dynamic>? data)
        $default,
  ) {
    return $default(label, actionKey, data);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String label, String actionKey, Map<String, dynamic>? data)?
        $default,
  ) {
    return $default?.call(label, actionKey, data);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String label, String actionKey, Map<String, dynamic>? data)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(label, actionKey, data);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MessageAction value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MessageAction value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MessageAction value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _MessageAction extends MessageAction {
  const factory _MessageAction(
      {required final String label,
      required final String actionKey,
      final Map<String, dynamic>? data}) = _$MessageActionImpl;
  const _MessageAction._() : super._();

  @override

  /// Display label for the action button
  String get label;
  @override

  /// Unique key identifying this action (used for callback lookup)
  String get actionKey;
  @override

  /// Optional data to pass to the action callback
  Map<String, dynamic>? get data;
  @override
  @JsonKey(ignore: true)
  _$$MessageActionImplCopyWith<_$MessageActionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$AppMessage {
  /// Unique identifier
  String get id => throw _privateConstructorUsedError;

  /// Message content
  String get content => throw _privateConstructorUsedError;

  /// Message type
  MessageType get type => throw _privateConstructorUsedError;

  /// Message category
  MessageCategory get category => throw _privateConstructorUsedError;

  /// Message priority
  MessagePriority get priority => throw _privateConstructorUsedError;

  /// When the message was created
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Whether the message has been read
  bool get isRead => throw _privateConstructorUsedError;

  /// Whether the message has been dismissed
  bool get isDismissed => throw _privateConstructorUsedError;

  /// Optional action for the message
  MessageAction? get action => throw _privateConstructorUsedError;

  /// Source context (where the message originated)
  String? get sourceContext => throw _privateConstructorUsedError;

  /// Deduplication key (messages with same key within window are deduplicated)
  String? get deduplicationKey => throw _privateConstructorUsedError;

  /// Additional metadata
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String content,
            MessageType type,
            MessageCategory category,
            MessagePriority priority,
            DateTime timestamp,
            bool isRead,
            bool isDismissed,
            MessageAction? action,
            String? sourceContext,
            String? deduplicationKey,
            Map<String, dynamic>? metadata)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String content,
            MessageType type,
            MessageCategory category,
            MessagePriority priority,
            DateTime timestamp,
            bool isRead,
            bool isDismissed,
            MessageAction? action,
            String? sourceContext,
            String? deduplicationKey,
            Map<String, dynamic>? metadata)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String content,
            MessageType type,
            MessageCategory category,
            MessagePriority priority,
            DateTime timestamp,
            bool isRead,
            bool isDismissed,
            MessageAction? action,
            String? sourceContext,
            String? deduplicationKey,
            Map<String, dynamic>? metadata)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AppMessage value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AppMessage value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AppMessage value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AppMessageCopyWith<AppMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppMessageCopyWith<$Res> {
  factory $AppMessageCopyWith(
          AppMessage value, $Res Function(AppMessage) then) =
      _$AppMessageCopyWithImpl<$Res, AppMessage>;
  @useResult
  $Res call(
      {String id,
      String content,
      MessageType type,
      MessageCategory category,
      MessagePriority priority,
      DateTime timestamp,
      bool isRead,
      bool isDismissed,
      MessageAction? action,
      String? sourceContext,
      String? deduplicationKey,
      Map<String, dynamic>? metadata});

  $MessageActionCopyWith<$Res>? get action;
}

/// @nodoc
class _$AppMessageCopyWithImpl<$Res, $Val extends AppMessage>
    implements $AppMessageCopyWith<$Res> {
  _$AppMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? type = null,
    Object? category = null,
    Object? priority = null,
    Object? timestamp = null,
    Object? isRead = null,
    Object? isDismissed = null,
    Object? action = freezed,
    Object? sourceContext = freezed,
    Object? deduplicationKey = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as MessageCategory,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as MessagePriority,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      isDismissed: null == isDismissed
          ? _value.isDismissed
          : isDismissed // ignore: cast_nullable_to_non_nullable
              as bool,
      action: freezed == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as MessageAction?,
      sourceContext: freezed == sourceContext
          ? _value.sourceContext
          : sourceContext // ignore: cast_nullable_to_non_nullable
              as String?,
      deduplicationKey: freezed == deduplicationKey
          ? _value.deduplicationKey
          : deduplicationKey // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $MessageActionCopyWith<$Res>? get action {
    if (_value.action == null) {
      return null;
    }

    return $MessageActionCopyWith<$Res>(_value.action!, (value) {
      return _then(_value.copyWith(action: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AppMessageImplCopyWith<$Res>
    implements $AppMessageCopyWith<$Res> {
  factory _$$AppMessageImplCopyWith(
          _$AppMessageImpl value, $Res Function(_$AppMessageImpl) then) =
      __$$AppMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String content,
      MessageType type,
      MessageCategory category,
      MessagePriority priority,
      DateTime timestamp,
      bool isRead,
      bool isDismissed,
      MessageAction? action,
      String? sourceContext,
      String? deduplicationKey,
      Map<String, dynamic>? metadata});

  @override
  $MessageActionCopyWith<$Res>? get action;
}

/// @nodoc
class __$$AppMessageImplCopyWithImpl<$Res>
    extends _$AppMessageCopyWithImpl<$Res, _$AppMessageImpl>
    implements _$$AppMessageImplCopyWith<$Res> {
  __$$AppMessageImplCopyWithImpl(
      _$AppMessageImpl _value, $Res Function(_$AppMessageImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? type = null,
    Object? category = null,
    Object? priority = null,
    Object? timestamp = null,
    Object? isRead = null,
    Object? isDismissed = null,
    Object? action = freezed,
    Object? sourceContext = freezed,
    Object? deduplicationKey = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$AppMessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as MessageCategory,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as MessagePriority,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      isDismissed: null == isDismissed
          ? _value.isDismissed
          : isDismissed // ignore: cast_nullable_to_non_nullable
              as bool,
      action: freezed == action
          ? _value.action
          : action // ignore: cast_nullable_to_non_nullable
              as MessageAction?,
      sourceContext: freezed == sourceContext
          ? _value.sourceContext
          : sourceContext // ignore: cast_nullable_to_non_nullable
              as String?,
      deduplicationKey: freezed == deduplicationKey
          ? _value.deduplicationKey
          : deduplicationKey // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _$AppMessageImpl extends _AppMessage {
  const _$AppMessageImpl(
      {required this.id,
      required this.content,
      required this.type,
      required this.category,
      required this.priority,
      required this.timestamp,
      this.isRead = false,
      this.isDismissed = false,
      this.action,
      this.sourceContext,
      this.deduplicationKey,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata,
        super._();

  /// Unique identifier
  @override
  final String id;

  /// Message content
  @override
  final String content;

  /// Message type
  @override
  final MessageType type;

  /// Message category
  @override
  final MessageCategory category;

  /// Message priority
  @override
  final MessagePriority priority;

  /// When the message was created
  @override
  final DateTime timestamp;

  /// Whether the message has been read
  @override
  @JsonKey()
  final bool isRead;

  /// Whether the message has been dismissed
  @override
  @JsonKey()
  final bool isDismissed;

  /// Optional action for the message
  @override
  final MessageAction? action;

  /// Source context (where the message originated)
  @override
  final String? sourceContext;

  /// Deduplication key (messages with same key within window are deduplicated)
  @override
  final String? deduplicationKey;

  /// Additional metadata
  final Map<String, dynamic>? _metadata;

  /// Additional metadata
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'AppMessage(id: $id, content: $content, type: $type, category: $category, priority: $priority, timestamp: $timestamp, isRead: $isRead, isDismissed: $isDismissed, action: $action, sourceContext: $sourceContext, deduplicationKey: $deduplicationKey, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.isDismissed, isDismissed) ||
                other.isDismissed == isDismissed) &&
            (identical(other.action, action) || other.action == action) &&
            (identical(other.sourceContext, sourceContext) ||
                other.sourceContext == sourceContext) &&
            (identical(other.deduplicationKey, deduplicationKey) ||
                other.deduplicationKey == deduplicationKey) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      content,
      type,
      category,
      priority,
      timestamp,
      isRead,
      isDismissed,
      action,
      sourceContext,
      deduplicationKey,
      const DeepCollectionEquality().hash(_metadata));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppMessageImplCopyWith<_$AppMessageImpl> get copyWith =>
      __$$AppMessageImplCopyWithImpl<_$AppMessageImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String content,
            MessageType type,
            MessageCategory category,
            MessagePriority priority,
            DateTime timestamp,
            bool isRead,
            bool isDismissed,
            MessageAction? action,
            String? sourceContext,
            String? deduplicationKey,
            Map<String, dynamic>? metadata)
        $default,
  ) {
    return $default(id, content, type, category, priority, timestamp, isRead,
        isDismissed, action, sourceContext, deduplicationKey, metadata);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String content,
            MessageType type,
            MessageCategory category,
            MessagePriority priority,
            DateTime timestamp,
            bool isRead,
            bool isDismissed,
            MessageAction? action,
            String? sourceContext,
            String? deduplicationKey,
            Map<String, dynamic>? metadata)?
        $default,
  ) {
    return $default?.call(id, content, type, category, priority, timestamp,
        isRead, isDismissed, action, sourceContext, deduplicationKey, metadata);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String content,
            MessageType type,
            MessageCategory category,
            MessagePriority priority,
            DateTime timestamp,
            bool isRead,
            bool isDismissed,
            MessageAction? action,
            String? sourceContext,
            String? deduplicationKey,
            Map<String, dynamic>? metadata)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(id, content, type, category, priority, timestamp, isRead,
          isDismissed, action, sourceContext, deduplicationKey, metadata);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AppMessage value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AppMessage value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AppMessage value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _AppMessage extends AppMessage {
  const factory _AppMessage(
      {required final String id,
      required final String content,
      required final MessageType type,
      required final MessageCategory category,
      required final MessagePriority priority,
      required final DateTime timestamp,
      final bool isRead,
      final bool isDismissed,
      final MessageAction? action,
      final String? sourceContext,
      final String? deduplicationKey,
      final Map<String, dynamic>? metadata}) = _$AppMessageImpl;
  const _AppMessage._() : super._();

  @override

  /// Unique identifier
  String get id;
  @override

  /// Message content
  String get content;
  @override

  /// Message type
  MessageType get type;
  @override

  /// Message category
  MessageCategory get category;
  @override

  /// Message priority
  MessagePriority get priority;
  @override

  /// When the message was created
  DateTime get timestamp;
  @override

  /// Whether the message has been read
  bool get isRead;
  @override

  /// Whether the message has been dismissed
  bool get isDismissed;
  @override

  /// Optional action for the message
  MessageAction? get action;
  @override

  /// Source context (where the message originated)
  String? get sourceContext;
  @override

  /// Deduplication key (messages with same key within window are deduplicated)
  String? get deduplicationKey;
  @override

  /// Additional metadata
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(ignore: true)
  _$$AppMessageImplCopyWith<_$AppMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
