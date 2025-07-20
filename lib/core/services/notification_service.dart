// lib/core/services/notification_service.dart

import 'dart:async';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

import '../../features/ddip_event/domain/repositories/ddip_event_repository.dart';
import '../../main.dart'; // main.dart에 선언한 알림 플러그인 인스턴스를 가져오기 위함

/// 앱의 백그라운드 작업을 시뮬레이션하는 서비스 클래스입니다.
/// 이 클래스는 앱이 실행되는 동안 주기적으로 '새로운 근처 띱 요청'이 있는지 확인하고
/// 조건에 맞으면 사용자에게 로컬 알림을 보냅니다.
///
/// 실제 제품에서는 이 클래스의 로직 대부분이 '백엔드 서버'로 이전됩니다.
class NotificationService {
  // 생성자를 통해, 외부에서 '데이터 담당관'(Repository)을 주입받습니다.
  // 이렇게 하면 이 서비스는 데이터가 Fake이든, 실제 API 통신이든 신경쓰지 않고
  // 자신의 임무(감시 및 알림)에만 집중할 수 있습니다. (의존성 주입, DI)
  NotificationService({required this.ddipEventRepository});

  final DdipEventRepository ddipEventRepository;
  Timer? _timer; // 주기적인 작업을 수행할 타이머
  final Set<String> _sentNotificationIds = {}; // 이미 알림을 보낸 '띱'의 ID를 저장하는 집합

  /// 서비스를 시작하는 메서드. 앱이 시작될 때 한 번만 호출됩니다.
  void start() {
    // 이미 타이머가 실행 중이라면 중복 실행을 방지합니다.
    if (_timer?.isActive ?? false) return;

    // 15초마다 _checkAndNotify 메서드를 실행하는 타이머를 설정합니다.
    // (테스트를 위해 15초로 설정했으며, 실제 앱에서는 더 긴 주기로 조정할 수 있습니다.)
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkAndNotify();
    });
  }

  /// 서비스의 모든 동작을 중지하고 리소스를 해제하는 메서드.
  void dispose() {
    // 앱이 종료될 때 타이머를 반드시 취소하여 메모리 누수를 방지합니다.
    _timer?.cancel();
  }

  /// 실제 '감시 및 알림' 로직이 들어있는 핵심 메서드
  Future<void> _checkAndNotify() async {
    print('[NotificationService] 주변 요청을 확인합니다...');

    try {
      // 1. 현재 내 위치를 가져옵니다. (geolocator 사용)
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final myLatitude = position.latitude;
      final myLongitude = position.longitude;

      // 2. Repository를 통해 모든 '띱' 이벤트 목록을 가져옵니다.
      final events = await ddipEventRepository.getDdipEvents();

      // 3. 각 이벤트를 순회하며 조건을 확인합니다.
      for (final event in events) {
        // 4. 이벤트와 내 위치 사이의 거리를 계산합니다.
        final distance = _calculateDistance(
          myLatitude,
          myLongitude,
          event.latitude,
          event.longitude,
        );

        // 5. [핵심 조건] 거리가 300m 이내이고, 아직 알림을 보낸 적이 없는 'open' 상태의 요청이라면
        if (distance <= 300 &&
            event.status == 'open' &&
            !_sentNotificationIds.contains(event.id)) {
          print('[NotificationService] 근처 요청 발견! 알림을 보냅니다: ${event.title}');
          // 6. 로컬 알림을 사용자에게 보여줍니다.
          await _showLocalNotification(
            event.title,
            '${distance.toStringAsFixed(0)}m 근처에서 새로운 요청이 도착했어요!',
          );

          // 7. 알림을 보냈다고 기록하여, 다음 확인 시에 중복으로 보내지 않도록 합니다.
          _sentNotificationIds.add(event.id);
        }
      }
    } catch (e) {
      // 위치 정보 가져오기 실패 등 에러 발생 시 콘솔에 로그를 남깁니다.
      print('[NotificationService] 오류 발생: $e');
    }
  }

  /// 두 지점 간의 거리를 미터(m) 단위로 계산하는 헬퍼 메서드
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const R = 6371e3; // 지구 반지름 (미터)
    final phi1 = lat1 * pi / 180;
    final phi2 = lat2 * pi / 180;
    final deltaPhi = (lat2 - lat1) * pi / 180;
    final deltaLambda = (lon2 - lon1) * pi / 180;

    final a =
        sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c;
  }

  /// 로컬 알림을 실제로 생성하고 띄우는 헬퍼 메서드
  Future<void> _showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'ddip_nearby_channel', // 채널 ID (앱 내에서 유일해야 함)
          '주변 요청 알림', // 사용자에게 보여질 채널 이름
          channelDescription: '근처에 새로운 띱 요청이 있을 때 사용하는 알림 채널입니다.',
          importance: Importance.max, // 알림 중요도 (최대)
          priority: Priority.high, // 알림 우선순위 (높음)
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    // main.dart에서 만든 플러그인 인스턴스를 사용하여 알림을 표시합니다.
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000), // 알림 ID (고유하게)
      title, // 알림 제목
      body, // 알림 본문
      platformDetails,
    );
  }
}
