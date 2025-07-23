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
  String get content => throw _privateConstructorUsedError;
  @JsonKey(name: 'requester_id')
  String get requesterId => throw _privateConstructorUsedError;
  int get reward => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'selected_responder_id')
  String? get selectedResponderId => throw _privateConstructorUsedError;
  List<String> get applicants => throw _privateConstructorUsedError;
  List<PhotoFeedbackModel> get photos => throw _privateConstructorUsedError;
  List<InteractionModel> get interactions => throw _privateConstructorUsedError;

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
    int reward,
    double latitude,
    double longitude,
    @JsonKey(name: 'created_at') DateTime createdAt,
    String status,
    @JsonKey(name: 'selected_responder_id') String? selectedResponderId,
    List<String> applicants,
    List<PhotoFeedbackModel> photos,
    List<InteractionModel> interactions,
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
    Object? reward = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? createdAt = null,
    Object? status = null,
    Object? selectedResponderId = freezed,
    Object? applicants = null,
    Object? photos = null,
    Object? interactions = null,
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
            createdAt:
                null == createdAt
                    ? _value.createdAt
                    : createdAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String,
            selectedResponderId:
                freezed == selectedResponderId
                    ? _value.selectedResponderId
                    : selectedResponderId // ignore: cast_nullable_to_non_nullable
                        as String?,
            applicants:
                null == applicants
                    ? _value.applicants
                    : applicants // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            photos:
                null == photos
                    ? _value.photos
                    : photos // ignore: cast_nullable_to_non_nullable
                        as List<PhotoFeedbackModel>,
            interactions:
                null == interactions
                    ? _value.interactions
                    : interactions // ignore: cast_nullable_to_non_nullable
                        as List<InteractionModel>,
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
    int reward,
    double latitude,
    double longitude,
    @JsonKey(name: 'created_at') DateTime createdAt,
    String status,
    @JsonKey(name: 'selected_responder_id') String? selectedResponderId,
    List<String> applicants,
    List<PhotoFeedbackModel> photos,
    List<InteractionModel> interactions,
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
    Object? reward = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? createdAt = null,
    Object? status = null,
    Object? selectedResponderId = freezed,
    Object? applicants = null,
    Object? photos = null,
    Object? interactions = null,
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
        createdAt:
            null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String,
        selectedResponderId:
            freezed == selectedResponderId
                ? _value.selectedResponderId
                : selectedResponderId // ignore: cast_nullable_to_non_nullable
                    as String?,
        applicants:
            null == applicants
                ? _value._applicants
                : applicants // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        photos:
            null == photos
                ? _value._photos
                : photos // ignore: cast_nullable_to_non_nullable
                    as List<PhotoFeedbackModel>,
        interactions:
            null == interactions
                ? _value._interactions
                : interactions // ignore: cast_nullable_to_non_nullable
                    as List<InteractionModel>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DdipEventModelImpl extends _DdipEventModel {
  const _$DdipEventModelImpl({
    required this.id,
    required this.title,
    required this.content,
    @JsonKey(name: 'requester_id') required this.requesterId,
    required this.reward,
    required this.latitude,
    required this.longitude,
    @JsonKey(name: 'created_at') required this.createdAt,
    required this.status,
    @JsonKey(name: 'selected_responder_id') this.selectedResponderId,
    final List<String> applicants = const [],
    final List<PhotoFeedbackModel> photos = const [],
    final List<InteractionModel> interactions = const [],
  }) : _applicants = applicants,
       _photos = photos,
       _interactions = interactions,
       super._();

  factory _$DdipEventModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$DdipEventModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String content;
  @override
  @JsonKey(name: 'requester_id')
  final String requesterId;
  @override
  final int reward;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  final String status;
  @override
  @JsonKey(name: 'selected_responder_id')
  final String? selectedResponderId;
  final List<String> _applicants;
  @override
  @JsonKey()
  List<String> get applicants {
    if (_applicants is EqualUnmodifiableListView) return _applicants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_applicants);
  }

  final List<PhotoFeedbackModel> _photos;
  @override
  @JsonKey()
  List<PhotoFeedbackModel> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  final List<InteractionModel> _interactions;
  @override
  @JsonKey()
  List<InteractionModel> get interactions {
    if (_interactions is EqualUnmodifiableListView) return _interactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interactions);
  }

  @override
  String toString() {
    return 'DdipEventModel(id: $id, title: $title, content: $content, requesterId: $requesterId, reward: $reward, latitude: $latitude, longitude: $longitude, createdAt: $createdAt, status: $status, selectedResponderId: $selectedResponderId, applicants: $applicants, photos: $photos, interactions: $interactions)';
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
            (identical(other.reward, reward) || other.reward == reward) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.selectedResponderId, selectedResponderId) ||
                other.selectedResponderId == selectedResponderId) &&
            const DeepCollectionEquality().equals(
              other._applicants,
              _applicants,
            ) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            const DeepCollectionEquality().equals(
              other._interactions,
              _interactions,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    content,
    requesterId,
    reward,
    latitude,
    longitude,
    createdAt,
    status,
    selectedResponderId,
    const DeepCollectionEquality().hash(_applicants),
    const DeepCollectionEquality().hash(_photos),
    const DeepCollectionEquality().hash(_interactions),
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

abstract class _DdipEventModel extends DdipEventModel {
  const factory _DdipEventModel({
    required final String id,
    required final String title,
    required final String content,
    @JsonKey(name: 'requester_id') required final String requesterId,
    required final int reward,
    required final double latitude,
    required final double longitude,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    required final String status,
    @JsonKey(name: 'selected_responder_id') final String? selectedResponderId,
    final List<String> applicants,
    final List<PhotoFeedbackModel> photos,
    final List<InteractionModel> interactions,
  }) = _$DdipEventModelImpl;
  const _DdipEventModel._() : super._();

  factory _DdipEventModel.fromJson(Map<String, dynamic> json) =
      _$DdipEventModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get content;
  @override
  @JsonKey(name: 'requester_id')
  String get requesterId;
  @override
  int get reward;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  String get status;
  @override
  @JsonKey(name: 'selected_responder_id')
  String? get selectedResponderId;
  @override
  List<String> get applicants;
  @override
  List<PhotoFeedbackModel> get photos;
  @override
  List<InteractionModel> get interactions;

  /// Create a copy of DdipEventModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DdipEventModelImplCopyWith<_$DdipEventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
