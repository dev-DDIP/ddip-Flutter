// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_feedback_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PhotoFeedbackModelImpl _$$PhotoFeedbackModelImplFromJson(
  Map<String, dynamic> json,
) => _$PhotoFeedbackModelImpl(
  photoId: json['photoId'] as String,
  photoUrl: json['photo_url'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  status: json['status'] as String,
);

Map<String, dynamic> _$$PhotoFeedbackModelImplToJson(
  _$PhotoFeedbackModelImpl instance,
) => <String, dynamic>{
  'photoId': instance.photoId,
  'photo_url': instance.photoUrl,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'timestamp': instance.timestamp.toIso8601String(),
  'status': instance.status,
};
