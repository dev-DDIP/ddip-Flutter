// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhotoModelImpl _$$PhotoModelImplFromJson(Map<String, dynamic> json) =>
    _$PhotoModelImpl(
      id: json['photoId'] as String,
      url: json['photoUrl'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String,
      responderComment: json['responderComment'] as String?,
      requesterQuestion: json['requesterQuestion'] as String?,
      responderAnswer: json['responderAnswer'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
    );

Map<String, dynamic> _$$PhotoModelImplToJson(_$PhotoModelImpl instance) =>
    <String, dynamic>{
      'photoId': instance.id,
      'photoUrl': instance.url,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'timestamp': instance.timestamp.toIso8601String(),
      'status': instance.status,
      'responderComment': instance.responderComment,
      'requesterQuestion': instance.requesterQuestion,
      'responderAnswer': instance.responderAnswer,
      'rejectionReason': instance.rejectionReason,
    };
