// lib/features/evaluation/domain/entities/evaluation.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'evaluation.freezed.dart';

// 어떤 칭찬 태그가 있는지 정의하는 Enum
enum PraiseTag {
  // 수행자 대상 태그
  photoClarity, // 사진이 선명해요
  goodComprehension, // 요청을 정확히 이해했어요
  kindAndPolite, // 친절하고 매너가 좋아요
  sensibleExtraInfo, // 센스있는 추가 정보
  // 요청자 대상 태그
  clearRequest, // 요청사항이 명확했어요
  fastFeedback, // 빠른 확인과 피드백
  politeAndKind, // 매너있고 친절해요 (위와 통합 가능)
  reasonableRequest, // 합리적인 요구사항
}

@freezed
class Evaluation with _$Evaluation {
  const factory Evaluation({
    required String missionId,
    required String evaluatorId, // 평가를 하는 사람
    required String evaluateeId, // 평가를 받는 사람
    required int rating, // 종합 별점 (1~5)
    required List<PraiseTag> tags, // 선택된 칭찬 태그 목록
    String? comment, // 한줄평
  }) = _Evaluation;
}
