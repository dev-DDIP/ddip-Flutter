// lib/core/services/proximity_service.dart

// /// 이 파일은 FCM, 활동 감지, 위치 보고 등 눈에 보이지 않는 모든
// /// 백그라운드 서비스에 대한 '통합 계약서'입니다.
// ///
// /// UI(화면)는 실제 geolocator나 firebase_messaging 같은 복잡한 패키지를
// /// 직접 다루는 대신, 이 간단한 계약서에만 의존하게 됩니다.
// ///
// /// 예를 들어, UI는 그냥 start()를 호출하면 백그라운드 서비스가 시작되고,
// /// notificationStream을 듣고 있으면 새로운 알림이 온다는 것만 알면 됩니다.
// /// 실제 구현이 어떻게 되어있는지는 전혀 신경 쓸 필요가 없어지죠.
// /// 이것이 Repository에서 성공적으로 경험했던 '추상화'입니다.

// 앱 전체에서 사용할 알림 데이터의 형태를 미리 정의합니다.
// 지금은 간단하게 제목과 내용만 담겠습니다.
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';

class DdipNotification {
  final String title;
  final String body;
  final String? eventId;

  DdipNotification({
    required this.title,
    required this.body,
    required this.eventId,
  });
}

abstract class ProximityService {
  // 백그라운드에서 지능형 위치 보고 및 알림 수신을 시작하라는 명령
  Future<void> start();

  // 모든 백그라운드 동작을 중지하라는 명령
  Future<void> stop();

  // 새로운 '띱' 알림이 도착했을 때 UI에게 알려주기 위한 통로(Stream)
  // UI는 이 Stream을 듣고 있다가, 새로운 데이터가 들어오면 화면을 갱신합니다.
  Stream<DdipNotification> get notificationStream;

  // 테스트 목적으로 '띱' 생성을 시뮬레이션하는 메서드를 인터페이스에 추가
  void simulateEventCreation(DdipEvent event);
}
