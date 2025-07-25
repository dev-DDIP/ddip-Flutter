// [최종 개선] 점진적 로딩과 지능형 업데이트를 모두 적용
import 'dart:math';

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/map/presentation/widgets/cluster_marker.dart';
import 'package:ddip/features/map/presentation/widgets/declutter_marker.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class MapMarkerNotifier extends StateNotifier<AsyncValue<MapState>> {
  final Ref _ref;
  BuildContext? _context;
  final Map<String, NOverlayImage> _imageCache = {};

  List<DdipEvent> _currentEvents = [];

  // [추가] GPS 위치를 저장할 클래스 멤버 변수 선언
  Position? _currentPosition;
  late Function(String, String) _onPhotoMarkerTapCallback;
  bool _isCurrentlyClustered = false;

  MapMarkerNotifier(this._ref) : super(const AsyncValue.loading());

  void setContext(BuildContext context) {
    _context = context;
  }

  /// [신규] 점진적 로딩을 수행하는 새로운 초기화 함수
  Future<void> loadInitialMarkers({
    required List<DdipEvent> events,
    required Position? currentPosition, // 이 값을 저장해야 함
    required void Function(String eventId, String photoId) onPhotoMarkerTap,
  }) async {
    if (_context == null || !mounted) return;
    state = const AsyncValue.loading();

    _currentEvents = events;
    // [추가] 전달받은 GPS 위치를 클래스 멤버 변수에 저장
    _currentPosition = currentPosition;
    _onPhotoMarkerTapCallback = onPhotoMarkerTap;
    _isCurrentlyClustered = false;

    try {
      final allMarkers = await _generateAllMarkers();
      final allPositions = allMarkers.map((m) => m.position).toList();
      final bounds =
          allPositions.isNotEmpty ? NLatLngBounds.from(allPositions) : null;
      state = AsyncValue.data(MapState(markers: allMarkers, bounds: bounds));
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> updateMarkersForIdle({
    required NCameraPosition cameraPosition,
  }) async {
    if (_context == null || !mounted || state.isLoading) return;

    final double zoom = cameraPosition.zoom;
    final bool shouldBeClustered = zoom < 14;

    if (shouldBeClustered == _isCurrentlyClustered) {
      return;
    }

    _isCurrentlyClustered = shouldBeClustered;

    try {
      final Set<NMarker> updatedMarkers;
      if (shouldBeClustered) {
        updatedMarkers = await _generateClusteredMarkers(zoom);
      } else {
        // 이제 _generateAllMarkers는 _currentPosition을 정상적으로 참조 가능
        updatedMarkers = await _generateAllMarkers();
      }
      state = AsyncValue.data(MapState(markers: updatedMarkers, bounds: null));
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  // --- Private Helper Functions ---
  Future<Set<NMarker>> _generateEventAndPhotoMarkers() async {
    final Set<NMarker> markers = {};
    for (final event in _currentEvents) {
      markers.add(await _createSimpleMarker(event));
      for (final photo in event.photos) {
        markers.add(
          await _createPhotoMarker(event.id, photo, _onPhotoMarkerTapCallback),
        );
      }
    }
    return markers;
  }

  // --- Private Helper Functions ---
  Future<Set<NMarker>> _generateAllMarkers() async {
    final Set<NMarker> markers = {};
    // [수정] 이제 이 변수는 정상적으로 클래스 멤버를 가리킴
    if (_currentPosition != null) {
      markers.add(await _createMyLocationMarker(_currentPosition!));
    }
    for (final event in _currentEvents) {
      markers.add(await _createSimpleMarker(event));
      for (final photo in event.photos) {
        markers.add(
          await _createPhotoMarker(event.id, photo, _onPhotoMarkerTapCallback),
        );
      }
    }
    return markers;
  }

  Future<Set<NMarker>> _generateClusteredMarkers(double zoom) async {
    final Set<NMarker> markers = {};
    final clusters = _createClusters(_currentEvents, zoom);

    for (var entry in clusters.entries) {
      final clusterEvents = entry.value;
      if (clusterEvents.length == 1) {
        markers.add(await _createSimpleMarker(clusterEvents.first));
      } else {
        final clusterKey = 'cluster_${clusterEvents.length}';
        final clusterIcon = await _getCachedOverlayImage(
          clusterKey,
          ClusterMarker(count: clusterEvents.length),
        );
        markers.add(
          NMarker(
            id: 'cluster_${entry.key}',
            position: NLatLng(
              clusterEvents.first.latitude,
              clusterEvents.first.longitude,
            ),
            icon: clusterIcon,
          ),
        );
      }
    }
    return markers;
  }

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
      const DeclutterMarker(
        icon: Icons.my_location,
        color: Colors.purple,
        offset: Offset.zero,
      ),
    );
    final marker = NMarker(
      id: 'my_location',
      position: NLatLng(position.latitude, position.longitude),
      icon: icon,
    );
    marker.setZIndex(0);
    return marker;
  }

  Future<NMarker> _createSimpleMarker(DdipEvent event) async {
    final icon = await _getCachedOverlayImage(
      'simple_event_marker',
      const DeclutterMarker(
        icon: Icons.flag,
        color: Colors.blue,
        offset: Offset.zero,
      ),
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
    void Function(String, String) onTap,
  ) async {
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
    final icon = await _getCachedOverlayImage(
      cacheKey,
      DeclutterMarker(icon: iconData, color: color, offset: Offset.zero),
    );
    final marker = NMarker(
      id: photo.id,
      position: NLatLng(photo.latitude, photo.longitude),
      icon: icon,
    );
    marker.setZIndex(20);
    marker.setOnTapListener((_) => onTap(eventId, photo.id));
    return marker;
  }

  Map<String, List<DdipEvent>> _createClusters(
    List<DdipEvent> events,
    double zoom,
  ) {
    final Map<String, List<DdipEvent>> clusters = {};
    final gridSize = 0.5 / (pow(2, zoom - 10));
    for (var event in events) {
      final gridX = (event.longitude / gridSize).floor();
      final gridY = (event.latitude / gridSize).floor();
      final key = '$gridX-$gridY';
      if (!clusters.containsKey(key)) clusters[key] = [];
      clusters[key]!.add(event);
    }
    return clusters;
  }
}
