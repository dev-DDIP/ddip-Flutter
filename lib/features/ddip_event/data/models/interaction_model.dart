// lib/features/ddip_event/data/models/interaction_model.dart

import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'interaction_model.freezed.dart';
part 'interaction_model.g.dart';

@freezed
class InteractionModel with _$InteractionModel {
  const factory InteractionModel({
    @JsonKey(name: 'interactionId') required String id,
    @JsonKey(name: 'actorId') required String actorId,
    required String actorRole,
    @JsonKey(name: 'actionType') required String actionType,
    String? messageCode,
    String? relatedPhotoId,
    required DateTime timestamp,
  }) = _InteractionModel;

  const InteractionModel._();

  factory InteractionModel.fromJson(Map<String, dynamic> json) =>
      _$InteractionModelFromJson(json);

  Interaction toEntity() {
    return Interaction(
      id: id,
      actorId: actorId,
      actorRole: ActorRole.values.firstWhere(
        (e) => e.name == actorRole.toLowerCase(),
        orElse: () => ActorRole.system,
      ),
      actionType: ActionType.values.firstWhere(
        (e) => e.name == actionType.toLowerCase(),
        orElse: () => ActionType.reportIssue,
      ),
      messageCode:
          messageCode != null
              ? MessageCode.values.firstWhere(
                (e) => e.name == messageCode!.toLowerCase(),
                orElse: () => MessageCode.thanksALot,
              )
              : null,
      relatedPhotoId: relatedPhotoId,
      timestamp: timestamp,
    );
  }
}
