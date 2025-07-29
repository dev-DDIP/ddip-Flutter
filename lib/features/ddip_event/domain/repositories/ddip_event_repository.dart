// lib/features/ddip_event/domain/repositories/ddip_event_repository.dart

import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/map/domain/entities/cluster_or_marker.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

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

  /// 특정 '띱'에 수행자가 지원하는 기능을 요구합니다.
  Future<void> applyToEvent(String eventId, String userId);

  /// 요청자가 지원자 중 한 명을 최종 수행자로 선택하는 기능을 요구합니다.
  Future<void> selectResponder(String eventId, String responderId);

  /// 선택된 수행자가 '띱'에 사진을 제출하는 기능을 요구합니다.
  Future<void> addPhoto(
    String eventId,
    Photo photo, {
    required ActionType action,
    MessageCode? messageCode,
  });

  /// 요청자가 제출된 사진에 대해 피드백(승인/거절)을 남기는 기능을 요구합니다.
  Future<void> updatePhotoStatus(
    String eventId,
    String photoId,
    PhotoStatus status, {
    MessageCode? messageCode,
  });

  Future<List<ClusterOrMarker>> getClusters(NLatLngBounds bounds, double zoom);
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
