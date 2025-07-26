// lib/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 지도와 리스트 뷰의 상호작용 상태를 관리하는 Provider입니다.
///
/// 이 Provider는 현재 사용자가 선택한 이벤트의 ID('selectedEventId')를 상태로 가집니다.
/// 이 값이 변경되면, 지도와 리스트 UI가 각각 반응하여 업데이트됩니다.
/// 예를 들어, 지도에서 마커를 탭하면 이 Provider의 상태가 업데이트되고,
/// 리스트는 해당 아이템으로 스크롤되는 식입니다.
final feedViewInteractionProvider = StateProvider.autoDispose<String?>((ref) {
  // 초기 상태는 아무것도 선택되지 않았음을 의미하는 null입니다.
  return null;
});
