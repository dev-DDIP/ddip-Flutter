// lib/features/map/presentation/notifiers/map_marker_notifier.dart

import 'dart:math';

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/map/presentation/widgets/declutter_marker.dart';
import 'package:ddip/features/map/presentation/widgets/pulsing_marker_icon.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class MapMarkerNotifier extends StateNotifier<AsyncValue<MapState>> {
  final Ref _ref;
  BuildContext? _context;
  final Map<String, NOverlayImage> _imageCache = {};
  bool _initialBoundsFitted = false;

  MapMarkerNotifier(this._ref)
    : super(AsyncValue.data(MapState(markers: {}, bounds: null)));

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> initialize({
    required List<DdipEvent> events,
    required void Function(String eventId, String photoId) onPhotoMarkerTap,
  }) async {
    if (_context == null || !mounted) return;
    _initialBoundsFitted = false;

    state = AsyncValue.data(MapState(markers: {}, bounds: null));

    _loadUserLocation();
    _processEvents(events, onPhotoMarkerTap);
  }

  Future<void> _loadUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;

      final marker = await _createMyLocationMarker(position);

      final currentMarkers = Map.of(
        state.value?.markers ?? <String, NMarker>{},
      );
      currentMarkers[marker.info.id] = marker;

      // ▼▼▼ [추가] 새로운 마커가 추가될 때마다 경계를 다시 계산하여 상태를 업데이트합니다. ▼▼▼
      _updateStateWithNewMarkers(currentMarkers);
      // ▲▲▲ 여기까지 추가 ▲▲▲
    } catch (e) {
      print("사용자 위치 로딩 실패: $e");
    }
  }

  Future<void> _processEvents(
    List<DdipEvent> events,
    void Function(String eventId, String photoId) onPhotoMarkerTap,
  ) async {
    final eventMarkers = <String, NMarker>{};
    for (final event in events) {
      final marker = await _createEventMarker(event);
      eventMarkers[marker.info.id] = marker;
    }

    if (mounted) {
      final currentMarkers = Map.of(
        state.value?.markers ?? <String, NMarker>{},
      );
      currentMarkers.addAll(eventMarkers);

      // ▼▼▼ [추가] 이벤트 마커들이 추가된 후에도 경계를 다시 계산합니다. ▼▼▼
      _updateStateWithNewMarkers(currentMarkers);
      // ▲▲▲ 여기까지 추가 ▲▲▲
    }

    for (final event in events) {
      for (final photo in event.photos) {
        if (!mounted) return;

        final loadingMarker = await _createPhotoMarker(
          event.id,
          photo,
          onPhotoMarkerTap,
          isLoading: true,
        );

        final currentMarkers = Map.of(
          state.value?.markers ?? <String, NMarker>{},
        );
        currentMarkers[loadingMarker.info.id] = loadingMarker;

        // ▼▼▼ [추가] 로딩 마커가 추가될 때도 경계를 다시 계산하여 사용자가 로딩 위치를 볼 수 있게 합니다. ▼▼▼
        _updateStateWithNewMarkers(currentMarkers);
        // ▲▲▲ 여기까지 추가 ▲▲▲

        final finalMarker = await _createPhotoMarker(
          event.id,
          photo,
          onPhotoMarkerTap,
          isLoading: false,
        );

        if (mounted) {
          final updatedMarkers = Map.of(
            state.value?.markers ?? <String, NMarker>{},
          );
          updatedMarkers[finalMarker.info.id] = finalMarker;

          // ▼▼▼ [추가] 최종 마커로 교체된 후에도 마지막으로 경계를 다시 계산합니다. ▼▼▼
          _updateStateWithNewMarkers(updatedMarkers);
          // ▲▲▲ 여기까지 추가 ▲▲▲
        }
      }
    }
  }

  void _updateStateWithNewMarkers(Map<String, NMarker> newMarkers) {
    if (!mounted) return;

    NLatLngBounds? newBounds;
    final markerValues = newMarkers.values.toList();

    // 아직 초기 범위 조정이 실행되지 않았고,
    // '사용자 위치'와 '요청 위치' 마커가 모두 준비되었을 때만 실행
    if (!_initialBoundsFitted &&
        newMarkers.containsKey('my_location') &&
        newMarkers.isNotEmpty && // events 마커가 하나 이상 있다는 의미
        newMarkers.keys
            .firstWhere((k) => k != 'my_location', orElse: () => '')
            .isNotEmpty) {
      final positions = markerValues.map((m) => m.position).toList();
      newBounds = NLatLngBounds.from(positions);
      _initialBoundsFitted = true; // 플래그를 true로 바꿔 다시 실행되지 않도록 함
    }

    state = AsyncValue.data(
      state.value!.copyWith(
        markers: newMarkers,
        // newBounds가 null이 아닐 경우에만 (즉, 위의 조건이 충족될 때만) bounds를 업데이트
        bounds: newBounds ?? state.value?.bounds,
      ),
    );
  }

  // --- 마커 생성 헬퍼 함수들 (내부 구현은 변경 없음) ---

  Future<NOverlayImage> _getCachedOverlayImage(
    String key,
    Widget widget,
  ) async {
    if (_imageCache.containsKey(key)) return _imageCache[key]!;
    final image = await NOverlayImage.fromWidget(
      widget: widget,
      context: _context!,
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

  Future<void> updateOverlaysForZoom(double zoom) async {
    const double declutterZoomThreshold = 16.0; // 분산 배치를 시작할 줌 레벨
    final originalEvents = _ref.read(ddipFeedProvider); // 원본 데이터 가져오기

    if (zoom < declutterZoomThreshold) {
      // 줌 레벨이 낮으면: 클러스터링 로직 실행 (또는 원래 마커만 표시)
      // TODO: 여기에 클러스터링 로직을 추가하거나,
      //       기존처럼 단순히 원본 위치에 마커를 표시하는 로직을 실행합니다.
      //       (아래 로직은 단순화를 위해 원본 마커만 다시 그리는 것으로 가정)
      await initialize(
        events: originalEvents,
        onPhotoMarkerTap: (eventId, photoId) {
          /* ... */
        },
      );
      return;
    }

    // 줌 레벨이 높으면: 선 기반 분산 배치 로직 실행
    await _declutterMarkers(originalEvents);
  }

  Future<void> _declutterMarkers(List<DdipEvent> events) async {
    final newMarkers = <String, NMarker>{};
    final newPolylines = <String, NPolylineOverlay>{};

    // 1. 겹치는 마커 그룹 찾기 (단순화를 위해 이벤트 요청 위치 기준)
    final groups = _groupOverlappingEvents(events);

    for (final group in groups) {
      if (group.length == 1) {
        // 그룹에 마커가 하나뿐이면 그냥 그립니다.
        final event = group.first;
        newMarkers[event.id] = await _createEventMarker(event);
      } else {
        // 여러 개가 겹치면 분산 배치 로직을 실행합니다.
        final centerPosition = NLatLng(
          group.first.latitude,
          group.first.longitude,
        );

        // 중앙에 작은 점 마커를 추가합니다.
        final centerDot = NMarker(
          id: 'center_${group.first.id}',
          position: centerPosition,
          icon: await _getCachedOverlayImage(
            'center_dot',
            Icon(Icons.circle, size: 10, color: Colors.black),
          ),
        );
        newMarkers[centerDot.info.id] = centerDot;

        // 2. 각 마커를 원형으로 펼칠 위치 계산
        final offsetPositions = _calculateCircularOffsets(
          centerPosition,
          group.length,
        );

        for (int i = 0; i < group.length; i++) {
          final event = group[i];
          final offsetPos = offsetPositions[i];

          // 3. 펼쳐진 위치에 실제 마커 생성 (DeclutterMarker 사용)
          final markerWidget = DeclutterMarker(
            icon: Icons.flag,
            color: Colors.blue,
            offset: Offset.zero,
          );
          final markerIcon = await NOverlayImage.fromWidget(
            widget: markerWidget,
            context: _context!,
          );
          newMarkers[event.id] = NMarker(
            id: event.id,
            position: offsetPos,
            icon: markerIcon,
          );

          // 4. 중앙 점에서 꺾인 선 생성
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

    // 5. 계산된 마커와 폴리라인으로 상태 업데이트
    if (mounted) {
      state = AsyncValue.data(
        state.value!.copyWith(markers: newMarkers, polylines: newPolylines),
      );
    }
  }

  // 겹치는 이벤트 그룹을 찾는 간단한 로직 (개선 필요)
  List<List<DdipEvent>> _groupOverlappingEvents(List<DdipEvent> events) {
    // 실제 구현에서는 화면 픽셀 기반으로 거리를 계산해야 하지만,
    // 여기서는 간단히 위경도 0.0001 (약 10m) 이내면 겹친다고 가정합니다.
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

  // 원형으로 펼쳐질 위치를 계산하는 헬퍼 함수
  List<NLatLng> _calculateCircularOffsets(NLatLng center, int count) {
    final List<NLatLng> positions = [];
    const double radius = 0.0005; // 지도상의 위경도 거리 (조정 필요)
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
}
