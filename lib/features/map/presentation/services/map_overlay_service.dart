// lib/features/map/presentation/services/map_overlay_service.dart

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/map/presentation/widgets/cluster_marker.dart';
import 'package:ddip/features/map/presentation/widgets/pulsing_marker_icon.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

class MapOverlayService {
  final BuildContext _context;
  final Map<String, NOverlayImage> _imageCache = {};

  MapOverlayService(this._context);

  /// 지도에 표시될 모든 오버레이를 생성하는 메인 함수
  Future<MapState> buildOverlays({
    required NaverMapController mapController,
    required List<DdipEvent> events,
    required double zoom,
    required void Function(String eventId, String photoId) onPhotoMarkerTap,
    required void Function(String eventId) onEventMarkerTap,
    String? selectedEventId,
    Position? myLocation,
  }) async {
    final newMarkers = <String, NMarker>{};

    if (myLocation != null) {
      final myLocationMarker = await _createMyLocationMarker(myLocation);
      newMarkers[myLocationMarker.info.id] = myLocationMarker;
    }

    // ✨ [수정] 줌 레벨 14 이상일 경우 클러스터링을 생략하고 모든 마커를 개별 표시합니다.
    if (zoom >= 15) {
      for (final event in events) {
        final isSelected = event.id == selectedEventId;
        newMarkers[event.id] = await _createEventMarker(
          event,
          onEventMarkerTap,
          isSelected,
        );
      }
    } else {
      // ✨ [수정] 줌 레벨 14 미만일 때만 클러스터링 로직을 실행합니다.
      final groups = _groupEventsByGeoDistance(events, zoom);

      for (final group in groups) {
        if (group.length > 1) {
          final clusterMarker = await _createClusterMarker(
            group,
            mapController,
            zoom,
          );
          newMarkers[clusterMarker.info.id] = clusterMarker;
        } else {
          final event = group.first;
          final isSelected = event.id == selectedEventId;
          newMarkers[event.id] = await _createEventMarker(
            event,
            onEventMarkerTap,
            isSelected,
          );
        }
      }
    }

    return MapState(markers: newMarkers, polylines: const {});
  }

  /// 줌 레벨에 따라 동적인 지리적 거리로 이벤트를 그룹화하는 함수
  List<List<DdipEvent>> _groupEventsByGeoDistance(
    List<DdipEvent> events,
    double zoom,
  ) {
    if (events.isEmpty) return [];

    final double threshold = switch (zoom) {
      // 줌 레벨 12 미만 (캠퍼스 전체 조망): 반경을 넓게 잡아 캠퍼스 전체를 1~2개 그룹으로 묶습니다.
      < 13 => 0.008,

      // 줌 레벨 12~13 (주요 구역 구분): 반경을 줄여 '북문', '센팍' 등 주요 구역별로 묶습니다.
      < 14 => 0.004,

      // 줌 레벨 13~14 (건물 단위 구분): 반경을 더 줄여 매우 인접한 건물끼리만 묶습니다.
      < 15 => 0.0015,

      // buildOverlays 함수에서 zoom >= 14일 때는 이 함수가 호출되지 않습니다.
      _ => 0,
    };

    final List<List<DdipEvent>> clusters = [];
    final Set<String> processedEventIds = {};

    for (final event in events) {
      if (processedEventIds.contains(event.id)) continue;

      final cluster = <DdipEvent>[event];
      processedEventIds.add(event.id);

      for (final otherEvent in events) {
        if (processedEventIds.contains(otherEvent.id)) continue;

        if ((event.latitude - otherEvent.latitude).abs() < threshold &&
            (event.longitude - otherEvent.longitude).abs() < threshold) {
          cluster.add(otherEvent);
          processedEventIds.add(otherEvent.id);
        }
      }
      clusters.add(cluster);
    }
    return clusters;
  }

  /// 클러스터 마커(숫자 뱃지)를 생성하는 함수
  Future<NMarker> _createClusterMarker(
    List<DdipEvent> group,
    NaverMapController controller,
    double currentZoom,
  ) async {
    double avgLat =
        group.map((e) => e.latitude).reduce((a, b) => a + b) / group.length;
    double avgLon =
        group.map((e) => e.longitude).reduce((a, b) => a + b) / group.length;

    final clusterIcon = await NOverlayImage.fromWidget(
      widget: ClusterMarker(count: group.length),
      context: _context,
    );

    final markerId = 'cluster_${group.first.id}';
    final marker = NMarker(
      id: markerId,
      position: NLatLng(avgLat, avgLon),
      icon: clusterIcon,
    );

    marker.setOnTapListener((overlay) {
      controller.updateCamera(
        NCameraUpdate.scrollAndZoomTo(
          target: overlay.position as NLatLng,
          zoom: currentZoom + 2,
        ),
      );
    });

    return marker;
  }

  // --- 헬퍼 함수들 ---

  Future<NMarker> _createEventMarker(
    DdipEvent event,
    void Function(String eventId) onTap,
    bool isSelected,
  ) async {
    final color = isSelected ? Colors.purple : Colors.blue;
    final cacheKey = isSelected ? 'event_marker_selected' : 'event_marker';
    final icon = await _getCachedOverlayImage(
      cacheKey,
      PulsingMarkerIcon(icon: Icons.flag, color: color),
    );
    final marker = NMarker(
      id: event.id,
      position: NLatLng(event.latitude, event.longitude),
      icon: icon,
    );
    marker.setZIndex(isSelected ? 15 : 10);
    marker.setOnTapListener((_) => onTap(event.id));
    return marker;
  }

  Future<NOverlayImage> _getCachedOverlayImage(
    String key,
    Widget widget,
  ) async {
    if (_imageCache.containsKey(key)) return _imageCache[key]!;
    final image = await NOverlayImage.fromWidget(
      widget: widget,
      context: _context,
    );
    _imageCache[key] = image;
    return image;
  }

  Future<NMarker> _createMyLocationMarker(Position position) async {
    final icon = await _getCachedOverlayImage(
      'my_location',
      const PulsingMarkerIcon(icon: Icons.my_location, color: Colors.purple),
    );
    final marker = NMarker(
      id: 'my_location',
      position: NLatLng(position.latitude, position.longitude),
      icon: icon,
    );
    marker.setZIndex(0);
    return marker;
  }
}
