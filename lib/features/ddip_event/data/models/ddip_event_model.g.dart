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
      reward: (json['reward'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String,
      selectedResponderId: json['selected_responder_id'] as String?,
      applicants:
          (json['applicants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map(
                (e) => PhotoFeedbackModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      interactions:
          (json['interactions'] as List<dynamic>?)
              ?.map((e) => InteractionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$DdipEventModelImplToJson(
  _$DdipEventModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'content': instance.content,
  'requester_id': instance.requesterId,
  'reward': instance.reward,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'created_at': instance.createdAt.toIso8601String(),
  'status': instance.status,
  'selected_responder_id': instance.selectedResponderId,
  'applicants': instance.applicants,
  'photos': instance.photos,
  'interactions': instance.interactions,
};
