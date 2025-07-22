// 사진의 피드백 상태를 명확히 하기 위한 enum
enum FeedbackStatus { pending, approved, rejected }

class PhotoFeedback {
  final String photoId; // 각 사진의 고유 ID
  final String photoUrl; // 사진 파일 경로
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final FeedbackStatus status; // 요청자의 피드백 상태

  PhotoFeedback({
    required this.photoId,
    required this.photoUrl,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.status = FeedbackStatus.pending,
  });

  PhotoFeedback copyWith({
    String? photoId,
    String? photoUrl,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    FeedbackStatus? status,
  }) {
    return PhotoFeedback(
      photoId: photoId ?? this.photoId,
      photoUrl: photoUrl ?? this.photoUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}
