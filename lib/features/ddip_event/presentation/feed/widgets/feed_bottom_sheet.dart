// lib/features/ddip_event/presentation/feed/widgets/feed_bottom_sheet.dart

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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 지휘관(Strategy)의 상태가 프로그램적으로 변경될 때 시트의 높이를 애니메이션으로 조절합니다.
    ref.listen<double>(feedSheetStrategyProvider, (previous, next) {
      // 현재 높이와 목표 높이가 거의 같다면 불필요한 애니메이션을 실행하지 않습니다.
      if ((_scrollController.size - next).abs() < 0.01) return;
      if (_scrollController.isAttached) {
        _scrollController.animateTo(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });

    // UI를 그리는 데 필요한 상태들을 watch 합니다.
    final eventsState = ref.watch(ddipEventsNotifierProvider);
    final selectedEventId = ref.watch(selectedEventIdProvider);
    final isEventSelected = selectedEventId != null;

    // DraggableScrollableSheet를 NotificationListener로 감싸 스크롤 이벤트를 감지합니다.
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // 사용자의 드래그 스크롤이 끝나는 시점에만 실행됩니다.
        if (notification is ScrollEndNotification) {
          // 컨트롤러에서 현재 높이 비율을 가져옵니다.
          final currentFraction = _scrollController.size;
          // 가져온 비율 값을 지휘관(Strategy)에게 보고하여 상태를 동기화합니다.
          ref
              .read(feedSheetStrategyProvider.notifier)
              .syncHeightFromUI(currentFraction);
        }
        // 이벤트가 상위 위젯으로 전파되는 것을 막지 않기 위해 false를 반환합니다.
        return false;
      },
      child: DraggableScrollableSheet(
        controller: _scrollController,
        initialChildSize: ref.read(feedSheetStrategyProvider),
        minChildSize: isEventSelected ? peekOverviewFraction : peekFraction,
        maxChildSize: fullListFraction,
        snap: true,
        snapSizes:
            isEventSelected
                ? [peekOverviewFraction, overviewFraction, fullListFraction]
                : [peekFraction, fullListFraction],
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
      ),
    );
  }

  Widget _buildHandle() {
    return GestureDetector(
      onTap: () {
        final strategy = ref.read(feedSheetStrategyProvider.notifier);
        final currentHeight = ref.read(feedSheetStrategyProvider);

        if (currentHeight > peekOverviewFraction) {
          strategy.minimize();
        } else {
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
