// lib/core/providers/core_providers.dart

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
