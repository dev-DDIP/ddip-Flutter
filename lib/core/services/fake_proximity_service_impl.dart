// lib/core/services/fake_proximity_service_impl.dart

import 'dart:async';

import 'package:ddip/core/services/proximity_service.dart';

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
  Timer? _timer;

  @override
  Stream<DdipNotification> get notificationStream =>
      _notificationController.stream;

  @override
  Future<void> start() async {
    // 30초마다 가짜 알림을 생성하는 타이머를 시작합니다.
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final fakeNotification = DdipNotification(
        title: '[테스트] 근처 요청 발생!',
        body: '10초마다 가짜 요청이 자동으로 발생합니다.',
      );
      // 생성된 가짜 알림을 통로(Stream)에 흘려보냅니다.
      _notificationController.add(fakeNotification);
    });
  }

  @override
  Future<void> stop() async {
    // 서비스가 중지되면 타이머를 취소하고 통로를 닫습니다.
    _timer?.cancel();
    _notificationController.close();
  }
}
