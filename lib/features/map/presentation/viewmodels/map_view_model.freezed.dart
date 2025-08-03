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
  /// 지도에 표시될 모든 오버레이(마커, 사진 마커 등)의 최종 세트입니다.
  Set<NAddableOverlay<NOverlay<void>>> get overlays =>
      throw _privateConstructorUsedError;

  /// View에 전달하는 일회성 카메라 이동 명령입니다.
  /// View는 이 명령을 수행한 후 null로 초기화해야 합니다.
  NCameraUpdate? get cameraUpdate => throw _privateConstructorUsedError;

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
    Set<NAddableOverlay<NOverlay<void>>> overlays,
    NCameraUpdate? cameraUpdate,
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
  $Res call({Object? overlays = null, Object? cameraUpdate = freezed}) {
    return _then(
      _value.copyWith(
            overlays:
                null == overlays
                    ? _value.overlays
                    : overlays // ignore: cast_nullable_to_non_nullable
                        as Set<NAddableOverlay<NOverlay<void>>>,
            cameraUpdate:
                freezed == cameraUpdate
                    ? _value.cameraUpdate
                    : cameraUpdate // ignore: cast_nullable_to_non_nullable
                        as NCameraUpdate?,
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
    Set<NAddableOverlay<NOverlay<void>>> overlays,
    NCameraUpdate? cameraUpdate,
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
  $Res call({Object? overlays = null, Object? cameraUpdate = freezed}) {
    return _then(
      _$MapStateImpl(
        overlays:
            null == overlays
                ? _value._overlays
                : overlays // ignore: cast_nullable_to_non_nullable
                    as Set<NAddableOverlay<NOverlay<void>>>,
        cameraUpdate:
            freezed == cameraUpdate
                ? _value.cameraUpdate
                : cameraUpdate // ignore: cast_nullable_to_non_nullable
                    as NCameraUpdate?,
      ),
    );
  }
}

/// @nodoc

class _$MapStateImpl implements _MapState {
  const _$MapStateImpl({
    final Set<NAddableOverlay<NOverlay<void>>> overlays = const {},
    this.cameraUpdate,
  }) : _overlays = overlays;

  /// 지도에 표시될 모든 오버레이(마커, 사진 마커 등)의 최종 세트입니다.
  final Set<NAddableOverlay<NOverlay<void>>> _overlays;

  /// 지도에 표시될 모든 오버레이(마커, 사진 마커 등)의 최종 세트입니다.
  @override
  @JsonKey()
  Set<NAddableOverlay<NOverlay<void>>> get overlays {
    if (_overlays is EqualUnmodifiableSetView) return _overlays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_overlays);
  }

  /// View에 전달하는 일회성 카메라 이동 명령입니다.
  /// View는 이 명령을 수행한 후 null로 초기화해야 합니다.
  @override
  final NCameraUpdate? cameraUpdate;

  @override
  String toString() {
    return 'MapState(overlays: $overlays, cameraUpdate: $cameraUpdate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MapStateImpl &&
            const DeepCollectionEquality().equals(other._overlays, _overlays) &&
            (identical(other.cameraUpdate, cameraUpdate) ||
                other.cameraUpdate == cameraUpdate));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_overlays),
    cameraUpdate,
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
    final Set<NAddableOverlay<NOverlay<void>>> overlays,
    final NCameraUpdate? cameraUpdate,
  }) = _$MapStateImpl;

  /// 지도에 표시될 모든 오버레이(마커, 사진 마커 등)의 최종 세트입니다.
  @override
  Set<NAddableOverlay<NOverlay<void>>> get overlays;

  /// View에 전달하는 일회성 카메라 이동 명령입니다.
  /// View는 이 명령을 수행한 후 null로 초기화해야 합니다.
  @override
  NCameraUpdate? get cameraUpdate;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MapStateImplCopyWith<_$MapStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
