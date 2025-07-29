// lib/features/map/providers/map_providers.dart
import 'package:ddip/features/map/presentation/notifiers/map_state_notifier.dart';
import 'package:ddip/features/map/presentation/services/map_overlay_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// [수정] MapState 클래스: 개별 마커의 추가/수정/삭제를 용이하게 하기 위해
// Set<NMarker> 대신 Map<String, NMarker>를 사용합니다.
class MapState {
  // key: 마커의 고유 ID, value: NMarker 객체
  final Map<String, NMarker> markers;
  final NLatLngBounds? bounds;
  final List<String> drillDownPath;
  final List<NLatLngBounds> boundsHistory;

  const MapState({
    required this.markers,
    this.bounds,
    this.drillDownPath = const ['root'],
    this.boundsHistory = const [],
  });

  // 상태를 쉽게 업데이트하기 위한 copyWith 메서드
  MapState copyWith({
    Map<String, NMarker>? markers,
    NLatLngBounds? bounds,
    List<String>? drillDownPath,
    List<NLatLngBounds>? boundsHistory,
  }) {
    return MapState(
      markers: markers ?? this.markers,
      bounds: bounds,
      drillDownPath: drillDownPath ?? this.drillDownPath,
      boundsHistory: boundsHistory ?? this.boundsHistory,
    );
  }
}

final mapStateNotifierProvider =
    StateNotifierProvider.autoDispose<MapStateNotifier, AsyncValue<MapState>>((
      ref,
    ) {
      return MapStateNotifier(ref);
    });

// family를 사용하여 BuildContext를 전달받을 수 있게 합니다.
final mapOverlayServiceProvider = Provider.autoDispose
    .family<MapOverlayService, BuildContext>(
      (ref, context) => MapOverlayService(context),
    );
