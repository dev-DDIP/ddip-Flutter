import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/map/presentation/notifiers/map_state_notifier.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ========== [DDIP] MODIFIED CODE START ==========
/// 지도의 상태를 나타내는 추상 클래스
sealed class MapState {
  const MapState();
}

/// 전체 마커를 보여주는 기본 상태
class MapStateRoot extends MapState {
  const MapStateRoot();
}

/// 특정 클러스터로 확대(Drill-down)된 상태
class MapStateDrilledDown extends MapState {
  final List<DdipEvent> eventsInCluster;
  final NLatLngBounds bounds;

  MapStateDrilledDown(this.eventsInCluster)
    : bounds = NLatLngBounds.from(
        eventsInCluster.map((e) => NLatLng(e.latitude, e.longitude)),
      );
}
// ========== [DDIP] MODIFIED CODE END ==========

// Notifier Provider는 그대로 유지됩니다.
final mapStateNotifierProvider =
    StateNotifierProvider.autoDispose<MapStateNotifier, AsyncValue<MapState>>((
      ref,
    ) {
      return MapStateNotifier(ref);
    });
