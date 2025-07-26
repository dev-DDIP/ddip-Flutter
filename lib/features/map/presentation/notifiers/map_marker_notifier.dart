import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

// [수정] Notifier가 이제 UI 프레임워크에 의존하지 않습니다. (BuildContext 없음)
class MapMarkerNotifier extends StateNotifier<AsyncValue<MapState>> {
  final Ref _ref;

  MapMarkerNotifier(this._ref) : super(const AsyncValue.loading());

  // [수정] Notifier의 유일한 public 메서드
  Future<void> updateOverlays({
    required NaverMapController mapController,
    required BuildContext context,
    required List<DdipEvent> events,
    required double zoom,
    required void Function(String eventId, String photoId) onPhotoMarkerTap,
    required void Function(String eventId) onEventMarkerTap,
    String? selectedEventId,
    Position? myLocation,
  }) async {
    state = const AsyncValue.loading();
    try {
      // 1. 컨텍스트를 사용하여 서비스 인스턴스를 가져옵니다.
      final overlayService = _ref.read(mapOverlayServiceProvider(context));

      // 2. 서비스에게 모든 오버레이 생성을 위임합니다.
      final mapState = await overlayService.buildOverlays(
        mapController: mapController,
        events: events,
        zoom: zoom,
        onPhotoMarkerTap: onPhotoMarkerTap,
        onEventMarkerTap: onEventMarkerTap,
        selectedEventId: selectedEventId,
        myLocation: myLocation,
      );

      // 3. 서비스로부터 받은 결과로 상태를 업데이트합니다.
      state = AsyncValue.data(mapState);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
