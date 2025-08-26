// lib/features/profile/domain/entities/profile.dart

import 'package:freezed_annotation/freezed_annotation.dart';
// Evaluation 엔티티의 PraiseTag를 가져옵니다.
import 'package:ddip/features/evaluation/domain/entities/evaluation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    // --- 기본 정보 (유지) ---
    required String userId,
    required String nickname,
    required String profileImageUrl,
    required String oneLineIntro,
    required String? certifiedSchoolName,

    // --- 평판 요약 (유지) ---
    required double? responderAverageRating,
    required double? requesterAverageRating,

    // --- 핵심 활동 지표 (유지) ---
    required int totalRequestCount,
    required int totalExecutionCount,

    // --- [핵심 변경] 칭찬 태그 개수 ---
    // 사용자가 요청자로서 받은 칭찬 태그와 개수
    required Map<PraiseTag, int> requesterPraiseTags,
    // 사용자가 수행자로서 받은 칭찬 태그와 개수
    required Map<PraiseTag, int> responderPraiseTags,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}

// Tag 클래스는 이제 사용하지 않으므로 삭제합니다.
