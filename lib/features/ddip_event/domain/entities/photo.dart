enum PhotoStatus { pending, approved, rejected }

class Photo {
  final String id;
  final String url;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final PhotoStatus status;

  Photo({
    required this.id,
    required this.url,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    this.status = PhotoStatus.pending, // 수정
  });

  Photo copyWith({
    String? id,
    String? url,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    PhotoStatus? status, // 수정
  }) {
    return Photo(
      id: id ?? this.id,
      url: url ?? this.url,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}
