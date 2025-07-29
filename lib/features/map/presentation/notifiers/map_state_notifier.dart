import 'dart:async';

import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/map/domain/entities/cluster_or_marker.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 지도의 상태를 관리하는 중앙 관제탑 (StateNotifier)
class MapStateNotifier extends StateNotifier<AsyncValue<MapState>> {
  final Ref _ref;
  Timer? _debounce;

  MapStateNotifier(this._ref)
    : super(
        const AsyncValue.data(
          MapState(markers: {}, drillDownPath: ['root'], boundsHistory: []),
        ),
      );

  /// 지도가 처음 로드될 때 '최초의 역사'를 기록하는 메서드
  Future<void> initializeHistory(NLatLngBounds initialBounds) async {
    final currentState = state.value;
    if (currentState == null) return;

    // 초기 상태에서는 히스토리가 비어있을 때만 추가하여 중복을 방지
    if (currentState.boundsHistory.isEmpty) {
      final newHistory = [initialBounds];
      state = AsyncValue.data(currentState.copyWith(boundsHistory: newHistory));
    }
  }

  /// 지도 UI가 준비되었거나, 카메라가 멈췄을 때 호출되어 현재 보이는 영역의 마커/클러스터를 가져옴
  Future<void> fetchMarkers({
    required NaverMapController mapController,
    required BuildContext context,
  }) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final repository = _ref.read(ddipEventRepositoryProvider);
        final cameraPosition = await mapController.getCameraPosition();
        final bounds = await mapController.getContentBounds();
        final clustersOrMarkers = await repository.getClusters(
          bounds,
          cameraPosition.zoom,
        );

        final overlayService = _ref.read(mapOverlayServiceProvider(context));
        final selectedEventId = _ref.read(selectedEventIdProvider);
        final markers = await overlayService.buildOverlays(
          clustersOrMarkers: clustersOrMarkers,
          selectedEventId: selectedEventId,
          onEventMarkerTap: (eventId) {
            _ref.read(feedSheetStrategyProvider.notifier).showOverview(eventId);
          },
          onClusterMarkerTap: (cluster) {
            drillDownToCluster(cluster);
          },
        );

        // 평상시 마커 갱신 시에는 bounds를 null로 설정하여 카메라 이동을 막음
        final currentPath = state.valueOrNull?.drillDownPath ?? const ['root'];
        final currentHistory = state.valueOrNull?.boundsHistory ?? const [];
        state = AsyncValue.data(
          MapState(
            markers: markers,
            bounds: null,
            drillDownPath: currentPath,
            boundsHistory: currentHistory, // 기존 역사 유지
          ),
        );
      } catch (e, s) {
        state = AsyncValue.error(e, s);
      }
    });
  }

  /// 사용자가 클러스터를 탭했을 때 호출됨
  Future<void> drillDownToCluster(Cluster cluster) async {
    final currentState = state.value;
    if (currentState == null) return;

    final newPath = List<String>.from(currentState.drillDownPath)
      ..add("cluster_${cluster.events.first.id}");

    final targetBounds = NLatLngBounds.from(
      cluster.events.map((e) => NLatLng(e.latitude, e.longitude)),
    );

    // 새로운 '카메라 역사'를 기록
    final newHistory = List<NLatLngBounds>.from(currentState.boundsHistory)
      ..add(targetBounds);

    state = AsyncValue.data(
      currentState.copyWith(
        drillDownPath: newPath,
        bounds: targetBounds, // 카메라 이동 명령
        boundsHistory: newHistory, // 새로운 역사 업데이트
      ),
    );
  }

  /// 사용자가 '뒤로 가기'를 했을 때 호출됨
  Future<void> drillUp() async {
    final currentState = state.value;
    if (currentState == null || currentState.drillDownPath.length <= 1) return;

    final newPath = List<String>.from(currentState.drillDownPath)..removeLast();

    // '카메라 역사'에서 마지막 기록을 제거
    final newHistory = List<NLatLngBounds>.from(currentState.boundsHistory)
      ..removeLast();

    // 돌아갈 목표 지점은 이제 '역사'에 기록된 가장 마지막 위치
    final targetBounds = newHistory.isNotEmpty ? newHistory.last : null;

    state = AsyncValue.data(
      currentState.copyWith(
        drillDownPath: newPath,
        bounds: targetBounds, // 이전 위치로 돌아가라는 '카메라 이동 명령'
        boundsHistory: newHistory, // 역사 업데이트
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
