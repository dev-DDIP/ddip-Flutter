// lib/features/map/presentation/viewmodels/map_view_model.dart
import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/notifiers/ddip_events_notifier.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/map/presentation/widgets/marker_factory.dart';
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
  final DdipEvent? _initialEvent;
  final Map<String, NClusterableMarker> _markerCache = {};
  NaverMapController? _mapController;

  // 지도에 현재 표시된 오버레이를 추적하기 위한 Set
  final Set<NAddableOverlay> _currentOverlaysOnMap = {};

  MapViewModel(this._ref, {DdipEvent? initialEvent})
    : _markerFactory = _ref.read(markerFactoryProvider),
      _initialEvent = initialEvent,
      super(const MapState()) {
    if (_initialEvent != null) {
      _updateOverlays([_initialEvent!]);
    } else {
      _ref.listen<AsyncValue<DdipFeedState>>(ddipEventsNotifierProvider, (
        AsyncValue<DdipFeedState>? previous,
        AsyncValue<DdipFeedState> next,
      ) {
        next.whenData((state) => _updateOverlays(state.events));
      }, fireImmediately: true);
    }

    _ref.listen<String?>(selectedEventIdProvider, (
      String? previous,
      String? next,
    ) {
      final events =
          _initialEvent != null
              ? [_initialEvent!]
              : _ref.read(ddipEventsNotifierProvider).value?.events ?? [];
      _updateOverlays(events, selectedId: next);
      _moveCameraToSelectedEvent(next, events);
    });

    _ref.listen<MapStateForViewModel>(
      mapStateForViewModelProvider,
      (MapStateForViewModel? previous, MapStateForViewModel next) =>
          _handleClusterTap(next),
    );
  }

  void onMapReady(NaverMapController controller) {
    _mapController = controller;
    // 컨트롤러가 준비되면, 현재 ViewModel이 알고있는 오버레이들을 지도에 그립니다.
    if (_currentOverlaysOnMap.isNotEmpty) {
      _mapController?.addOverlayAll(_currentOverlaysOnMap);
    }
  }

  Future<void> _updateOverlays(
    List<DdipEvent> events, {
    String? selectedId,
  }) async {
    final currentSelectedId = selectedId ?? _ref.read(selectedEventIdProvider);
    final visibleEventIds = events.map((e) => e.id).toSet();

    // 1. [정리] 화면에서 사라진 마커들을 캐시에서 제거합니다.
    _markerCache.removeWhere((id, marker) => !visibleEventIds.contains(id));

    // 2. [업데이트 또는 생성] 화면에 보여야 할 마커들을 준비합니다.
    await Future.wait(
      events.map((event) async {
        final isSelected = currentSelectedId == event.id;
        final icon = await _markerFactory.getOrCacheMarkerIcon(
          type: 'event',
          isSelected: isSelected,
        );

        final cachedMarker = _markerCache[event.id];
        if (cachedMarker != null) {
          // [재사용] 이미 캐시에 있다면, 속성만 업데이트합니다. (매우 효율적)
          cachedMarker.setIcon(icon);
          cachedMarker.setZIndex(isSelected ? 10 : 1);
        } else {
          // [신규 생성] 캐시에 없다면, 새로 만들어서 캐시에 추가합니다.
          final newMarker =
              NClusterableMarker(
                  id: event.id,
                  position: NLatLng(event.latitude, event.longitude),
                  icon: icon,
                )
                ..setZIndex(isSelected ? 10 : 1)
                ..setOnTapListener((_) {
                  _ref
                      .read(feedSheetStrategyProvider.notifier)
                      .showOverview(event.id);
                });
          _markerCache[event.id] = newMarker;
        }
      }),
    );

    // 3. [지도에 반영] 최종적으로 정리된 캐시를 기준으로 지도에 diff 업데이트를 수행합니다.
    final newOverlaysOnMap = _markerCache.values.toSet();

    // 이전에 지도에 그려졌던 마커 목록과 현재 캐시 목록을 비교
    final overlaysToAdd = newOverlaysOnMap.difference(_currentOverlaysOnMap);
    final overlaysToRemove = _currentOverlaysOnMap.difference(newOverlaysOnMap);

    if (_mapController != null) {
      if (overlaysToAdd.isNotEmpty) {
        _mapController!.addOverlayAll(overlaysToAdd);
      }
      if (overlaysToRemove.isNotEmpty) {
        for (final overlay in overlaysToRemove) {
          _mapController!.deleteOverlay(overlay.info);
        }
      }
    }

    // 4. [상태 동기화] 현재 지도에 그려진 마커 목록을 최신 상태로 기록합니다.
    _currentOverlaysOnMap.clear();
    _currentOverlaysOnMap.addAll(newOverlaysOnMap);
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
      final cameraUpdate = NCameraUpdate.fitBounds(
        clusterState.cameraTargetBounds!,
        padding: const EdgeInsets.all(80),
      )..setAnimation(
        animation: NCameraAnimation.easing,
        duration: const Duration(milliseconds: 300),
      );
      // ViewModel의 상태(MapState)에 cameraUpdate 명령을 기록합니다.
      state = state.copyWith(cameraUpdate: cameraUpdate);
    }
  }

  /// View에서 카메라 이동 애니메이션이 완료된 후 호출되어,
  /// 일회성 명령이었던 `cameraUpdate`를 null로 초기화합니다.
  void onCameraMoveCompleted() {
    // 이미 처리된 명령이 다시 실행되지 않도록 null로 초기화합니다.
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
