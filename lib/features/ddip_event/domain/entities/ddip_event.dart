// lib/features/ddip_event/domain/entities/ddip_event.dart

// 이 클래스는 '띱 이벤트'라는 비즈니스 개념 그 자체를 정의합니다.
// 서버 API의 필드명이 바뀌거나, 데이터베이스 구조가 바뀌어도
// 이 파일은 영향을 받지 않아야 합니다.

/*
## DdipEvent (Domain 영역의 엔티티)
목적: 앱의 핵심 비즈니스 로직에서 사용하는 순수한 데이터 클래스입니다.

특징: 이 클래스는 서버, 데이터베이스, UI 등 외부 세상에 대해 아무것도 모릅니다.
오직 '띱 이벤트'라는 개념 자체만을 표현합니다.
이 클래스는 외부의 변화로부터 완벽하게 보호되어야 합니다.
 */

import 'package:ddip/features/ddip_event/domain/entities/photo_feedback.dart';

enum DdipEventStatus { open, pending_selection, in_progress, completed, failed }

class DdipEvent {
  final String id;
  final String title;
  final String content;
  final String requesterId;
  final String? responderId; // 응답자는 아직 없을 수 있으므로 nullable
  final int reward;
  final double latitude;
  final double longitude;
  final DdipEventStatus status; // 기존 String에서 enum으로 변경
  final DateTime createdAt;
  final String? responsePhotoUrl; // 응답 사진은 아직 없을 수 있으므로 nullable
  // 응답 사진의 위도와 경도를 저장할 필드 (nullable)
  final double? responseLatitude;
  final double? responseLongitude;
  final List<String> applicants; // 지원자 userId 목록
  final String? selectedResponderId; // 선택된 수행자 userId
  final List<PhotoFeedback> photos; // 주고받은 사진과 피드백 목록!

  DdipEvent({
    required this.id,
    required this.title,
    required this.content,
    required this.requesterId,
    this.responderId,
    required this.reward,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.responsePhotoUrl,
    // 생성자에 필드 추가
    this.responseLatitude,
    this.responseLongitude,
    this.applicants = const [], // 기본값은 빈 리스트
    this.selectedResponderId,
    this.photos = const [], // 기본값은 빈 리스트
  });

  DdipEvent copyWith({
    String? id,
    String? title,
    String? content,
    String? requesterId,
    DdipEventStatus? status,
    List<String>? applicants,
    String? selectedResponderId,
    List<PhotoFeedback>? photos,
    int? reward,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return DdipEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      requesterId: requesterId ?? this.requesterId,
      status: status ?? this.status,
      applicants: applicants ?? this.applicants,
      // selectedResponderId는 null이 될 수 있으므로 별도 처리 불필요
      selectedResponderId: selectedResponderId ?? this.selectedResponderId,
      photos: photos ?? this.photos,
      reward: reward ?? this.reward,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
