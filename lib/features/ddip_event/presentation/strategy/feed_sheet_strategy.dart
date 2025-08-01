// lib/features/ddip_event/presentation/strategy/feed_sheet_strategy.dart

import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/ddip_event/presentation/strategy/base_bottom_sheet_strategy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 피드 화면 바텀시트의 높이 값을 상수로 정의합니다.
const double peekFraction = 0.10;
const double peekOverviewFraction = 0.20;
const double overviewFraction = 0.40;
const double fullListFraction = 0.90;

/// 바텀시트의 모든 상태와 동작을 관리하는 지휘관 클래스입니다.
/// StateNotifier를 상속받아, 현재 바텀시트가 유지해야 할 높이(double)를 상태로 관리합니다.
class FeedSheetStrategy extends BaseBottomSheetStrategy {
  final Ref _ref;

  FeedSheetStrategy(this._ref) : super(peekFraction);

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
