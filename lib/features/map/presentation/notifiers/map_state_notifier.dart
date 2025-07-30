import 'dart:async';

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 지도의 상태를 관리하는 중앙 관제탑 (StateNotifier)
class MapStateNotifier extends StateNotifier<AsyncValue<MapState>> {
  final Ref _ref;
  NLatLngBounds? _rootBounds;

  NLatLngBounds? get rootBounds => _rootBounds;

  MapStateNotifier(this._ref) : super(const AsyncValue.data(MapStateRoot()));

  /// 지도가 처음 로드될 때 '최초의 역사'를 기록하는 메서드
  Future<void> initializeHistory(NLatLngBounds initialBounds) async {
    _rootBounds = initialBounds;
  }

  /// 사용자가 클러스터를 탭했을 때 호출됨
  Future<void> drillDownToCluster(List<DdipEvent> eventsInCluster) async {
    // 💡 새로운 상태 객체를 생성하여 상태를 변경
    state = AsyncValue.data(MapStateDrilledDown(eventsInCluster));
  }

  /// 사용자가 '뒤로 가기'를 했을 때 호출됨
  Future<void> drillUp() async {
    // 💡 기본 상태(Root)로 되돌림
    state = const AsyncValue.data(MapStateRoot());
  }

  @override
  void dispose() {
    super.dispose();
  }
}
