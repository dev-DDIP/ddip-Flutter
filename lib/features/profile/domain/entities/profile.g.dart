// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileImpl _$$ProfileImplFromJson(Map<String, dynamic> json) =>
    _$ProfileImpl(
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      profileImageUrl: json['profileImageUrl'] as String,
      oneLineIntro: json['oneLineIntro'] as String,
      totalRequestCount: (json['totalRequestCount'] as num).toInt(),
      totalExecutionCount: (json['totalExecutionCount'] as num).toInt(),
      ddipPoints: (json['ddipPoints'] as num).toInt(),
      certificationMark:
          json['certificationMark'] == null
              ? null
              : CertificationMark.fromJson(
                json['certificationMark'] as Map<String, dynamic>,
              ),
      requesterReputation: RequesterReputation.fromJson(
        json['requesterReputation'] as Map<String, dynamic>,
      ),
      responderReputation: ResponderReputation.fromJson(
        json['responderReputation'] as Map<String, dynamic>,
      ),
      badges:
          (json['badges'] as List<dynamic>)
              .map((e) => Badge.fromJson(e as Map<String, dynamic>))
              .toList(),
      tags:
          (json['tags'] as List<dynamic>)
              .map((e) => Tag.fromJson(e as Map<String, dynamic>))
              .toList(),
      activityHours: Map<String, int>.from(json['activityHours'] as Map),
    );

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'profileImageUrl': instance.profileImageUrl,
      'oneLineIntro': instance.oneLineIntro,
      'totalRequestCount': instance.totalRequestCount,
      'totalExecutionCount': instance.totalExecutionCount,
      'ddipPoints': instance.ddipPoints,
      'certificationMark': instance.certificationMark,
      'requesterReputation': instance.requesterReputation,
      'responderReputation': instance.responderReputation,
      'badges': instance.badges,
      'tags': instance.tags,
      'activityHours': instance.activityHours,
    };

_$CertificationMarkImpl _$$CertificationMarkImplFromJson(
  Map<String, dynamic> json,
) => _$CertificationMarkImpl(
  title: json['title'] as String,
  semester: json['semester'] as String,
);

Map<String, dynamic> _$$CertificationMarkImplToJson(
  _$CertificationMarkImpl instance,
) => <String, dynamic>{'title': instance.title, 'semester': instance.semester};

_$RequesterReputationImpl _$$RequesterReputationImplFromJson(
  Map<String, dynamic> json,
) => _$RequesterReputationImpl(
  photoApprovalRate: (json['photoApprovalRate'] as num).toDouble(),
  avgSelectionTimeMinutes: (json['avgSelectionTimeMinutes'] as num).toInt(),
  responderSatisfaction: (json['responderSatisfaction'] as num).toDouble(),
);

Map<String, dynamic> _$$RequesterReputationImplToJson(
  _$RequesterReputationImpl instance,
) => <String, dynamic>{
  'photoApprovalRate': instance.photoApprovalRate,
  'avgSelectionTimeMinutes': instance.avgSelectionTimeMinutes,
  'responderSatisfaction': instance.responderSatisfaction,
};

_$ResponderReputationImpl _$$ResponderReputationImplFromJson(
  Map<String, dynamic> json,
) => _$ResponderReputationImpl(
  avgResponseTimeMinutes: (json['avgResponseTimeMinutes'] as num).toInt(),
  photoApprovalRate: (json['photoApprovalRate'] as num).toDouble(),
  abandonmentRate: (json['abandonmentRate'] as num).toDouble(),
);

Map<String, dynamic> _$$ResponderReputationImplToJson(
  _$ResponderReputationImpl instance,
) => <String, dynamic>{
  'avgResponseTimeMinutes': instance.avgResponseTimeMinutes,
  'photoApprovalRate': instance.photoApprovalRate,
  'abandonmentRate': instance.abandonmentRate,
};

_$BadgeImpl _$$BadgeImplFromJson(Map<String, dynamic> json) => _$BadgeImpl(
  name: json['name'] as String,
  description: json['description'] as String,
  imageUrl: json['imageUrl'] as String,
  category: $enumDecode(_$BadgeCategoryEnumMap, json['category']),
);

Map<String, dynamic> _$$BadgeImplToJson(_$BadgeImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'category': _$BadgeCategoryEnumMap[instance.category]!,
    };

const _$BadgeCategoryEnumMap = {
  BadgeCategory.activity: 'activity',
  BadgeCategory.professionalism: 'professionalism',
  BadgeCategory.special: 'special',
};

_$TagImpl _$$TagImplFromJson(Map<String, dynamic> json) => _$TagImpl(
  name: json['name'] as String,
  count: (json['count'] as num).toInt(),
);

Map<String, dynamic> _$$TagImplToJson(_$TagImpl instance) => <String, dynamic>{
  'name': instance.name,
  'count': instance.count,
};
