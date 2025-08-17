enum PhotoStatus { pending, approved, rejected }

class Photo {
  final String id;
  final String url;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final PhotoStatus status;
  final String? responderComment; // [추가] 수행자가 사진과 함께 남기는 코멘트
  final String? requesterQuestion; // [추가] 요청자가 남기는 1회성 질문
  final String? responderAnswer; // [추가] 수행자가 질문에 남기는 답변
  final String? rejectionReason; // [추가] 요청자가 최종 반려 시 남기는 사유

  Photo({
    required this.id,
    required this.url,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.status = PhotoStatus.pending,
    this.responderComment,
    this.requesterQuestion,
    this.responderAnswer,
    this.rejectionReason,
  });

  Photo copyWith({
    String? id,
    String? url,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    PhotoStatus? status,
    String? responderComment,
    String? requesterQuestion,
    String? responderAnswer,
    String? rejectionReason,
  }) {
    return Photo(
      id: id ?? this.id,
      url: url ?? this.url,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      responderComment: responderComment ?? this.responderComment,
      requesterQuestion: requesterQuestion ?? this.requesterQuestion,
      responderAnswer: responderAnswer ?? this.responderAnswer,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
