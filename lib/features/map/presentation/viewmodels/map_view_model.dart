// lib/features/map/presentation/viewmodels/map_view_model.dart
import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/map/presentation/widgets/marker_factory.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter/material.dart'; // EdgeInsets를 위해 material.dart 임포트
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'map_view_model.freezed.dart';

/// ## MapState: 최종 '설계도'
///
/// 지도 UI를 그리는 데 필요한 모든 최종 결과물을 담는 불변(immutable) 상태 클래스입니다.
/// View는 이 상태 객체 하나만 바라보며 화면을 그립니다.
@freezed
class MapState with _$MapState {
  const factory MapState({
    /// 지도에 표시될 모든 오버레이(마커, 사진 마커 등)의 최종 세트입니다.
    @Default({}) Set<NAddableOverlay> overlays,

    /// View에 전달하는 일회성 카메라 이동 명령입니다.
    /// View는 이 명령을 수행한 후 null로 초기화해야 합니다.
    NCameraUpdate? cameraUpdate,
    NaverMapViewOptions? viewOptions,
    NaverMapClusteringOptions? clusterOptions,
  }) = _MapState;
}

/// ## MapViewModel: '총괄 셰프' 또는 '두뇌'
///
/// 지도와 관련된 모든 비즈니스 로직과 상태 변화를 책임지는 컨트롤 타워입니다.
/// 여러 데이터 소스(Provider)를 구독하고, 이를 가공하여 최종 `MapState`를 생성합니다.
class MapViewModel extends StateNotifier<MapState> {
  final Ref _ref;
  final MarkerFactory _markerFactory;

  MapViewModel(this._ref, List<DdipEvent> initialEvents)
    : _markerFactory = _ref.read(markerFactoryProvider),
      super(const MapState()) {
    // 2. 생성되자마자 외부에서 주입받은 initialEvents로 첫 상태를 바로 만듭니다.
    _updateState(initialEvents);

    // 3. 더 이상 mapEventsProvider를 직접 구독하지 않습니다. 이 ViewModel은 이제 외부 상황을 모릅니다.
    // _ref.listen<List<DdipEvent>>(
    //   mapEventsProvider,
    //   (_, events) => _updateState(events),
    //   fireImmediately: true,
    // );

    // selectedEventIdProvider는 여전히 UI 상호작용에 필요하므로 유지하되, 로직을 수정합니다.
    _ref.listen<String?>(selectedEventIdProvider, (previous, next) {
      // 선택된 ID가 변경되면, 현재 자신이 관리하던 이벤트 목록을 기준으로 다시 상태를 업데이트합니다.
      final currentEvents =
          state.overlays
              .whereType<NClusterableMarker>()
              .map(
                (marker) => _ref
                    .read(ddipFeedProvider)
                    .firstWhere((e) => e.id == marker.info.id),
              )
              .toList();
      _updateState(currentEvents, selectedId: next);
    });

    _ref.listen<MapStateForViewModel>(
      mapStateForViewModelProvider,
      (_, next) => _handleClusterTap(next),
    );
  }

  // 4. _updateState 메서드가 이벤트 목록과 선택된 ID를 인자로 받도록 수정합니다.
  Future<void> _updateState(
    List<DdipEvent> events, {
    String? selectedId,
  }) async {
    // 5. 인자로 받은 selectedId를 사용합니다. 없다면 ref에서 읽어옵니다.
    final currentSelectedId = selectedId ?? _ref.read(selectedEventIdProvider);

    if (events.isEmpty) {
      state = state.copyWith(overlays: {});
      return;
    }

    final newOverlays = <NAddableOverlay>{};

    for (final event in events) {
      final isSelected = currentSelectedId == event.id;
      final icon = await _markerFactory.getOrCacheMarkerIcon(
        type: 'event',
        isSelected: isSelected,
      );

      // --- ▼▼▼ [수정] NClusterableMarker 생성 방식 변경 ---
      // zIndex는 생성자 파라미터가 아니므로, 객체 생성 후 메서드로 설정합니다.
      final marker = NClusterableMarker(
        id: event.id,
        position: NLatLng(event.latitude, event.longitude),
        icon: icon,
      )..setZIndex(isSelected ? 10 : 1); // 선택된 마커가 항상 위에 보이도록 z-index 설정
      // --- ▲▲▲ [수정] NClusterableMarker 생성 방식 변경 ---

      // 마커를 탭했을 때의 동작을 정의합니다.
      marker.setOnTapListener((_) {
        _ref.read(feedSheetStrategyProvider.notifier).showOverview(event.id);
      });
      newOverlays.add(marker);
    }

    // TODO: 상세 화면의 사진 마커(Photo)를 오버레이로 변환하는 로직도 이곳에 추가해야 합니다.

    // 새로 계산된 오버레이 목록으로 상태를 업데이트합니다.
    state = state.copyWith(overlays: newOverlays);

    // 목록이 업데이트된 후, 선택된 이벤트가 있다면 카메라를 이동시킵니다.
    _moveCameraToSelectedEvent(selectedId, events);
  }

  /// 선택된 이벤트의 위치로 카메라를 이동시키는 `NCameraUpdate` 객체를 생성합니다.
  void _moveCameraToSelectedEvent(String? eventId, List<DdipEvent> allEvents) {
    if (eventId == null) return;
    final event = allEvents.firstWhereOrNull((e) => e.id == eventId);
    if (event == null) return;

    final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
      target: NLatLng(event.latitude, event.longitude),
      zoom: 16,
    )..setAnimation(
      animation: NCameraAnimation.easing,
      duration: const Duration(milliseconds: 500),
    );

    state = state.copyWith(cameraUpdate: cameraUpdate);
  }

  /// 클러스터가 탭되었을 때 해당 클러스터 영역으로 카메라를 이동시킵니다.
  void _handleClusterTap(MapStateForViewModel clusterState) {
    if (clusterState.cameraTargetBounds != null) {
      // --- ▼▼▼ [수정] EdgeInsets.all 생성자 오타 수정 ---
      final cameraUpdate = NCameraUpdate.fitBounds(
        clusterState.cameraTargetBounds!,
        padding: const EdgeInsets.all(80), // .all() 메서드 호출 방식으로 수정
      )..setAnimation(
        animation: NCameraAnimation.easing,
        duration: const Duration(milliseconds: 300),
      );
      // --- ▲▲▲ [수정] EdgeInsets.all 생성자 오타 수정 ---
      state = state.copyWith(cameraUpdate: cameraUpdate);
    }
  }

  /// View에서 카메라 이동 애니메이션이 완료된 후 호출되어,
  /// 일회성 명령이었던 `cameraUpdate`를 null로 초기화합니다.
  void onCameraMoveCompleted() {
    if (state.cameraUpdate != null) {
      state = state.copyWith(cameraUpdate: null);
    }
  }

  /// View로부터 지도 옵션 업데이트 요청을 받습니다.
  void updateMapOptions(NaverMapViewOptions options) {
    state = state.copyWith(viewOptions: options);
  }

  /// View로부터 지도 탭 이벤트를 전달받습니다.
  void onMapTapped() {
    // feedSheetStrategyProvider를 직접 제어하는 로직은 여기에 위치합니다.
    _ref.read(feedSheetStrategyProvider.notifier).minimize();
  }

  /// View로부터 카메라 변경 이벤트를 전달받습니다.
  void onCameraChange(NCameraUpdateReason reason) {
    if (reason == NCameraUpdateReason.gesture) {
      _ref.read(feedSheetStrategyProvider.notifier).minimize();
    }
  }
}
