// lib/features/ddip_event/data/models/ddip_event_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/data/models/photo_feedback_model.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo_feedback.dart';

part 'ddip_event_model.freezed.dart';
part 'ddip_event_model.g.dart';

@freezed
class DdipEventModel with _$DdipEventModel {
  // [오류 수정]
  // 이 factory 생성자가 클래스의 모든 필드를 정의하는 유일한 곳입니다.
  // 여기에 모든 필드가 포함되어야 합니다.
  const factory DdipEventModel({
    required String id,
    required String title,
    required String content,
    @JsonKey(name: 'requester_id') required String requesterId,
    required int reward,
    required double latitude,
    required double longitude,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    required String status,
    @JsonKey(name: 'selected_responder_id') String? selectedResponderId,
    @Default([]) List<String> applicants,
    @Default([]) List<PhotoFeedbackModel> photos,
  }) = _DdipEventModel;

  const DdipEventModel._();

  factory DdipEventModel.fromJson(Map<String, dynamic> json) =>
      _$DdipEventModelFromJson(json);

  DdipEvent toEntity() {
    return DdipEvent(
      id: id,
      title: title,
      content: content,
      requesterId: requesterId,
      reward: reward,
      latitude: latitude,
      longitude: longitude,
      createdAt: createdAt,
      status: DdipEventStatus.values.firstWhere(
        (e) => e.toString() == 'DdipEventStatus.$status',
        orElse: () => DdipEventStatus.open,
      ),
      // [오류 수정]
      // 이제 생성자에 필드가 올바르게 정의되었으므로
      // toEntity 메서드에서 정상적으로 접근할 수 있습니다.
      applicants: applicants,
      selectedResponderId: selectedResponderId,
      photos: photos.map((photoModel) => photoModel.toEntity()).toList(),
    );
  }
}
