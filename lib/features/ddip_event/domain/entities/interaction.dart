// lib/features/ddip_event/domain/entities/interaction.dart

/// 행위자의 역할을 정의하는 Enum
enum ActorRole { requester, responder, system }

/// 수행된 행동의 종류를 정의하는 Enum
enum ActionType {
  create,
  selectResponder,
  approve,
  requestRevision,
  cancelByRequester,
  apply,
  submitPhoto,
  reportSituation,
  giveUpByResponder,
  expire,
  rewardPaid,
  reportIssue,
  askQuestion, // 요청자의 질문 행위
  answerQuestion, // 수행자의 답변 행위
}

/// '띱' 이벤트와 관련된 모든 행위를 기록하는 핵심 엔티티
class Interaction {
  final String id;
  final String actorId;
  final ActorRole actorRole;
  final ActionType actionType;
  final String? comment;
  final String? relatedPhotoId; // Nullable (사진과 관련될 경우)
  final DateTime timestamp;

  Interaction({
    required this.id,
    required this.actorId,
    required this.actorRole,
    required this.actionType,
    this.comment,
    this.relatedPhotoId,
    required this.timestamp,
  });

  // copyWith 메서드는 선택 사항이지만, 불변 객체 사용 시 매우 유용합니다.
  Interaction copyWith({
    String? id,
    String? actorId,
    ActorRole? actorRole,
    ActionType? action,
    String? comment,
    String? relatedPhotoId,
    DateTime? timestamp,
  }) {
    return Interaction(
      id: id ?? this.id,
      actorId: actorId ?? this.actorId,
      actorRole: actorRole ?? this.actorRole,
      actionType: action ?? this.actionType,
      comment: comment ?? this.comment,
      relatedPhotoId: relatedPhotoId ?? this.relatedPhotoId,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
