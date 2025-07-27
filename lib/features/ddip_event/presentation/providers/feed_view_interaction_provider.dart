// lib/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 피드 화면 바텀 시트의 상태를 정의합니다.
enum FeedBottomSheetState {
  /// 핸들만 살짝 보이는 최소화 상태
  peek,
  peekOverview,

  /// 선택된 이벤트의 개요만 보여주는 상태
  overview,

  /// 전체 이벤트 목록을 보여주는 상태
  fullList,
}

/// 바텀 시트의 현재 UI 상태를 관리하는 Provider입니다.
final feedBottomSheetStateProvider =
    StateProvider.autoDispose<FeedBottomSheetState>((ref) {
      // 초기 상태는 최소화(peek) 상태입니다.
      return FeedBottomSheetState.peek;
    });

/// 사용자가 지도나 리스트에서 선택한 이벤트의 ID를 관리하는 Provider입니다.
final selectedEventIdProvider = StateProvider.autoDispose<String?>((ref) {
  // 초기에는 아무것도 선택되지 않았습니다.
  return null;
});
