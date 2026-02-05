// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'room_device_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RoomDeviceState {
  List<Device> get allDevices => throw _privateConstructorUsedError;
  List<Device> get filteredDevices => throw _privateConstructorUsedError;
  RoomDeviceStats get stats => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(List<Device> allDevices, List<Device> filteredDevices,
            RoomDeviceStats stats, bool isLoading, String? error)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(List<Device> allDevices, List<Device> filteredDevices,
            RoomDeviceStats stats, bool isLoading, String? error)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(List<Device> allDevices, List<Device> filteredDevices,
            RoomDeviceStats stats, bool isLoading, String? error)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_RoomDeviceState value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_RoomDeviceState value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_RoomDeviceState value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RoomDeviceStateCopyWith<RoomDeviceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomDeviceStateCopyWith<$Res> {
  factory $RoomDeviceStateCopyWith(
          RoomDeviceState value, $Res Function(RoomDeviceState) then) =
      _$RoomDeviceStateCopyWithImpl<$Res, RoomDeviceState>;
  @useResult
  $Res call(
      {List<Device> allDevices,
      List<Device> filteredDevices,
      RoomDeviceStats stats,
      bool isLoading,
      String? error});

  $RoomDeviceStatsCopyWith<$Res> get stats;
}

/// @nodoc
class _$RoomDeviceStateCopyWithImpl<$Res, $Val extends RoomDeviceState>
    implements $RoomDeviceStateCopyWith<$Res> {
  _$RoomDeviceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allDevices = null,
    Object? filteredDevices = null,
    Object? stats = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      allDevices: null == allDevices
          ? _value.allDevices
          : allDevices // ignore: cast_nullable_to_non_nullable
              as List<Device>,
      filteredDevices: null == filteredDevices
          ? _value.filteredDevices
          : filteredDevices // ignore: cast_nullable_to_non_nullable
              as List<Device>,
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as RoomDeviceStats,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $RoomDeviceStatsCopyWith<$Res> get stats {
    return $RoomDeviceStatsCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RoomDeviceStateImplCopyWith<$Res>
    implements $RoomDeviceStateCopyWith<$Res> {
  factory _$$RoomDeviceStateImplCopyWith(_$RoomDeviceStateImpl value,
          $Res Function(_$RoomDeviceStateImpl) then) =
      __$$RoomDeviceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Device> allDevices,
      List<Device> filteredDevices,
      RoomDeviceStats stats,
      bool isLoading,
      String? error});

  @override
  $RoomDeviceStatsCopyWith<$Res> get stats;
}

/// @nodoc
class __$$RoomDeviceStateImplCopyWithImpl<$Res>
    extends _$RoomDeviceStateCopyWithImpl<$Res, _$RoomDeviceStateImpl>
    implements _$$RoomDeviceStateImplCopyWith<$Res> {
  __$$RoomDeviceStateImplCopyWithImpl(
      _$RoomDeviceStateImpl _value, $Res Function(_$RoomDeviceStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? allDevices = null,
    Object? filteredDevices = null,
    Object? stats = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$RoomDeviceStateImpl(
      allDevices: null == allDevices
          ? _value._allDevices
          : allDevices // ignore: cast_nullable_to_non_nullable
              as List<Device>,
      filteredDevices: null == filteredDevices
          ? _value._filteredDevices
          : filteredDevices // ignore: cast_nullable_to_non_nullable
              as List<Device>,
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as RoomDeviceStats,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$RoomDeviceStateImpl implements _RoomDeviceState {
  const _$RoomDeviceStateImpl(
      {final List<Device> allDevices = const [],
      final List<Device> filteredDevices = const [],
      this.stats = const RoomDeviceStats(),
      this.isLoading = false,
      this.error})
      : _allDevices = allDevices,
        _filteredDevices = filteredDevices;

  final List<Device> _allDevices;
  @override
  @JsonKey()
  List<Device> get allDevices {
    if (_allDevices is EqualUnmodifiableListView) return _allDevices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allDevices);
  }

  final List<Device> _filteredDevices;
  @override
  @JsonKey()
  List<Device> get filteredDevices {
    if (_filteredDevices is EqualUnmodifiableListView) return _filteredDevices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredDevices);
  }

  @override
  @JsonKey()
  final RoomDeviceStats stats;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'RoomDeviceState(allDevices: $allDevices, filteredDevices: $filteredDevices, stats: $stats, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomDeviceStateImpl &&
            const DeepCollectionEquality()
                .equals(other._allDevices, _allDevices) &&
            const DeepCollectionEquality()
                .equals(other._filteredDevices, _filteredDevices) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_allDevices),
      const DeepCollectionEquality().hash(_filteredDevices),
      stats,
      isLoading,
      error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomDeviceStateImplCopyWith<_$RoomDeviceStateImpl> get copyWith =>
      __$$RoomDeviceStateImplCopyWithImpl<_$RoomDeviceStateImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(List<Device> allDevices, List<Device> filteredDevices,
            RoomDeviceStats stats, bool isLoading, String? error)
        $default,
  ) {
    return $default(allDevices, filteredDevices, stats, isLoading, error);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(List<Device> allDevices, List<Device> filteredDevices,
            RoomDeviceStats stats, bool isLoading, String? error)?
        $default,
  ) {
    return $default?.call(allDevices, filteredDevices, stats, isLoading, error);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(List<Device> allDevices, List<Device> filteredDevices,
            RoomDeviceStats stats, bool isLoading, String? error)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(allDevices, filteredDevices, stats, isLoading, error);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_RoomDeviceState value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_RoomDeviceState value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_RoomDeviceState value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _RoomDeviceState implements RoomDeviceState {
  const factory _RoomDeviceState(
      {final List<Device> allDevices,
      final List<Device> filteredDevices,
      final RoomDeviceStats stats,
      final bool isLoading,
      final String? error}) = _$RoomDeviceStateImpl;

  @override
  List<Device> get allDevices;
  @override
  List<Device> get filteredDevices;
  @override
  RoomDeviceStats get stats;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$RoomDeviceStateImplCopyWith<_$RoomDeviceStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RoomDeviceStats {
  int get total => throw _privateConstructorUsedError;
  int get accessPoints => throw _privateConstructorUsedError;
  int get switches => throw _privateConstructorUsedError;
  int get onts => throw _privateConstructorUsedError;
  int get wlanControllers => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int total, int accessPoints, int switches, int onts,
            int wlanControllers)
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int total, int accessPoints, int switches, int onts,
            int wlanControllers)?
        $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int total, int accessPoints, int switches, int onts,
            int wlanControllers)?
        $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_RoomDeviceStats value) $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_RoomDeviceStats value)? $default,
  ) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_RoomDeviceStats value)? $default, {
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RoomDeviceStatsCopyWith<RoomDeviceStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoomDeviceStatsCopyWith<$Res> {
  factory $RoomDeviceStatsCopyWith(
          RoomDeviceStats value, $Res Function(RoomDeviceStats) then) =
      _$RoomDeviceStatsCopyWithImpl<$Res, RoomDeviceStats>;
  @useResult
  $Res call(
      {int total,
      int accessPoints,
      int switches,
      int onts,
      int wlanControllers});
}

/// @nodoc
class _$RoomDeviceStatsCopyWithImpl<$Res, $Val extends RoomDeviceStats>
    implements $RoomDeviceStatsCopyWith<$Res> {
  _$RoomDeviceStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? accessPoints = null,
    Object? switches = null,
    Object? onts = null,
    Object? wlanControllers = null,
  }) {
    return _then(_value.copyWith(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      accessPoints: null == accessPoints
          ? _value.accessPoints
          : accessPoints // ignore: cast_nullable_to_non_nullable
              as int,
      switches: null == switches
          ? _value.switches
          : switches // ignore: cast_nullable_to_non_nullable
              as int,
      onts: null == onts
          ? _value.onts
          : onts // ignore: cast_nullable_to_non_nullable
              as int,
      wlanControllers: null == wlanControllers
          ? _value.wlanControllers
          : wlanControllers // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RoomDeviceStatsImplCopyWith<$Res>
    implements $RoomDeviceStatsCopyWith<$Res> {
  factory _$$RoomDeviceStatsImplCopyWith(_$RoomDeviceStatsImpl value,
          $Res Function(_$RoomDeviceStatsImpl) then) =
      __$$RoomDeviceStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int total,
      int accessPoints,
      int switches,
      int onts,
      int wlanControllers});
}

/// @nodoc
class __$$RoomDeviceStatsImplCopyWithImpl<$Res>
    extends _$RoomDeviceStatsCopyWithImpl<$Res, _$RoomDeviceStatsImpl>
    implements _$$RoomDeviceStatsImplCopyWith<$Res> {
  __$$RoomDeviceStatsImplCopyWithImpl(
      _$RoomDeviceStatsImpl _value, $Res Function(_$RoomDeviceStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? total = null,
    Object? accessPoints = null,
    Object? switches = null,
    Object? onts = null,
    Object? wlanControllers = null,
  }) {
    return _then(_$RoomDeviceStatsImpl(
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      accessPoints: null == accessPoints
          ? _value.accessPoints
          : accessPoints // ignore: cast_nullable_to_non_nullable
              as int,
      switches: null == switches
          ? _value.switches
          : switches // ignore: cast_nullable_to_non_nullable
              as int,
      onts: null == onts
          ? _value.onts
          : onts // ignore: cast_nullable_to_non_nullable
              as int,
      wlanControllers: null == wlanControllers
          ? _value.wlanControllers
          : wlanControllers // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$RoomDeviceStatsImpl implements _RoomDeviceStats {
  const _$RoomDeviceStatsImpl(
      {this.total = 0,
      this.accessPoints = 0,
      this.switches = 0,
      this.onts = 0,
      this.wlanControllers = 0});

  @override
  @JsonKey()
  final int total;
  @override
  @JsonKey()
  final int accessPoints;
  @override
  @JsonKey()
  final int switches;
  @override
  @JsonKey()
  final int onts;
  @override
  @JsonKey()
  final int wlanControllers;

  @override
  String toString() {
    return 'RoomDeviceStats(total: $total, accessPoints: $accessPoints, switches: $switches, onts: $onts, wlanControllers: $wlanControllers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoomDeviceStatsImpl &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.accessPoints, accessPoints) ||
                other.accessPoints == accessPoints) &&
            (identical(other.switches, switches) ||
                other.switches == switches) &&
            (identical(other.onts, onts) || other.onts == onts) &&
            (identical(other.wlanControllers, wlanControllers) ||
                other.wlanControllers == wlanControllers));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, total, accessPoints, switches, onts, wlanControllers);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoomDeviceStatsImplCopyWith<_$RoomDeviceStatsImpl> get copyWith =>
      __$$RoomDeviceStatsImplCopyWithImpl<_$RoomDeviceStatsImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(int total, int accessPoints, int switches, int onts,
            int wlanControllers)
        $default,
  ) {
    return $default(total, accessPoints, switches, onts, wlanControllers);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(int total, int accessPoints, int switches, int onts,
            int wlanControllers)?
        $default,
  ) {
    return $default?.call(total, accessPoints, switches, onts, wlanControllers);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(int total, int accessPoints, int switches, int onts,
            int wlanControllers)?
        $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(total, accessPoints, switches, onts, wlanControllers);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_RoomDeviceStats value) $default,
  ) {
    return $default(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_RoomDeviceStats value)? $default,
  ) {
    return $default?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_RoomDeviceStats value)? $default, {
    required TResult orElse(),
  }) {
    if ($default != null) {
      return $default(this);
    }
    return orElse();
  }
}

abstract class _RoomDeviceStats implements RoomDeviceStats {
  const factory _RoomDeviceStats(
      {final int total,
      final int accessPoints,
      final int switches,
      final int onts,
      final int wlanControllers}) = _$RoomDeviceStatsImpl;

  @override
  int get total;
  @override
  int get accessPoints;
  @override
  int get switches;
  @override
  int get onts;
  @override
  int get wlanControllers;
  @override
  @JsonKey(ignore: true)
  _$$RoomDeviceStatsImplCopyWith<_$RoomDeviceStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
