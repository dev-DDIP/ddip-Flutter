// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ddip_event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DdipEventModel _$DdipEventModelFromJson(Map<String, dynamic> json) {
  return _DdipEventModel.fromJson(json);
}

/// @nodoc
mixin _$DdipEventModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content =>
      throw _privateConstructorUsedError; // @JsonKey를 이렇게 각 필드에 직접 적용해야 합니다.
  @JsonKey(name: 'requester_id')
  String get requesterId => throw _privateConstructorUsedError;
  @JsonKey(name: 'responder_id')
  String? get responderId => throw _privateConstructorUsedError;
  int get reward => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'response_photo_url')
  String? get responsePhotoUrl => throw _privateConstructorUsedError;

  /// Serializes this DdipEventModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DdipEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DdipEventModelCopyWith<DdipEventModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DdipEventModelCopyWith<$Res> {
  factory $DdipEventModelCopyWith(
    DdipEventModel value,
    $Res Function(DdipEventModel) then,
  ) = _$DdipEventModelCopyWithImpl<$Res, DdipEventModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String content,
    @JsonKey(name: 'requester_id') String requesterId,
    @JsonKey(name: 'responder_id') String? responderId,
    int reward,
    double latitude,
    double longitude,
    String status,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'response_photo_url') String? responsePhotoUrl,
  });
}

/// @nodoc
class _$DdipEventModelCopyWithImpl<$Res, $Val extends DdipEventModel>
    implements $DdipEventModelCopyWith<$Res> {
  _$DdipEventModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DdipEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? requesterId = null,
    Object? responderId = freezed,
    Object? reward = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? status = null,
    Object? createdAt = null,
    Object? responsePhotoUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            content:
                null == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String,
            requesterId:
                null == requesterId
                    ? _value.requesterId
                    : requesterId // ignore: cast_nullable_to_non_nullable
                        as String,
            responderId:
                freezed == responderId
                    ? _value.responderId
                    : responderId // ignore: cast_nullable_to_non_nullable
                        as String?,
            reward:
                null == reward
                    ? _value.reward
                    : reward // ignore: cast_nullable_to_non_nullable
                        as int,
            latitude:
                null == latitude
                    ? _value.latitude
                    : latitude // ignore: cast_nullable_to_non_nullable
                        as double,
            longitude:
                null == longitude
                    ? _value.longitude
                    : longitude // ignore: cast_nullable_to_non_nullable
                        as double,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            responsePhotoUrl:
                freezed == responsePhotoUrl
                    ? _value.responsePhotoUrl
                    : responsePhotoUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DdipEventModelImplCopyWith<$Res>
    implements $DdipEventModelCopyWith<$Res> {
  factory _$$DdipEventModelImplCopyWith(
    _$DdipEventModelImpl value,
    $Res Function(_$DdipEventModelImpl) then,
  ) = __$$DdipEventModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String content,
    @JsonKey(name: 'requester_id') String requesterId,
    @JsonKey(name: 'responder_id') String? responderId,
    int reward,
    double latitude,
    double longitude,
    String status,
    @JsonKey(name: 'created_at') DateTime createdAt,
    @JsonKey(name: 'response_photo_url') String? responsePhotoUrl,
  });
}

/// @nodoc
class __$$DdipEventModelImplCopyWithImpl<$Res>
    extends _$DdipEventModelCopyWithImpl<$Res, _$DdipEventModelImpl>
    implements _$$DdipEventModelImplCopyWith<$Res> {
  __$$DdipEventModelImplCopyWithImpl(
    _$DdipEventModelImpl _value,
    $Res Function(_$DdipEventModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DdipEventModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? content = null,
    Object? requesterId = null,
    Object? responderId = freezed,
    Object? reward = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? status = null,
    Object? createdAt = null,
    Object? responsePhotoUrl = freezed,
  }) {
    return _then(
      _$DdipEventModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        content:
            null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String,
        requesterId:
            null == requesterId
                ? _value.requesterId
                : requesterId // ignore: cast_nullable_to_non_nullable
                    as String,
        responderId:
            freezed == responderId
                ? _value.responderId
                : responderId // ignore: cast_nullable_to_non_nullable
                    as String?,
        reward:
            null == reward
                ? _value.reward
                : reward // ignore: cast_nullable_to_non_nullable
                    as int,
        latitude:
            null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                    as double,
        longitude:
            null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                    as double,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        responsePhotoUrl:
            freezed == responsePhotoUrl
                ? _value.responsePhotoUrl
                : responsePhotoUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DdipEventModelImpl implements _DdipEventModel {
  const _$DdipEventModelImpl({
    required this.id,
    required this.title,
    required this.content,
    @JsonKey(name: 'requester_id') required this.requesterId,
    @JsonKey(name: 'responder_id') this.responderId,
    required this.reward,
    required this.latitude,
    required this.longitude,
    required this.status,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'response_photo_url') this.responsePhotoUrl,
  });

  factory _$DdipEventModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DdipEventModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String content;
  // @JsonKey를 이렇게 각 필드에 직접 적용해야 합니다.
  @override
  @JsonKey(name: 'requester_id')
  final String requesterId;
  @override
  @JsonKey(name: 'responder_id')
  final String? responderId;
  @override
  final int reward;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final String status;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  @JsonKey(name: 'response_photo_url')
  final String? responsePhotoUrl;

  @override
  String toString() {
    return 'DdipEventModel(id: $id, title: $title, content: $content, requesterId: $requesterId, responderId: $responderId, reward: $reward, latitude: $latitude, longitude: $longitude, status: $status, createdAt: $createdAt, responsePhotoUrl: $responsePhotoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DdipEventModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.requesterId, requesterId) ||
                other.requesterId == requesterId) &&
            (identical(other.responderId, responderId) ||
                other.responderId == responderId) &&
            (identical(other.reward, reward) || other.reward == reward) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.responsePhotoUrl, responsePhotoUrl) ||
                other.responsePhotoUrl == responsePhotoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    content,
    requesterId,
    responderId,
    reward,
    latitude,
    longitude,
    status,
    createdAt,
    responsePhotoUrl,
  );

  /// Create a copy of DdipEventModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DdipEventModelImplCopyWith<_$DdipEventModelImpl> get copyWith =>
      __$$DdipEventModelImplCopyWithImpl<_$DdipEventModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DdipEventModelImplToJson(this);
  }
}

abstract class _DdipEventModel implements DdipEventModel {
  const factory _DdipEventModel({
    required final String id,
    required final String title,
    required final String content,
    @JsonKey(name: 'requester_id') required final String requesterId,
    @JsonKey(name: 'responder_id') final String? responderId,
    required final int reward,
    required final double latitude,
    required final double longitude,
    required final String status,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    @JsonKey(name: 'response_photo_url') final String? responsePhotoUrl,
  }) = _$DdipEventModelImpl;

  factory _DdipEventModel.fromJson(Map<String, dynamic> json) =
      _$DdipEventModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get content; // @JsonKey를 이렇게 각 필드에 직접 적용해야 합니다.
  @override
  @JsonKey(name: 'requester_id')
  String get requesterId;
  @override
  @JsonKey(name: 'responder_id')
  String? get responderId;
  @override
  int get reward;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  String get status;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(name: 'response_photo_url')
  String? get responsePhotoUrl;

  /// Create a copy of DdipEventModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DdipEventModelImplCopyWith<_$DdipEventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
