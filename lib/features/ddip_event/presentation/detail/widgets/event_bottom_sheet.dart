// lib/features/ddip_event/presentation/detail/widgets/event_bottom_sheet.dart

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/event_action_button.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/event_detail_tab_view.dart';
import 'package:ddip/features/ddip_event/presentation/strategy/detail_sheet_strategy.dart';
import 'package:ddip/features/ddip_event/presentation/widgets/multi_stage_bottom_sheet.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventBottomSheet extends ConsumerWidget {
  final DdipEvent event;

  const EventBottomSheet({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 탭 구성 로직, CustomScrollView 등 모든 복잡한 코드가 사라졌습니다.
    return MultiStageBottomSheet(
      strategyProvider: detailSheetStrategyProvider,
      minSnapSize: detailInitialFraction,
      maxSnapSize: detailFullFraction,
      snapSizes: const [detailInitialFraction, detailFullFraction],
      builder: (context, scrollController) {
        // EventBottomSheet의 유일한 책임:
        // 필요한 위젯들(TabView, ActionButton)을 조립하여 배치하는 것.
        return Column(
          children: [
            Expanded(
              child: EventDetailTabView(
                event: event,
                scrollController: scrollController,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: EventActionButton(event: event),
            ),
          ],
        );
      },
    );
  }
}
