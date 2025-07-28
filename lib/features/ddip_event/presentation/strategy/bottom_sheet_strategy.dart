// lib/features/ddip_event/presentation/strategy/bottom_sheet_strategy.dart

import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 피드 화면 바텀시트의 높이 값을 상수로 정의합니다.
const double peekFraction = 0.10;
const double peekOverviewFraction = 0.25;
const double overviewFraction = 0.50;
const double fullListFraction = 0.90;

/// 바텀시트의 모든 상태와 동작을 관리하는 지휘관 클래스입니다.
/// StateNotifier를 상속받아, 현재 바텀시트가 유지해야 할 높이(double)를 상태로 관리합니다.
class FeedSheetStrategy extends StateNotifier<double> {
  final Ref _ref;

  FeedSheetStrategy(this._ref) : super(peekFraction);

  /// UI(사용자 드래그)에 의해 변경된 높이를 Strategy의 상태와 동기화합니다.
  /// 이 메서드가 '역방향' 소통의 핵심입니다.
  void syncHeightFromUI(double currentHeight) {
    // 현재 Strategy가 알고 있는 높이와 UI의 실제 높이가 다를 때만
    // 상태를 업데이트하여 불필요한 재빌드를 방지합니다.
    if ((state - currentHeight).abs() > 0.001) {
      state = currentHeight;
    }
  }

  /// 사용자가 특정 이벤트를 선택했을 때 호출됩니다.
  void showOverview(String eventId) {
    _ref.read(selectedEventIdProvider.notifier).state = eventId;
    state = overviewFraction;
  }

  /// 사용자가 지도를 탐색할 때(탭, 드래그) 호출됩니다.
  void minimize() {
    final selectedEventId = _ref.read(selectedEventIdProvider);
    state = selectedEventId != null ? peekOverviewFraction : peekFraction;
  }

  /// 전체 목록을 봐야 할 때 호출됩니다. (예: 오버뷰에서 '뒤로가기')
  void showFullList() {
    _ref.read(selectedEventIdProvider.notifier).state = null;
    state = fullListFraction;
  }
}
