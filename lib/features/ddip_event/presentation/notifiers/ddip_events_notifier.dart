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
  Future<void> addPhoto(
    String eventId,
    Photo photo, {
    ActionType action = ActionType.submitPhoto,
    MessageCode? messageCode,
  }) async {
    final previousState = state.value; // .valueOrNull 대신 .value 사용
    if (previousState == null) return;

    try {
      final repository = _ref.read(ddipEventRepositoryProvider);
      await repository.addPhoto(
        eventId,
        photo,
        action: action,
        messageCode: messageCode,
      );

      // [수정] previousState.events.map으로 수정
      final newEvents =
          previousState.events.map((event) {
            if (event.id == eventId) {
              final newPhotos = [...event.photos, photo];
              final newInteraction = Interaction(
                id: photo.id,
                actorId: _ref.read(authProvider)!.id,
                actorRole: ActorRole.responder,
                actionType: action,
                messageCode: messageCode,
                relatedPhotoId: photo.id,
                timestamp: DateTime.now(),
              );
              final newInteractions = [...event.interactions, newInteraction];
              return event.copyWith(
                photos: newPhotos,
                interactions: newInteractions,
              );
            }
            return event;
          }).toList();

      // [수정] copyWith로 상태 업데이트
      state = AsyncValue.data(previousState.copyWith(events: newEvents));
    } catch (e) {
      rethrow;
    }
  }

  // 사진에 피드백을 남기는 메서드
  Future<void> updatePhotoStatus(
    String eventId,
    String photoId,
    PhotoStatus status, {
    MessageCode? messageCode,
  }) async {
    final previousState = state.value; // .valueOrNull 대신 .value 사용
    if (previousState == null) return;

    try {
      final repository = _ref.read(ddipEventRepositoryProvider);
      await repository.updatePhotoStatus(
        eventId,
        photoId,
        status,
        messageCode: messageCode,
      );

      // [수정] previousState.events.map으로 수정
      final newEvents =
          previousState.events.map((event) {
            if (event.id == eventId) {
              final newPhotos =
                  event.photos.map((p) {
                    if (p.id == photoId) {
                      return p.copyWith(status: status);
                    }
                    return p;
                  }).toList();

              DdipEventStatus newEventStatus = event.status;
              if (status == PhotoStatus.approved) {
                newEventStatus = DdipEventStatus.completed;
              } else if (status == PhotoStatus.rejected) {
                final rejectedCount =
                    newPhotos
                        .where((p) => p.status == PhotoStatus.rejected)
                        .length;
                if (rejectedCount >= 3) {
                  newEventStatus = DdipEventStatus.failed;
                }
              }

              final newInteraction = Interaction(
                id: 'feedback_${photoId}',
                actorId: _ref.read(authProvider)!.id,
                actorRole: ActorRole.requester,
                actionType:
                    status == PhotoStatus.approved
                        ? ActionType.approve
                        : ActionType.requestRevision,
                messageCode: messageCode,
                relatedPhotoId: photoId,
                timestamp: DateTime.now(),
              );
              final newInteractions = [...event.interactions, newInteraction];
              return event.copyWith(
                photos: newPhotos,
                status: newEventStatus,
                interactions: newInteractions,
              );
            }
            return event;
          }).toList();

      // [수정] copyWith로 상태 업데이트
      state = AsyncValue.data(previousState.copyWith(events: newEvents));
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
}
