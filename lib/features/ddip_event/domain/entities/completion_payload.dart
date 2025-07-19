// lib/features/ddip_event/domain/entities/completion_payload.dart
import 'package:flutter_naver_map/flutter_naver_map.dart';

// 요청 완료에 필요한 데이터들을 담는 꾸러미 클래스
class CompletionPayload {
  final String imagePath;
  final NLatLng location;

  CompletionPayload({required this.imagePath, required this.location});
}
