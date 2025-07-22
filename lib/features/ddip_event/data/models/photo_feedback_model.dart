// lib/features/ddip_event/data/models/photo_feedback_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo_feedback.dart';

part 'photo_feedback_model.freezed.dart';
part 'photo_feedback_model.g.dart';

@freezed
class PhotoFeedbackModel with _$PhotoFeedbackModel {
  const factory PhotoFeedbackModel({
    required String photoId,
    @JsonKey(name: 'photo_url') required String photoUrl,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    required String status, // 서버와는 String으로 통신
  }) = _PhotoFeedbackModel;

  const PhotoFeedbackModel._();

  factory PhotoFeedbackModel.fromJson(Map<String, dynamic> json) =>
      _$PhotoFeedbackModelFromJson(json);

  // 모델을 엔티티로 변환하는 메서드
  PhotoFeedback toEntity() {
    return PhotoFeedback(
      photoId: photoId,
      photoUrl: photoUrl,
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp,
      // String status를 FeedbackStatus enum으로 변환
      status: FeedbackStatus.values.firstWhere(
        (e) => e.toString() == 'FeedbackStatus.$status',
        orElse: () => FeedbackStatus.pending, // 기본값
      ),
    );
  }
}
