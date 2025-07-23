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

  // [신규 로직] '띱'에 지원하는 메서드
  Future<void> applyToEvent(String eventId) async {
    final currentUser = _ref.read(authProvider);
    if (currentUser == null) throw Exception("로그인이 필요합니다.");

    final repository = _ref.read(ddipEventRepositoryProvider);
    await repository.applyToEvent(eventId, currentUser.id);

    // 상태를 즉시 갱신하기 위해 데이터를 다시 로드합니다.
    await loadEvents();
  }

  // [신규 로직] 수행자를 선택하는 메서드
  Future<void> selectResponder(String eventId, String responderId) async {
    final repository = _ref.read(ddipEventRepositoryProvider);
    await repository.selectResponder(eventId, responderId);
    await loadEvents();
  }

  // [신규 로직] 사진을 제출하는 메서드
  Future<void> addPhoto(String eventId, Photo photo) async {
    final repository = _ref.read(ddipEventRepositoryProvider);
    await repository.addPhoto(eventId, photo);
    await loadEvents();
  }

  // [신규 로직] 사진에 피드백을 남기는 메서드
  Future<void> updatePhotoStatus(
    String eventId,
    String photoId,
    PhotoStatus status,
    MessageCode? messageCode,
  ) async {
    final repository = _ref.read(ddipEventRepositoryProvider);
    await repository.updatePhotoStatus(eventId, photoId, status, messageCode);
    await loadEvents();
  }
}
