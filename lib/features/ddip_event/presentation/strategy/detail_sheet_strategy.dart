// lib/features/ddip_event/presentation/strategy/detail_sheet_strategy.dart
import 'package:ddip/features/ddip_event/presentation/strategy/base_bottom_sheet_strategy.dart';

// 상세 화면 바텀시트의 높이 값을 상수로 정의합니다.
const double detailInitialFraction = 0.40; // 초기/최소 높이
const double detailFullFraction = 0.90; // 전체 확장 높이

class DetailSheetStrategy extends BaseBottomSheetStrategy {
  // 초기 높이를 부모 클래스에 전달하며 생성됩니다.
  DetailSheetStrategy() : super(detailInitialFraction);

  void expand() {
    state = detailFullFraction;
  }

  void minimize() {
    state = detailInitialFraction;
  }
}
