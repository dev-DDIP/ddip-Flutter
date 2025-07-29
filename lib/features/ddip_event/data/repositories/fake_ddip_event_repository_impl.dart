import 'package:ddip/core/providers/core_providers.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/data/repositories/mock_ddip_event_data.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:ddip/features/map/domain/entities/cluster_or_marker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

// 실제 서버 API 대신, 앱의 메모리에서 가짜 데이터를 관리하는 클래스입니다.
// 클린 아키텍처 덕분에, 나중에 이 파일만 실제 API를 호출하는 파일로 교체하면
// 앱의 다른 부분은 전혀 수정할 필요가 없습니다.

// Isolate에서 실행될 클러스터링 로직을 클래스 외부의 최상위 함수로 분리합니다.
// compute 함수는 클래스 메서드가 아닌 최상위 함수만 실행할 수 있습니다.
List<ClusterOrMarker> _performClustering(Map<String, dynamic> args) {
  // compute로 전달받은 데이터들을 다시 원래 타입으로 변환합니다.
  final List<DdipEvent> allEvents = args['events'] as List<DdipEvent>;
  final NLatLngBounds bounds = args['bounds'] as NLatLngBounds;
  final double zoom = args['zoom'] as double;

  // 1. 현재 화면에 보이는 이벤트만 필터링
  final visibleEvents =
      allEvents.where((event) {
        final eventPosition = NLatLng(event.latitude, event.longitude);
        return bounds.containsPoint(eventPosition);
      }).toList();

  // 2. 줌 레벨에 따라 클러스터링 수행 여부 결정
  if (zoom >= 15) {
    // 줌 레벨이 높으면 클러스터링 없이 개별 마커로 반환
    return visibleEvents
        .map(
          (event) => IndividualMarker(
            position: NLatLng(event.latitude, event.longitude),
            event: event,
          ),
        )
        .toList();
  } else {
    // 줌 레벨이 낮으면 클러스터링 로직 수행 (기존 _groupEventsByGeoDistance 로직)
    if (visibleEvents.isEmpty) return [];

    final double threshold = switch (zoom) {
      < 13 => 0.008,
      < 14 => 0.004,
      < 15 => 0.0015,
      _ => 0,
    };

    final List<List<DdipEvent>> groups = [];
    final Set<String> processedEventIds = {};

    for (final event in visibleEvents) {
      if (processedEventIds.contains(event.id)) continue;
      final clusterGroup = <DdipEvent>[event];
      processedEventIds.add(event.id);
      for (final otherEvent in visibleEvents) {
        if (processedEventIds.contains(otherEvent.id)) continue;
        if ((event.latitude - otherEvent.latitude).abs() < threshold &&
            (event.longitude - otherEvent.longitude).abs() < threshold) {
          clusterGroup.add(otherEvent);
          processedEventIds.add(otherEvent.id);
        }
      }
      groups.add(clusterGroup);
    }

    final result = <ClusterOrMarker>[];
    for (final group in groups) {
      if (group.length > 1) {
        double avgLat =
            group.map((e) => e.latitude).reduce((a, b) => a + b) / group.length;
        double avgLon =
            group.map((e) => e.longitude).reduce((a, b) => a + b) /
            group.length;
        result.add(
          Cluster(
            position: NLatLng(avgLat, avgLon),
            count: group.length,
            events: group,
          ),
        );
      } else {
        final event = group.first;
        result.add(
          IndividualMarker(
            position: NLatLng(event.latitude, event.longitude),
            event: event,
          ),
        );
      }
    }
    return result;
  }
}

class FakeDdipEventRepositoryImpl implements DdipEventRepository {
  final Ref ref; // ✨ 1. 생성자를 통해 Ref를 전달받음
  FakeDdipEventRepositoryImpl(this.ref);

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
    await Future.delayed(const Duration(milliseconds: 400));
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
    await Future.delayed(const Duration(milliseconds: 500));
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

  // getClusters 메서드가 직접 계산하는 대신 'compute'를 통해 백그라운드 함수를 호출합니다.
  @override
  Future<List<ClusterOrMarker>> getClusters(
    NLatLngBounds bounds,
    double zoom,
  ) async {
    // 백그라운드 Isolate에 넘겨줄 데이터 꾸러미를 만듭니다.
    final args = {'events': _ddipEvents, 'bounds': bounds, 'zoom': zoom};

    // compute 함수로 백그라운드 작업을 요청하고 결과가 올 때까지 기다립니다.
    return await compute(_performClustering, args);
  }
}
