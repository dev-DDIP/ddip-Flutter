// lib/features/ddip_event/domain/repositories/ddip_event_repository.dart

import '../entities/ddip_event.dart';

// '띱 생성' 기능이 데이터 계층에 요구하는 기능 목록입니다.
// 지금은 '띱 생성' 기능 하나만 필요합니다.
abstract class DdipEventRepository {
  // '띱' 이벤트를 생성하는 기능을 요구합니다.
  // 성공 또는 실패에 대한 결과를 반환해야 합니다.
  // (지금은 간단하게 Future<void>로 정의하고, 나중에 에러 처리를 추가하겠습니다.)
  Future<void> createDdipEvent(DdipEvent event);

  // '띱 목록'을 가져오는 기능을 요구합니다.
  Future<List<DdipEvent>> getDdipEvents();

  // ID로 특정 '띱'을 가져오는 기능을 요구합니다.
  Future<DdipEvent> getDdipEventById(String id);

  // '띱' 요청을 수락하는 기능을 요구합니다.
  /// - eventId: 어떤 요청을 수락할지 식별하는 ID
  /// - responderId: 누가 요청을 수락했는지 식별하는 ID (수락자)
  Future<void> acceptDdipEvent(String eventId, String responderId);

  ///'띱' 요청을 완료하는 기능을 요구합니다.
  /// - eventId: 어떤 요청을 완료할지 식별하는 ID
  /// - 나중에 사진 기능을 추가할 때, 이 메서드에 이미지 파일 관련 파라미터가 추가될 예정입니다.
  Future<void> completeDdipEvent(
    String eventId,
    String imagePath,
    double latitude,
    double longitude,
  );
}

/*
## 레포지토리(Repository)의 진짜 의미: '데이터 저장소'가 아닌 '데이터 담당관'
클린 아키텍처에서 레포지토리의 역할은 **"데이터가 어디에서 오는지 숨기는 것"**입니다.

앱의 핵심 로직(Domain) 입장에서는 데이터가 필요한 상황에 레포지토리에게
 "나 DdipEvent 데이터 좀 줘" 또는 "이 DdipEvent 좀 저장해 줘" 라고 요청만 하면 됩니다.

그러면 레포지토리가 알아서 판단합니다.

'A' 데이터는 서버 API에서 가져오고,
'B' 데이터는 스마트폰 내부 데이터베이스에서 가져오고,
'C' 데이터는 캐시된 메모리에서 가져오는 등...

이 모든 과정을 레포지토리가 총괄하며, 앱의 핵심 로직은 이 복잡한 과정을 전혀 알 필요가 없게 됩니다.
레포지토리가 모든 데이터 관련 업무를 처리하는 유일한 창구, 즉 '데이터 담당관' 역할을 하는 것입니다.
 */
