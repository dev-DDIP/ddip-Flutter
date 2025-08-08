// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return _Profile.fromJson(json);
}

/// @nodoc
mixin _$Profile {
  String get userId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String get profileImageUrl => throw _privateConstructorUsedError;
  String get oneLineIntro => throw _privateConstructorUsedError;
  int get totalRequestCount => throw _privateConstructorUsedError;
  int get totalExecutionCount => throw _privateConstructorUsedError;
  int get ddipPoints => throw _privateConstructorUsedError;
  CertificationMark? get certificationMark =>
      throw _privateConstructorUsedError;
  RequesterReputation get requesterReputation =>
      throw _privateConstructorUsedError;
  ResponderReputation get responderReputation =>
      throw _privateConstructorUsedError;
  List<Badge> get badges => throw _privateConstructorUsedError;
  List<Tag> get tags =>
      throw _privateConstructorUsedError; // Key: 시간(e.g., "09", "18"), Value: 활동 횟수
  Map<String, int> get activityHours => throw _privateConstructorUsedError;

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileCopyWith<Profile> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileCopyWith<$Res> {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) then) =
      _$ProfileCopyWithImpl<$Res, Profile>;
  @useResult
  $Res call({
    String userId,
    String nickname,
    String profileImageUrl,
    String oneLineIntro,
    int totalRequestCount,
    int totalExecutionCount,
    int ddipPoints,
    CertificationMark? certificationMark,
    RequesterReputation requesterReputation,
    ResponderReputation responderReputation,
    List<Badge> badges,
    List<Tag> tags,
    Map<String, int> activityHours,
  });

  $CertificationMarkCopyWith<$Res>? get certificationMark;
  $RequesterReputationCopyWith<$Res> get requesterReputation;
  $ResponderReputationCopyWith<$Res> get responderReputation;
}

/// @nodoc
class _$ProfileCopyWithImpl<$Res, $Val extends Profile>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? profileImageUrl = null,
    Object? oneLineIntro = null,
    Object? totalRequestCount = null,
    Object? totalExecutionCount = null,
    Object? ddipPoints = null,
    Object? certificationMark = freezed,
    Object? requesterReputation = null,
    Object? responderReputation = null,
    Object? badges = null,
    Object? tags = null,
    Object? activityHours = null,
  }) {
    return _then(
      _value.copyWith(
            userId:
                null == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String,
            nickname:
                null == nickname
                    ? _value.nickname
                    : nickname // ignore: cast_nullable_to_non_nullable
                        as String,
            profileImageUrl:
                null == profileImageUrl
                    ? _value.profileImageUrl
                    : profileImageUrl // ignore: cast_nullable_to_non_nullable
                        as String,
            oneLineIntro:
                null == oneLineIntro
                    ? _value.oneLineIntro
                    : oneLineIntro // ignore: cast_nullable_to_non_nullable
                        as String,
            totalRequestCount:
                null == totalRequestCount
                    ? _value.totalRequestCount
                    : totalRequestCount // ignore: cast_nullable_to_non_nullable
                        as int,
            totalExecutionCount:
                null == totalExecutionCount
                    ? _value.totalExecutionCount
                    : totalExecutionCount // ignore: cast_nullable_to_non_nullable
                        as int,
            ddipPoints:
                null == ddipPoints
                    ? _value.ddipPoints
                    : ddipPoints // ignore: cast_nullable_to_non_nullable
                        as int,
            certificationMark:
                freezed == certificationMark
                    ? _value.certificationMark
                    : certificationMark // ignore: cast_nullable_to_non_nullable
                        as CertificationMark?,
            requesterReputation:
                null == requesterReputation
                    ? _value.requesterReputation
                    : requesterReputation // ignore: cast_nullable_to_non_nullable
                        as RequesterReputation,
            responderReputation:
                null == responderReputation
                    ? _value.responderReputation
                    : responderReputation // ignore: cast_nullable_to_non_nullable
                        as ResponderReputation,
            badges:
                null == badges
                    ? _value.badges
                    : badges // ignore: cast_nullable_to_non_nullable
                        as List<Badge>,
            tags:
                null == tags
                    ? _value.tags
                    : tags // ignore: cast_nullable_to_non_nullable
                        as List<Tag>,
            activityHours:
                null == activityHours
                    ? _value.activityHours
                    : activityHours // ignore: cast_nullable_to_non_nullable
                        as Map<String, int>,
          )
          as $Val,
    );
  }

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CertificationMarkCopyWith<$Res>? get certificationMark {
    if (_value.certificationMark == null) {
      return null;
    }

    return $CertificationMarkCopyWith<$Res>(_value.certificationMark!, (value) {
      return _then(_value.copyWith(certificationMark: value) as $Val);
    });
  }

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RequesterReputationCopyWith<$Res> get requesterReputation {
    return $RequesterReputationCopyWith<$Res>(_value.requesterReputation, (
      value,
    ) {
      return _then(_value.copyWith(requesterReputation: value) as $Val);
    });
  }

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ResponderReputationCopyWith<$Res> get responderReputation {
    return $ResponderReputationCopyWith<$Res>(_value.responderReputation, (
      value,
    ) {
      return _then(_value.copyWith(responderReputation: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProfileImplCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$$ProfileImplCopyWith(
    _$ProfileImpl value,
    $Res Function(_$ProfileImpl) then,
  ) = __$$ProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String nickname,
    String profileImageUrl,
    String oneLineIntro,
    int totalRequestCount,
    int totalExecutionCount,
    int ddipPoints,
    CertificationMark? certificationMark,
    RequesterReputation requesterReputation,
    ResponderReputation responderReputation,
    List<Badge> badges,
    List<Tag> tags,
    Map<String, int> activityHours,
  });

  @override
  $CertificationMarkCopyWith<$Res>? get certificationMark;
  @override
  $RequesterReputationCopyWith<$Res> get requesterReputation;
  @override
  $ResponderReputationCopyWith<$Res> get responderReputation;
}

/// @nodoc
class __$$ProfileImplCopyWithImpl<$Res>
    extends _$ProfileCopyWithImpl<$Res, _$ProfileImpl>
    implements _$$ProfileImplCopyWith<$Res> {
  __$$ProfileImplCopyWithImpl(
    _$ProfileImpl _value,
    $Res Function(_$ProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? profileImageUrl = null,
    Object? oneLineIntro = null,
    Object? totalRequestCount = null,
    Object? totalExecutionCount = null,
    Object? ddipPoints = null,
    Object? certificationMark = freezed,
    Object? requesterReputation = null,
    Object? responderReputation = null,
    Object? badges = null,
    Object? tags = null,
    Object? activityHours = null,
  }) {
    return _then(
      _$ProfileImpl(
        userId:
            null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String,
        nickname:
            null == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                    as String,
        profileImageUrl:
            null == profileImageUrl
                ? _value.profileImageUrl
                : profileImageUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        oneLineIntro:
            null == oneLineIntro
                ? _value.oneLineIntro
                : oneLineIntro // ignore: cast_nullable_to_non_nullable
                    as String,
        totalRequestCount:
            null == totalRequestCount
                ? _value.totalRequestCount
                : totalRequestCount // ignore: cast_nullable_to_non_nullable
                    as int,
        totalExecutionCount:
            null == totalExecutionCount
                ? _value.totalExecutionCount
                : totalExecutionCount // ignore: cast_nullable_to_non_nullable
                    as int,
        ddipPoints:
            null == ddipPoints
                ? _value.ddipPoints
                : ddipPoints // ignore: cast_nullable_to_non_nullable
                    as int,
        certificationMark:
            freezed == certificationMark
                ? _value.certificationMark
                : certificationMark // ignore: cast_nullable_to_non_nullable
                    as CertificationMark?,
        requesterReputation:
            null == requesterReputation
                ? _value.requesterReputation
                : requesterReputation // ignore: cast_nullable_to_non_nullable
                    as RequesterReputation,
        responderReputation:
            null == responderReputation
                ? _value.responderReputation
                : responderReputation // ignore: cast_nullable_to_non_nullable
                    as ResponderReputation,
        badges:
            null == badges
                ? _value._badges
                : badges // ignore: cast_nullable_to_non_nullable
                    as List<Badge>,
        tags:
            null == tags
                ? _value._tags
                : tags // ignore: cast_nullable_to_non_nullable
                    as List<Tag>,
        activityHours:
            null == activityHours
                ? _value._activityHours
                : activityHours // ignore: cast_nullable_to_non_nullable
                    as Map<String, int>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileImpl implements _Profile {
  const _$ProfileImpl({
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
    required this.oneLineIntro,
    required this.totalRequestCount,
    required this.totalExecutionCount,
    required this.ddipPoints,
    required this.certificationMark,
    required this.requesterReputation,
    required this.responderReputation,
    required final List<Badge> badges,
    required final List<Tag> tags,
    required final Map<String, int> activityHours,
  }) : _badges = badges,
       _tags = tags,
       _activityHours = activityHours;

  factory _$ProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileImplFromJson(json);

  @override
  final String userId;
  @override
  final String nickname;
  @override
  final String profileImageUrl;
  @override
  final String oneLineIntro;
  @override
  final int totalRequestCount;
  @override
  final int totalExecutionCount;
  @override
  final int ddipPoints;
  @override
  final CertificationMark? certificationMark;
  @override
  final RequesterReputation requesterReputation;
  @override
  final ResponderReputation responderReputation;
  final List<Badge> _badges;
  @override
  List<Badge> get badges {
    if (_badges is EqualUnmodifiableListView) return _badges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_badges);
  }

  final List<Tag> _tags;
  @override
  List<Tag> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  // Key: 시간(e.g., "09", "18"), Value: 활동 횟수
  final Map<String, int> _activityHours;
  // Key: 시간(e.g., "09", "18"), Value: 활동 횟수
  @override
  Map<String, int> get activityHours {
    if (_activityHours is EqualUnmodifiableMapView) return _activityHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_activityHours);
  }

  @override
  String toString() {
    return 'Profile(userId: $userId, nickname: $nickname, profileImageUrl: $profileImageUrl, oneLineIntro: $oneLineIntro, totalRequestCount: $totalRequestCount, totalExecutionCount: $totalExecutionCount, ddipPoints: $ddipPoints, certificationMark: $certificationMark, requesterReputation: $requesterReputation, responderReputation: $responderReputation, badges: $badges, tags: $tags, activityHours: $activityHours)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.oneLineIntro, oneLineIntro) ||
                other.oneLineIntro == oneLineIntro) &&
            (identical(other.totalRequestCount, totalRequestCount) ||
                other.totalRequestCount == totalRequestCount) &&
            (identical(other.totalExecutionCount, totalExecutionCount) ||
                other.totalExecutionCount == totalExecutionCount) &&
            (identical(other.ddipPoints, ddipPoints) ||
                other.ddipPoints == ddipPoints) &&
            (identical(other.certificationMark, certificationMark) ||
                other.certificationMark == certificationMark) &&
            (identical(other.requesterReputation, requesterReputation) ||
                other.requesterReputation == requesterReputation) &&
            (identical(other.responderReputation, responderReputation) ||
                other.responderReputation == responderReputation) &&
            const DeepCollectionEquality().equals(other._badges, _badges) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            const DeepCollectionEquality().equals(
              other._activityHours,
              _activityHours,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    nickname,
    profileImageUrl,
    oneLineIntro,
    totalRequestCount,
    totalExecutionCount,
    ddipPoints,
    certificationMark,
    requesterReputation,
    responderReputation,
    const DeepCollectionEquality().hash(_badges),
    const DeepCollectionEquality().hash(_tags),
    const DeepCollectionEquality().hash(_activityHours),
  );

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      __$$ProfileImplCopyWithImpl<_$ProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileImplToJson(this);
  }
}

abstract class _Profile implements Profile {
  const factory _Profile({
    required final String userId,
    required final String nickname,
    required final String profileImageUrl,
    required final String oneLineIntro,
    required final int totalRequestCount,
    required final int totalExecutionCount,
    required final int ddipPoints,
    required final CertificationMark? certificationMark,
    required final RequesterReputation requesterReputation,
    required final ResponderReputation responderReputation,
    required final List<Badge> badges,
    required final List<Tag> tags,
    required final Map<String, int> activityHours,
  }) = _$ProfileImpl;

  factory _Profile.fromJson(Map<String, dynamic> json) = _$ProfileImpl.fromJson;

  @override
  String get userId;
  @override
  String get nickname;
  @override
  String get profileImageUrl;
  @override
  String get oneLineIntro;
  @override
  int get totalRequestCount;
  @override
  int get totalExecutionCount;
  @override
  int get ddipPoints;
  @override
  CertificationMark? get certificationMark;
  @override
  RequesterReputation get requesterReputation;
  @override
  ResponderReputation get responderReputation;
  @override
  List<Badge> get badges;
  @override
  List<Tag> get tags; // Key: 시간(e.g., "09", "18"), Value: 활동 횟수
  @override
  Map<String, int> get activityHours;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CertificationMark _$CertificationMarkFromJson(Map<String, dynamic> json) {
  return _CertificationMark.fromJson(json);
}

/// @nodoc
mixin _$CertificationMark {
  String get title =>
      throw _privateConstructorUsedError; // e.g., "상위 10% 활발 수행자"
  String get semester => throw _privateConstructorUsedError;

  /// Serializes this CertificationMark to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CertificationMark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CertificationMarkCopyWith<CertificationMark> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CertificationMarkCopyWith<$Res> {
  factory $CertificationMarkCopyWith(
    CertificationMark value,
    $Res Function(CertificationMark) then,
  ) = _$CertificationMarkCopyWithImpl<$Res, CertificationMark>;
  @useResult
  $Res call({String title, String semester});
}

/// @nodoc
class _$CertificationMarkCopyWithImpl<$Res, $Val extends CertificationMark>
    implements $CertificationMarkCopyWith<$Res> {
  _$CertificationMarkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CertificationMark
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? title = null, Object? semester = null}) {
    return _then(
      _value.copyWith(
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            semester:
                null == semester
                    ? _value.semester
                    : semester // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CertificationMarkImplCopyWith<$Res>
    implements $CertificationMarkCopyWith<$Res> {
  factory _$$CertificationMarkImplCopyWith(
    _$CertificationMarkImpl value,
    $Res Function(_$CertificationMarkImpl) then,
  ) = __$$CertificationMarkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String title, String semester});
}

/// @nodoc
class __$$CertificationMarkImplCopyWithImpl<$Res>
    extends _$CertificationMarkCopyWithImpl<$Res, _$CertificationMarkImpl>
    implements _$$CertificationMarkImplCopyWith<$Res> {
  __$$CertificationMarkImplCopyWithImpl(
    _$CertificationMarkImpl _value,
    $Res Function(_$CertificationMarkImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CertificationMark
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? title = null, Object? semester = null}) {
    return _then(
      _$CertificationMarkImpl(
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        semester:
            null == semester
                ? _value.semester
                : semester // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CertificationMarkImpl implements _CertificationMark {
  const _$CertificationMarkImpl({required this.title, required this.semester});

  factory _$CertificationMarkImpl.fromJson(Map<String, dynamic> json) =>
      _$$CertificationMarkImplFromJson(json);

  @override
  final String title;
  // e.g., "상위 10% 활발 수행자"
  @override
  final String semester;

  @override
  String toString() {
    return 'CertificationMark(title: $title, semester: $semester)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CertificationMarkImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.semester, semester) ||
                other.semester == semester));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, title, semester);

  /// Create a copy of CertificationMark
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CertificationMarkImplCopyWith<_$CertificationMarkImpl> get copyWith =>
      __$$CertificationMarkImplCopyWithImpl<_$CertificationMarkImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CertificationMarkImplToJson(this);
  }
}

abstract class _CertificationMark implements CertificationMark {
  const factory _CertificationMark({
    required final String title,
    required final String semester,
  }) = _$CertificationMarkImpl;

  factory _CertificationMark.fromJson(Map<String, dynamic> json) =
      _$CertificationMarkImpl.fromJson;

  @override
  String get title; // e.g., "상위 10% 활발 수행자"
  @override
  String get semester;

  /// Create a copy of CertificationMark
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CertificationMarkImplCopyWith<_$CertificationMarkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RequesterReputation _$RequesterReputationFromJson(Map<String, dynamic> json) {
  return _RequesterReputation.fromJson(json);
}

/// @nodoc
mixin _$RequesterReputation {
  double get photoApprovalRate => throw _privateConstructorUsedError;
  int get avgSelectionTimeMinutes => throw _privateConstructorUsedError;
  double get responderSatisfaction => throw _privateConstructorUsedError;

  /// Serializes this RequesterReputation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RequesterReputation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RequesterReputationCopyWith<RequesterReputation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RequesterReputationCopyWith<$Res> {
  factory $RequesterReputationCopyWith(
    RequesterReputation value,
    $Res Function(RequesterReputation) then,
  ) = _$RequesterReputationCopyWithImpl<$Res, RequesterReputation>;
  @useResult
  $Res call({
    double photoApprovalRate,
    int avgSelectionTimeMinutes,
    double responderSatisfaction,
  });
}

/// @nodoc
class _$RequesterReputationCopyWithImpl<$Res, $Val extends RequesterReputation>
    implements $RequesterReputationCopyWith<$Res> {
  _$RequesterReputationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RequesterReputation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoApprovalRate = null,
    Object? avgSelectionTimeMinutes = null,
    Object? responderSatisfaction = null,
  }) {
    return _then(
      _value.copyWith(
            photoApprovalRate:
                null == photoApprovalRate
                    ? _value.photoApprovalRate
                    : photoApprovalRate // ignore: cast_nullable_to_non_nullable
                        as double,
            avgSelectionTimeMinutes:
                null == avgSelectionTimeMinutes
                    ? _value.avgSelectionTimeMinutes
                    : avgSelectionTimeMinutes // ignore: cast_nullable_to_non_nullable
                        as int,
            responderSatisfaction:
                null == responderSatisfaction
                    ? _value.responderSatisfaction
                    : responderSatisfaction // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RequesterReputationImplCopyWith<$Res>
    implements $RequesterReputationCopyWith<$Res> {
  factory _$$RequesterReputationImplCopyWith(
    _$RequesterReputationImpl value,
    $Res Function(_$RequesterReputationImpl) then,
  ) = __$$RequesterReputationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double photoApprovalRate,
    int avgSelectionTimeMinutes,
    double responderSatisfaction,
  });
}

/// @nodoc
class __$$RequesterReputationImplCopyWithImpl<$Res>
    extends _$RequesterReputationCopyWithImpl<$Res, _$RequesterReputationImpl>
    implements _$$RequesterReputationImplCopyWith<$Res> {
  __$$RequesterReputationImplCopyWithImpl(
    _$RequesterReputationImpl _value,
    $Res Function(_$RequesterReputationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RequesterReputation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? photoApprovalRate = null,
    Object? avgSelectionTimeMinutes = null,
    Object? responderSatisfaction = null,
  }) {
    return _then(
      _$RequesterReputationImpl(
        photoApprovalRate:
            null == photoApprovalRate
                ? _value.photoApprovalRate
                : photoApprovalRate // ignore: cast_nullable_to_non_nullable
                    as double,
        avgSelectionTimeMinutes:
            null == avgSelectionTimeMinutes
                ? _value.avgSelectionTimeMinutes
                : avgSelectionTimeMinutes // ignore: cast_nullable_to_non_nullable
                    as int,
        responderSatisfaction:
            null == responderSatisfaction
                ? _value.responderSatisfaction
                : responderSatisfaction // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RequesterReputationImpl implements _RequesterReputation {
  const _$RequesterReputationImpl({
    required this.photoApprovalRate,
    required this.avgSelectionTimeMinutes,
    required this.responderSatisfaction,
  });

  factory _$RequesterReputationImpl.fromJson(Map<String, dynamic> json) =>
      _$$RequesterReputationImplFromJson(json);

  @override
  final double photoApprovalRate;
  @override
  final int avgSelectionTimeMinutes;
  @override
  final double responderSatisfaction;

  @override
  String toString() {
    return 'RequesterReputation(photoApprovalRate: $photoApprovalRate, avgSelectionTimeMinutes: $avgSelectionTimeMinutes, responderSatisfaction: $responderSatisfaction)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RequesterReputationImpl &&
            (identical(other.photoApprovalRate, photoApprovalRate) ||
                other.photoApprovalRate == photoApprovalRate) &&
            (identical(
                  other.avgSelectionTimeMinutes,
                  avgSelectionTimeMinutes,
                ) ||
                other.avgSelectionTimeMinutes == avgSelectionTimeMinutes) &&
            (identical(other.responderSatisfaction, responderSatisfaction) ||
                other.responderSatisfaction == responderSatisfaction));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    photoApprovalRate,
    avgSelectionTimeMinutes,
    responderSatisfaction,
  );

  /// Create a copy of RequesterReputation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RequesterReputationImplCopyWith<_$RequesterReputationImpl> get copyWith =>
      __$$RequesterReputationImplCopyWithImpl<_$RequesterReputationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RequesterReputationImplToJson(this);
  }
}

abstract class _RequesterReputation implements RequesterReputation {
  const factory _RequesterReputation({
    required final double photoApprovalRate,
    required final int avgSelectionTimeMinutes,
    required final double responderSatisfaction,
  }) = _$RequesterReputationImpl;

  factory _RequesterReputation.fromJson(Map<String, dynamic> json) =
      _$RequesterReputationImpl.fromJson;

  @override
  double get photoApprovalRate;
  @override
  int get avgSelectionTimeMinutes;
  @override
  double get responderSatisfaction;

  /// Create a copy of RequesterReputation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RequesterReputationImplCopyWith<_$RequesterReputationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ResponderReputation _$ResponderReputationFromJson(Map<String, dynamic> json) {
  return _ResponderReputation.fromJson(json);
}

/// @nodoc
mixin _$ResponderReputation {
  int get avgResponseTimeMinutes => throw _privateConstructorUsedError;
  double get photoApprovalRate => throw _privateConstructorUsedError;
  double get abandonmentRate => throw _privateConstructorUsedError;

  /// Serializes this ResponderReputation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResponderReputation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResponderReputationCopyWith<ResponderReputation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResponderReputationCopyWith<$Res> {
  factory $ResponderReputationCopyWith(
    ResponderReputation value,
    $Res Function(ResponderReputation) then,
  ) = _$ResponderReputationCopyWithImpl<$Res, ResponderReputation>;
  @useResult
  $Res call({
    int avgResponseTimeMinutes,
    double photoApprovalRate,
    double abandonmentRate,
  });
}

/// @nodoc
class _$ResponderReputationCopyWithImpl<$Res, $Val extends ResponderReputation>
    implements $ResponderReputationCopyWith<$Res> {
  _$ResponderReputationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResponderReputation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avgResponseTimeMinutes = null,
    Object? photoApprovalRate = null,
    Object? abandonmentRate = null,
  }) {
    return _then(
      _value.copyWith(
            avgResponseTimeMinutes:
                null == avgResponseTimeMinutes
                    ? _value.avgResponseTimeMinutes
                    : avgResponseTimeMinutes // ignore: cast_nullable_to_non_nullable
                        as int,
            photoApprovalRate:
                null == photoApprovalRate
                    ? _value.photoApprovalRate
                    : photoApprovalRate // ignore: cast_nullable_to_non_nullable
                        as double,
            abandonmentRate:
                null == abandonmentRate
                    ? _value.abandonmentRate
                    : abandonmentRate // ignore: cast_nullable_to_non_nullable
                        as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ResponderReputationImplCopyWith<$Res>
    implements $ResponderReputationCopyWith<$Res> {
  factory _$$ResponderReputationImplCopyWith(
    _$ResponderReputationImpl value,
    $Res Function(_$ResponderReputationImpl) then,
  ) = __$$ResponderReputationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int avgResponseTimeMinutes,
    double photoApprovalRate,
    double abandonmentRate,
  });
}

/// @nodoc
class __$$ResponderReputationImplCopyWithImpl<$Res>
    extends _$ResponderReputationCopyWithImpl<$Res, _$ResponderReputationImpl>
    implements _$$ResponderReputationImplCopyWith<$Res> {
  __$$ResponderReputationImplCopyWithImpl(
    _$ResponderReputationImpl _value,
    $Res Function(_$ResponderReputationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ResponderReputation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avgResponseTimeMinutes = null,
    Object? photoApprovalRate = null,
    Object? abandonmentRate = null,
  }) {
    return _then(
      _$ResponderReputationImpl(
        avgResponseTimeMinutes:
            null == avgResponseTimeMinutes
                ? _value.avgResponseTimeMinutes
                : avgResponseTimeMinutes // ignore: cast_nullable_to_non_nullable
                    as int,
        photoApprovalRate:
            null == photoApprovalRate
                ? _value.photoApprovalRate
                : photoApprovalRate // ignore: cast_nullable_to_non_nullable
                    as double,
        abandonmentRate:
            null == abandonmentRate
                ? _value.abandonmentRate
                : abandonmentRate // ignore: cast_nullable_to_non_nullable
                    as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ResponderReputationImpl implements _ResponderReputation {
  const _$ResponderReputationImpl({
    required this.avgResponseTimeMinutes,
    required this.photoApprovalRate,
    required this.abandonmentRate,
  });

  factory _$ResponderReputationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResponderReputationImplFromJson(json);

  @override
  final int avgResponseTimeMinutes;
  @override
  final double photoApprovalRate;
  @override
  final double abandonmentRate;

  @override
  String toString() {
    return 'ResponderReputation(avgResponseTimeMinutes: $avgResponseTimeMinutes, photoApprovalRate: $photoApprovalRate, abandonmentRate: $abandonmentRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResponderReputationImpl &&
            (identical(other.avgResponseTimeMinutes, avgResponseTimeMinutes) ||
                other.avgResponseTimeMinutes == avgResponseTimeMinutes) &&
            (identical(other.photoApprovalRate, photoApprovalRate) ||
                other.photoApprovalRate == photoApprovalRate) &&
            (identical(other.abandonmentRate, abandonmentRate) ||
                other.abandonmentRate == abandonmentRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    avgResponseTimeMinutes,
    photoApprovalRate,
    abandonmentRate,
  );

  /// Create a copy of ResponderReputation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResponderReputationImplCopyWith<_$ResponderReputationImpl> get copyWith =>
      __$$ResponderReputationImplCopyWithImpl<_$ResponderReputationImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ResponderReputationImplToJson(this);
  }
}

abstract class _ResponderReputation implements ResponderReputation {
  const factory _ResponderReputation({
    required final int avgResponseTimeMinutes,
    required final double photoApprovalRate,
    required final double abandonmentRate,
  }) = _$ResponderReputationImpl;

  factory _ResponderReputation.fromJson(Map<String, dynamic> json) =
      _$ResponderReputationImpl.fromJson;

  @override
  int get avgResponseTimeMinutes;
  @override
  double get photoApprovalRate;
  @override
  double get abandonmentRate;

  /// Create a copy of ResponderReputation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResponderReputationImplCopyWith<_$ResponderReputationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Badge _$BadgeFromJson(Map<String, dynamic> json) {
  return _Badge.fromJson(json);
}

/// @nodoc
mixin _$Badge {
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  BadgeCategory get category => throw _privateConstructorUsedError;

  /// Serializes this Badge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BadgeCopyWith<Badge> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BadgeCopyWith<$Res> {
  factory $BadgeCopyWith(Badge value, $Res Function(Badge) then) =
      _$BadgeCopyWithImpl<$Res, Badge>;
  @useResult
  $Res call({
    String name,
    String description,
    String imageUrl,
    BadgeCategory category,
  });
}

/// @nodoc
class _$BadgeCopyWithImpl<$Res, $Val extends Badge>
    implements $BadgeCopyWith<$Res> {
  _$BadgeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? category = null,
  }) {
    return _then(
      _value.copyWith(
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            description:
                null == description
                    ? _value.description
                    : description // ignore: cast_nullable_to_non_nullable
                        as String,
            imageUrl:
                null == imageUrl
                    ? _value.imageUrl
                    : imageUrl // ignore: cast_nullable_to_non_nullable
                        as String,
            category:
                null == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as BadgeCategory,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BadgeImplCopyWith<$Res> implements $BadgeCopyWith<$Res> {
  factory _$$BadgeImplCopyWith(
    _$BadgeImpl value,
    $Res Function(_$BadgeImpl) then,
  ) = __$$BadgeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    String description,
    String imageUrl,
    BadgeCategory category,
  });
}

/// @nodoc
class __$$BadgeImplCopyWithImpl<$Res>
    extends _$BadgeCopyWithImpl<$Res, _$BadgeImpl>
    implements _$$BadgeImplCopyWith<$Res> {
  __$$BadgeImplCopyWithImpl(
    _$BadgeImpl _value,
    $Res Function(_$BadgeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? category = null,
  }) {
    return _then(
      _$BadgeImpl(
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        description:
            null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                    as String,
        imageUrl:
            null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                    as String,
        category:
            null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as BadgeCategory,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BadgeImpl implements _Badge {
  const _$BadgeImpl({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
  });

  factory _$BadgeImpl.fromJson(Map<String, dynamic> json) =>
      _$$BadgeImplFromJson(json);

  @override
  final String name;
  @override
  final String description;
  @override
  final String imageUrl;
  @override
  final BadgeCategory category;

  @override
  String toString() {
    return 'Badge(name: $name, description: $description, imageUrl: $imageUrl, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, description, imageUrl, category);

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeImplCopyWith<_$BadgeImpl> get copyWith =>
      __$$BadgeImplCopyWithImpl<_$BadgeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BadgeImplToJson(this);
  }
}

abstract class _Badge implements Badge {
  const factory _Badge({
    required final String name,
    required final String description,
    required final String imageUrl,
    required final BadgeCategory category,
  }) = _$BadgeImpl;

  factory _Badge.fromJson(Map<String, dynamic> json) = _$BadgeImpl.fromJson;

  @override
  String get name;
  @override
  String get description;
  @override
  String get imageUrl;
  @override
  BadgeCategory get category;

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BadgeImplCopyWith<_$BadgeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Tag _$TagFromJson(Map<String, dynamic> json) {
  return _Tag.fromJson(json);
}

/// @nodoc
mixin _$Tag {
  String get name => throw _privateConstructorUsedError; // e.g., "#자리찾기"
  int get count => throw _privateConstructorUsedError;

  /// Serializes this Tag to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TagCopyWith<Tag> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TagCopyWith<$Res> {
  factory $TagCopyWith(Tag value, $Res Function(Tag) then) =
      _$TagCopyWithImpl<$Res, Tag>;
  @useResult
  $Res call({String name, int count});
}

/// @nodoc
class _$TagCopyWithImpl<$Res, $Val extends Tag> implements $TagCopyWith<$Res> {
  _$TagCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? count = null}) {
    return _then(
      _value.copyWith(
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            count:
                null == count
                    ? _value.count
                    : count // ignore: cast_nullable_to_non_nullable
                        as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TagImplCopyWith<$Res> implements $TagCopyWith<$Res> {
  factory _$$TagImplCopyWith(_$TagImpl value, $Res Function(_$TagImpl) then) =
      __$$TagImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, int count});
}

/// @nodoc
class __$$TagImplCopyWithImpl<$Res> extends _$TagCopyWithImpl<$Res, _$TagImpl>
    implements _$$TagImplCopyWith<$Res> {
  __$$TagImplCopyWithImpl(_$TagImpl _value, $Res Function(_$TagImpl) _then)
    : super(_value, _then);

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? count = null}) {
    return _then(
      _$TagImpl(
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        count:
            null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                    as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TagImpl implements _Tag {
  const _$TagImpl({required this.name, required this.count});

  factory _$TagImpl.fromJson(Map<String, dynamic> json) =>
      _$$TagImplFromJson(json);

  @override
  final String name;
  // e.g., "#자리찾기"
  @override
  final int count;

  @override
  String toString() {
    return 'Tag(name: $name, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TagImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.count, count) || other.count == count));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, count);

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TagImplCopyWith<_$TagImpl> get copyWith =>
      __$$TagImplCopyWithImpl<_$TagImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TagImplToJson(this);
  }
}

abstract class _Tag implements Tag {
  const factory _Tag({required final String name, required final int count}) =
      _$TagImpl;

  factory _Tag.fromJson(Map<String, dynamic> json) = _$TagImpl.fromJson;

  @override
  String get name; // e.g., "#자리찾기"
  @override
  int get count;

  /// Create a copy of Tag
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TagImplCopyWith<_$TagImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
