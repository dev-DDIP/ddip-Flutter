// lib/features/weather/data/repositories/weather_repository_impl.dart

import 'package:ddip/features/weather/domain/repositories/weather_repository.dart';
import 'package:dio/dio.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final Dio dio;
  final String apiKey;

  WeatherRepositoryImpl({required this.dio, required this.apiKey});

  @override
  Future<WeatherData> getCurrentWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': apiKey,
          'units': 'metric',
          'lang': 'kr',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        // API 응답에서 필요한 정보를 추출하여 WeatherData 객체로 반환
        return WeatherData(
          main: response.data['weather'][0]['main'] as String,
          // JSON 숫자는 int일 수도 있으므로 num으로 받은 후 double로 변환하는 것이 안전합니다.
          temp: (response.data['main']['temp'] as num).toDouble(),
          locationName: response.data['name'] as String,
        );
      } else {
        throw Exception('날씨 정보를 가져오는데 실패했습니다.');
      }
    } catch (e) {
      print('날씨 API 호출 오류: $e');
      rethrow;
    }
  }
}
