// lib/features/ddip_event/data/models/interaction_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';

part 'interaction_model.freezed.dart';
part 'interaction_model.g.dart';

@freezed
class InteractionModel with _$InteractionModel {
  const factory InteractionModel({
    required String id,
    @JsonKey(name: 'actor_id') required String actorId,
    @JsonKey(name: 'actor_role') required String actorRole, // Enum을 String으로 통신
    @JsonKey(name: 'action_type')
    required String actionType, // Enum을 String으로 통신
    @JsonKey(name: 'message_code')
    String? messageCode, // Nullable Enum을 String으로 통신
    @JsonKey(name: 'related_photo_id') String? relatedPhotoId, // Nullable
    required DateTime timestamp,
  }) = _InteractionModel;

  const InteractionModel._(); // toEntity() 메서드를 추가하기 위한 private 생성자

  factory InteractionModel.fromJson(Map<String, dynamic> json) =>
      _$InteractionModelFromJson(json);

  /// 모델을 엔티티로 변환하는 메서드
  Interaction toEntity() {
    return Interaction(
      id: id,
      actorId: actorId,
      actorRole: ActorRole.values.firstWhere(
        (e) => e.toString() == 'ActorRole.$actorRole',
        orElse: () => ActorRole.system, // 기본값 (혹은 에러 처리)
      ),
      action: ActionType.values.firstWhere(
        (e) => e.toString() == 'ActionType.$actionType',
        orElse: () => ActionType.reportIssue, // 기본값 (혹은 에러 처리)
      ),
      messageCode:
          messageCode == null
              ? null
              : MessageCode.values.firstWhere(
                (e) => e.toString() == 'MessageCode.$messageCode',
                orElse: () => MessageCode.thanksALot, // 기본값 (혹은 에러 처리)
              ),
      relatedPhotoId: relatedPhotoId,
      timestamp: timestamp,
    );
  }
}
