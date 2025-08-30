// lib/features/weather/providers/weather_providers.dart

import 'package:ddip/core/providers/core_providers.dart';
import 'package:ddip/features/weather/data/repositories/weather_repository_impl.dart';
import 'package:ddip/features/weather/domain/repositories/weather_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// WeatherRepository의 구현체를 제공하는 프로바이더입니다.
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  // 1. 네트워크 통신을 위한 Dio 인스턴스를 가져옵니다.
  final dio = ref.watch(dioProvider);
  // 2. .env 파일에서 API 키를 읽어옵니다.
  final apiKey = dotenv.env['OPENWEATHER_API_KEY'];

  if (apiKey == null || apiKey.isEmpty) {
    throw Exception('.env 파일에 OPENWEATHER_API_KEY가 설정되지 않았습니다.');
  }

  // 3. Dio와 API 키를 WeatherRepositoryImpl에 주입하여 인스턴스를 생성합니다.
  return WeatherRepositoryImpl(dio: dio, apiKey: apiKey);
});
