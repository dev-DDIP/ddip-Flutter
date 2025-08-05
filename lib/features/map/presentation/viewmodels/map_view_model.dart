// lib/features/map/presentation/viewmodels/map_view_model.dart
import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
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
  final List<DdipEvent> _initialEvents;
  final Map<String, NClusterableMarker> _markerCache = {};

  MapViewModel(this._ref, List<DdipEvent> initialEvents)
    : _markerFactory = _ref.read(markerFactoryProvider),
      _initialEvents = initialEvents,
      super(const MapState()) {
    _updateState(_initialEvents);

    _ref.listen<String?>(selectedEventIdProvider, (previous, next) {
      // 1. 마커 아이콘 색상 등 UI 상태를 업데이트합니다.
      _updateState(_initialEvents, selectedId: next);

      // 2. 그리고 "여기서만" 카메라 이동을 명령합니다.
      _moveCameraToSelectedEvent(next, _initialEvents);
    });

    _ref.listen<MapStateForViewModel>(
      mapStateForViewModelProvider,
      (previous, next) => _handleClusterTap(next),
    );
  }

  Future<void> _updateState(
    List<DdipEvent> events, {
    String? selectedId,
  }) async {
    final currentSelectedId = selectedId ?? _ref.read(selectedEventIdProvider);
    final Set<String> newEventIds = events.map((e) => e.id).toSet();

    // 사라진 마커 정리
    _markerCache.removeWhere((id, marker) => !newEventIds.contains(id));

    // 기존 마커 업데이트 및 신규 마커 생성
    for (final event in events) {
      final isSelected = currentSelectedId == event.id;
      final icon = await _markerFactory.getOrCacheMarkerIcon(
        type: 'event',
        isSelected: isSelected,
      );

      // 캐시에 마커가 있는지 확인
      if (_markerCache.containsKey(event.id)) {
        // 있으면 아이콘과 zIndex만 업데이트 (리모델링)
        final marker = _markerCache[event.id]!;
        marker.setIcon(icon);
        marker.setZIndex(isSelected ? 10 : 1);
      } else {
        // 없으면 새로 생성해서 캐시에 추가 (신축)
        final marker = NClusterableMarker(
          id: event.id,
          position: NLatLng(event.latitude, event.longitude),
          icon: icon,
        )..setZIndex(isSelected ? 10 : 1);

        marker.setOnTapListener((_) {
          _ref.read(feedSheetStrategyProvider.notifier).showOverview(event.id);
        });
        _markerCache[event.id] = marker;
      }
    }

    // 최종적으로 캐시에 있는 모든 마커들로 상태를 업데이트
    state = state.copyWith(overlays: _markerCache.values.toSet());
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
