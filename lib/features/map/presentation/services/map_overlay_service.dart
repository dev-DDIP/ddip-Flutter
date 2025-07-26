import 'dart:math';

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/map/presentation/widgets/declutter_marker.dart';
import 'package:ddip/features/map/presentation/widgets/pulsing_marker_icon.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

// [신규] UI 렌더링/배치 로직을 전담하는 서비스 클래스
class MapOverlayService {
  final BuildContext _context;
  final Map<String, NOverlayImage> _imageCache = {};

  MapOverlayService(this._context);

  /// 주어진 데이터를 바탕으로 지도에 표시할 모든 오버레이(마커, 폴리라인)를 계산하여 반환합니다.
  Future<MapState> buildOverlays({
    required List<DdipEvent> events,
    required double zoom,
    required void Function(String eventId, String photoId) onPhotoMarkerTap,
    Position? myLocation,
  }) async {
    final newMarkers = <String, NMarker>{};
    final newPolylines = <String, NPolylineOverlay>{};

    // 1. 내 위치 마커 추가 (전달받은 위치 사용)
    if (myLocation != null) {
      final myLocationMarker = await _createMyLocationMarker(myLocation);
      newMarkers[myLocationMarker.info.id] = myLocationMarker;
    }

    // 2. 줌 레벨에 따라 마커 분산(Declutter) 또는 일반 마커 생성
    const double declutterZoomThreshold = 16.0;
    if (zoom < declutterZoomThreshold) {
      // 줌 레벨이 낮을 때: 일반 마커 생성
      for (final event in events) {
        final eventMarker = await _createEventMarker(event);
        newMarkers[eventMarker.info.id] = eventMarker;

        for (final photo in event.photos) {
          final photoMarker = await _createPhotoMarker(
            event.id,
            photo,
            onPhotoMarkerTap,
          );
          newMarkers[photoMarker.info.id] = photoMarker;
        }
      }
    } else {
      // 줌 레벨이 높을 때: 마커 분산(Spiderfication) 로직 실행
      final decluttered = await _declutterMarkers(events);
      newMarkers.addAll(decluttered.markers);
      newPolylines.addAll(decluttered.polylines);
    }

    return MapState(markers: newMarkers, polylines: newPolylines);
  }

  // ▼▼▼ 아래는 기존 Notifier에 있던 로직을 그대로 옮겨온 것입니다 ▼▼▼

  Future<MapState> _declutterMarkers(List<DdipEvent> events) async {
    // ... (기존 _declutterMarkers 로직 전체를 여기에 복사)
    final newMarkers = <String, NMarker>{};
    final newPolylines = <String, NPolylineOverlay>{};
    final groups = _groupOverlappingEvents(events);

    for (final group in groups) {
      if (group.length == 1) {
        final event = group.first;
        newMarkers[event.id] = await _createEventMarker(event);
      } else {
        final centerPosition = NLatLng(
          group.first.latitude,
          group.first.longitude,
        );
        final centerDot = NMarker(
          id: 'center_${group.first.id}',
          position: centerPosition,
          icon: await _getCachedOverlayImage(
            'center_dot',
            Icon(Icons.circle, size: 10, color: Colors.black),
          ),
        );
        newMarkers[centerDot.info.id] = centerDot;
        final offsetPositions = _calculateCircularOffsets(
          centerPosition,
          group.length,
        );
        for (int i = 0; i < group.length; i++) {
          final event = group[i];
          final offsetPos = offsetPositions[i];
          final markerWidget = DeclutterMarker(
            icon: Icons.flag,
            color: Colors.blue,
            offset: Offset.zero,
          );
          final markerIcon = await NOverlayImage.fromWidget(
            widget: markerWidget,
            context: _context,
          );
          newMarkers[event.id] = NMarker(
            id: event.id,
            position: offsetPos,
            icon: markerIcon,
          );
          final intermediatePoint = NLatLng(
            centerPosition.latitude +
                (offsetPos.latitude - centerPosition.latitude) / 2,
            offsetPos.longitude,
          );
          final polyline = NPolylineOverlay(
            id: 'line_${event.id}',
            coords: [centerPosition, intermediatePoint, offsetPos],
            color: Colors.black54,
            width: 1,
          );
          newPolylines[polyline.info.id] = polyline;
        }
      }
    }
    return MapState(markers: newMarkers, polylines: newPolylines);
  }

  List<List<DdipEvent>> _groupOverlappingEvents(List<DdipEvent> events) {
    // ... (기존 _groupOverlappingEvents 로직 전체를 여기에 복사)
    final List<List<DdipEvent>> groups = [];
    final Set<String> processedIds = {};
    for (final event in events) {
      if (processedIds.contains(event.id)) continue;
      final group =
          events
              .where(
                (other) =>
                    !processedIds.contains(other.id) &&
                    (event.latitude - other.latitude).abs() < 0.0001 &&
                    (event.longitude - other.longitude).abs() < 0.0001,
              )
              .toList();
      groups.add(group);
      processedIds.addAll(group.map((e) => e.id));
    }
    return groups;
  }

  List<NLatLng> _calculateCircularOffsets(NLatLng center, int count) {
    // ... (기존 _calculateCircularOffsets 로직 전체를 여기에 복사)
    final List<NLatLng> positions = [];
    const double radius = 0.0005;
    final double angleStep = (2 * 3.14159) / count;
    for (int i = 0; i < count; i++) {
      final double angle = i * angleStep;
      positions.add(
        NLatLng(
          center.latitude + radius * 1.5 * sin(angle),
          center.longitude + radius * cos(angle),
        ),
      );
    }
    return positions;
  }

  Future<NOverlayImage> _getCachedOverlayImage(
    String key,
    Widget widget,
  ) async {
    // ... (기존 _getCachedOverlayImage 로직 전체를 여기에 복사)
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

  Future<NMarker> _createEventMarker(DdipEvent event) async {
    final icon = await _getCachedOverlayImage(
      'event_marker',
      const PulsingMarkerIcon(icon: Icons.flag, color: Colors.blue),
    );

    final marker = NMarker(
      id: event.id,
      position: NLatLng(event.latitude, event.longitude),
      icon: icon,
    );

    marker.setZIndex(10);
    return marker;
  }

  Future<NMarker> _createPhotoMarker(
    String eventId,
    Photo photo,
    void Function(String, String) onTap, {
    bool isLoading = false,
  }) async {
    IconData iconData;
    Color color;
    String cacheKey;
    switch (photo.status) {
      case PhotoStatus.approved:
        iconData = Icons.check_circle;
        color = Colors.green;
        cacheKey = 'photo_approved';
        break;
      case PhotoStatus.rejected:
        iconData = Icons.cancel;
        color = Colors.red;
        cacheKey = 'photo_rejected';
        break;
      default:
        iconData = Icons.photo_camera;
        color = Colors.orange;
        cacheKey = 'photo_pending';
        break;
    }
    if (isLoading) {
      cacheKey = '${cacheKey}_loading';
    }
    final iconWidget = PulsingMarkerIcon(
      icon: iconData,
      color: color,
      isLoading: isLoading,
    );
    final icon = await _getCachedOverlayImage(cacheKey, iconWidget);
    final marker = NMarker(
      id: photo.id,
      position: NLatLng(photo.latitude, photo.longitude),
      icon: icon,
    );
    marker.setZIndex(20);
    marker.setOnTapListener((_) => onTap(eventId, photo.id));
    return marker;
  }
}
