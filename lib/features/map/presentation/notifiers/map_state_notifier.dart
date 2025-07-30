import 'dart:async';

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 지도의 상태를 관리하는 중앙 관제탑 (StateNotifier)
class MapStateNotifier extends StateNotifier<AsyncValue<MapState>> {
  final Ref _ref;

  MapStateNotifier(this._ref)
    : super(
        const AsyncValue.data(
          MapState(drillDownPath: ['root'], boundsHistory: []),
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

  /// 사용자가 클러스터를 탭했을 때 호출됨
  Future<void> drillDownToCluster(List<DdipEvent> eventsInCluster) async {
    // Cluster -> List<DdipEvent>
    final currentState = state.value;
    if (currentState == null) return;

    final newPath = List<String>.from(currentState.drillDownPath)
      ..add("cluster_${eventsInCluster.first.id}");

    final targetBounds = NLatLngBounds.from(
      eventsInCluster.map(
        (e) => NLatLng(e.latitude, e.longitude),
      ), // cluster.events -> eventsInCluster
    );

    final newHistory = List<NLatLngBounds>.from(currentState.boundsHistory)
      ..add(targetBounds);

    state = AsyncValue.data(
      currentState.copyWith(
        drillDownPath: newPath,
        bounds: targetBounds,
        boundsHistory: newHistory,
      ),
    );
  }

  /// 사용자가 '뒤로 가기'를 했을 때 호출됨
  Future<void> drillUp() async {
    final currentState = state.value;
    // 1. 현재 상태가 null이거나 이미 최상위(root) 경로에 있다면 아무것도 하지 않음.
    if (currentState == null || currentState.drillDownPath.length <= 1) return;

    // 2. '카메라 역사'에서 가장 처음 저장된, 즉 전체 뷰에 해당하는 'root' 영역을 가져옴.
    final rootBounds = currentState.boundsHistory.firstOrNull;

    // 3. 상태를 최상위(root)로 리셋함.
    state = AsyncValue.data(
      currentState.copyWith(
        // 3-1. 경로를 최상위 경로로 초기화
        drillDownPath: ['root'],
        // 3-2. 카메라를 전체 뷰 영역으로 이동하라고 '명령'
        bounds: rootBounds,
        // 3-3. 카메라 역사를 전체 뷰 하나만 남기고 모두 비움
        boundsHistory: rootBounds != null ? [rootBounds] : [],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
