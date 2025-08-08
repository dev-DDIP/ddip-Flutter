// ▼▼▼ lib/features/profile/domain/entities/profile.dart ▼▼▼
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
// freezed로 생성될 파일을 명시합니다.
part 'profile.g.dart';

// MARK: - Enums
enum BadgeCategory { activity, professionalism, special }

// MARK: - Main Profile Entity
@freezed
class Profile with _$Profile {
  const factory Profile({
    required String userId,
    required String nickname,
    required String profileImageUrl,
    required String oneLineIntro,
    required int totalRequestCount,
    required int totalExecutionCount,
    required int ddipPoints,
    required CertificationMark? certificationMark,
    required RequesterReputation requesterReputation,
    required ResponderReputation responderReputation,
    required List<Badge> badges,
    required List<Tag> tags,
    // Key: 시간(e.g., "09", "18"), Value: 활동 횟수
    required Map<String, int> activityHours,
  }) = _Profile;

  // fromJson 팩토리 생성자 추가
  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

// MARK: - Sub-Entities
@freezed
class CertificationMark with _$CertificationMark {
  const factory CertificationMark({
    required String title, // e.g., "상위 10% 활발 수행자"
    required String semester, // e.g., "25-2학기"
  }) = _CertificationMark;

  // fromJson 팩토리 생성자 추가
  factory CertificationMark.fromJson(Map<String, dynamic> json) =>
      _$CertificationMarkFromJson(json);
}

@freezed
class RequesterReputation with _$RequesterReputation {
  const factory RequesterReputation({
    required double photoApprovalRate,
    required int avgSelectionTimeMinutes,
    required double responderSatisfaction,
  }) = _RequesterReputation;

  // fromJson 팩토리 생성자 추가
  factory RequesterReputation.fromJson(Map<String, dynamic> json) =>
      _$RequesterReputationFromJson(json);
}

@freezed
class ResponderReputation with _$ResponderReputation {
  const factory ResponderReputation({
    required int avgResponseTimeMinutes,
    required double photoApprovalRate,
    required double abandonmentRate,
  }) = _ResponderReputation;

  // fromJson 팩토리 생성자 추가
  factory ResponderReputation.fromJson(Map<String, dynamic> json) =>
      _$ResponderReputationFromJson(json);
}

@freezed
class Badge with _$Badge {
  const factory Badge({
    required String name,
    required String description,
    required String imageUrl,
    required BadgeCategory category,
  }) = _Badge;

  // fromJson 팩토리 생성자 추가
  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
}

@freezed
class Tag with _$Tag {
  const factory Tag({
    required String name, // e.g., "#자리찾기"
    required int count,
  }) = _Tag;

  // fromJson 팩토리 생성자 추가
  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}

// ▲▲▲ lib/features/profile/domain/entities/profile.dart ▲▲▲
