// lib/features/ddip_event/domain/entities/ddip_event.dart

import 'package:ddip/features/ddip_event/domain/entities/photo_feedback.dart';

enum DdipEventStatus { open, in_progress, completed, failed }

// pending_selection 상태를 제거하고 open으로 통합하여 흐름을 단순화합니다.
// (추후 '지원 마감' 기능이 필요할 때 다시 추가할 수 있습니다.)

class DdipEvent {
  final String id;
  final String title;
  final String content;
  final String requesterId;
  final int reward;
  final double latitude;
  final double longitude;
  final DdipEventStatus status;
  final DateTime createdAt;
  final List<String> applicants;
  final String? selectedResponderId;
  final List<PhotoFeedback> photos;

  DdipEvent({
    required this.id,
    required this.title,
    required this.content,
    required this.requesterId,
    required this.reward,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.applicants = const [],
    this.selectedResponderId,
    this.photos = const [],
  });

  DdipEvent copyWith({
    String? id,
    String? title,
    String? content,
    String? requesterId,
    int? reward,
    double? latitude,
    double? longitude,
    DdipEventStatus? status,
    DateTime? createdAt,
    List<String>? applicants,
    // copyWith에서 nullable 필드를 null로 업데이트할 수 있도록 수정
    String? selectedResponderId,
    List<PhotoFeedback>? photos,
  }) {
    return DdipEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      requesterId: requesterId ?? this.requesterId,
      reward: reward ?? this.reward,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      applicants: applicants ?? this.applicants,
      selectedResponderId: selectedResponderId ?? this.selectedResponderId,
      photos: photos ?? this.photos,
    );
  }
}
