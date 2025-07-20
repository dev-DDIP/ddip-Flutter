// lib/core/providers/core_providers.dart

// 우리가 만든 알림 서비스 클래스를 가져옵니다.
import 'package:ddip/core/services/notification_service.dart';
// 알림 서비스가 필요로 하는 '띱 이벤트 저장소' 프로바이더를 가져옵니다.
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
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

/// NotificationService를 생성하고 관리하는 Riverpod Provider입니다.
///
/// 이 프로바이더의 역할은 앱 전체에서 단 하나의 NotificationService 인스턴스만 존재하도록 보장하고,
/// 필요할 때 이 인스턴스를 쉽게 가져다 쓸 수 있는 '창구' 역할을 합니다.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  // 1. NotificationService를 만들려면 'DdipEventRepository'라는 부품이 필요합니다.
  //    ref.watch를 사용해 다른 프로바이더(ddipEventRepositoryProvider)로부터
  //    그 부품을 먼저 가져옵니다.
  final repository = ref.watch(ddipEventRepositoryProvider);

  // 2. 가져온 부품을 사용하여 NotificationService를 최종적으로 조립(생성)하고 반환합니다.
  //    이제 앱의 다른 곳에서는 이 notificationServiceProvider를 통해
  //    잘 조립된 NotificationService를 언제든지 사용할 수 있습니다.
  return NotificationService(ddipEventRepository: repository);
});
