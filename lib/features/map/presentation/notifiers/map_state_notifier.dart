import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MapStateNotifier extends StateNotifier<MapStateForViewModel> {
  MapStateNotifier() : super(const MapStateForViewModel());

  void drillDownToCluster(List<DdipEvent> eventsInCluster) {
    final bounds = NLatLngBounds.from(
      eventsInCluster.map((e) => NLatLng(e.latitude, e.longitude)),
    );
    state = MapStateForViewModel(cameraTargetBounds: bounds);
  }

  void completeCameraMove() {
    state = const MapStateForViewModel(cameraTargetBounds: null);
  }
}
