// lib/features/ddip_event/domain/entities/interaction.dart

import 'package:ddip/features/ddip_event/domain/entities/photo_feedback.dart'; // PhotoFeedback 엔티티 import

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
}

/// 특정 ActionType에 따라 사용될 매크로 메시지 코드를 정의하는 Enum
enum MessageCode {
  // APPROVE
  thanksALot,
  greatSense,
  // REQUEST_REVISION
  blurred,
  tooFar,
  wrongSubject,
  // REPORT_SITUATION
  goneAlready,
  soldOut,
  placeClosed,
  accessDenied,
  tooCrowdedToShoot,
  longQueue,
  // GIVE_UP_BY_RESPONDER
  personalReason,
  tooLongDistance,
  requestUnclear,
}

/// '띱' 이벤트와 관련된 모든 행위를 기록하는 핵심 엔티티
class Interaction {
  final String id;
  final String actorId;
  final ActorRole actorRole;
  final ActionType action;
  final MessageCode? messageCode; // Nullable
  final String? relatedPhotoId; // Nullable (사진과 관련될 경우)
  final DateTime timestamp;

  Interaction({
    required this.id,
    required this.actorId,
    required this.actorRole,
    required this.action,
    this.messageCode,
    this.relatedPhotoId,
    required this.timestamp,
  });

  // copyWith 메서드는 선택 사항이지만, 불변 객체 사용 시 매우 유용합니다.
  Interaction copyWith({
    String? id,
    String? actorId,
    ActorRole? actorRole,
    ActionType? action,
    MessageCode? messageCode,
    String? relatedPhotoId,
    DateTime? timestamp,
  }) {
    return Interaction(
      id: id ?? this.id,
      actorId: actorId ?? this.actorId,
      actorRole: actorRole ?? this.actorRole,
      action: action ?? this.action,
      messageCode: messageCode ?? this.messageCode,
      relatedPhotoId: relatedPhotoId ?? this.relatedPhotoId,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
