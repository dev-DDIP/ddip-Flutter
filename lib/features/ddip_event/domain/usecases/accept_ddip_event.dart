// lib/features/ddip_event/domain/usecases/accept_ddip_event.dart

import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';

/// '요청 수락'이라는 단일 비즈니스 로직을 캡슐화하는 UseCase 클래스입니다.
/// 이 클래스는 오직 '요청을 수락한다'는 한 가지 임무만 수행합니다.
class AcceptDdipEvent {
  // 실제 구현체(Fake 또는 Impl)가 아닌, 추상적인 계약서(Repository)에만 의존합니다.
  // 이를 통해 Presentation Layer와 Data Layer가 완전히 분리됩니다.
  final DdipEventRepository repository;

  // 생성자를 통해 외부에서 데이터 담당관(Repository)을 주입받습니다.
  AcceptDdipEvent({required this.repository});

  /// UseCase를 함수처럼 호출할 수 있게 해주는 'call' 메서드입니다.
  /// UI(화면)에서 이 UseCase를 실행하면 이 메서드가 호출됩니다.
  Future<void> call(String eventId, String responderId) async {
    // 실제 작업은 데이터 담당관(Repository)에게 그대로 위임합니다.
    // "나는 요청을 수락하는 책임자야. 실제 처리는 네(Repository)가 해." 라는 의미입니다.
    return await repository.acceptDdipEvent(eventId, responderId);
  }
}