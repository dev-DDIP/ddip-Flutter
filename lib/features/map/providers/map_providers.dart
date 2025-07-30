import 'package:ddip/features/map/presentation/notifiers/map_state_notifier.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// [핵심 수정] 복잡한 Sealed Class 상태를 제거하고, 카메라가 이동할 목표 영역(bounds)만 관리하는 단순한 상태로 변경합니다.
class MapState {
  // 카메라 이동이 필요할 때만 값을 가집니다. 평소에는 null입니다.
  final NLatLngBounds? cameraTargetBounds;

  const MapState({this.cameraTargetBounds});
}

final mapStateNotifierProvider =
    StateNotifierProvider.autoDispose<MapStateNotifier, MapState>(
      (ref) => MapStateNotifier(),
    );
