// lib/core/services/fake_proximity_service_impl.dart

import 'dart:async';

import 'package:ddip/core/services/proximity_service.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';

// /// '계약서(ProximityService)'를 실제로 구현하는 '가짜 담당자'입니다.
// /// 이름처럼, 이 클래스는 실제 FCM이나 GPS를 전혀 사용하지 않습니다.
// ///
// /// 대신, Timer를 사용해서 주기적으로 '가짜 알림'을 만들어냅니다.
// ///
// /// **[핵심 이점]**
// /// UI 개발자는 이제 FCM 서버가 준비될 때까지 기다릴 필요도,
// /// 위치 권한을 허용하기 위해 직접 밖을 걸어 다닐 필요도 없습니다.
// /// 그냥 이 FakeProximityService를 실행시키기만 하면,
// /// "주변 요청이 도착했습니다!"라는 알림이 오는 상황을
// /// 컴퓨터 앞에서 얼마든지 테스트하고 UI를 개발할 수 있습니다.

class FakeProximityService implements ProximityService {
  // UI에게 알림을 전달할 통로(StreamController)를 만듭니다.
  final _notificationController = StreamController<DdipNotification>();

  @override
  Stream<DdipNotification> get notificationStream =>
      _notificationController.stream;

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {
    _notificationController.close();
  }

  // '가짜' 서비스에서는 이 메서드가 호출되면 실제로 알림을 스트림에 추가합니다.
  @override
  void simulateEventCreation(DdipEvent event) {
    // 5초 뒤에 실행되도록 '예약'만 하고, 이 함수는 바로 다음 줄로 넘어감
    Future.delayed(const Duration(seconds: 3), () {
      final fakeNotification = DdipNotification(
        title: '[가상 알림] "${event.title}" 요청 발생!',
        body: "${event.reward}원 보상의 새로운 요청이 근처에서 등록되었습니다.",
        eventId: event.id,
      );
      _notificationController.add(fakeNotification);
    });
  }
}
