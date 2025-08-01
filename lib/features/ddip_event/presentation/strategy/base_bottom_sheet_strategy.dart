// lib/features/ddip_event/presentation/strategy/base_bottom_sheet_strategy.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 모든 바텀시트 Strategy의 기반이 될 추상 클래스입니다.
/// StateNotifier<double>을 상속받아 시트의 높이를 상태로 관리합니다.
abstract class BaseBottomSheetStrategy extends StateNotifier<double> {
  BaseBottomSheetStrategy(super.initialState);

  /// UI(사용자 드래그)에 의해 변경된 높이를 Strategy의 상태와 동기화합니다.
  /// 이 메서드는 UI와 Strategy 간의 핵심적인 '역방향' 소통을 담당합니다.
  void syncHeightFromUI(double currentHeight) {
    // 현재 Strategy가 알고 있는 높이와 UI의 실제 높이가 다를 때만
    // 상태를 업데이트하여 불필요한 재빌드를 방지합니다.
    if ((state - currentHeight).abs() > 0.001) {
      state = currentHeight;
    }
  }
}
