import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MapStateNotifier extends StateNotifier<MapState> {
  MapStateNotifier() : super(const MapState());

  // [핵심 수정] 클러스터를 탭하면, 마커를 직접 조작하는 대신 카메라를 이동시킬 '목표 영역'만 상태에 기록합니다.
  void drillDownToCluster(List<DdipEvent> eventsInCluster) {
    final bounds = NLatLngBounds.from(
      eventsInCluster.map((e) => NLatLng(e.latitude, e.longitude)),
    );
    state = MapState(cameraTargetBounds: bounds);
  }

  // [핵심 수정] 카메라 이동이 끝나면, 목표 영역을 null로 초기화하여 불필요한 재실행을 방지합니다.
  void completeCameraMove() {
    state = const MapState(cameraTargetBounds: null);
  }
}
