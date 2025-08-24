// lib/features/ddip_event/presentation/notifiers/ddip_events_notifier.dart

import 'dart:async';

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

@immutable // 불변 객체임을 명시
class DdipFeedState {
  final List<DdipEvent> events;
  final NCameraPosition? lastFetchedCameraPosition; // 마지막으로 요청했던 카메라 위치

  const DdipFeedState({this.events = const [], this.lastFetchedCameraPosition});

  DdipFeedState copyWith({
    List<DdipEvent>? events,
    NCameraPosition? lastFetchedCameraPosition,
  }) {
    return DdipFeedState(
      events: events ?? this.events,
      lastFetchedCameraPosition:
          lastFetchedCameraPosition ?? this.lastFetchedCameraPosition,
    );
  }
}

class DdipEventsNotifier extends StateNotifier<AsyncValue<DdipFeedState>> {
  final Ref _ref;
  StreamSubscription? _newEventsSubscription;

  DdipEventsNotifier(this._ref)
    : super(AsyncValue.data(const DdipFeedState())) {
    loadEvents();
    _listenToNewEvents();
  }

  @override
  void dispose() {
    _newEventsSubscription?.cancel();
    super.dispose();
  }

  //  최초 로드 시, 현재 위치를 기반으로 초기 영역 데이터를 가져오도록 수정
  Future<void> loadEvents() async {
    state = const AsyncValue.loading();
    try {
      Position position;
      try {
        position = await Geolocator.getCurrentPosition();
      } catch (e) {
        position = Position(
          latitude: 35.890,
          longitude: 128.612,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: 0,
          speedAccuracy: 0,
        );
      }
      final initialPosition = NLatLng(position.latitude, position.longitude);

      // 1. 초기 지도 영역(Bounds) 생성 (기존과 동일)
      final initialBounds = NLatLngBounds(
        southWest: initialPosition.offsetByMeter(
          northMeter: -1500,
          eastMeter: -1500,
        ),
        northEast: initialPosition.offsetByMeter(
          northMeter: 1500,
          eastMeter: 1500,
        ),
      );

      // 2. [신규] 초기 카메라 위치(Position) 생성 (기본 줌 레벨 15로 설정)
      const initialZoom = 15.0;
      final initialCameraPosition = NCameraPosition(
        target: initialPosition,
        zoom: initialZoom,
      );

      // 3. [수정] 새로운 메서드 호출
      await fetchEventsIfNeeded(
        currentPosition: initialCameraPosition,
        currentBounds: initialBounds,
      );
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  // 새로운 '띱' 이벤트를 실시간으로 감지하고 상태를 업데이트하는 메서드
  void _listenToNewEvents() {
    // 실시간으로 새 이벤트가 추가될 때 상태를 업데이트하는 로직
    final repository = _ref.read(ddipEventRepositoryProvider);
    _newEventsSubscription = repository.getNewEventsStream().listen((newEvent) {
      final previousState = state.value;
      if (previousState == null) return;

      final newEvents = [newEvent, ...previousState.events];
      state = AsyncValue.data(previousState.copyWith(events: newEvents));
    });
  }

  // '띱'에 지원하는 메서드
  Future<void> applyToEvent(String eventId) async {
    final currentUser = _ref.read(authProvider);
    if (currentUser == null) throw Exception("로그인이 필요합니다.");

    final previousState = state.value;
    if (previousState == null) return;

    try {
      final repository = _ref.read(ddipEventRepositoryProvider);
      await repository.applyToEvent(eventId, currentUser.id);

      final newEvents =
          previousState.events.map((event) {
            if (event.id == eventId) {
              return event.copyWith(
                applicants: [...event.applicants, currentUser.id],
              );
            }
            return event;
          }).toList();

      // copyWith를 사용해 events 목록만 갱신하고 lastFetchedBounds는 유지합니다.
      state = AsyncValue.data(previousState.copyWith(events: newEvents));
    } catch (e) {
      rethrow;
    }
  }

  // 수행자를 선택하는 메서드
  Future<void> selectResponder(String eventId, String responderId) async {
    final previousState = state.value; // .valueOrNull 대신 .value 사용
    if (previousState == null) return;

    try {
      final repository = _ref.read(ddipEventRepositoryProvider);
      await repository.selectResponder(eventId, responderId);

      // [수정] previousState에서 .events를 통해 목록에 접근
      final newEvents =
          previousState.events.map((event) {
            if (event.id == eventId) {
              return event.copyWith(
                status: DdipEventStatus.in_progress,
                selectedResponderId: responderId,
              );
            }
            return event;
          }).toList();

      // [수정] copyWith로 새로운 DdipFeedState를 만들어 상태 업데이트
      state = AsyncValue.data(previousState.copyWith(events: newEvents));
    } catch (e) {
      rethrow;
    }
  }

  // 사진을 제출하는 메서드
  Future<DdipEvent> addPhoto(
    String eventId,
    Photo photo, {
    ActionType action = ActionType.submitPhoto,
  }) async {
    final previousState = state.value;
    if (previousState == null) throw Exception("State is not available");

    try {
      final repository = _ref.read(ddipEventRepositoryProvider);
      // Photo 객체 자체에 responderComment가 있으므로, Notifier는 Photo 객체만 받습니다.
      await repository.addPhoto(eventId, photo, action: action);

      DdipEvent? updatedEvent; // 변경된 이벤트를 저장할 변수

      final newEvents =
          previousState.events.map((event) {
            if (event.id == eventId) {
              final newPhotos = [...event.photos, photo];
              final newInteraction = Interaction(
                id: photo.id,
                actorId: _ref.read(authProvider)!.id,
                actorRole: ActorRole.responder,
                actionType: action,
                comment: photo.responderComment,
                relatedPhotoId: photo.id,
                timestamp: DateTime.now(),
              );
              final newInteractions = [...event.interactions, newInteraction];

              // 수정된 이벤트를 변수에 저장합니다.
              updatedEvent = event.copyWith(
                photos: newPhotos,
                interactions: newInteractions,
              );
              return updatedEvent!;
            }
            return event;
          }).toList();

      state = AsyncValue.data(previousState.copyWith(events: newEvents));

      if (updatedEvent == null) {
        throw Exception("Failed to find the updated event.");
      }
      // 저장해둔 변경된 이벤트를 반환합니다.
      return updatedEvent!;
    } catch (e) {
      rethrow;
    }
  }

  // 사진에 피드백을 남기는 메서드
  Future<DdipEvent> updatePhotoStatus(
    String eventId,
    String photoId,
    PhotoStatus status, {
    String? comment,
  }) async {
    final previousState = state.value;
    if (previousState == null) throw Exception("State is not available");

    try {
      await _ref
          .read(ddipEventRepositoryProvider)
          .updatePhotoStatus(eventId, photoId, status, comment: comment);

      DdipEvent? updatedEvent;

      final newEvents =
          previousState.events.map((event) {
            if (event.id == eventId) {
              Photo? targetPhoto;
              final newPhotos =
                  event.photos.map((p) {
                    if (p.id == photoId) {
                      // ✅ [핵심 수정] status와 함께 반려 사유(rejectionReason)도 업데이트합니다.
                      targetPhoto = p.copyWith(
                        status: status,
                        // status가 rejected일 때만 comment를 rejectionReason에 저장합니다.
                        rejectionReason:
                            status == PhotoStatus.rejected ? comment : null,
                      );
                      return targetPhoto!;
                    }
                    return p;
                  }).toList();

              if (targetPhoto == null) return event;

              DdipEventStatus newEventStatus = event.status;
              if (status == PhotoStatus.approved) {
                newEventStatus = DdipEventStatus.completed;
              }

              final newInteraction = Interaction(
                id:
                    'feedback_${photoId}_${DateTime.now().millisecondsSinceEpoch}',
                actorId: _ref.read(authProvider)!.id,
                actorRole: ActorRole.requester,
                actionType:
                    status == PhotoStatus.approved
                        ? ActionType.approve
                        : ActionType.requestRevision,
                comment: comment,
                // Interaction에는 반려 사유나 승인 코멘트가 모두 기록될 수 있습니다.
                relatedPhotoId: photoId,
                timestamp: DateTime.now(),
              );
              final newInteractions = [...event.interactions, newInteraction];

              updatedEvent = event.copyWith(
                photos: newPhotos,
                status: newEventStatus,
                interactions: newInteractions,
              );
              return updatedEvent!;
            }
            return event;
          }).toList();

      state = AsyncValue.data(previousState.copyWith(events: newEvents));

      if (updatedEvent == null) {
        throw Exception("Failed to find the updated event for photo feedback.");
      }
      return updatedEvent!;
    } catch (e) {
      rethrow;
    }
  }

  // 데이터 요청 메서드를 카메라 위치 기반으로
  Future<void> fetchEventsIfNeeded({
    required NCameraPosition currentPosition,
    required NLatLngBounds currentBounds,
  }) async {
    final lastPosition = state.value?.lastFetchedCameraPosition;

    // [핵심] 카메라의 '위치'와 '줌 레벨'이 거의 같다면 API 호출을 막습니다.
    if (_isCameraPositionSimilar(lastPosition, currentPosition)) {
      return;
    }

    state = const AsyncValue.loading();
    try {
      final getDdipEvents = _ref.read(getDdipEventsUseCaseProvider);
      // API 요청에는 여전히 bounds를 사용합니다.
      final events = await getDdipEvents(bounds: currentBounds);

      // 성공 시, 이벤트 목록과 함께 '요청했던 카메라 위치'를 상태에 저장합니다.
      state = AsyncValue.data(
        DdipFeedState(
          events: events,
          lastFetchedCameraPosition: currentPosition,
        ),
      );
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  bool _isCameraPositionSimilar(NCameraPosition? a, NCameraPosition b) {
    if (a == null) return false;

    final latDiff = (a.target.latitude - b.target.latitude).abs();
    final lonDiff = (a.target.longitude - b.target.longitude).abs();
    final zoomDiff = (a.zoom - b.zoom).abs();

    // 위도/경도 0.0001도 이내, 줌 레벨 0.1 이내의 변화는 무시
    return latDiff < 0.0001 && lonDiff < 0.0001 && zoomDiff < 0.1;
  }

  Future<void> askQuestionOnPhoto(
    String eventId,
    String photoId,
    String question,
  ) async {
    try {
      // 1. 실제 데이터 처리를 담당하는 Repository의 메소드를 호출합니다.
      final repository = _ref.read(ddipEventRepositoryProvider);
      await repository.askQuestionOnPhoto(eventId, photoId, question);

      // 2. Repository가 스트림을 통해 변경사항을 전파할 것이므로,
      //    여기서는 별도의 상태 업데이트 로직이 필요 없습니다.
    } catch (e) {
      // 에러가 발생하면 상위로 전파하여 ViewModel에서 처리하도록 합니다.
      rethrow;
    }
  }

  /// 수행자가 사진에 달린 질문에 답변하는 로직
  Future<void> answerQuestionOnPhoto(
    String eventId,
    String photoId,
    String answer,
  ) async {
    try {
      // 실제 데이터 처리는 Repository에 위임합니다.
      final repository = _ref.read(ddipEventRepositoryProvider);
      await repository.answerQuestionOnPhoto(eventId, photoId, answer);
      // Repository가 스트림을 통해 변경사항을 전파하므로,
      // 여기서 별도의 상태 업데이트는 필요 없습니다.
    } catch (e) {
      rethrow; // 에러는 ViewModel으로 다시 던져서 UI에 피드백을 줍니다.
    }
  }

  Future<void> completeMission(String eventId) async {
    try {
      // 실제 데이터 처리를 담당하는 Repository를 찾아 completeMission 메소드를 호출합니다.
      final repository = _ref.read(ddipEventRepositoryProvider);
      await repository.completeMission(eventId);

      // 성공 시 데이터 업데이트는 Repository의 스트림을 통해 자동으로 전파되므로
      // 여기서 별도의 상태 변경 코드는 필요 없습니다.
    } catch (e) {
      // 에러 발생 시 ViewModel로 에러를 다시 전달하여 UI에 피드백을 줍니다.
      rethrow;
    }
  }

  Future<void> cancelMission(String eventId) async {
    final currentUser = _ref.read(authProvider);
    if (currentUser == null) throw Exception("로그인이 필요합니다.");

    final previousState = state.value;
    if (previousState == null) return;

    try {
      final repository = _ref.read(ddipEventRepositoryProvider);
      // 데이터 계층에 만들어둔 cancelMission 메서드 호출
      await repository.cancelMission(eventId, currentUser.id);

      // --- 로직 성공 시, UI 상태를 즉시 업데이트 ---
      // (서버 응답을 기다리지 않고 바로 UI를 변경하여 사용자 경험을 향상시킵니다)
      final newEvents =
          previousState.events.map((event) {
            if (event.id == eventId) {
              // 이벤트의 상태를 'failed'로 변경
              return event.copyWith(status: DdipEventStatus.failed);
            }
            return event;
          }).toList();

      state = AsyncValue.data(previousState.copyWith(events: newEvents));
    } catch (e) {
      // 에러가 발생하면 상위로 전파하여 ViewModel에서 처리하도록 함
      rethrow;
    }
  }
}
