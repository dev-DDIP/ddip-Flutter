// ▼▼▼ 신규 파일 전체 코드 ▼▼▼
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

// UI에 표시될 것이 클러스터인지, 개별 마커인지를 나타내는 공통 타입
sealed class ClusterOrMarker {
  final NLatLng position;

  ClusterOrMarker({required this.position});
}

// 여러 이벤트를 포함하는 클러스터
class Cluster extends ClusterOrMarker {
  final int count;
  final List<DdipEvent> events;

  Cluster({required super.position, required this.count, required this.events});
}

// 단일 이벤트를 나타내는 개별 마커
class IndividualMarker extends ClusterOrMarker {
  final DdipEvent event;

  IndividualMarker({required super.position, required this.event});
}

// ▲▲▲ 신규 파일 전체 코드 ▲▲▲
