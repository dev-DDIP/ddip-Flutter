// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileImpl _$$ProfileImplFromJson(
  Map<String, dynamic> json,
) => _$ProfileImpl(
  userId: json['userId'] as String,
  nickname: json['nickname'] as String,
  profileImageUrl: json['profileImageUrl'] as String,
  oneLineIntro: json['oneLineIntro'] as String,
  certifiedSchoolName: json['certifiedSchoolName'] as String?,
  responderAverageRating: (json['responderAverageRating'] as num?)?.toDouble(),
  requesterAverageRating: (json['requesterAverageRating'] as num?)?.toDouble(),
  totalRequestCount: (json['totalRequestCount'] as num).toInt(),
  totalExecutionCount: (json['totalExecutionCount'] as num).toInt(),
  requesterPraiseTags: (json['requesterPraiseTags'] as Map<String, dynamic>)
      .map(
        (k, e) =>
            MapEntry($enumDecode(_$PraiseTagEnumMap, k), (e as num).toInt()),
      ),
  responderPraiseTags: (json['responderPraiseTags'] as Map<String, dynamic>)
      .map(
        (k, e) =>
            MapEntry($enumDecode(_$PraiseTagEnumMap, k), (e as num).toInt()),
      ),
);

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'profileImageUrl': instance.profileImageUrl,
      'oneLineIntro': instance.oneLineIntro,
      'certifiedSchoolName': instance.certifiedSchoolName,
      'responderAverageRating': instance.responderAverageRating,
      'requesterAverageRating': instance.requesterAverageRating,
      'totalRequestCount': instance.totalRequestCount,
      'totalExecutionCount': instance.totalExecutionCount,
      'requesterPraiseTags': instance.requesterPraiseTags.map(
        (k, e) => MapEntry(_$PraiseTagEnumMap[k]!, e),
      ),
      'responderPraiseTags': instance.responderPraiseTags.map(
        (k, e) => MapEntry(_$PraiseTagEnumMap[k]!, e),
      ),
    };

const _$PraiseTagEnumMap = {
  PraiseTag.photoClarity: 'photoClarity',
  PraiseTag.goodComprehension: 'goodComprehension',
  PraiseTag.kindAndPolite: 'kindAndPolite',
  PraiseTag.sensibleExtraInfo: 'sensibleExtraInfo',
  PraiseTag.clearRequest: 'clearRequest',
  PraiseTag.fastFeedback: 'fastFeedback',
  PraiseTag.politeAndKind: 'politeAndKind',
  PraiseTag.reasonableRequest: 'reasonableRequest',
};
