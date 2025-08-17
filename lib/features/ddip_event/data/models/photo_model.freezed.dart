// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PhotoModel _$PhotoModelFromJson(Map<String, dynamic> json) {
  return _PhotoModel.fromJson(json);
}

/// @nodoc
mixin _$PhotoModel {
  @JsonKey(name: 'photoId')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'photoUrl')
  String get url => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get responderComment => throw _privateConstructorUsedError;
  String? get requesterQuestion => throw _privateConstructorUsedError;
  String? get responderAnswer => throw _privateConstructorUsedError;
  String? get rejectionReason => throw _privateConstructorUsedError;

  /// Serializes this PhotoModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoModelCopyWith<PhotoModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoModelCopyWith<$Res> {
  factory $PhotoModelCopyWith(
    PhotoModel value,
    $Res Function(PhotoModel) then,
  ) = _$PhotoModelCopyWithImpl<$Res, PhotoModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'photoId') String id,
    @JsonKey(name: 'photoUrl') String url,
    double latitude,
    double longitude,
    DateTime timestamp,
    String status,
    String? responderComment,
    String? requesterQuestion,
    String? responderAnswer,
    String? rejectionReason,
  });
}

/// @nodoc
class _$PhotoModelCopyWithImpl<$Res, $Val extends PhotoModel>
    implements $PhotoModelCopyWith<$Res> {
  _$PhotoModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = null,
    Object? status = null,
    Object? responderComment = freezed,
    Object? requesterQuestion = freezed,
    Object? responderAnswer = freezed,
    Object? rejectionReason = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            url:
                null == url
                    ? _value.url
                    : url // ignore: cast_nullable_to_non_nullable
                        as String,
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
            timestamp:
                null == timestamp
                    ? _value.timestamp
                    : timestamp // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            responderComment:
                freezed == responderComment
                    ? _value.responderComment
                    : responderComment // ignore: cast_nullable_to_non_nullable
                        as String?,
            requesterQuestion:
                freezed == requesterQuestion
                    ? _value.requesterQuestion
                    : requesterQuestion // ignore: cast_nullable_to_non_nullable
                        as String?,
            responderAnswer:
                freezed == responderAnswer
                    ? _value.responderAnswer
                    : responderAnswer // ignore: cast_nullable_to_non_nullable
                        as String?,
            rejectionReason:
                freezed == rejectionReason
                    ? _value.rejectionReason
                    : rejectionReason // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PhotoModelImplCopyWith<$Res>
    implements $PhotoModelCopyWith<$Res> {
  factory _$$PhotoModelImplCopyWith(
    _$PhotoModelImpl value,
    $Res Function(_$PhotoModelImpl) then,
  ) = __$$PhotoModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'photoId') String id,
    @JsonKey(name: 'photoUrl') String url,
    double latitude,
    double longitude,
    DateTime timestamp,
    String status,
    String? responderComment,
    String? requesterQuestion,
    String? responderAnswer,
    String? rejectionReason,
  });
}

/// @nodoc
class __$$PhotoModelImplCopyWithImpl<$Res>
    extends _$PhotoModelCopyWithImpl<$Res, _$PhotoModelImpl>
    implements _$$PhotoModelImplCopyWith<$Res> {
  __$$PhotoModelImplCopyWithImpl(
    _$PhotoModelImpl _value,
    $Res Function(_$PhotoModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = null,
    Object? status = null,
    Object? responderComment = freezed,
    Object? requesterQuestion = freezed,
    Object? responderAnswer = freezed,
    Object? rejectionReason = freezed,
  }) {
    return _then(
      _$PhotoModelImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        url:
            null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                    as String,
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
        timestamp:
            null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        responderComment:
            freezed == responderComment
                ? _value.responderComment
                : responderComment // ignore: cast_nullable_to_non_nullable
                    as String?,
        requesterQuestion:
            freezed == requesterQuestion
                ? _value.requesterQuestion
                : requesterQuestion // ignore: cast_nullable_to_non_nullable
                    as String?,
        responderAnswer:
            freezed == responderAnswer
                ? _value.responderAnswer
                : responderAnswer // ignore: cast_nullable_to_non_nullable
                    as String?,
        rejectionReason:
            freezed == rejectionReason
                ? _value.rejectionReason
                : rejectionReason // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PhotoModelImpl extends _PhotoModel {
  const _$PhotoModelImpl({
    @JsonKey(name: 'photoId') required this.id,
    @JsonKey(name: 'photoUrl') required this.url,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.status,
    this.responderComment,
    this.requesterQuestion,
    this.responderAnswer,
    this.rejectionReason,
  }) : super._();

  factory _$PhotoModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoModelImplFromJson(json);

  @override
  @JsonKey(name: 'photoId')
  final String id;
  @override
  @JsonKey(name: 'photoUrl')
  final String url;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final DateTime timestamp;
  @override
  final String status;
  @override
  final String? responderComment;
  @override
  final String? requesterQuestion;
  @override
  final String? responderAnswer;
  @override
  final String? rejectionReason;

  @override
  String toString() {
    return 'PhotoModel(id: $id, url: $url, latitude: $latitude, longitude: $longitude, timestamp: $timestamp, status: $status, responderComment: $responderComment, requesterQuestion: $requesterQuestion, responderAnswer: $responderAnswer, rejectionReason: $rejectionReason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.responderComment, responderComment) ||
                other.responderComment == responderComment) &&
            (identical(other.requesterQuestion, requesterQuestion) ||
                other.requesterQuestion == requesterQuestion) &&
            (identical(other.responderAnswer, responderAnswer) ||
                other.responderAnswer == responderAnswer) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    url,
    latitude,
    longitude,
    timestamp,
    status,
    responderComment,
    requesterQuestion,
    responderAnswer,
    rejectionReason,
  );

  /// Create a copy of PhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoModelImplCopyWith<_$PhotoModelImpl> get copyWith =>
      __$$PhotoModelImplCopyWithImpl<_$PhotoModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoModelImplToJson(this);
  }
}

abstract class _PhotoModel extends PhotoModel {
  const factory _PhotoModel({
    @JsonKey(name: 'photoId') required final String id,
    @JsonKey(name: 'photoUrl') required final String url,
    required final double latitude,
    required final double longitude,
    required final DateTime timestamp,
    required final String status,
    final String? responderComment,
    final String? requesterQuestion,
    final String? responderAnswer,
    final String? rejectionReason,
  }) = _$PhotoModelImpl;
  const _PhotoModel._() : super._();

  factory _PhotoModel.fromJson(Map<String, dynamic> json) =
      _$PhotoModelImpl.fromJson;

  @override
  @JsonKey(name: 'photoId')
  String get id;
  @override
  @JsonKey(name: 'photoUrl')
  String get url;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  DateTime get timestamp;
  @override
  String get status;
  @override
  String? get responderComment;
  @override
  String? get requesterQuestion;
  @override
  String? get responderAnswer;
  @override
  String? get rejectionReason;

  /// Create a copy of PhotoModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoModelImplCopyWith<_$PhotoModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
