// lib/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart

import 'package:ddip/features/ddip_event/presentation/strategy/bottom_sheet_strategy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// [신규] 새로운 Strategy 클래스를 제어할 Provider를 등록합니다.
final feedSheetStrategyProvider =
    StateNotifierProvider.autoDispose<FeedSheetStrategy, double>(
      (ref) => FeedSheetStrategy(ref),
    );

/// 사용자가 지도나 리스트에서 선택한 이벤트의 ID를 관리하는 Provider입니다.
final selectedEventIdProvider = StateProvider.autoDispose<String?>((ref) {
  // 초기에는 아무것도 선택되지 않았습니다.
  return null;
});

/// DraggableScrollableSheet의 현재 높이를 픽셀 단위로 관리하는 Provider입니다.
/// DdipMapView가 이 값을 감시하여 contentPadding을 동적으로 조절합니다.
final bottomSheetHeightProvider = StateProvider<double>((ref) {
  // 앱 시작 시 초기 높이는 0으로 설정하고,
  // 이후 바텀시트가 렌더링되면서 실제 높이로 업데이트됩니다.
  return 0.0;
});
