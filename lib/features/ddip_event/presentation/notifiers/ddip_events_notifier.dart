// lib/features/ddip_event/presentation/notifiers/ddip_events_notifier.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DdipEventsNotifier extends StateNotifier<AsyncValue<List<DdipEvent>>> {
  final Ref _ref;

  DdipEventsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadEvents();
  }

  // 저장소에서 모든 이벤트 목록(원본 데이터)을 가져와 상태를 초기화합니다.
  Future<void> loadEvents() async {
    state = const AsyncValue.loading();
    try {
      final repository = _ref.read(ddipEventRepositoryProvider);
      final events = await repository.getDdipEvents();
      state = AsyncValue.data(events);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  // '띱'에 지원하는 메서드
  Future<void> applyToEvent(String eventId) async {
    final currentUser = _ref.read(authProvider);
    if (currentUser == null) throw Exception("로그인이 필요합니다.");

    // state.valueOrNull를 사용해 현재 로드된 데이터 목록을 가져옵니다.
    final previousState = state.valueOrNull;
    if (previousState == null) return; // 데이터가 아직 로드되지 않았으면 아무것도 하지 않음

    try {
      // 1. API 호출은 그대로 진행
      final repository = _ref.read(ddipEventRepositoryProvider);
      await repository.applyToEvent(eventId, currentUser.id);

      // 2. API 성공 시, 메모리에서 상태를 직접 업데이트 (loadEvents() 대체)
      final newEvents =
          previousState.map((event) {
            // 목록에서 변경이 필요한 이벤트를 찾음
            if (event.id == eventId) {
              // 불변성을 유지하며 지원자 목록이 갱신된 새로운 이벤트 객체를 생성
              return event.copyWith(
                applicants: [...event.applicants, currentUser.id],
              );
            }
            return event;
          }).toList();

      // 3. 새로 만들어진 목록으로 상태를 갱신
      state = AsyncValue.data(newEvents);
    } catch (e) {
      // 에러가 발생하면 UI를 롤백할 수도 있지만, 지금은 에러를 던지기만 합니다.
      rethrow;
    }
  }

  // 수행자를 선택하는 메서드
  Future<void> selectResponder(String eventId, String responderId) async {
    final previousState = state.valueOrNull;
    if (previousState == null) return;

    try {
      // 1. API 호출은 그대로 진행
      final repository = _ref.read(ddipEventRepositoryProvider);
      await repository.selectResponder(eventId, responderId);

      // 2. API 성공 시, 메모리에서 상태를 직접 업데이트
      final newEvents =
          previousState.map((event) {
            if (event.id == eventId) {
              // 상태(status)와 선택된 수행자 ID(selectedResponderId)를 업데이트
              return event.copyWith(
                status: DdipEventStatus.in_progress,
                selectedResponderId: responderId,
              );
            }
            return event;
          }).toList();

      // 3. 새로 만들어진 목록으로 상태를 갱신
      state = AsyncValue.data(newEvents);
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
    final previousState = state.valueOrNull;
    if (previousState == null) return;

    try {
      final repository = _ref.read(ddipEventRepositoryProvider);
      await repository.addPhoto(
        eventId,
        photo,
        action: action,
        messageCode: messageCode,
      );

      final newEvents =
          previousState.map((event) {
            if (event.id == eventId) {
              // 새로운 사진을 photos 리스트에 추가
              final newPhotos = [...event.photos, photo];

              // 새로운 상호작용 로그도 interactions 리스트에 추가
              final newInteraction = Interaction(
                id: photo.id, // 임시로 사진 ID를 사용
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
      state = AsyncValue.data(newEvents);
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
    final previousState = state.valueOrNull;
    if (previousState == null) return;

    try {
      final repository = _ref.read(ddipEventRepositoryProvider);
      await repository.updatePhotoStatus(
        eventId,
        photoId,
        status,
        messageCode: messageCode,
      );

      final newEvents =
          previousState.map((event) {
            if (event.id == eventId) {
              // 1. 사진 상태 업데이트
              final newPhotos =
                  event.photos.map((p) {
                    if (p.id == photoId) {
                      return p.copyWith(status: status);
                    }
                    return p;
                  }).toList();

              // 2. 이벤트 전체 상태 결정
              DdipEventStatus newEventStatus = event.status;
              if (status == PhotoStatus.approved) {
                newEventStatus = DdipEventStatus.completed;
              } else if (status == PhotoStatus.rejected) {
                // 거절된 사진이 3개 이상이면 실패 처리 (Fake Repo 로직 참고)
                final rejectedCount =
                    newPhotos
                        .where((p) => p.status == PhotoStatus.rejected)
                        .length;
                if (rejectedCount >= 3) {
                  newEventStatus = DdipEventStatus.failed;
                }
              }

              // 3. 상호작용 로그 추가
              final newInteraction = Interaction(
                id: 'feedback_${photoId}', // 임시 ID
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
      state = AsyncValue.data(newEvents);
    } catch (e) {
      rethrow;
    }
  }
}
