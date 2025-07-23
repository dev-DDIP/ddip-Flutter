// lib/features/ddip_event/domain/entities/ddip_event.dart

import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';

enum DdipEventStatus { open, in_progress, completed, failed }

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
  final List<Photo> photos;
  final List<Interaction> interactions;

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
    this.interactions = const [],
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
    String? selectedResponderId,
    List<Photo>? photos,
    List<Interaction>? interactions,
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
      interactions: interactions ?? this.interactions,
    );
  }
}
