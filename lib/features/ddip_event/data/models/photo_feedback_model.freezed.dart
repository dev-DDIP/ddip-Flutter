// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'photo_feedback_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PhotoFeedbackModel _$PhotoFeedbackModelFromJson(Map<String, dynamic> json) {
  return _PhotoFeedbackModel.fromJson(json);
}

/// @nodoc
mixin _$PhotoFeedbackModel {
  String get photoId => throw _privateConstructorUsedError;
  @JsonKey(name: 'photo_url')
  String get photoUrl => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  /// Serializes this PhotoFeedbackModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PhotoFeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PhotoFeedbackModelCopyWith<PhotoFeedbackModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PhotoFeedbackModelCopyWith<$Res> {
  factory $PhotoFeedbackModelCopyWith(
    PhotoFeedbackModel value,
    $Res Function(PhotoFeedbackModel) then,
  ) = _$PhotoFeedbackModelCopyWithImpl<$Res, PhotoFeedbackModel>;
  @useResult
  $Res call({
    String photoId,
    @JsonKey(name: 'photo_url') String photoUrl,
    double latitude,
    double longitude,
    DateTime timestamp,
    String status,
  });
}

/// @nodoc
class _$PhotoFeedbackModelCopyWithImpl<$Res, $Val extends PhotoFeedbackModel>
    implements $PhotoFeedbackModelCopyWith<$Res> {
  _$PhotoFeedbackModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PhotoFeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoId = null,
    Object? photoUrl = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = null,
    Object? status = null,
  }) {
    return _then(
      _value.copyWith(
            photoId:
                null == photoId
                    ? _value.photoId
                    : photoId // ignore: cast_nullable_to_non_nullable
                        as String,
            photoUrl:
                null == photoUrl
                    ? _value.photoUrl
                    : photoUrl // ignore: cast_nullable_to_non_nullable
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PhotoFeedbackModelImplCopyWith<$Res>
    implements $PhotoFeedbackModelCopyWith<$Res> {
  factory _$$PhotoFeedbackModelImplCopyWith(
    _$PhotoFeedbackModelImpl value,
    $Res Function(_$PhotoFeedbackModelImpl) then,
  ) = __$$PhotoFeedbackModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String photoId,
    @JsonKey(name: 'photo_url') String photoUrl,
    double latitude,
    double longitude,
    DateTime timestamp,
    String status,
  });
}

/// @nodoc
class __$$PhotoFeedbackModelImplCopyWithImpl<$Res>
    extends _$PhotoFeedbackModelCopyWithImpl<$Res, _$PhotoFeedbackModelImpl>
    implements _$$PhotoFeedbackModelImplCopyWith<$Res> {
  __$$PhotoFeedbackModelImplCopyWithImpl(
    _$PhotoFeedbackModelImpl _value,
    $Res Function(_$PhotoFeedbackModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PhotoFeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoId = null,
    Object? photoUrl = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = null,
    Object? status = null,
  }) {
    return _then(
      _$PhotoFeedbackModelImpl(
        photoId:
            null == photoId
                ? _value.photoId
                : photoId // ignore: cast_nullable_to_non_nullable
                    as String,
        photoUrl:
            null == photoUrl
                ? _value.photoUrl
                : photoUrl // ignore: cast_nullable_to_non_nullable
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PhotoFeedbackModelImpl extends _PhotoFeedbackModel {
  const _$PhotoFeedbackModelImpl({
    required this.photoId,
    @JsonKey(name: 'photo_url') required this.photoUrl,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.status,
  }) : super._();

  factory _$PhotoFeedbackModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PhotoFeedbackModelImplFromJson(json);

  @override
  final String photoId;
  @override
  @JsonKey(name: 'photo_url')
  final String photoUrl;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final DateTime timestamp;
  @override
  final String status;

  @override
  String toString() {
    return 'PhotoFeedbackModel(photoId: $photoId, photoUrl: $photoUrl, latitude: $latitude, longitude: $longitude, timestamp: $timestamp, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PhotoFeedbackModelImpl &&
            (identical(other.photoId, photoId) || other.photoId == photoId) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    photoId,
    photoUrl,
    latitude,
    longitude,
    timestamp,
    status,
  );

  /// Create a copy of PhotoFeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PhotoFeedbackModelImplCopyWith<_$PhotoFeedbackModelImpl> get copyWith =>
      __$$PhotoFeedbackModelImplCopyWithImpl<_$PhotoFeedbackModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PhotoFeedbackModelImplToJson(this);
  }
}

abstract class _PhotoFeedbackModel extends PhotoFeedbackModel {
  const factory _PhotoFeedbackModel({
    required final String photoId,
    @JsonKey(name: 'photo_url') required final String photoUrl,
    required final double latitude,
    required final double longitude,
    required final DateTime timestamp,
    required final String status,
  }) = _$PhotoFeedbackModelImpl;
  const _PhotoFeedbackModel._() : super._();

  factory _PhotoFeedbackModel.fromJson(Map<String, dynamic> json) =
      _$PhotoFeedbackModelImpl.fromJson;

  @override
  String get photoId;
  @override
  @JsonKey(name: 'photo_url')
  String get photoUrl;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  DateTime get timestamp;
  @override
  String get status;

  /// Create a copy of PhotoFeedbackModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PhotoFeedbackModelImplCopyWith<_$PhotoFeedbackModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
