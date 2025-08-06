// lib/features/map/providers/map_providers.dart
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/map/presentation/notifiers/map_state_notifier.dart';
import 'package:ddip/features/map/presentation/viewmodels/map_view_model.dart';
import 'package:ddip/features/map/presentation/widgets/marker_factory.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// 1. 기존 ViewModelProvider의 이름을 '피드 화면용'으로 명확하게 변경합니다.
final feedMapViewModelProvider =
    StateNotifierProvider.autoDispose<MapViewModel, MapState>((ref) {
      return MapViewModel(ref);
    });

// 2. 상세 페이지 전용 ViewModelProvider를 '.family'를 사용하여 새롭게 생성합니다.
// '.family'는 프로바이더에 외부 변수(여기서는 eventId)를 전달하여
// 각 eventId마다 고유하고 독립적인 ViewModel 인스턴스를 생성하게 해줍니다.
final detailMapViewModelProvider = StateNotifierProvider.autoDispose
    .family<MapViewModel, MapState, String>((ref, eventId) {
      final event = ref.watch(eventDetailProvider(eventId));
      return MapViewModel(ref, initialEvent: event);
    });

/// MarkerFactory 인스턴스를 앱 전역에서 싱글턴으로 제공하는 Provider입니다.
final markerFactoryProvider = Provider<MarkerFactory>((ref) {
  return MarkerFactory();
});

// 기본적으로는 피드에 있는 모든 이벤트를 반환합니다.
// 하지만 이 Provider를 다른 위젯에서 'override'하면, 지도에 표시될 데이터를
// 동적으로 변경할 수 있습니다. (예: 상세 화면에서는 이벤트 하나만 반환)
final mapEventsProvider = Provider<List<DdipEvent>>((ref) {
  return ref.watch(ddipFeedProvider);
});

/// 지도의 현재 보이는 영역(Bounds)을 실시간으로 관리하는 Provider
final mapBoundsProvider = StateProvider.autoDispose<NLatLngBounds?>(
  (ref) => null,
);
