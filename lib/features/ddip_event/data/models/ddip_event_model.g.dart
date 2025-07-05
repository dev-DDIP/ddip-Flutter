// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ddip_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DdipEventModelImpl _$$DdipEventModelImplFromJson(Map<String, dynamic> json) =>
    _$DdipEventModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      requesterId: json['requester_id'] as String,
      responderId: json['responder_id'] as String?,
      reward: (json['reward'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      responsePhotoUrl: json['response_photo_url'] as String?,
    );

Map<String, dynamic> _$$DdipEventModelImplToJson(
  _$DdipEventModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'content': instance.content,
  'requester_id': instance.requesterId,
  'responder_id': instance.responderId,
  'reward': instance.reward,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'status': instance.status,
  'created_at': instance.createdAt.toIso8601String(),
  'response_photo_url': instance.responsePhotoUrl,
};
