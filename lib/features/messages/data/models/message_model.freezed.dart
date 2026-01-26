// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MessageActionModel _$MessageActionModelFromJson(Map<String, dynamic> json) {
  return _MessageActionModel.fromJson(json);
}

/// @nodoc
mixin _$MessageActionModel {
  String get label => throw _privateConstructorUsedError;
  String get actionKey => throw _privateConstructorUsedError;
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
    TResult Function(_MessageActionModel value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MessageActionModel value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MessageActionModel value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MessageActionModelCopyWith<MessageActionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageActionModelCopyWith<$Res> {
  factory $MessageActionModelCopyWith(
          MessageActionModel value, $Res Function(MessageActionModel) then) =
      _$MessageActionModelCopyWithImpl<$Res, MessageActionModel>;
  @useResult
  $Res call({String label, String actionKey, Map<String, dynamic>? data});
}

/// @nodoc
class _$MessageActionModelCopyWithImpl<$Res, $Val extends MessageActionModel>
    implements $MessageActionModelCopyWith<$Res> {
  _$MessageActionModelCopyWithImpl(this._value, this._then);

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
abstract class _$$MessageActionModelImplCopyWith<$Res>
    implements $MessageActionModelCopyWith<$Res> {
  factory _$$MessageActionModelImplCopyWith(_$MessageActionModelImpl value,
          $Res Function(_$MessageActionModelImpl) then) =
      __$$MessageActionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String label, String actionKey, Map<String, dynamic>? data});
}

/// @nodoc
class __$$MessageActionModelImplCopyWithImpl<$Res>
    extends _$MessageActionModelCopyWithImpl<$Res, _$MessageActionModelImpl>
    implements _$$MessageActionModelImplCopyWith<$Res> {
  __$$MessageActionModelImplCopyWithImpl(_$MessageActionModelImpl _value,
      $Res Function(_$MessageActionModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? label = null,
    Object? actionKey = null,
    Object? data = freezed,
  }) {
    return _then(_$MessageActionModelImpl(
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
@JsonSerializable()
class _$MessageActionModelImpl extends _MessageActionModel {
  const _$MessageActionModelImpl(
      {required this.label,
      required this.actionKey,
      final Map<String, dynamic>? data})
      : _data = data,
        super._();

  factory _$MessageActionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageActionModelImplFromJson(json);

  @override
  final String label;
  @override
  final String actionKey;
  final Map<String, dynamic>? _data;
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
    return 'MessageActionModel(label: $label, actionKey: $actionKey, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageActionModelImpl &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.actionKey, actionKey) ||
                other.actionKey == actionKey) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, label, actionKey,
      const DeepCollectionEquality().hash(_data));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageActionModelImplCopyWith<_$MessageActionModelImpl> get copyWith =>
      __$$MessageActionModelImplCopyWithImpl<_$MessageActionModelImpl>(
          this, _$identity);

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
    TResult Function(_MessageActionModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MessageActionModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MessageActionModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageActionModelImplToJson(
      this,
    );
  }
}

abstract class _MessageActionModel extends MessageActionModel {
  const factory _MessageActionModel(
      {required final String label,
      required final String actionKey,
      final Map<String, dynamic>? data}) = _$MessageActionModelImpl;
  const _MessageActionModel._() : super._();

  factory _MessageActionModel.fromJson(Map<String, dynamic> json) =
      _$MessageActionModelImpl.fromJson;

  @override
  String get label;
  @override
  String get actionKey;
  @override
  Map<String, dynamic>? get data;
  @override
  @JsonKey(ignore: true)
  _$$MessageActionModelImplCopyWith<_$MessageActionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) {
  return _MessageModel.fromJson(json);
}

/// @nodoc
mixin _$MessageModel {
  String get id => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get priority => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  bool get isDismissed => throw _privateConstructorUsedError;
  MessageActionModel? get action => throw _privateConstructorUsedError;
  String? get sourceContext => throw _privateConstructorUsedError;
  String? get deduplicationKey => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String content,
            String type,
            String category,
            String priority,
            DateTime timestamp,
            bool isRead,
            bool isDismissed,
            MessageActionModel? action,
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
            String type,
            String category,
            String priority,
            DateTime timestamp,
            bool isRead,
            bool isDismissed,
            MessageActionModel? action,
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
            String type,
            String category,
            String priority,
            DateTime timestamp,
            bool isRead,
            bool isDismissed,
            MessageActionModel? action,
            String? sourceContext,
            String? deduplicationKey,
            Map<String, dynamic>? metadata)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_MessageModel value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MessageModel value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MessageModel value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MessageModelCopyWith<MessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageModelCopyWith<$Res> {
  factory $MessageModelCopyWith(
          MessageModel value, $Res Function(MessageModel) then) =
      _$MessageModelCopyWithImpl<$Res, MessageModel>;
  @useResult
  $Res call(
      {String id,
      String content,
      String type,
      String category,
      String priority,
      DateTime timestamp,
      bool isRead,
      bool isDismissed,
      MessageActionModel? action,
      String? sourceContext,
      String? deduplicationKey,
      Map<String, dynamic>? metadata});

  $MessageActionModelCopyWith<$Res>? get action;
}

/// @nodoc
class _$MessageModelCopyWithImpl<$Res, $Val extends MessageModel>
    implements $MessageModelCopyWith<$Res> {
  _$MessageModelCopyWithImpl(this._value, this._then);

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
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
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
              as MessageActionModel?,
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
  $MessageActionModelCopyWith<$Res>? get action {
    if (_value.action == null) {
      return null;
    }

    return $MessageActionModelCopyWith<$Res>(_value.action!, (value) {
      return _then(_value.copyWith(action: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MessageModelImplCopyWith<$Res>
    implements $MessageModelCopyWith<$Res> {
  factory _$$MessageModelImplCopyWith(
          _$MessageModelImpl value, $Res Function(_$MessageModelImpl) then) =
      __$$MessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String content,
      String type,
      String category,
      String priority,
      DateTime timestamp,
      bool isRead,
      bool isDismissed,
      MessageActionModel? action,
      String? sourceContext,
      String? deduplicationKey,
      Map<String, dynamic>? metadata});

  @override
  $MessageActionModelCopyWith<$Res>? get action;
}

/// @nodoc
class __$$MessageModelImplCopyWithImpl<$Res>
    extends _$MessageModelCopyWithImpl<$Res, _$MessageModelImpl>
    implements _$$MessageModelImplCopyWith<$Res> {
  __$$MessageModelImplCopyWithImpl(
      _$MessageModelImpl _value, $Res Function(_$MessageModelImpl) _then)
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
    return _then(_$MessageModelImpl(
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
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      priority: null == priority
          ? _value.priority
          : priority // ignore: cast_nullable_to_non_nullable
              as String,
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
              as MessageActionModel?,
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
@JsonSerializable()
class _$MessageModelImpl extends _MessageModel {
  const _$MessageModelImpl(
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

  factory _$MessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageModelImplFromJson(json);

  @override
  final String id;
  @override
  final String content;
  @override
  final String type;
  @override
  final String category;
  @override
  final String priority;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final bool isRead;
  @override
  @JsonKey()
  final bool isDismissed;
  @override
  final MessageActionModel? action;
  @override
  final String? sourceContext;
  @override
  final String? deduplicationKey;
  final Map<String, dynamic>? _metadata;
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
    return 'MessageModel(id: $id, content: $content, type: $type, category: $category, priority: $priority, timestamp: $timestamp, isRead: $isRead, isDismissed: $isDismissed, action: $action, sourceContext: $sourceContext, deduplicationKey: $deduplicationKey, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageModelImpl &&
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

  @JsonKey(ignore: true)
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
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      __$$MessageModelImplCopyWithImpl<_$MessageModelImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String content,
            String type,
            String category,
            String priority,
            DateTime timestamp,
            bool isRead,
            bool isDismissed,
            MessageActionModel? action,
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
            String type,
            String category,
            String priority,
            DateTime timestamp,
            bool isRead,
            bool isDismissed,
            MessageActionModel? action,
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
            String type,
            String category,
            String priority,
            DateTime timestamp,
            bool isRead,
            bool isDismissed,
            MessageActionModel? action,
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
    TResult Function(_MessageModel value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_MessageModel value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_MessageModel value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageModelImplToJson(
      this,
    );
  }
}

abstract class _MessageModel extends MessageModel {
  const factory _MessageModel(
      {required final String id,
      required final String content,
      required final String type,
      required final String category,
      required final String priority,
      required final DateTime timestamp,
      final bool isRead,
      final bool isDismissed,
      final MessageActionModel? action,
      final String? sourceContext,
      final String? deduplicationKey,
      final Map<String, dynamic>? metadata}) = _$MessageModelImpl;
  const _MessageModel._() : super._();

  factory _MessageModel.fromJson(Map<String, dynamic> json) =
      _$MessageModelImpl.fromJson;

  @override
  String get id;
  @override
  String get content;
  @override
  String get type;
  @override
  String get category;
  @override
  String get priority;
  @override
  DateTime get timestamp;
  @override
  bool get isRead;
  @override
  bool get isDismissed;
  @override
  MessageActionModel? get action;
  @override
  String? get sourceContext;
  @override
  String? get deduplicationKey;
  @override
  Map<String, dynamic>? get metadata;
  @override
  @JsonKey(ignore: true)
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
