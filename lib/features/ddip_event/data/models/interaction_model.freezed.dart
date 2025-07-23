// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

InteractionModel _$InteractionModelFromJson(Map<String, dynamic> json) {
  return _InteractionModel.fromJson(json);
}

/// @nodoc
mixin _$InteractionModel {
  @JsonKey(name: 'interactionId')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'actorId')
  String get actorId => throw _privateConstructorUsedError;
  String get actorRole => throw _privateConstructorUsedError;
  @JsonKey(name: 'actionType')
  String get actionType => throw _privateConstructorUsedError;
  String? get messageCode => throw _privateConstructorUsedError;
  String? get relatedPhotoId => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this InteractionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of InteractionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InteractionModelCopyWith<InteractionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InteractionModelCopyWith<$Res> {
  factory $InteractionModelCopyWith(
    InteractionModel value,
    $Res Function(InteractionModel) then,
  ) = _$InteractionModelCopyWithImpl<$Res, InteractionModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'interactionId') String id,
    @JsonKey(name: 'actorId') String actorId,
    String actorRole,
    @JsonKey(name: 'actionType') String actionType,
    String? messageCode,
    String? relatedPhotoId,
    DateTime timestamp,
  });
}

/// @nodoc
class _$InteractionModelCopyWithImpl<$Res, $Val extends InteractionModel>
    implements $InteractionModelCopyWith<$Res> {
  _$InteractionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of InteractionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? actorId = null,
    Object? actorRole = null,
    Object? actionType = null,
    Object? messageCode = freezed,
    Object? relatedPhotoId = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            actorId:
                null == actorId
                    ? _value.actorId
                    : actorId // ignore: cast_nullable_to_non_nullable
                        as String,
            actorRole:
                null == actorRole
                    ? _value.actorRole
                    : actorRole // ignore: cast_nullable_to_non_nullable
                        as String,
            actionType:
                null == actionType
                    ? _value.actionType
                    : actionType // ignore: cast_nullable_to_non_nullable
                        as String,
            messageCode:
                freezed == messageCode
                    ? _value.messageCode
                    : messageCode // ignore: cast_nullable_to_non_nullable
                        as String?,
            relatedPhotoId:
                freezed == relatedPhotoId
                    ? _value.relatedPhotoId
                    : relatedPhotoId // ignore: cast_nullable_to_non_nullable
                        as String?,
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$InteractionModelImplCopyWith<$Res>
    implements $InteractionModelCopyWith<$Res> {
  factory _$$InteractionModelImplCopyWith(
    _$InteractionModelImpl value,
    $Res Function(_$InteractionModelImpl) then,
  ) = __$$InteractionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'interactionId') String id,
    @JsonKey(name: 'actorId') String actorId,
    String actorRole,
    @JsonKey(name: 'actionType') String actionType,
    String? messageCode,
    String? relatedPhotoId,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$InteractionModelImplCopyWithImpl<$Res>
    extends _$InteractionModelCopyWithImpl<$Res, _$InteractionModelImpl>
    implements _$$InteractionModelImplCopyWith<$Res> {
  __$$InteractionModelImplCopyWithImpl(
    _$InteractionModelImpl _value,
    $Res Function(_$InteractionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of InteractionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? actorId = null,
    Object? actorRole = null,
    Object? actionType = null,
    Object? messageCode = freezed,
    Object? relatedPhotoId = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _$InteractionModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        actorId:
            null == actorId
                ? _value.actorId
                : actorId // ignore: cast_nullable_to_non_nullable
                    as String,
        actorRole:
            null == actorRole
                ? _value.actorRole
                : actorRole // ignore: cast_nullable_to_non_nullable
                    as String,
        actionType:
            null == actionType
                ? _value.actionType
                : actionType // ignore: cast_nullable_to_non_nullable
                    as String,
        messageCode:
            freezed == messageCode
                ? _value.messageCode
                : messageCode // ignore: cast_nullable_to_non_nullable
                    as String?,
        relatedPhotoId:
            freezed == relatedPhotoId
                ? _value.relatedPhotoId
                : relatedPhotoId // ignore: cast_nullable_to_non_nullable
                    as String?,
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$InteractionModelImpl extends _InteractionModel {
  const _$InteractionModelImpl({
    @JsonKey(name: 'interactionId') required this.id,
    @JsonKey(name: 'actorId') required this.actorId,
    required this.actorRole,
    @JsonKey(name: 'actionType') required this.actionType,
    this.messageCode,
    this.relatedPhotoId,
    required this.timestamp,
  }) : super._();

  factory _$InteractionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$InteractionModelImplFromJson(json);

  @override
  @JsonKey(name: 'interactionId')
  final String id;
  @override
  @JsonKey(name: 'actorId')
  final String actorId;
  @override
  final String actorRole;
  @override
  @JsonKey(name: 'actionType')
  final String actionType;
  @override
  final String? messageCode;
  @override
  final String? relatedPhotoId;
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'InteractionModel(id: $id, actorId: $actorId, actorRole: $actorRole, actionType: $actionType, messageCode: $messageCode, relatedPhotoId: $relatedPhotoId, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InteractionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.actorId, actorId) || other.actorId == actorId) &&
            (identical(other.actorRole, actorRole) ||
                other.actorRole == actorRole) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.messageCode, messageCode) ||
                other.messageCode == messageCode) &&
            (identical(other.relatedPhotoId, relatedPhotoId) ||
                other.relatedPhotoId == relatedPhotoId) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    actorId,
    actorRole,
    actionType,
    messageCode,
    relatedPhotoId,
    timestamp,
  );

  /// Create a copy of InteractionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InteractionModelImplCopyWith<_$InteractionModelImpl> get copyWith =>
      __$$InteractionModelImplCopyWithImpl<_$InteractionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$InteractionModelImplToJson(this);
  }
}

abstract class _InteractionModel extends InteractionModel {
  const factory _InteractionModel({
    @JsonKey(name: 'interactionId') required final String id,
    @JsonKey(name: 'actorId') required final String actorId,
    required final String actorRole,
    @JsonKey(name: 'actionType') required final String actionType,
    final String? messageCode,
    final String? relatedPhotoId,
    required final DateTime timestamp,
  }) = _$InteractionModelImpl;
  const _InteractionModel._() : super._();

  factory _InteractionModel.fromJson(Map<String, dynamic> json) =
      _$InteractionModelImpl.fromJson;

  @override
  @JsonKey(name: 'interactionId')
  String get id;
  @override
  @JsonKey(name: 'actorId')
  String get actorId;
  @override
  String get actorRole;
  @override
  @JsonKey(name: 'actionType')
  String get actionType;
  @override
  String? get messageCode;
  @override
  String? get relatedPhotoId;
  @override
  DateTime get timestamp;

  /// Create a copy of InteractionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InteractionModelImplCopyWith<_$InteractionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
