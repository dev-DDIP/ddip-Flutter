import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';

/// 사용자의 프로필 정보를 담는 최상위 불변 객체입니다.
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String userId,
    required String nickname,
    required String profileImageUrl,
    required int level, // 레벨
    required String title, // 대표 칭호 (e.g., "북문 지박령")
    required UserProfileStats stats, // 상세 스탯
    required List<Badge> badges, // 획득한 뱃지 목록
    required List<ActivityArea> activityAreas, // 주요 활동 구역
  }) = _UserProfile;
}

/// 요청자와 수행자 역할별 통계를 종합적으로 담는 객체입니다.
@freezed
class UserProfileStats with _$UserProfileStats {
  const factory UserProfileStats({
    required RoleStats requesterStats,
    required RoleStats responderStats,
  }) = _UserProfileStats;
}

/// 역할별(요청자/수행자) 상세 통계를 정의하는 객체입니다.
/// 재사용성을 위해 별도 클래스로 분리했습니다.
@freezed
class RoleStats with _$RoleStats {
  const factory RoleStats({
    required int totalCount, // 요청 횟수 또는 수행 시도 횟수
    required int successCount,
    required int failCount,
    required double averageRating, // 받은 또는 준 평점 평균
    required List<String> recentFeedbacks, // 최근 받은 또는 준 피드백 코멘트
  }) = _RoleStats;
}

/// 사용자가 획득한 뱃지(도전과제) 정보를 담는 객체입니다.
@freezed
class Badge with _$Badge {
  const factory Badge({
    required String badgeId,
    required String name,
    required String description,
    required String imageUrl,
    required DateTime achievedAt,
  }) = _Badge;
}

/// 사용자의 주요 활동 구역 정보를 담는 객체입니다.
@freezed
class ActivityArea with _$ActivityArea {
  const factory ActivityArea({required String areaName, required int count}) =
      _ActivityArea;
}
