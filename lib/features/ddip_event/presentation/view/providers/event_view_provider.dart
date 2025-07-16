import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/ddip_event.dart';
import '../../../domain/usecases/get_ddip_event_by_id.dart';

// 상세 화면의 상태(로딩, 데이터, 에러)를 관리하는 Notifier
class EventViewNotifier extends AutoDisposeFamilyAsyncNotifier<DdipEvent, String> {
  @override
  FutureOr<DdipEvent> build(String eventId) async {
    // 이 provider가 처음 호출될 때, 유스케이스를 통해 데이터를 가져옵니다.
    // AutoDisposeFamilyAsyncNotifier를 사용하면 eventId를 파라미터로 받을 수 있습니다.
    final getDdipEventById = ref.watch(getDdipEventByIdUseCaseProvider);
    return getDdipEventById(eventId);
  }
}

// Notifier를 제공하는 프로바이더
final eventViewProvider =
AsyncNotifierProvider.autoDispose.family<EventViewNotifier, DdipEvent, String>(
      () => EventViewNotifier(),
);
