// lib/core/providers/core_providers.dart

// 우리가 만든 알림 서비스 클래스를 가져옵니다.

import 'package:ddip/core/services/proximity_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Dio 인스턴스를 앱 전역에서 사용할 수 있도록 프로바이더를 생성합니다.
// 다른 기능에서도 네트워크 통신이 필요할 때 이 프로바이더를 재사용할 수 있습니다.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      // 실제 운영 서버의 기본 URL을 입력해야 합니다.
      // 지금은 안드로이드 에뮬레이터에서 개발용 PC의 로컬 서버를
      // 가리키는 특수 주소를 사용합니다.
      baseUrl: 'http://10.0.2.2:8080',
    ),
  );
  // 필요하다면 여기에 로깅이나 인증 토큰을 위한 인터셉터를 추가할 수 있습니다.
  // dio.interceptors.add(...);
  return dio;
});

// ▼▼▼ [추가] proximityServiceProvider를 정의합니다. ▼▼▼
// /// 앱의 백그라운드 동작(위치, 알림)을 총괄하는 서비스의 Provider입니다.
// ///
// /// 지금은 '가짜 서비스(FakeProximityService)'를 제공하도록 설정합니다.
// /// 나중에 실제 FCM과 GPS를 사용하는 '진짜 서비스'가 완성되면,
// /// 이 Provider 내부에서 생성하는 클래스만 바꿔주면(Fake -> Real),
// /// 앱의 다른 코드는 전혀 건드리지 않고도 기능을 교체할 수 있습니다.
// /// 이것이 바로 '한 줄만 바꿔서 갈아끼울 수 있도록' 만드는 핵심입니다.
final proximityServiceProvider = Provider<ProximityService>((ref) {
  // 이 Provider는 이제 어떤 ProximityService 구현체를 사용해야 할지 모릅니다.
  // 앱의 시작점인 main.dart에서 반드시 override하여 주입해주어야 합니다.
  throw UnimplementedError('proximityServiceProvider must be overridden');
});
