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
      requesterId: json['requesterId'] as String,
      reward: (json['reward'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: json['status'] as String,
      selectedResponderId: json['selectedResponderId'] as String?,
      applicants:
          (json['applicants'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      photos:
          (json['photos'] as List<dynamic>?)
              ?.map((e) => PhotoModel.fromJson(e as Map<String, dynamic>))
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
  'requesterId': instance.requesterId,
  'reward': instance.reward,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'createdAt': instance.createdAt.toIso8601String(),
  'status': instance.status,
  'selectedResponderId': instance.selectedResponderId,
  'applicants': instance.applicants,
  'photos': instance.photos,
  'interactions': instance.interactions,
};
