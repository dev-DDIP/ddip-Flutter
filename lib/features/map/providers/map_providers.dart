// lib/features/map/providers/map_providers.dart
import 'package:ddip/features/map/presentation/notifiers/map_marker_notifier.dart';
import 'package:ddip/features/map/presentation/services/map_overlay_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// [수정] MapState 클래스: 개별 마커의 추가/수정/삭제를 용이하게 하기 위해
// Set<NMarker> 대신 Map<String, NMarker>를 사용합니다.
class MapState {
  // key: 마커의 고유 ID, value: NMarker 객체
  final Map<String, NMarker> markers;
  final Map<String, NPolylineOverlay> polylines;
  final NLatLngBounds? bounds;

  MapState({required this.markers, this.polylines = const {}, this.bounds});

  // 상태를 쉽게 업데이트하기 위한 copyWith 메서드
  MapState copyWith({
    Map<String, NMarker>? markers,
    Map<String, NPolylineOverlay>? polylines,
    NLatLngBounds? bounds,
  }) {
    return MapState(
      markers: markers ?? this.markers,
      polylines: polylines ?? this.polylines,
      bounds: bounds ?? this.bounds,
    );
  }
}

final mapMarkerNotifierProvider =
    StateNotifierProvider.autoDispose<MapMarkerNotifier, AsyncValue<MapState>>((
      ref,
    ) {
      return MapMarkerNotifier(ref);
    });

// family를 사용하여 BuildContext를 전달받을 수 있게 합니다.
final mapOverlayServiceProvider = Provider.autoDispose
    .family<MapOverlayService, BuildContext>(
      (ref, context) => MapOverlayService(context),
    );
