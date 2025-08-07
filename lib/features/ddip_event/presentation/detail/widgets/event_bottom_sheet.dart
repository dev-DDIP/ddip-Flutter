// lib/features/ddip_event/presentation/detail/widgets/event_bottom_sheet.dart

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/MissionControlLayout.dart';
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
        // TabView와 ActionButton을 제거하고 새로운 레이아웃으로 교체!
        return MissionControlLayout(
          event: event,
          scrollController: scrollController,
        );
      },
    );
  }
}
