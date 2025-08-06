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
  /// View에 전달하는 일회성 카메라 이동 명령입니다.
  /// View는 이 명령을 수행한 후 null로 초기화해야 합니다.
  NCameraUpdate? get cameraUpdate => throw _privateConstructorUsedError;
  NaverMapViewOptions? get viewOptions => throw _privateConstructorUsedError;
  NaverMapClusteringOptions? get clusterOptions =>
      throw _privateConstructorUsedError;

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
    NCameraUpdate? cameraUpdate,
    NaverMapViewOptions? viewOptions,
    NaverMapClusteringOptions? clusterOptions,
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
    Object? cameraUpdate = freezed,
    Object? viewOptions = freezed,
    Object? clusterOptions = freezed,
  }) {
    return _then(
      _value.copyWith(
            cameraUpdate:
                freezed == cameraUpdate
                    ? _value.cameraUpdate
                    : cameraUpdate // ignore: cast_nullable_to_non_nullable
                        as NCameraUpdate?,
            viewOptions:
                freezed == viewOptions
                    ? _value.viewOptions
                    : viewOptions // ignore: cast_nullable_to_non_nullable
                        as NaverMapViewOptions?,
            clusterOptions:
                freezed == clusterOptions
                    ? _value.clusterOptions
                    : clusterOptions // ignore: cast_nullable_to_non_nullable
                        as NaverMapClusteringOptions?,
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
    NCameraUpdate? cameraUpdate,
    NaverMapViewOptions? viewOptions,
    NaverMapClusteringOptions? clusterOptions,
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
    Object? cameraUpdate = freezed,
    Object? viewOptions = freezed,
    Object? clusterOptions = freezed,
  }) {
    return _then(
      _$MapStateImpl(
        cameraUpdate:
            freezed == cameraUpdate
                ? _value.cameraUpdate
                : cameraUpdate // ignore: cast_nullable_to_non_nullable
                    as NCameraUpdate?,
        viewOptions:
            freezed == viewOptions
                ? _value.viewOptions
                : viewOptions // ignore: cast_nullable_to_non_nullable
                    as NaverMapViewOptions?,
        clusterOptions:
            freezed == clusterOptions
                ? _value.clusterOptions
                : clusterOptions // ignore: cast_nullable_to_non_nullable
                    as NaverMapClusteringOptions?,
      ),
    );
  }
}

/// @nodoc

class _$MapStateImpl implements _MapState {
  const _$MapStateImpl({
    this.cameraUpdate,
    this.viewOptions,
    this.clusterOptions,
  });

  /// View에 전달하는 일회성 카메라 이동 명령입니다.
  /// View는 이 명령을 수행한 후 null로 초기화해야 합니다.
  @override
  final NCameraUpdate? cameraUpdate;
  @override
  final NaverMapViewOptions? viewOptions;
  @override
  final NaverMapClusteringOptions? clusterOptions;

  @override
  String toString() {
    return 'MapState(cameraUpdate: $cameraUpdate, viewOptions: $viewOptions, clusterOptions: $clusterOptions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MapStateImpl &&
            (identical(other.cameraUpdate, cameraUpdate) ||
                other.cameraUpdate == cameraUpdate) &&
            (identical(other.viewOptions, viewOptions) ||
                other.viewOptions == viewOptions) &&
            (identical(other.clusterOptions, clusterOptions) ||
                other.clusterOptions == clusterOptions));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, cameraUpdate, viewOptions, clusterOptions);

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
    final NCameraUpdate? cameraUpdate,
    final NaverMapViewOptions? viewOptions,
    final NaverMapClusteringOptions? clusterOptions,
  }) = _$MapStateImpl;

  /// View에 전달하는 일회성 카메라 이동 명령입니다.
  /// View는 이 명령을 수행한 후 null로 초기화해야 합니다.
  @override
  NCameraUpdate? get cameraUpdate;
  @override
  NaverMapViewOptions? get viewOptions;
  @override
  NaverMapClusteringOptions? get clusterOptions;

  /// Create a copy of MapState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MapStateImplCopyWith<_$MapStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
