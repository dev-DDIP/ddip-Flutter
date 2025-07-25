// [최종 수정] Provider의 상태 타입을 MapState로 정확히 명시
import 'package:ddip/features/map/presentation/notifiers/map_marker_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

// [수정] MapState 클래스 정의를 Notifier 파일에서 이곳으로 이동
class MapState {
  final Set<NMarker> markers;
  final NLatLngBounds? bounds;

  MapState({required this.markers, this.bounds});
}

// [수정] Provider가 관리하는 상태 타입을 AsyncValue<Set<NMarker>>에서 AsyncValue<MapState>로 변경
final mapMarkerNotifierProvider =
    StateNotifierProvider.autoDispose<MapMarkerNotifier, AsyncValue<MapState>>((
      ref,
    ) {
      return MapMarkerNotifier(ref);
    });
