// lib/features/ddip_creation/domain/usecases/create_ddip_event.dart

import 'package:ddip/features/ddip_creation/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_creation/domain/repositories/ddip_creation_repository.dart';

class CreateDdipEvent {
  // UseCase는 실제 구현체(Impl)가 아닌, 추상적인 계약서(Repository)에만 의존합니다.
  final DdipCreationRepository repository;

  CreateDdipEvent({required this.repository});

  // UseCase는 보통 'call'이라는 이름의 단일 함수를 가집니다.
  // 이를 통해 클래스 인스턴스를 함수처럼 호출할 수 있습니다.
  Future<void> call(DdipEvent event) async {
    // UseCase는 Repository에 실제 작업을 위임합니다.
    // 만약 '띱을 생성하기 전에 사용자의 포인트를 확인해야 한다'와 같은
    // 복잡한 비즈니스 로직이 있다면 바로 이곳에서 처리됩니다.
    // 지금은 단순히 생성 요청만 전달합니다.
    return await repository.createDdipEvent(event);
  }
}