// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InteractionModelImpl _$$InteractionModelImplFromJson(
  Map<String, dynamic> json,
) => _$InteractionModelImpl(
  id: json['id'] as String,
  actorId: json['actor_id'] as String,
  actorRole: json['actor_role'] as String,
  actionType: json['action_type'] as String,
  messageCode: json['message_code'] as String?,
  relatedPhotoId: json['related_photo_id'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$InteractionModelImplToJson(
  _$InteractionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'actor_id': instance.actorId,
  'actor_role': instance.actorRole,
  'action_type': instance.actionType,
  'message_code': instance.messageCode,
  'related_photo_id': instance.relatedPhotoId,
  'timestamp': instance.timestamp.toIso8601String(),
};
