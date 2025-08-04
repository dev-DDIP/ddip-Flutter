// lib/features/ddip_event/data/datasources/web_socket_data_source.dart

import 'package:ddip/features/ddip_event/data/models/ddip_event_model.dart';

import '../models/interaction_model.dart';

// ----- ▼▼▼ [신규] 웹소켓 통신을 위한 추상 계약서 정의 ▼▼▼ -----
/// 실시간 데이터 통신을 위한 데이터 소스의 추상 클래스(계약서)입니다.
/// 실제 구현체(Fake 또는 Real)는 반드시 이 계약서의 규칙을 따라야 합니다.
abstract class WebSocketDataSource {
  /// 특정 이벤트 ID에 대한 실시간 Interaction 데이터 스트림을 반환합니다.
  /// UI는 이 스트림을 구독하여 실시간 업데이트를 받게 됩니다.
  Stream<InteractionModel> getInteractionStream(String eventId);

  /// 새로 생성되는 DdipEvent를 실시간으로 방송(broadcast)하는 스트림입니다.
  /// 피드 화면에서 이 스트림을 구독하여 새로운 '띱'을 지도와 목록에 즉시 반영합니다.
  Stream<DdipEventModel> getNewDdipEventStream();

  /// 스트림과 관련된 모든 리소스를 정리하고 연결을 닫습니다.
  void close();
}

// ----- ▲▲▲ [신규] 웹소켓 통신을 위한 추상 계약서 정의 ▲▲▲ -----
