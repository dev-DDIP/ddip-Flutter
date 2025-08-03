// lib/features/map/presentation/viewmodels/map_view_model.dart
import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_view_model.freezed.dart';

/// 지도 UI가 그려져야 할 모든 상태 정보를 담는 클래스입니다.
@freezed
class MapState with _$MapState {
  const factory MapState({
    @Default([]) List<DdipEvent> events,
    String? selectedEventId,
    NCameraUpdate? cameraUpdate,
    NLatLngBounds? cameraTargetBounds,
  }) = _MapState;
}

/// 지도와 관련된 모든 비즈니스 로직과 상태 변화를 관리하는 ViewModel입니다.
class MapViewModel extends StateNotifier<MapState> {
  final Ref _ref;

  MapViewModel(this._ref) : super(const MapState()) {
    // ViewModel이 생성될 때, 필요한 Provider들을 구독하기 시작합니다.
    _listenToEventChanges();
    _listenToSelectionChanges();
    _listenToClusterTap();
  }

  void _listenToEventChanges() {
    _ref.listen<AsyncValue<List<DdipEvent>>>(ddipEventsNotifierProvider, (
      _,
      next,
    ) {
      if (next is AsyncData) {
        state = state.copyWith(events: next.value ?? []);
      }
    });
  }

  void _listenToSelectionChanges() {
    _ref.listen<String?>(selectedEventIdProvider, (_, nextId) {
      final allEvents = _ref.read(ddipEventsNotifierProvider).value ?? [];
      final selectedEvent = allEvents.firstWhereOrNull((e) => e.id == nextId);

      NCameraUpdate? cameraUpdate;
      if (selectedEvent != null) {
        cameraUpdate = NCameraUpdate.scrollAndZoomTo(
          target: NLatLng(selectedEvent.latitude, selectedEvent.longitude),
          zoom: 16,
        )..setAnimation(
          animation: NCameraAnimation.easing,
          duration: const Duration(milliseconds: 500),
        );
      }
      state = state.copyWith(
        selectedEventId: nextId,
        cameraUpdate: cameraUpdate,
      );
    });
  }

  void _listenToClusterTap() {
    _ref.listen<MapStateForViewModel>(mapStateForViewModelProvider, (_, next) {
      if (next.cameraTargetBounds != null) {
        state = state.copyWith(cameraTargetBounds: next.cameraTargetBounds);
      }
    });
  }

  /// 카메라 이동이 완료되었음을 ViewModel에 알립니다.
  void onCameraMoveCompleted() {
    // 일회성 이벤트를 초기화하여 불필요한 재실행을 방지합니다.
    if (state.cameraUpdate != null) {
      state = state.copyWith(cameraUpdate: null);
    }
    if (state.cameraTargetBounds != null) {
      state = state.copyWith(cameraTargetBounds: null);
    }
  }
}
