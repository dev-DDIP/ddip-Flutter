// lib/features/ddip_event/domain/usecases/complete_ddip_event.dart

import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';

/// '요청 완료'라는 단일 비즈니스 로직을 캡슐화하는 UseCase 클래스입니다.
class CompleteDdipEvent {
  final DdipEventRepository repository;

  // 생성자를 통해 외부에서 데이터 담당관(Repository)을 주입받습니다.
  CompleteDdipEvent({required this.repository});

  /// UseCase를 함수처럼 호출할 수 있게 해주는 'call' 메서드입니다.
  Future<void> call(String eventId) async {
    // 실제 작업은 데이터 담당관(Repository)에게 그대로 위임합니다.
    return await repository.completeDdipEvent(eventId);
  }
}
