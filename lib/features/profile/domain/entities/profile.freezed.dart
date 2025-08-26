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
  // --- 기본 정보 (유지) ---
  String get userId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String get profileImageUrl => throw _privateConstructorUsedError;
  String get oneLineIntro => throw _privateConstructorUsedError;
  String? get certifiedSchoolName =>
      throw _privateConstructorUsedError; // --- 평판 요약 (유지) ---
  double? get responderAverageRating => throw _privateConstructorUsedError;
  double? get requesterAverageRating =>
      throw _privateConstructorUsedError; // --- 핵심 활동 지표 (유지) ---
  int get totalRequestCount => throw _privateConstructorUsedError;
  int get totalExecutionCount =>
      throw _privateConstructorUsedError; // --- [핵심 변경] 칭찬 태그 개수 ---
  // 사용자가 요청자로서 받은 칭찬 태그와 개수
  Map<PraiseTag, int> get requesterPraiseTags =>
      throw _privateConstructorUsedError; // 사용자가 수행자로서 받은 칭찬 태그와 개수
  Map<PraiseTag, int> get responderPraiseTags =>
      throw _privateConstructorUsedError;

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
    String? certifiedSchoolName,
    double? responderAverageRating,
    double? requesterAverageRating,
    int totalRequestCount,
    int totalExecutionCount,
    Map<PraiseTag, int> requesterPraiseTags,
    Map<PraiseTag, int> responderPraiseTags,
  });
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
    Object? certifiedSchoolName = freezed,
    Object? responderAverageRating = freezed,
    Object? requesterAverageRating = freezed,
    Object? totalRequestCount = null,
    Object? totalExecutionCount = null,
    Object? requesterPraiseTags = null,
    Object? responderPraiseTags = null,
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
            certifiedSchoolName:
                freezed == certifiedSchoolName
                    ? _value.certifiedSchoolName
                    : certifiedSchoolName // ignore: cast_nullable_to_non_nullable
                        as String?,
            responderAverageRating:
                freezed == responderAverageRating
                    ? _value.responderAverageRating
                    : responderAverageRating // ignore: cast_nullable_to_non_nullable
                        as double?,
            requesterAverageRating:
                freezed == requesterAverageRating
                    ? _value.requesterAverageRating
                    : requesterAverageRating // ignore: cast_nullable_to_non_nullable
                        as double?,
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
            requesterPraiseTags:
                null == requesterPraiseTags
                    ? _value.requesterPraiseTags
                    : requesterPraiseTags // ignore: cast_nullable_to_non_nullable
                        as Map<PraiseTag, int>,
            responderPraiseTags:
                null == responderPraiseTags
                    ? _value.responderPraiseTags
                    : responderPraiseTags // ignore: cast_nullable_to_non_nullable
                        as Map<PraiseTag, int>,
          )
          as $Val,
    );
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
    String? certifiedSchoolName,
    double? responderAverageRating,
    double? requesterAverageRating,
    int totalRequestCount,
    int totalExecutionCount,
    Map<PraiseTag, int> requesterPraiseTags,
    Map<PraiseTag, int> responderPraiseTags,
  });
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
    Object? certifiedSchoolName = freezed,
    Object? responderAverageRating = freezed,
    Object? requesterAverageRating = freezed,
    Object? totalRequestCount = null,
    Object? totalExecutionCount = null,
    Object? requesterPraiseTags = null,
    Object? responderPraiseTags = null,
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
        certifiedSchoolName:
            freezed == certifiedSchoolName
                ? _value.certifiedSchoolName
                : certifiedSchoolName // ignore: cast_nullable_to_non_nullable
                    as String?,
        responderAverageRating:
            freezed == responderAverageRating
                ? _value.responderAverageRating
                : responderAverageRating // ignore: cast_nullable_to_non_nullable
                    as double?,
        requesterAverageRating:
            freezed == requesterAverageRating
                ? _value.requesterAverageRating
                : requesterAverageRating // ignore: cast_nullable_to_non_nullable
                    as double?,
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
        requesterPraiseTags:
            null == requesterPraiseTags
                ? _value._requesterPraiseTags
                : requesterPraiseTags // ignore: cast_nullable_to_non_nullable
                    as Map<PraiseTag, int>,
        responderPraiseTags:
            null == responderPraiseTags
                ? _value._responderPraiseTags
                : responderPraiseTags // ignore: cast_nullable_to_non_nullable
                    as Map<PraiseTag, int>,
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
    required this.certifiedSchoolName,
    required this.responderAverageRating,
    required this.requesterAverageRating,
    required this.totalRequestCount,
    required this.totalExecutionCount,
    required final Map<PraiseTag, int> requesterPraiseTags,
    required final Map<PraiseTag, int> responderPraiseTags,
  }) : _requesterPraiseTags = requesterPraiseTags,
       _responderPraiseTags = responderPraiseTags;

  factory _$ProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileImplFromJson(json);

  // --- 기본 정보 (유지) ---
  @override
  final String userId;
  @override
  final String nickname;
  @override
  final String profileImageUrl;
  @override
  final String oneLineIntro;
  @override
  final String? certifiedSchoolName;
  // --- 평판 요약 (유지) ---
  @override
  final double? responderAverageRating;
  @override
  final double? requesterAverageRating;
  // --- 핵심 활동 지표 (유지) ---
  @override
  final int totalRequestCount;
  @override
  final int totalExecutionCount;
  // --- [핵심 변경] 칭찬 태그 개수 ---
  // 사용자가 요청자로서 받은 칭찬 태그와 개수
  final Map<PraiseTag, int> _requesterPraiseTags;
  // --- [핵심 변경] 칭찬 태그 개수 ---
  // 사용자가 요청자로서 받은 칭찬 태그와 개수
  @override
  Map<PraiseTag, int> get requesterPraiseTags {
    if (_requesterPraiseTags is EqualUnmodifiableMapView)
      return _requesterPraiseTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_requesterPraiseTags);
  }

  // 사용자가 수행자로서 받은 칭찬 태그와 개수
  final Map<PraiseTag, int> _responderPraiseTags;
  // 사용자가 수행자로서 받은 칭찬 태그와 개수
  @override
  Map<PraiseTag, int> get responderPraiseTags {
    if (_responderPraiseTags is EqualUnmodifiableMapView)
      return _responderPraiseTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_responderPraiseTags);
  }

  @override
  String toString() {
    return 'Profile(userId: $userId, nickname: $nickname, profileImageUrl: $profileImageUrl, oneLineIntro: $oneLineIntro, certifiedSchoolName: $certifiedSchoolName, responderAverageRating: $responderAverageRating, requesterAverageRating: $requesterAverageRating, totalRequestCount: $totalRequestCount, totalExecutionCount: $totalExecutionCount, requesterPraiseTags: $requesterPraiseTags, responderPraiseTags: $responderPraiseTags)';
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
            (identical(other.certifiedSchoolName, certifiedSchoolName) ||
                other.certifiedSchoolName == certifiedSchoolName) &&
            (identical(other.responderAverageRating, responderAverageRating) ||
                other.responderAverageRating == responderAverageRating) &&
            (identical(other.requesterAverageRating, requesterAverageRating) ||
                other.requesterAverageRating == requesterAverageRating) &&
            (identical(other.totalRequestCount, totalRequestCount) ||
                other.totalRequestCount == totalRequestCount) &&
            (identical(other.totalExecutionCount, totalExecutionCount) ||
                other.totalExecutionCount == totalExecutionCount) &&
            const DeepCollectionEquality().equals(
              other._requesterPraiseTags,
              _requesterPraiseTags,
            ) &&
            const DeepCollectionEquality().equals(
              other._responderPraiseTags,
              _responderPraiseTags,
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
    certifiedSchoolName,
    responderAverageRating,
    requesterAverageRating,
    totalRequestCount,
    totalExecutionCount,
    const DeepCollectionEquality().hash(_requesterPraiseTags),
    const DeepCollectionEquality().hash(_responderPraiseTags),
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
    required final String? certifiedSchoolName,
    required final double? responderAverageRating,
    required final double? requesterAverageRating,
    required final int totalRequestCount,
    required final int totalExecutionCount,
    required final Map<PraiseTag, int> requesterPraiseTags,
    required final Map<PraiseTag, int> responderPraiseTags,
  }) = _$ProfileImpl;

  factory _Profile.fromJson(Map<String, dynamic> json) = _$ProfileImpl.fromJson;

  // --- 기본 정보 (유지) ---
  @override
  String get userId;
  @override
  String get nickname;
  @override
  String get profileImageUrl;
  @override
  String get oneLineIntro;
  @override
  String? get certifiedSchoolName; // --- 평판 요약 (유지) ---
  @override
  double? get responderAverageRating;
  @override
  double? get requesterAverageRating; // --- 핵심 활동 지표 (유지) ---
  @override
  int get totalRequestCount;
  @override
  int get totalExecutionCount; // --- [핵심 변경] 칭찬 태그 개수 ---
  // 사용자가 요청자로서 받은 칭찬 태그와 개수
  @override
  Map<PraiseTag, int> get requesterPraiseTags; // 사용자가 수행자로서 받은 칭찬 태그와 개수
  @override
  Map<PraiseTag, int> get responderPraiseTags;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
