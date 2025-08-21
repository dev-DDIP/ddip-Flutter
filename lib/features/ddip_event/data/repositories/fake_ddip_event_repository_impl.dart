import 'dart:async';

import 'package:ddip/core/providers/core_providers.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/data/datasources/web_socket_data_source.dart';
import 'package:ddip/features/ddip_event/data/repositories/mock_ddip_event_data.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// 실제 서버 API 대신, 앱의 메모리에서 가짜 데이터를 관리하는 클래스입니다.
// 클린 아키텍처 덕분에, 나중에 이 파일만 실제 API를 호출하는 파일로 교체하면
// 앱의 다른 부분은 전혀 수정할 필요가 없습니다.

class FakeDdipEventRepositoryImpl implements DdipEventRepository {
  final Ref ref; // ✨ 1. 생성자를 통해 Ref를 전달받음
  final WebSocketDataSource webSocketDataSource;
  final _eventStreamControllers = <String, StreamController<DdipEvent>>{};

  FakeDdipEventRepositoryImpl(this.ref, {required this.webSocketDataSource});

  final List<DdipEvent> _ddipEvents = List.from(mockDdipEvents);

  void _broadcastUpdate(String eventId) {
    // 1. 현재 컨트롤러 맵에 해당 이벤트 ID의 방송 채널이 있는지 확인
    if (_eventStreamControllers.containsKey(eventId)) {
      // 2. 내부 데이터 목록에서 최신 이벤트 정보를 찾음
      final updatedEvent = _ddipEvents.firstWhere((e) => e.id == eventId);
      // 3. 해당 채널을 통해 최신 이벤트 데이터를 방송(emit)함
      _eventStreamControllers[eventId]!.add(updatedEvent);
    }
  }

  @override
  Future<void> applyToEvent(String eventId, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _ddipEvents.indexWhere((event) => event.id == eventId);

    if (index != -1) {
      final event = _ddipEvents[index];
      if (!event.applicants.contains(userId)) {
        final newApplicants = List<String>.from(event.applicants)..add(userId);
        final updatedEvent = event.copyWith(applicants: newApplicants);
        _ddipEvents[index] = updatedEvent;
        _broadcastUpdate(eventId);
      }
    } else {
      throw Exception('Event not found');
    }
  }

  @override
  Future<void> selectResponder(String eventId, String responderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _ddipEvents.indexWhere((event) => event.id == eventId);

    if (index != -1) {
      final event = _ddipEvents[index];
      if (event.applicants.contains(responderId)) {
        final updatedEvent = event.copyWith(
          selectedResponderId: responderId,
          status: DdipEventStatus.in_progress,
        );
        _ddipEvents[index] = updatedEvent;
        _broadcastUpdate(eventId);
      } else {
        throw Exception('Responder not in applicants list');
      }
    } else {
      throw Exception('Event not found');
    }
  }

  @override
  Future<void> addPhoto(
    String eventId,
    Photo photo, {
    required ActionType action,
    String? comment, // [수정] messageCode -> comment
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _ddipEvents.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      final event = _ddipEvents[index];
      final currentUser = ref.read(authProvider);
      if (currentUser == null) throw Exception("User not logged in");

      // [수정] Photo 객체는 이제 모든 정보를 담아서 파라미터로 전달받으므로,
      // 여기서는 photo.responderComment에 comment를 별도로 할당할 필요가 없습니다.
      // 뷰모델 단에서 Photo 객체를 만들 때 comment를 포함해서 만들게 됩니다.
      final newPhotos = List<Photo>.from(event.photos)..add(photo);

      // 새로운 Interaction 로그를 생성합니다.
      final newInteraction = Interaction(
        id: const Uuid().v4(),
        actorId: currentUser.id,
        actorRole: ActorRole.responder,
        actionType: action,
        comment: comment,
        // [수정] messageCode -> comment
        relatedPhotoId: photo.id,
        timestamp: DateTime.now(),
      );
      final newInteractions = List<Interaction>.from(event.interactions)
        ..add(newInteraction);
      // 사진과 상호작용 로그가 모두 업데이트된 새로운 이벤트 객체를 만듭니다.
      final updatedEvent = event.copyWith(
        photos: newPhotos,
        interactions: newInteractions,
      );
      _ddipEvents[index] = updatedEvent;
      _broadcastUpdate(eventId);
    } else {
      throw Exception('Event not found');
    }
  }

  @override
  Future<void> updatePhotoStatus(
    String eventId,
    String photoId,
    PhotoStatus status, {
    String? comment, // [수정] messageCode -> comment (반려 사유 등이 담김)
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final eventIndex = _ddipEvents.indexWhere((event) => event.id == eventId);

    if (eventIndex != -1) {
      final event = _ddipEvents[eventIndex];
      final currentUser = ref.read(authProvider);
      if (currentUser == null) throw Exception("User not logged in");
      final photoIndex = event.photos.indexWhere((p) => p.id == photoId);
      if (photoIndex != -1) {
        // [수정] 사진의 상태와 반려 사유를 함께 업데이트합니다.
        final updatedPhoto = event.photos[photoIndex].copyWith(
          status: status,
          rejectionReason: status == PhotoStatus.rejected ? comment : null,
        );
        final newPhotos = List<Photo>.from(event.photos);
        newPhotos[photoIndex] = updatedPhoto;

        DdipEventStatus newEventStatus = event.status;
        if (status == PhotoStatus.approved) {
          newEventStatus = DdipEventStatus.completed;
        } else if (status == PhotoStatus.rejected &&
            newPhotos.where((p) => p.status == PhotoStatus.rejected).length >=
                3) {
          newEventStatus = DdipEventStatus.failed;
        }

        // 새로운 Interaction 로그를 생성합니다.
        final newInteraction = Interaction(
          id: const Uuid().v4(),
          actorId: currentUser.id,
          actorRole: ActorRole.requester,
          actionType:
              status == PhotoStatus.approved
                  ? ActionType.approve
                  : ActionType.requestRevision,
          comment: comment,
          // [수정] 반려 사유 또는 승인 코멘트가 담길 수 있음
          relatedPhotoId: photoId,
          timestamp: DateTime.now(),
        );
        final newInteractions = List<Interaction>.from(event.interactions)
          ..add(newInteraction);
        // 모든 변경사항을 반영한 최종 이벤트 객체를 만듭니다.
        final updatedEvent = event.copyWith(
          photos: newPhotos,
          status: newEventStatus,
          interactions: newInteractions,
        );
        _ddipEvents[eventIndex] = updatedEvent;
        _broadcastUpdate(eventId);
      } else {
        throw Exception('Photo not found');
      }
    } else {
      throw Exception('Event not found');
    }
  }

  @override
  Future<void> createDdipEvent(DdipEvent event) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _ddipEvents.insert(0, event);
    print('Fake createDdipEvent success: ${event.title}');

    // 가짜 알림을 트리거하는 로직 추가
    ref.read(proximityServiceProvider).simulateEventCreation(event);
  }

  Future<List<DdipEvent>> getDdipEvents({required NLatLngBounds bounds}) async {
    await Future.delayed(const Duration(milliseconds: 300)); // API 호출 흉내

    // bounds를 이용해 mock 데이터를 필터링하는 로직
    final filteredEvents =
        _ddipEvents.where((event) {
          final eventPosition = NLatLng(event.latitude, event.longitude);
          return bounds.containsPoint(eventPosition);
        }).toList();

    return filteredEvents;
  }

  @override
  Future<DdipEvent> getDdipEventById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final event = _ddipEvents.firstWhere((event) => event.id == id);
      return event;
    } catch (e) {
      throw Exception('ID($id)에 해당하는 띱 이벤트를 찾을 수 없습니다.');
    }
  }

  @override
  Stream<DdipEvent> getEventStreamById(String id) {
    // 1. 해당 ID의 스트림 컨트롤러(방송 채널)가 없으면 새로 생성
    _eventStreamControllers.putIfAbsent(
      id,
      () => StreamController<DdipEvent>.broadcast(),
    );

    // 2. 구독하는 즉시 현재 최신 데이터를 먼저 한 번 보내줌
    final currentEvent = _ddipEvents.firstWhere((e) => e.id == id);
    _eventStreamControllers[id]!.add(currentEvent);

    // 3. 생성된 방송 채널의 스트림(라디오 주파수)을 반환
    return _eventStreamControllers[id]!.stream;
  }

  @override
  Stream<DdipEvent> getNewEventsStream() {
    // 1. 외부 전문가(DataSource)로부터 오는 Model(DTO) 스트림을 받습니다.
    return webSocketDataSource.getNewDdipEventStream().map((eventModel) {
      // 2. 새로운 이벤트가 생겼으므로 내부 데이터 목록에도 추가합니다.
      final newEvent = eventModel.toEntity();
      _ddipEvents.insert(0, newEvent);

      // 3. Model(DTO)을 Entity로 변환하여 Notifier(상위 관리자)에게 전달합니다.
      return newEvent;
    });
  }

  // ▼▼▼ 새로 추가된 getEventsByUserId 메소드를 구현합니다. ▼▼▼
  @override
  Future<List<DdipEvent>> getEventsByUserId(
    String userId,
    UserActivityType type,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300)); // API 호출 흉내

    switch (type) {
      case UserActivityType.requested:
        return _ddipEvents
            .where((event) => event.requesterId == userId)
            .toList();
      case UserActivityType.responded:
        return _ddipEvents
            .where(
              (event) =>
                  event.selectedResponderId == userId &&
                  (event.status == DdipEventStatus.completed ||
                      event.status == DdipEventStatus.failed),
            )
            .toList();
      case UserActivityType.ongoing:
        return _ddipEvents
            .where(
              (event) =>
                  (event.requesterId == userId ||
                      event.selectedResponderId == userId) &&
                  (event.status == DdipEventStatus.open ||
                      event.status == DdipEventStatus.in_progress),
            )
            .toList();
    }
  }

  @override
  Future<void> askQuestionOnPhoto(
    String eventId,
    String photoId,
    String question,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200)); // API 호출 흉내

    final eventIndex = _ddipEvents.indexWhere((e) => e.id == eventId);
    if (eventIndex != -1) {
      final event = _ddipEvents[eventIndex];
      final photoIndex = event.photos.indexWhere((p) => p.id == photoId);
      if (photoIndex != -1) {
        final newPhotos = List<Photo>.from(event.photos);
        newPhotos[photoIndex] = newPhotos[photoIndex].copyWith(
          requesterQuestion: question,
        );
        _ddipEvents[eventIndex] = event.copyWith(photos: newPhotos);

        _broadcastUpdate(eventId);
      }
    }
  }

  @override
  Future<void> answerQuestionOnPhoto(
    String eventId,
    String photoId,
    String answer,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200)); // API 호출 흉내

    final eventIndex = _ddipEvents.indexWhere((e) => e.id == eventId);
    if (eventIndex != -1) {
      final event = _ddipEvents[eventIndex];
      final photoIndex = event.photos.indexWhere((p) => p.id == photoId);
      if (photoIndex != -1) {
        // 1. 사진 목록에서 해당 사진을 찾아 `responderAnswer` 필드를 업데이트
        final newPhotos = List<Photo>.from(event.photos);
        newPhotos[photoIndex] = newPhotos[photoIndex].copyWith(
          responderAnswer: answer,
        );

        // 2. 답변 행위를 Interaction 로그로 추가
        final newInteraction = Interaction(
          id: const Uuid().v4(),
          actorId: ref.read(authProvider)!.id, // 현재 로그인 유저
          actorRole: ActorRole.responder,
          actionType: ActionType.answerQuestion,
          comment: answer,
          relatedPhotoId: photoId,
          timestamp: DateTime.now(),
        );
        final newInteractions = [...event.interactions, newInteraction];

        // 3. 변경된 사진 목록과 상호작용 로그로 이벤트 객체를 업데이트
        _ddipEvents[eventIndex] = event.copyWith(
          photos: newPhotos,
          interactions: newInteractions,
        );

        // 4. 변경 사항을 스트림으로 전파!
        _broadcastUpdate(eventId);
      }
    }
  }

  // FakeDdipEventRepositoryImpl 클래스 내부에 아래 메소드 구현을 추가
  @override
  Future<void> completeMission(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final eventIndex = _ddipEvents.indexWhere((e) => e.id == eventId);
    if (eventIndex != -1) {
      final event = _ddipEvents[eventIndex];
      // 가장 마지막에 제출된 pending 사진을 approved로 변경
      final lastPendingPhotoIndex = event.photos.lastIndexWhere(
        (p) => p.status == PhotoStatus.pending,
      );

      List<Photo> newPhotos = List.from(event.photos);
      if (lastPendingPhotoIndex != -1) {
        newPhotos[lastPendingPhotoIndex] = newPhotos[lastPendingPhotoIndex]
            .copyWith(status: PhotoStatus.approved);
      }

      // 이벤트 상태를 completed로 변경
      final updatedEvent = event.copyWith(
        status: DdipEventStatus.completed,
        photos: newPhotos,
      );
      _ddipEvents[eventIndex] = updatedEvent;
      _broadcastUpdate(eventId);
    }
  }
}
