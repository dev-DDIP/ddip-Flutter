// lib/core/services/real_proximity_service_impl.dart

import 'dart:async';

import 'package:ddip/core/services/proximity_service.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// /// 'ProximityService' 계약서의 '진짜' 구현체입니다.
// /// 이 클래스는 Fake와 달리, FirebaseMessaging 같은 실제 패키지를 사용하여
// /// OS 및 외부 서비스와 직접 통신합니다.
class RealProximityService implements ProximityService {
  final _notificationController =
      StreamController<DdipNotification>.broadcast();
  final _firebaseMessaging = FirebaseMessaging.instance;

  @override
  Stream<DdipNotification> get notificationStream =>
      _notificationController.stream;

  @override
  Future<void> start() async {
    // 1. FCM 토큰 가져오기 및 서버에 전송
    await _initializeFCMToken();

    // 2. FCM 메시지 수신 리스너 설정
    _setupFCMListeners();
  }

  Future<void> _initializeFCMToken() async {
    // FCM 토큰은 사용자의 기기를 식별하는 고유 주소입니다.
    // 이 토큰이 있어야 서버가 특정 사용자에게 알림을 보낼 수 있습니다.
    final fcmToken = await _firebaseMessaging.getToken();
    print('FCM 토큰: $fcmToken');

    // ▼▼▼ 백엔드 연동 필요 ▼▼▼
    // TODO: 백엔드 구현 후, 이 fcmToken을 서버로 전송하여
    //       현재 로그인한 사용자 정보와 함께 저장하는 API를 호출해야 합니다.
    // await dio.post('/users/fcm-token', data: {'token': fcmToken});
  }

  void _setupFCMListeners() {
    // 3. 앱이 포그라운드(켜져 있는 상태)일 때 알림을 수신하는 리스너
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // 수신한 FCM 메시지를 우리 앱의 DdipNotification 형태로 변환합니다.
        final notification = DdipNotification(
          title: message.notification?.title ?? '새 알림',
          body: message.notification?.body ?? '새로운 내용이 도착했습니다.',
          eventId: message.data['eventId'] as String?,
        );
        // 변환된 알림을 스트림에 추가하여 UI에 전달합니다.
        _notificationController.add(notification);
      }
    });
  }

  @override
  Future<void> stop() async {
    // StreamController를 닫아 리소스를 정리합니다.
    _notificationController.close();
  }

  // '진짜' 서비스에서는 이 메서드가 아무 동작도 하지 않아야 합니다.
  @override
  void simulateEventCreation(DdipEvent event) {
    // No operation needed. Real notifications are triggered by actual FCM messages.
    return;
  }
}
