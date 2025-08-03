// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_detail_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$EventDetailState {
  bool get isProcessing => throw _privateConstructorUsedError; // 로딩 중 여부
  String? get buttonText =>
      throw _privateConstructorUsedError; // 버튼에 표시될 텍스트 (nullable)
  bool get buttonIsEnabled => throw _privateConstructorUsedError; // 버튼 활성화 여부
  Color? get buttonColor => throw _privateConstructorUsedError;

  /// Create a copy of EventDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EventDetailStateCopyWith<EventDetailState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventDetailStateCopyWith<$Res> {
  factory $EventDetailStateCopyWith(
    EventDetailState value,
    $Res Function(EventDetailState) then,
  ) = _$EventDetailStateCopyWithImpl<$Res, EventDetailState>;
  @useResult
  $Res call({
    bool isProcessing,
    String? buttonText,
    bool buttonIsEnabled,
    Color? buttonColor,
  });
}

/// @nodoc
class _$EventDetailStateCopyWithImpl<$Res, $Val extends EventDetailState>
    implements $EventDetailStateCopyWith<$Res> {
  _$EventDetailStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EventDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isProcessing = null,
    Object? buttonText = freezed,
    Object? buttonIsEnabled = null,
    Object? buttonColor = freezed,
  }) {
    return _then(
      _value.copyWith(
            isProcessing:
                null == isProcessing
                    ? _value.isProcessing
                    : isProcessing // ignore: cast_nullable_to_non_nullable
                        as bool,
            buttonText:
                freezed == buttonText
                    ? _value.buttonText
                    : buttonText // ignore: cast_nullable_to_non_nullable
                        as String?,
            buttonIsEnabled:
                null == buttonIsEnabled
                    ? _value.buttonIsEnabled
                    : buttonIsEnabled // ignore: cast_nullable_to_non_nullable
                        as bool,
            buttonColor:
                freezed == buttonColor
                    ? _value.buttonColor
                    : buttonColor // ignore: cast_nullable_to_non_nullable
                        as Color?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$EventDetailStateImplCopyWith<$Res>
    implements $EventDetailStateCopyWith<$Res> {
  factory _$$EventDetailStateImplCopyWith(
    _$EventDetailStateImpl value,
    $Res Function(_$EventDetailStateImpl) then,
  ) = __$$EventDetailStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isProcessing,
    String? buttonText,
    bool buttonIsEnabled,
    Color? buttonColor,
  });
}

/// @nodoc
class __$$EventDetailStateImplCopyWithImpl<$Res>
    extends _$EventDetailStateCopyWithImpl<$Res, _$EventDetailStateImpl>
    implements _$$EventDetailStateImplCopyWith<$Res> {
  __$$EventDetailStateImplCopyWithImpl(
    _$EventDetailStateImpl _value,
    $Res Function(_$EventDetailStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EventDetailState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isProcessing = null,
    Object? buttonText = freezed,
    Object? buttonIsEnabled = null,
    Object? buttonColor = freezed,
  }) {
    return _then(
      _$EventDetailStateImpl(
        isProcessing:
            null == isProcessing
                ? _value.isProcessing
                : isProcessing // ignore: cast_nullable_to_non_nullable
                    as bool,
        buttonText:
            freezed == buttonText
                ? _value.buttonText
                : buttonText // ignore: cast_nullable_to_non_nullable
                    as String?,
        buttonIsEnabled:
            null == buttonIsEnabled
                ? _value.buttonIsEnabled
                : buttonIsEnabled // ignore: cast_nullable_to_non_nullable
                    as bool,
        buttonColor:
            freezed == buttonColor
                ? _value.buttonColor
                : buttonColor // ignore: cast_nullable_to_non_nullable
                    as Color?,
      ),
    );
  }
}

/// @nodoc

class _$EventDetailStateImpl implements _EventDetailState {
  const _$EventDetailStateImpl({
    this.isProcessing = false,
    this.buttonText,
    this.buttonIsEnabled = false,
    this.buttonColor,
  });

  @override
  @JsonKey()
  final bool isProcessing;
  // 로딩 중 여부
  @override
  final String? buttonText;
  // 버튼에 표시될 텍스트 (nullable)
  @override
  @JsonKey()
  final bool buttonIsEnabled;
  // 버튼 활성화 여부
  @override
  final Color? buttonColor;

  @override
  String toString() {
    return 'EventDetailState(isProcessing: $isProcessing, buttonText: $buttonText, buttonIsEnabled: $buttonIsEnabled, buttonColor: $buttonColor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventDetailStateImpl &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing) &&
            (identical(other.buttonText, buttonText) ||
                other.buttonText == buttonText) &&
            (identical(other.buttonIsEnabled, buttonIsEnabled) ||
                other.buttonIsEnabled == buttonIsEnabled) &&
            (identical(other.buttonColor, buttonColor) ||
                other.buttonColor == buttonColor));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isProcessing,
    buttonText,
    buttonIsEnabled,
    buttonColor,
  );

  /// Create a copy of EventDetailState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EventDetailStateImplCopyWith<_$EventDetailStateImpl> get copyWith =>
      __$$EventDetailStateImplCopyWithImpl<_$EventDetailStateImpl>(
        this,
        _$identity,
      );
}

abstract class _EventDetailState implements EventDetailState {
  const factory _EventDetailState({
    final bool isProcessing,
    final String? buttonText,
    final bool buttonIsEnabled,
    final Color? buttonColor,
  }) = _$EventDetailStateImpl;

  @override
  bool get isProcessing; // 로딩 중 여부
  @override
  String? get buttonText; // 버튼에 표시될 텍스트 (nullable)
  @override
  bool get buttonIsEnabled; // 버튼 활성화 여부
  @override
  Color? get buttonColor;

  /// Create a copy of EventDetailState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EventDetailStateImplCopyWith<_$EventDetailStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
