// lib/features/map/providers/map_providers.dart
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/map/presentation/notifiers/map_state_notifier.dart';
import 'package:ddip/features/map/presentation/viewmodels/map_view_model.dart';
import 'package:ddip/features/map/presentation/widgets/marker_factory.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// -----------------------------------------------------------------------------
// [기존] 클러스터 탭 -> ViewModel 통신을 위한 Provider
// -----------------------------------------------------------------------------

/// 클러스터 탭 시 발생하는 카메라 이동 목표 영역을 전달하는 상태 클래스입니다.
/// ViewModel이 이 상태를 감지하여 카메라 이동을 처리합니다.
class MapStateForViewModel {
  final NLatLngBounds? cameraTargetBounds;

  const MapStateForViewModel({this.cameraTargetBounds});
}

/// MapStateForViewModel 상태를 관리하는 Notifier를 제공합니다.
final mapStateForViewModelProvider =
    StateNotifierProvider.autoDispose<MapStateNotifier, MapStateForViewModel>(
      (ref) => MapStateNotifier(),
    );

// -----------------------------------------------------------------------------
// [신규] 리팩토링으로 추가된 Provider들
// -----------------------------------------------------------------------------

/// MarkerFactory 인스턴스를 앱 전역에서 싱글턴으로 제공하는 Provider입니다.
final markerFactoryProvider = Provider<MarkerFactory>((ref) {
  return MarkerFactory();
});

/// 지도 UI의 모든 상태와 비즈니스 로직을 총괄하는 MapViewModel을 제공하는 Provider입니다.
/// UI 위젯은 이 Provider를 `watch`하여 상태 변화에 따라 다시 그려집니다.
final mapViewModelProvider =
    StateNotifierProvider.autoDispose<MapViewModel, MapState>(
      (ref) => MapViewModel(ref),
    );
