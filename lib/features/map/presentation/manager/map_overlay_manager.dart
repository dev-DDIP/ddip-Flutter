// lib/features/map/presentation/manager/map_overlay_manager.dart -----
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/map/presentation/widgets/marker_factory.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 지도 위에 올라가는 모든 오버레이(마커, 클러스터 등)를 관리하는 책임을 가지는 클래스입니다.
/// NaverMapController를 직접 제어하며, UI 위젯으로부터 오버레이 관리 로직을 분리합니다.
class MapOverlayManager {
  final NaverMapController _mapController;
  final WidgetRef _ref;
  final MarkerFactory _markerFactory;

  // 관리 중인 마커의 상태를 내부적으로 추적합니다.
  final Map<String, NClusterableMarker> _currentEventMarkers = {};
  final Set<NMarker> _photoMarkers = {};

  MapOverlayManager({
    required NaverMapController mapController,
    required WidgetRef ref,
    required MarkerFactory markerFactory,
  }) : _mapController = mapController,
       _ref = ref,
       _markerFactory = markerFactory;

  // 사라진 마커를 제거하는 로직을 포함하여 완전한 형태로 만듭니다.
  Future<void> updateEventMarkers(List<DdipEvent> events) async {
    final existingEventIds = _currentEventMarkers.keys.toSet();
    final newEventIds = events.map((e) => e.id).toSet();

    final removedIds = existingEventIds.difference(newEventIds);
    for (final id in removedIds) {
      final marker = _currentEventMarkers.remove(id);
      if (marker != null) {
        _mapController.deleteOverlay(marker.info);
      }
    }

    final markersToUpdate = <NClusterableMarker>[];
    for (final event in events) {
      final icon = await _markerFactory.getOrCacheMarkerIcon(
        type: 'event',
        isSelected: _ref.read(selectedEventIdProvider) == event.id,
      );
      final marker = NClusterableMarker(
        id: event.id,
        position: NLatLng(event.latitude, event.longitude),
        icon: icon,
      );
      marker.setZIndex(1);
      marker.setOnTapListener((_) {
        _ref.read(feedSheetStrategyProvider.notifier).showOverview(event.id);
      });
      markersToUpdate.add(marker);
      _currentEventMarkers[event.id] = marker;
    }

    if (markersToUpdate.isNotEmpty) {
      _mapController.addOverlayAll(markersToUpdate.toSet());
    }
  }

  /// 지도에 표시될 사진 마커들을 그리고 업데이트합니다.
  Future<void> drawPhotoMarkers(List<Photo> photos) async {
    // 기존 사진 마커들을 모두 지웁니다.
    for (final marker in _photoMarkers) {
      _mapController.deleteOverlay(marker.info);
    }
    _photoMarkers.clear();

    final newMarkers = await Future.wait(
      photos.map((photo) async {
        final icon = await _markerFactory.getOrCacheMarkerIcon(type: 'photo');
        final marker = NMarker(
          id: 'photo_${photo.id}',
          position: NLatLng(photo.latitude, photo.longitude),
          icon: icon,
        );
        marker.setZIndex(2); // 사진 마커가 이벤트 마커보다 위에 보이도록 zIndex 설정
        return marker;
      }),
    );

    _photoMarkers.addAll(newMarkers);
    if (_photoMarkers.isNotEmpty) {
      _mapController.addOverlayAll(_photoMarkers);
    }
  }

  // 📌 목록에서 이벤트를 선택했을 때 마커 아이콘을 변경하기 위한 메서드
  Future<void> updateMarkerSelection(String? previousId, String? nextId) async {
    final markerFactory = _ref.read(markerFactoryProvider);

    if (previousId != null && _currentEventMarkers.containsKey(previousId)) {
      final marker = _currentEventMarkers[previousId]!;

      marker.setIcon(
        await markerFactory.getOrCacheMarkerIcon(
          type: 'event',
          isSelected: false,
        ),
      );
      marker.setZIndex(1);
    }
    if (nextId != null && _currentEventMarkers.containsKey(nextId)) {
      final marker = _currentEventMarkers[nextId]!;
      marker.setIcon(
        await markerFactory.getOrCacheMarkerIcon(
          type: 'event',
          isSelected: true,
        ),
      );
      marker.setZIndex(10);
    }
  }

  /// 위젯이 dispose될 때 호출하여 관리하던 마커들을 정리합니다.
  void dispose() {
    _currentEventMarkers.clear();
    _photoMarkers.clear();
  }
}
