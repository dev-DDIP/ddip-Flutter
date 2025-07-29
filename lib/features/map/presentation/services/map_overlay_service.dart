// lib/features/map/presentation/services/map_overlay_service.dart

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/map/domain/entities/cluster_or_marker.dart';
import 'package:ddip/features/map/presentation/widgets/cluster_marker.dart';
import 'package:ddip/features/map/presentation/widgets/pulsing_marker_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

class MapOverlayService {
  final BuildContext _context;
  final Map<String, NOverlayImage> _imageCache = {};

  MapOverlayService(this._context);

  /// 지도에 표시될 모든 오버레이를 생성하는 메인 함수
  Future<Map<String, NMarker>> buildOverlays({
    required List<ClusterOrMarker> clustersOrMarkers,
    required void Function(Cluster cluster) onClusterMarkerTap,
    required void Function(String eventId) onEventMarkerTap,
    String? selectedEventId,
  }) async {
    final newMarkers = <String, NMarker>{};

    for (final item in clustersOrMarkers) {
      switch (item) {
        case final Cluster cluster:
          final clusterMarker = await _createClusterMarker(
            cluster,
            () => onClusterMarkerTap(cluster),
          );
          newMarkers[clusterMarker.info.id] = clusterMarker;
          break;
        case final IndividualMarker individualMarker:
          final event = individualMarker.event;
          final isSelected = event.id == selectedEventId;
          final eventMarker = await _createEventMarker(
            event,
            onEventMarkerTap,
            isSelected,
          );
          newMarkers[eventMarker.info.id] = eventMarker;
          break;
      }
    }
    return newMarkers;
  }

  /// 클러스터 마커(숫자 뱃지)를 생성하는 함수
  Future<NMarker> _createClusterMarker(
    Cluster cluster,
    VoidCallback onTap,
  ) async {
    final clusterIcon = await NOverlayImage.fromWidget(
      widget: ClusterMarker(count: cluster.count),
      context: _context,
    );
    final markerId = 'cluster_${cluster.events.first.id}';
    final marker = NMarker(
      id: markerId,
      position: cluster.position,
      icon: clusterIcon,
    );
    marker.setOnTapListener((overlay) => onTap());
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
