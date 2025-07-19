import 'dart:async';

import 'package:ddip/features/ddip_event/domain/usecases/accept_ddip_event.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/ddip_event.dart';

// AcceptDdipEvent UseCase를 앱의 다른 곳에서 쓸 수 있도록 제공(Provide)합니다.
// Notifier가 이 Provider를 읽어서 UseCase를 사용할 수 있게 됩니다.
// (ddipEventRepositoryProvider는 다른 파일에 이미 만들어져 있으므로 재활용합니다.)
final acceptDdipEventUseCaseProvider = Provider<AcceptDdipEvent>((ref) {
  final repository = ref.watch(ddipEventRepositoryProvider);
  return AcceptDdipEvent(repository: repository);
});

// 상세 화면의 상태(로딩, 데이터, 에러)를 관리하는 Notifier
class EventViewNotifier extends AutoDisposeFamilyAsyncNotifier<DdipEvent, String> {
  @override
  FutureOr<DdipEvent> build(String eventId) async {
    // 이 provider가 처음 호출될 때, 유스케이스를 통해 데이터를 가져옵니다.
    // AutoDisposeFamilyAsyncNotifier를 사용하면 eventId를 파라미터로 받을 수 있습니다.
    final getDdipEventById = ref.watch(getDdipEventByIdUseCaseProvider);
    return getDdipEventById(eventId);
  }

  /// UI로부터 '요청 수락' 신호를 받아 처리하는 메서드
  Future<void> acceptEvent() async {
    // 1. 상태를 로딩 중으로 변경합니다.
    state = const AsyncValue.loading();

    // 2. state를 직접 업데이트하므로, guard를 사용해 안전하게 비동기 코드를 실행합니다.
    //    guard는 try-catch를 자동으로 처리해주고, 성공/실패에 따라 state를
    //    AsyncData 또는 AsyncError로 자동 변경해줍니다.
    state = await AsyncValue.guard(() async {
      // 3. UseCase를 읽어와 실행합니다.
      final useCase = ref.read(acceptDdipEventUseCaseProvider);
      await useCase(arg, 'fake_responder_id_123');

      // 4. [중요] 데이터가 변경되었으므로, 변경된 최신 데이터를 다시 가져와서 반환합니다.
      //    여기서 반환된 값이 새로운 AsyncData의 값이 됩니다.
      return ref.read(getDdipEventByIdUseCaseProvider)(arg);
    });
  }

  /// UI로부터 '요청 완료' 신호를 받아 처리하는 메서드
  Future<void> completeEvent() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // CompleteDdipEvent UseCase를 읽어와 실행합니다.
      final useCase = ref.read(completeDdipEventUseCaseProvider);
      await useCase(arg);

      // 데이터가 변경되었으므로, 최신 데이터를 다시 가져와 반환합니다.
      return ref.read(getDdipEventByIdUseCaseProvider)(arg);
    });
  }
}

// Notifier를 제공하는 프로바이더
final eventViewProvider =
AsyncNotifierProvider.autoDispose.family<EventViewNotifier, DdipEvent, String>(
      () => EventViewNotifier(),
);
