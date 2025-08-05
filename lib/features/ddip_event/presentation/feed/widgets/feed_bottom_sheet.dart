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
    // UI를 그리는 데 필요한 상태들을 watch 합니다.
    final eventsState = ref.watch(ddipEventsNotifierProvider);
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
        return eventsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('오류: $err')),
          // 1. 콜백 파라미터 이름을 'allEvents' -> 'feedState'로 변경하여 명확히 함
          data: (feedState) {
            // 2. feedState 객체에서 실제 이벤트 목록을 추출!
            final allEvents = feedState.events;

            final selectedEvent =
                selectedEventId != null
                    // 3. 이제 allEvents는 List이므로 모든 메서드가 정상 작동합니다.
                    ? allEvents.firstWhereOrNull((e) => e.id == selectedEventId)
                    : null;

            return ListView.builder(
              controller: scrollController,
              padding: EdgeInsets.zero,
              itemCount: selectedEvent != null ? 2 : allEvents.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHandle(ref);
                }
                if (selectedEvent != null) {
                  return EventOverviewCard(
                    event: selectedEvent,
                    onBackToList: () {
                      ref
                          .read(feedSheetStrategyProvider.notifier)
                          .showFullList();
                    },
                    onViewDetails: () {
                      context.push('/feed/${selectedEvent.id}');
                    },
                  );
                } else {
                  final event = allEvents[index - 1];
                  return DdipListItem(event: event);
                }
              },
            );
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
