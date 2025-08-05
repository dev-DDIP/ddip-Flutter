import 'dart:async';

import 'package:ddip/core/providers/core_providers.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/data/datasources/web_socket_data_source.dart';
import 'package:ddip/features/ddip_event/data/repositories/mock_ddip_event_data.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// 실제 서버 API 대신, 앱의 메모리에서 가짜 데이터를 관리하는 클래스입니다.
// 클린 아키텍처 덕분에, 나중에 이 파일만 실제 API를 호출하는 파일로 교체하면
// 앱의 다른 부분은 전혀 수정할 필요가 없습니다.

class FakeDdipEventRepositoryImpl implements DdipEventRepository {
  final Ref ref; // ✨ 1. 생성자를 통해 Ref를 전달받음
  final WebSocketDataSource webSocketDataSource;

  FakeDdipEventRepositoryImpl(this.ref, {required this.webSocketDataSource});

  final List<DdipEvent> _ddipEvents = List.from(mockDdipEvents);

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
    MessageCode? messageCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _ddipEvents.indexWhere((event) => event.id == eventId);
    if (index != -1) {
      final event = _ddipEvents[index];
      final currentUser = ref.read(authProvider);
      if (currentUser == null) throw Exception("User not logged in");

      // 1. 새로운 사진을 photos 리스트에 추가합니다.
      final newPhotos = List<Photo>.from(event.photos)..add(photo);

      // 2. 새로운 Interaction 로그를 생성합니다.
      final newInteraction = Interaction(
        id: const Uuid().v4(),
        actorId: currentUser.id,
        actorRole: ActorRole.responder,
        actionType: action,
        messageCode: messageCode,
        relatedPhotoId: photo.id,
        // 이 상호작용이 어떤 사진과 관련있는지 명시
        timestamp: DateTime.now(),
      );
      final newInteractions = List<Interaction>.from(event.interactions)
        ..add(newInteraction);

      // 3. 사진과 상호작용 로그가 모두 업데이트된 새로운 이벤트 객체를 만듭니다.
      final updatedEvent = event.copyWith(
        photos: newPhotos,
        interactions: newInteractions,
      );
      _ddipEvents[index] = updatedEvent;
    } else {
      throw Exception('Event not found');
    }
  }

  @override
  Future<void> updatePhotoStatus(
    String eventId,
    String photoId,
    PhotoStatus status, {
    MessageCode? messageCode,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final eventIndex = _ddipEvents.indexWhere((event) => event.id == eventId);

    if (eventIndex != -1) {
      final event = _ddipEvents[eventIndex];
      final currentUser = ref.read(authProvider);
      if (currentUser == null) throw Exception("User not logged in");

      final photoIndex = event.photos.indexWhere((p) => p.id == photoId);
      if (photoIndex != -1) {
        // 1. 사진의 상태를 업데이트합니다.
        final updatedPhoto = event.photos[photoIndex].copyWith(status: status);
        final newPhotos = List<Photo>.from(event.photos);
        newPhotos[photoIndex] = updatedPhoto;

        // 2. 이벤트의 최종 상태를 결정합니다.
        DdipEventStatus newEventStatus = event.status;
        if (status == PhotoStatus.approved) {
          newEventStatus = DdipEventStatus.completed;
        } else if (status == PhotoStatus.rejected &&
            newPhotos.where((p) => p.status == PhotoStatus.rejected).length >=
                3) {
          newEventStatus = DdipEventStatus.failed;
        }

        // 3. 새로운 Interaction 로그를 생성합니다.
        final newInteraction = Interaction(
          id: const Uuid().v4(),
          actorId: currentUser.id,
          actorRole: ActorRole.requester,
          actionType:
              status == PhotoStatus.approved
                  ? ActionType.approve
                  : ActionType.requestRevision,
          messageCode: messageCode,
          relatedPhotoId: photoId,
          timestamp: DateTime.now(),
        );
        final newInteractions = List<Interaction>.from(event.interactions)
          ..add(newInteraction);

        // 4. 모든 변경사항을 반영한 최종 이벤트 객체를 만듭니다.
        final updatedEvent = event.copyWith(
          photos: newPhotos,
          status: newEventStatus,
          interactions: newInteractions,
        );
        _ddipEvents[eventIndex] = updatedEvent;
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

  @override
  Future<List<DdipEvent>> getDdipEvents() async {
    await Future.delayed(const Duration(seconds: 1));
    return _ddipEvents;
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
  Stream<DdipEvent> getEventStreamById(String id) async* {
    // 1. 먼저 현재 저장된 최신 버전의 이벤트를 한 번 보내줍니다. (스냅샷)
    final initialEvent = _ddipEvents.firstWhere((e) => e.id == id);
    yield initialEvent;

    // 2. 외부 전문가(WebSocketDataSource)로부터 오는 실시간 업데이트를 구독합니다.
    final interactionStream = webSocketDataSource.getInteractionStream(id);

    // 3. 새로운 업데이트(Interaction)가 올 때마다,
    //    기존 이벤트 데이터에 변경사항을 적용하여 새로운 버전의 DdipEvent를 만들어 UI에 보내줍니다.
    await for (final interaction in interactionStream) {
      final targetEvent = _ddipEvents.firstWhere((e) => e.id == id);

      // 실제로는 interaction의 actionType에 따라 분기 처리가 필요하지만,
      // 지금은 지원자(applicant)가 추가되는 시나리오만 가정합니다.
      final updatedEvent = targetEvent.copyWith(
        applicants: [...targetEvent.applicants, interaction.actorId],
      );

      // 내부 데이터도 최신 상태로 업데이트합니다.
      final eventIndex = _ddipEvents.indexWhere((e) => e.id == id);
      _ddipEvents[eventIndex] = updatedEvent;

      // UI에 업데이트된 최신 버전의 이벤트를 흘려보냅니다 (라이브 비디오).
      yield updatedEvent;
    }
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
}
