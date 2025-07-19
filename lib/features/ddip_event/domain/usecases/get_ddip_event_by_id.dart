import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';

import '../entities/ddip_event.dart';
import '../repositories/ddip_event_repository.dart';

// 유스케이스: ID로 특정 띱 이벤트를 가져오는 단일 책임 클래스
class GetDdipEventById {
  final DdipEventRepository _repository;

  GetDdipEventById(this._repository);

  Future<DdipEvent> call(String id) async {
    // 실제 작업은 레포지토리에 위임합니다.
    return _repository.getDdipEventById(id);
  }
}
