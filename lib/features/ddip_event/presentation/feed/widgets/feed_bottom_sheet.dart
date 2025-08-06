// lib/features/ddip_event/presentation/feed/widgets/feed_bottom_sheet.dart

import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/ddip_list_item.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/event_overview_card.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/ddip_event/presentation/strategy/feed_sheet_strategy.dart';
import 'package:ddip/features/ddip_event/presentation/widgets/multi_stage_bottom_sheet.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FeedBottomSheet extends ConsumerWidget {
  const FeedBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 필터링된 '보이는 이벤트 목록'만 구독합니다.
    final visibleEvents = ref.watch(visibleEventsProvider);
    final selectedEventId = ref.watch(selectedEventIdProvider);
    final isEventSelected = selectedEventId != null;

    // 새로 만든 범용 바텀시트를 조립하여 반환합니다.
    return MultiStageBottomSheet(
      strategyProvider: feedSheetStrategyProvider,
      minSnapSize: isEventSelected ? peekOverviewFraction : peekFraction,
      maxSnapSize: fullListFraction,
      snapSizes:
          isEventSelected
              ? [peekOverviewFraction, overviewFraction, fullListFraction]
              : [peekFraction, fullListFraction],
      // builder를 통해 시트 내부에 들어갈 콘텐츠를 정의하여 주입합니다.
      builder: (context, scrollController) {
        final selectedEvent =
            selectedEventId != null
                ? visibleEvents.firstWhereOrNull((e) => e.id == selectedEventId)
                : null;

        return ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.zero,
          itemCount: selectedEvent != null ? 2 : visibleEvents.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildHandle(ref);
            }
            if (selectedEvent != null) {
              return EventOverviewCard(
                event: selectedEvent,
                onBackToList: () {
                  ref.read(feedSheetStrategyProvider.notifier).showFullList();
                },
                onViewDetails: () {
                  context.push('/feed/${selectedEvent.id}');
                },
              );
            } else {
              // index 0번이 핸들이므로, 이벤트 목록의 인덱스는 index - 1이 됩니다.
              final event = visibleEvents[index - 1];
              return DdipListItem(event: event);
            }
          },
        );
      },
    );
  }

  // 핸들 위젯은 별도 메서드로 분리하여 builder 내부를 깔끔하게 유지합니다.
  Widget _buildHandle(WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final strategy = ref.read(feedSheetStrategyProvider.notifier);
        final currentHeight = ref.read(feedSheetStrategyProvider);

        // 오버뷰 상태보다 시트가 높이 있다면 최소화, 아니면 전체 목록 표시
        if (currentHeight > peekOverviewFraction) {
          strategy.minimize();
        } else {
          strategy.showFullList();
        }
      },
      child: Container(
        width: double.infinity,
        color: Colors.transparent, // 터치 영역을 확보하기 위해 색상은 투명으로 설정
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
