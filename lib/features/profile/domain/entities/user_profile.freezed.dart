// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$UserProfile {
  String get userId => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  String get profileImageUrl => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError; // 레벨
  String get title =>
      throw _privateConstructorUsedError; // 대표 칭호 (e.g., "북문 지박령")
  UserProfileStats get stats => throw _privateConstructorUsedError; // 상세 스탯
  List<Badge> get badges => throw _privateConstructorUsedError; // 획득한 뱃지 목록
  List<ActivityArea> get activityAreas => throw _privateConstructorUsedError;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
    UserProfile value,
    $Res Function(UserProfile) then,
  ) = _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call({
    String userId,
    String nickname,
    String profileImageUrl,
    int level,
    String title,
    UserProfileStats stats,
    List<Badge> badges,
    List<ActivityArea> activityAreas,
  });

  $UserProfileStatsCopyWith<$Res> get stats;
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? profileImageUrl = null,
    Object? level = null,
    Object? title = null,
    Object? stats = null,
    Object? badges = null,
    Object? activityAreas = null,
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
            level:
                null == level
                    ? _value.level
                    : level // ignore: cast_nullable_to_non_nullable
                        as int,
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            stats:
                null == stats
                    ? _value.stats
                    : stats // ignore: cast_nullable_to_non_nullable
                        as UserProfileStats,
            badges:
                null == badges
                    ? _value.badges
                    : badges // ignore: cast_nullable_to_non_nullable
                        as List<Badge>,
            activityAreas:
                null == activityAreas
                    ? _value.activityAreas
                    : activityAreas // ignore: cast_nullable_to_non_nullable
                        as List<ActivityArea>,
          )
          as $Val,
    );
  }

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserProfileStatsCopyWith<$Res> get stats {
    return $UserProfileStatsCopyWith<$Res>(_value.stats, (value) {
      return _then(_value.copyWith(stats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
    _$UserProfileImpl value,
    $Res Function(_$UserProfileImpl) then,
  ) = __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String nickname,
    String profileImageUrl,
    int level,
    String title,
    UserProfileStats stats,
    List<Badge> badges,
    List<ActivityArea> activityAreas,
  });

  @override
  $UserProfileStatsCopyWith<$Res> get stats;
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
    _$UserProfileImpl _value,
    $Res Function(_$UserProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? nickname = null,
    Object? profileImageUrl = null,
    Object? level = null,
    Object? title = null,
    Object? stats = null,
    Object? badges = null,
    Object? activityAreas = null,
  }) {
    return _then(
      _$UserProfileImpl(
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
        level:
            null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                    as int,
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        stats:
            null == stats
                ? _value.stats
                : stats // ignore: cast_nullable_to_non_nullable
                    as UserProfileStats,
        badges:
            null == badges
                ? _value._badges
                : badges // ignore: cast_nullable_to_non_nullable
                    as List<Badge>,
        activityAreas:
            null == activityAreas
                ? _value._activityAreas
                : activityAreas // ignore: cast_nullable_to_non_nullable
                    as List<ActivityArea>,
      ),
    );
  }
}

/// @nodoc

class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl({
    required this.userId,
    required this.nickname,
    required this.profileImageUrl,
    required this.level,
    required this.title,
    required this.stats,
    required final List<Badge> badges,
    required final List<ActivityArea> activityAreas,
  }) : _badges = badges,
       _activityAreas = activityAreas;

  @override
  final String userId;
  @override
  final String nickname;
  @override
  final String profileImageUrl;
  @override
  final int level;
  // 레벨
  @override
  final String title;
  // 대표 칭호 (e.g., "북문 지박령")
  @override
  final UserProfileStats stats;
  // 상세 스탯
  final List<Badge> _badges;
  // 상세 스탯
  @override
  List<Badge> get badges {
    if (_badges is EqualUnmodifiableListView) return _badges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_badges);
  }

  // 획득한 뱃지 목록
  final List<ActivityArea> _activityAreas;
  // 획득한 뱃지 목록
  @override
  List<ActivityArea> get activityAreas {
    if (_activityAreas is EqualUnmodifiableListView) return _activityAreas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_activityAreas);
  }

  @override
  String toString() {
    return 'UserProfile(userId: $userId, nickname: $nickname, profileImageUrl: $profileImageUrl, level: $level, title: $title, stats: $stats, badges: $badges, activityAreas: $activityAreas)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.stats, stats) || other.stats == stats) &&
            const DeepCollectionEquality().equals(other._badges, _badges) &&
            const DeepCollectionEquality().equals(
              other._activityAreas,
              _activityAreas,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    nickname,
    profileImageUrl,
    level,
    title,
    stats,
    const DeepCollectionEquality().hash(_badges),
    const DeepCollectionEquality().hash(_activityAreas),
  );

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile({
    required final String userId,
    required final String nickname,
    required final String profileImageUrl,
    required final int level,
    required final String title,
    required final UserProfileStats stats,
    required final List<Badge> badges,
    required final List<ActivityArea> activityAreas,
  }) = _$UserProfileImpl;

  @override
  String get userId;
  @override
  String get nickname;
  @override
  String get profileImageUrl;
  @override
  int get level; // 레벨
  @override
  String get title; // 대표 칭호 (e.g., "북문 지박령")
  @override
  UserProfileStats get stats; // 상세 스탯
  @override
  List<Badge> get badges; // 획득한 뱃지 목록
  @override
  List<ActivityArea> get activityAreas;

  /// Create a copy of UserProfile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UserProfileStats {
  RoleStats get requesterStats => throw _privateConstructorUsedError;
  RoleStats get responderStats => throw _privateConstructorUsedError;

  /// Create a copy of UserProfileStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileStatsCopyWith<UserProfileStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileStatsCopyWith<$Res> {
  factory $UserProfileStatsCopyWith(
    UserProfileStats value,
    $Res Function(UserProfileStats) then,
  ) = _$UserProfileStatsCopyWithImpl<$Res, UserProfileStats>;
  @useResult
  $Res call({RoleStats requesterStats, RoleStats responderStats});

  $RoleStatsCopyWith<$Res> get requesterStats;
  $RoleStatsCopyWith<$Res> get responderStats;
}

/// @nodoc
class _$UserProfileStatsCopyWithImpl<$Res, $Val extends UserProfileStats>
    implements $UserProfileStatsCopyWith<$Res> {
  _$UserProfileStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfileStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? requesterStats = null, Object? responderStats = null}) {
    return _then(
      _value.copyWith(
            requesterStats:
                null == requesterStats
                    ? _value.requesterStats
                    : requesterStats // ignore: cast_nullable_to_non_nullable
                        as RoleStats,
            responderStats:
                null == responderStats
                    ? _value.responderStats
                    : responderStats // ignore: cast_nullable_to_non_nullable
                        as RoleStats,
          )
          as $Val,
    );
  }

  /// Create a copy of UserProfileStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RoleStatsCopyWith<$Res> get requesterStats {
    return $RoleStatsCopyWith<$Res>(_value.requesterStats, (value) {
      return _then(_value.copyWith(requesterStats: value) as $Val);
    });
  }

  /// Create a copy of UserProfileStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RoleStatsCopyWith<$Res> get responderStats {
    return $RoleStatsCopyWith<$Res>(_value.responderStats, (value) {
      return _then(_value.copyWith(responderStats: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserProfileStatsImplCopyWith<$Res>
    implements $UserProfileStatsCopyWith<$Res> {
  factory _$$UserProfileStatsImplCopyWith(
    _$UserProfileStatsImpl value,
    $Res Function(_$UserProfileStatsImpl) then,
  ) = __$$UserProfileStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({RoleStats requesterStats, RoleStats responderStats});

  @override
  $RoleStatsCopyWith<$Res> get requesterStats;
  @override
  $RoleStatsCopyWith<$Res> get responderStats;
}

/// @nodoc
class __$$UserProfileStatsImplCopyWithImpl<$Res>
    extends _$UserProfileStatsCopyWithImpl<$Res, _$UserProfileStatsImpl>
    implements _$$UserProfileStatsImplCopyWith<$Res> {
  __$$UserProfileStatsImplCopyWithImpl(
    _$UserProfileStatsImpl _value,
    $Res Function(_$UserProfileStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfileStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? requesterStats = null, Object? responderStats = null}) {
    return _then(
      _$UserProfileStatsImpl(
        requesterStats:
            null == requesterStats
                ? _value.requesterStats
                : requesterStats // ignore: cast_nullable_to_non_nullable
                    as RoleStats,
        responderStats:
            null == responderStats
                ? _value.responderStats
                : responderStats // ignore: cast_nullable_to_non_nullable
                    as RoleStats,
      ),
    );
  }
}

/// @nodoc

class _$UserProfileStatsImpl implements _UserProfileStats {
  const _$UserProfileStatsImpl({
    required this.requesterStats,
    required this.responderStats,
  });

  @override
  final RoleStats requesterStats;
  @override
  final RoleStats responderStats;

  @override
  String toString() {
    return 'UserProfileStats(requesterStats: $requesterStats, responderStats: $responderStats)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileStatsImpl &&
            (identical(other.requesterStats, requesterStats) ||
                other.requesterStats == requesterStats) &&
            (identical(other.responderStats, responderStats) ||
                other.responderStats == responderStats));
  }

  @override
  int get hashCode => Object.hash(runtimeType, requesterStats, responderStats);

  /// Create a copy of UserProfileStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileStatsImplCopyWith<_$UserProfileStatsImpl> get copyWith =>
      __$$UserProfileStatsImplCopyWithImpl<_$UserProfileStatsImpl>(
        this,
        _$identity,
      );
}

abstract class _UserProfileStats implements UserProfileStats {
  const factory _UserProfileStats({
    required final RoleStats requesterStats,
    required final RoleStats responderStats,
  }) = _$UserProfileStatsImpl;

  @override
  RoleStats get requesterStats;
  @override
  RoleStats get responderStats;

  /// Create a copy of UserProfileStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileStatsImplCopyWith<_$UserProfileStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RoleStats {
  int get totalCount => throw _privateConstructorUsedError; // 요청 횟수 또는 수행 시도 횟수
  int get successCount => throw _privateConstructorUsedError;
  int get failCount => throw _privateConstructorUsedError;
  double get averageRating =>
      throw _privateConstructorUsedError; // 받은 또는 준 평점 평균
  List<String> get recentFeedbacks => throw _privateConstructorUsedError;

  /// Create a copy of RoleStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoleStatsCopyWith<RoleStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoleStatsCopyWith<$Res> {
  factory $RoleStatsCopyWith(RoleStats value, $Res Function(RoleStats) then) =
      _$RoleStatsCopyWithImpl<$Res, RoleStats>;
  @useResult
  $Res call({
    int totalCount,
    int successCount,
    int failCount,
    double averageRating,
    List<String> recentFeedbacks,
  });
}

/// @nodoc
class _$RoleStatsCopyWithImpl<$Res, $Val extends RoleStats>
    implements $RoleStatsCopyWith<$Res> {
  _$RoleStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoleStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCount = null,
    Object? successCount = null,
    Object? failCount = null,
    Object? averageRating = null,
    Object? recentFeedbacks = null,
  }) {
    return _then(
      _value.copyWith(
            totalCount:
                null == totalCount
                    ? _value.totalCount
                    : totalCount // ignore: cast_nullable_to_non_nullable
                        as int,
            successCount:
                null == successCount
                    ? _value.successCount
                    : successCount // ignore: cast_nullable_to_non_nullable
                        as int,
            failCount:
                null == failCount
                    ? _value.failCount
                    : failCount // ignore: cast_nullable_to_non_nullable
                        as int,
            averageRating:
                null == averageRating
                    ? _value.averageRating
                    : averageRating // ignore: cast_nullable_to_non_nullable
                        as double,
            recentFeedbacks:
                null == recentFeedbacks
                    ? _value.recentFeedbacks
                    : recentFeedbacks // ignore: cast_nullable_to_non_nullable
                        as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RoleStatsImplCopyWith<$Res>
    implements $RoleStatsCopyWith<$Res> {
  factory _$$RoleStatsImplCopyWith(
    _$RoleStatsImpl value,
    $Res Function(_$RoleStatsImpl) then,
  ) = __$$RoleStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int totalCount,
    int successCount,
    int failCount,
    double averageRating,
    List<String> recentFeedbacks,
  });
}

/// @nodoc
class __$$RoleStatsImplCopyWithImpl<$Res>
    extends _$RoleStatsCopyWithImpl<$Res, _$RoleStatsImpl>
    implements _$$RoleStatsImplCopyWith<$Res> {
  __$$RoleStatsImplCopyWithImpl(
    _$RoleStatsImpl _value,
    $Res Function(_$RoleStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RoleStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalCount = null,
    Object? successCount = null,
    Object? failCount = null,
    Object? averageRating = null,
    Object? recentFeedbacks = null,
  }) {
    return _then(
      _$RoleStatsImpl(
        totalCount:
            null == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                    as int,
        successCount:
            null == successCount
                ? _value.successCount
                : successCount // ignore: cast_nullable_to_non_nullable
                    as int,
        failCount:
            null == failCount
                ? _value.failCount
                : failCount // ignore: cast_nullable_to_non_nullable
                    as int,
        averageRating:
            null == averageRating
                ? _value.averageRating
                : averageRating // ignore: cast_nullable_to_non_nullable
                    as double,
        recentFeedbacks:
            null == recentFeedbacks
                ? _value._recentFeedbacks
                : recentFeedbacks // ignore: cast_nullable_to_non_nullable
                    as List<String>,
      ),
    );
  }
}

/// @nodoc

class _$RoleStatsImpl implements _RoleStats {
  const _$RoleStatsImpl({
    required this.totalCount,
    required this.successCount,
    required this.failCount,
    required this.averageRating,
    required final List<String> recentFeedbacks,
  }) : _recentFeedbacks = recentFeedbacks;

  @override
  final int totalCount;
  // 요청 횟수 또는 수행 시도 횟수
  @override
  final int successCount;
  @override
  final int failCount;
  @override
  final double averageRating;
  // 받은 또는 준 평점 평균
  final List<String> _recentFeedbacks;
  // 받은 또는 준 평점 평균
  @override
  List<String> get recentFeedbacks {
    if (_recentFeedbacks is EqualUnmodifiableListView) return _recentFeedbacks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentFeedbacks);
  }

  @override
  String toString() {
    return 'RoleStats(totalCount: $totalCount, successCount: $successCount, failCount: $failCount, averageRating: $averageRating, recentFeedbacks: $recentFeedbacks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoleStatsImpl &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount) &&
            (identical(other.successCount, successCount) ||
                other.successCount == successCount) &&
            (identical(other.failCount, failCount) ||
                other.failCount == failCount) &&
            (identical(other.averageRating, averageRating) ||
                other.averageRating == averageRating) &&
            const DeepCollectionEquality().equals(
              other._recentFeedbacks,
              _recentFeedbacks,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    totalCount,
    successCount,
    failCount,
    averageRating,
    const DeepCollectionEquality().hash(_recentFeedbacks),
  );

  /// Create a copy of RoleStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoleStatsImplCopyWith<_$RoleStatsImpl> get copyWith =>
      __$$RoleStatsImplCopyWithImpl<_$RoleStatsImpl>(this, _$identity);
}

abstract class _RoleStats implements RoleStats {
  const factory _RoleStats({
    required final int totalCount,
    required final int successCount,
    required final int failCount,
    required final double averageRating,
    required final List<String> recentFeedbacks,
  }) = _$RoleStatsImpl;

  @override
  int get totalCount; // 요청 횟수 또는 수행 시도 횟수
  @override
  int get successCount;
  @override
  int get failCount;
  @override
  double get averageRating; // 받은 또는 준 평점 평균
  @override
  List<String> get recentFeedbacks;

  /// Create a copy of RoleStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoleStatsImplCopyWith<_$RoleStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Badge {
  String get badgeId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  DateTime get achievedAt => throw _privateConstructorUsedError;

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
    String badgeId,
    String name,
    String description,
    String imageUrl,
    DateTime achievedAt,
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
    Object? badgeId = null,
    Object? name = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? achievedAt = null,
  }) {
    return _then(
      _value.copyWith(
            badgeId:
                null == badgeId
                    ? _value.badgeId
                    : badgeId // ignore: cast_nullable_to_non_nullable
                        as String,
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
            achievedAt:
                null == achievedAt
                    ? _value.achievedAt
                    : achievedAt // ignore: cast_nullable_to_non_nullable
                        as DateTime,
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
    String badgeId,
    String name,
    String description,
    String imageUrl,
    DateTime achievedAt,
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
    Object? badgeId = null,
    Object? name = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? achievedAt = null,
  }) {
    return _then(
      _$BadgeImpl(
        badgeId:
            null == badgeId
                ? _value.badgeId
                : badgeId // ignore: cast_nullable_to_non_nullable
                    as String,
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
        achievedAt:
            null == achievedAt
                ? _value.achievedAt
                : achievedAt // ignore: cast_nullable_to_non_nullable
                    as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$BadgeImpl implements _Badge {
  const _$BadgeImpl({
    required this.badgeId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.achievedAt,
  });

  @override
  final String badgeId;
  @override
  final String name;
  @override
  final String description;
  @override
  final String imageUrl;
  @override
  final DateTime achievedAt;

  @override
  String toString() {
    return 'Badge(badgeId: $badgeId, name: $name, description: $description, imageUrl: $imageUrl, achievedAt: $achievedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeImpl &&
            (identical(other.badgeId, badgeId) || other.badgeId == badgeId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.achievedAt, achievedAt) ||
                other.achievedAt == achievedAt));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    badgeId,
    name,
    description,
    imageUrl,
    achievedAt,
  );

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeImplCopyWith<_$BadgeImpl> get copyWith =>
      __$$BadgeImplCopyWithImpl<_$BadgeImpl>(this, _$identity);
}

abstract class _Badge implements Badge {
  const factory _Badge({
    required final String badgeId,
    required final String name,
    required final String description,
    required final String imageUrl,
    required final DateTime achievedAt,
  }) = _$BadgeImpl;

  @override
  String get badgeId;
  @override
  String get name;
  @override
  String get description;
  @override
  String get imageUrl;
  @override
  DateTime get achievedAt;

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BadgeImplCopyWith<_$BadgeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ActivityArea {
  String get areaName => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  /// Create a copy of ActivityArea
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ActivityAreaCopyWith<ActivityArea> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ActivityAreaCopyWith<$Res> {
  factory $ActivityAreaCopyWith(
    ActivityArea value,
    $Res Function(ActivityArea) then,
  ) = _$ActivityAreaCopyWithImpl<$Res, ActivityArea>;
  @useResult
  $Res call({String areaName, int count});
}

/// @nodoc
class _$ActivityAreaCopyWithImpl<$Res, $Val extends ActivityArea>
    implements $ActivityAreaCopyWith<$Res> {
  _$ActivityAreaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ActivityArea
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? areaName = null, Object? count = null}) {
    return _then(
      _value.copyWith(
            areaName:
                null == areaName
                    ? _value.areaName
                    : areaName // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ActivityAreaImplCopyWith<$Res>
    implements $ActivityAreaCopyWith<$Res> {
  factory _$$ActivityAreaImplCopyWith(
    _$ActivityAreaImpl value,
    $Res Function(_$ActivityAreaImpl) then,
  ) = __$$ActivityAreaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String areaName, int count});
}

/// @nodoc
class __$$ActivityAreaImplCopyWithImpl<$Res>
    extends _$ActivityAreaCopyWithImpl<$Res, _$ActivityAreaImpl>
    implements _$$ActivityAreaImplCopyWith<$Res> {
  __$$ActivityAreaImplCopyWithImpl(
    _$ActivityAreaImpl _value,
    $Res Function(_$ActivityAreaImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ActivityArea
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? areaName = null, Object? count = null}) {
    return _then(
      _$ActivityAreaImpl(
        areaName:
            null == areaName
                ? _value.areaName
                : areaName // ignore: cast_nullable_to_non_nullable
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

class _$ActivityAreaImpl implements _ActivityArea {
  const _$ActivityAreaImpl({required this.areaName, required this.count});

  @override
  final String areaName;
  @override
  final int count;

  @override
  String toString() {
    return 'ActivityArea(areaName: $areaName, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ActivityAreaImpl &&
            (identical(other.areaName, areaName) ||
                other.areaName == areaName) &&
            (identical(other.count, count) || other.count == count));
  }

  @override
  int get hashCode => Object.hash(runtimeType, areaName, count);

  /// Create a copy of ActivityArea
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ActivityAreaImplCopyWith<_$ActivityAreaImpl> get copyWith =>
      __$$ActivityAreaImplCopyWithImpl<_$ActivityAreaImpl>(this, _$identity);
}

abstract class _ActivityArea implements ActivityArea {
  const factory _ActivityArea({
    required final String areaName,
    required final int count,
  }) = _$ActivityAreaImpl;

  @override
  String get areaName;
  @override
  int get count;

  /// Create a copy of ActivityArea
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ActivityAreaImplCopyWith<_$ActivityAreaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
