// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'map_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MapState {
  List<DdipEvent> get events => throw _privateConstructorUsedError;
  String? get selectedEventId => throw _privateConstructorUsedError;
  NCameraUpdate? get cameraUpdate => throw _privateConstructorUsedError;
  NLatLngBounds? get cameraTargetBounds => throw _privateConstructorUsedError;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MapStateCopyWith<MapState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MapStateCopyWith<$Res> {
  factory $MapStateCopyWith(MapState value, $Res Function(MapState) then) =
      _$MapStateCopyWithImpl<$Res, MapState>;
  @useResult
  $Res call({
    List<DdipEvent> events,
    String? selectedEventId,
    NCameraUpdate? cameraUpdate,
    NLatLngBounds? cameraTargetBounds,
  });
}

/// @nodoc
class _$MapStateCopyWithImpl<$Res, $Val extends MapState>
    implements $MapStateCopyWith<$Res> {
  _$MapStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? events = null,
    Object? selectedEventId = freezed,
    Object? cameraUpdate = freezed,
    Object? cameraTargetBounds = freezed,
  }) {
    return _then(
      _value.copyWith(
            events:
                null == events
                    ? _value.events
                    : events // ignore: cast_nullable_to_non_nullable
                        as List<DdipEvent>,
            selectedEventId:
                freezed == selectedEventId
                    ? _value.selectedEventId
                    : selectedEventId // ignore: cast_nullable_to_non_nullable
                        as String?,
            cameraUpdate:
                freezed == cameraUpdate
                    ? _value.cameraUpdate
                    : cameraUpdate // ignore: cast_nullable_to_non_nullable
                        as NCameraUpdate?,
            cameraTargetBounds:
                freezed == cameraTargetBounds
                    ? _value.cameraTargetBounds
                    : cameraTargetBounds // ignore: cast_nullable_to_non_nullable
                        as NLatLngBounds?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MapStateImplCopyWith<$Res>
    implements $MapStateCopyWith<$Res> {
  factory _$$MapStateImplCopyWith(
    _$MapStateImpl value,
    $Res Function(_$MapStateImpl) then,
  ) = __$$MapStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<DdipEvent> events,
    String? selectedEventId,
    NCameraUpdate? cameraUpdate,
    NLatLngBounds? cameraTargetBounds,
  });
}

/// @nodoc
class __$$MapStateImplCopyWithImpl<$Res>
    extends _$MapStateCopyWithImpl<$Res, _$MapStateImpl>
    implements _$$MapStateImplCopyWith<$Res> {
  __$$MapStateImplCopyWithImpl(
    _$MapStateImpl _value,
    $Res Function(_$MapStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? events = null,
    Object? selectedEventId = freezed,
    Object? cameraUpdate = freezed,
    Object? cameraTargetBounds = freezed,
  }) {
    return _then(
      _$MapStateImpl(
        events:
            null == events
                ? _value._events
                : events // ignore: cast_nullable_to_non_nullable
                    as List<DdipEvent>,
        selectedEventId:
            freezed == selectedEventId
                ? _value.selectedEventId
                : selectedEventId // ignore: cast_nullable_to_non_nullable
                    as String?,
        cameraUpdate:
            freezed == cameraUpdate
                ? _value.cameraUpdate
                : cameraUpdate // ignore: cast_nullable_to_non_nullable
                    as NCameraUpdate?,
        cameraTargetBounds:
            freezed == cameraTargetBounds
                ? _value.cameraTargetBounds
                : cameraTargetBounds // ignore: cast_nullable_to_non_nullable
                    as NLatLngBounds?,
      ),
    );
  }
}

/// @nodoc

class _$MapStateImpl implements _MapState {
  const _$MapStateImpl({
    final List<DdipEvent> events = const [],
    this.selectedEventId,
    this.cameraUpdate,
    this.cameraTargetBounds,
  }) : _events = events;

  final List<DdipEvent> _events;
  @override
  @JsonKey()
  List<DdipEvent> get events {
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_events);
  }

  @override
  final String? selectedEventId;
  @override
  final NCameraUpdate? cameraUpdate;
  @override
  final NLatLngBounds? cameraTargetBounds;

  @override
  String toString() {
    return 'MapState(events: $events, selectedEventId: $selectedEventId, cameraUpdate: $cameraUpdate, cameraTargetBounds: $cameraTargetBounds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MapStateImpl &&
            const DeepCollectionEquality().equals(other._events, _events) &&
            (identical(other.selectedEventId, selectedEventId) ||
                other.selectedEventId == selectedEventId) &&
            (identical(other.cameraUpdate, cameraUpdate) ||
                other.cameraUpdate == cameraUpdate) &&
            (identical(other.cameraTargetBounds, cameraTargetBounds) ||
                other.cameraTargetBounds == cameraTargetBounds));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_events),
    selectedEventId,
    cameraUpdate,
    cameraTargetBounds,
  );

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MapStateImplCopyWith<_$MapStateImpl> get copyWith =>
      __$$MapStateImplCopyWithImpl<_$MapStateImpl>(this, _$identity);
}

abstract class _MapState implements MapState {
  const factory _MapState({
    final List<DdipEvent> events,
    final String? selectedEventId,
    final NCameraUpdate? cameraUpdate,
    final NLatLngBounds? cameraTargetBounds,
  }) = _$MapStateImpl;

  @override
  List<DdipEvent> get events;
  @override
  String? get selectedEventId;
  @override
  NCameraUpdate? get cameraUpdate;
  @override
  NLatLngBounds? get cameraTargetBounds;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MapStateImplCopyWith<_$MapStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
