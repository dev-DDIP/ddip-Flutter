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

  /// 사용자가 특정 이벤트를 선택했을 때 호출됩니다.
  void showOverview(String eventId) {
    // 1. 어떤 이벤트가 선택되었는지 앱 전체에 알립니다.
    _ref.read(selectedEventIdProvider.notifier).state = eventId;
    // 2. 바텀시트 상태를 '오버뷰' 높이로 변경합니다.
    state = overviewFraction;
  }

  /// 사용자가 지도를 탐색할 때(탭, 드래그) 호출됩니다.
  void minimize() {
    final selectedEventId = _ref.read(selectedEventIdProvider);
    // 선택된 이벤트 유무에 따라 다른 최소화 높이를 설정합니다.
    if (selectedEventId != null) {
      state = peekOverviewFraction;
    } else {
      state = peekFraction;
    }
  }

  /// 전체 목록을 봐야 할 때 호출됩니다. (예: 오버뷰에서 '뒤로가기')
  void showFullList() {
    // 1. 선택된 이벤트를 해제합니다.
    _ref.read(selectedEventIdProvider.notifier).state = null;
    // 2. 바텀시트 상태를 '전체 목록' 높이로 변경합니다.
    state = fullListFraction;
  }
}
