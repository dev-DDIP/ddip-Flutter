// lib/features/map/presentation/notifiers/map_marker_notifier.dart
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
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
}
