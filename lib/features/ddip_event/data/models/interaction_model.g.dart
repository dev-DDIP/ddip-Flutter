// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InteractionModelImpl _$$InteractionModelImplFromJson(
  Map<String, dynamic> json,
) => _$InteractionModelImpl(
  id: json['interactionId'] as String,
  actorId: json['actorId'] as String,
  actorRole: json['actorRole'] as String,
  actionType: json['actionType'] as String,
  comment: json['comment'] as String?,
  relatedPhotoId: json['relatedPhotoId'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$InteractionModelImplToJson(
  _$InteractionModelImpl instance,
) => <String, dynamic>{
  'interactionId': instance.id,
  'actorId': instance.actorId,
  'actorRole': instance.actorRole,
  'actionType': instance.actionType,
  'comment': instance.comment,
  'relatedPhotoId': instance.relatedPhotoId,
  'timestamp': instance.timestamp.toIso8601String(),
};
