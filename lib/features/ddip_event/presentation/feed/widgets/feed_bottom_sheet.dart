import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/ddip_list_item.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/event_overview_card.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/ddip_event/presentation/strategy/bottom_sheet_strategy.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FeedBottomSheet extends ConsumerStatefulWidget {
  const FeedBottomSheet({super.key});

  @override
  ConsumerState<FeedBottomSheet> createState() => _FeedBottomSheetState();
}

class _FeedBottomSheetState extends ConsumerState<FeedBottomSheet> {
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Strategy가 관리하는 높이(double) 상태가 변경될 때마다,
    // 컨트롤러를 이용해 바텀시트 높이를 애니메이션합니다.
    ref.listen<double>(feedSheetStrategyProvider, (previous, next) {
      // ▼▼▼ [추가] 임시 상태값(-1.0)은 무시하고 넘어갑니다. ▼▼▼
      if (next < 0) return;

      if (_scrollController.isAttached) {
        _scrollController.animateTo(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });

    final eventsState = ref.watch(ddipEventsNotifierProvider);
    final selectedEventId = ref.watch(selectedEventIdProvider);
    final isEventSelected = selectedEventId != null;

    // Strategy 파일에 정의된 공개 상수를 사용합니다.
    final List<double> snapSizes =
        isEventSelected
            ? const [peekOverviewFraction, overviewFraction, fullListFraction]
            : const [peekFraction, fullListFraction];

    final minFraction = isEventSelected ? peekOverviewFraction : peekFraction;
    final initialFraction = ref.read(feedSheetStrategyProvider);

    return DraggableScrollableSheet(
      controller: _scrollController,
      initialChildSize: initialFraction,
      minChildSize: minFraction,
      maxChildSize: fullListFraction,
      snap: true,
      snapSizes: snapSizes,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
            ],
          ),
          child: eventsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('오류: $err')),
            data: (allEvents) {
              final selectedEvent =
                  selectedEventId != null
                      ? allEvents.firstWhereOrNull(
                        (e) => e.id == selectedEventId,
                      )
                      : null;

              return ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.zero,
                itemCount: selectedEvent != null ? 2 : allEvents.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildHandle();
                  }

                  if (selectedEvent != null) {
                    return EventOverviewCard(
                      event: selectedEvent,
                      onBackToList: () {
                        // Strategy에게 전체 목록을 보여달라고 명령합니다.
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
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return GestureDetector(
      onTap: () {
        final strategy = ref.read(feedSheetStrategyProvider.notifier);
        final currentHeight = ref.read(feedSheetStrategyProvider);

        // 현재 높이가 최소화 상태가 아닐 때만 최소화 명령을 내립니다.
        if (currentHeight > peekOverviewFraction) {
          strategy.minimize();
        } else {
          // 최소화 상태일 땐 전체 목록을 보여줍니다.
          strategy.showFullList();
        }
      },
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
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
