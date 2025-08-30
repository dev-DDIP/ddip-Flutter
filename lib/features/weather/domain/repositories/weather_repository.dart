// lib/features/weather/domain/repositories/weather_repository.dart

/// API로부터 받은 날씨 정보를 담을 간단한 데이터 클래스
class WeatherData {
  final String main; // 날씨 상태 (e.g., "Clear", "Rain")
  final double temp; // 현재 온도
  final String locationName; // 지역 이름 (e.g., "Jung-gu")

  WeatherData({
    required this.main,
    required this.temp,
    required this.locationName,
  });
}

/// 날씨 데이터 소스에 대한 계약(추상 클래스)입니다.
abstract class WeatherRepository {
  /// 주어진 위도와 경도를 기반으로 현재 날씨 정보를 가져옵니다.
  Future<WeatherData> getCurrentWeather(double latitude, double longitude);
}
