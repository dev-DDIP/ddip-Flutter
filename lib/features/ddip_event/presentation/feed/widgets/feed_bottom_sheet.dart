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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Strategy의 상태(목표 높이)가 바뀌면 UI를 애니메이션합니다. (정방향)
    ref.listen<double>(feedSheetStrategyProvider, (previous, next) {
      // 사용자가 이미 드래그해서 목표 높이에 도달한 경우, 불필요한 애니메이션을 실행하지 않습니다.
      if ((_scrollController.size - next).abs() < 0.01) return;

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

    final List<double> snapSizes =
        isEventSelected
            ? const [peekOverviewFraction, overviewFraction, fullListFraction]
            : const [peekFraction, fullListFraction];
    final minFraction = isEventSelected ? peekOverviewFraction : peekFraction;
    final initialFraction = ref.read(feedSheetStrategyProvider);

    // DraggableScrollableSheet를 NotificationListener로 감싸서 UI의 드래그 이벤트를 감지합니다.
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        // 스크롤(드래그) 이벤트가 발생할 때마다 Strategy에게 현재 높이를 보고합니다. (역방향)
        ref
            .read(feedSheetStrategyProvider.notifier)
            .syncHeightFromUI(notification.extent);
        // true를 반환하여 이벤트가 위젯 트리 위로 전파되는 것을 막습니다.
        return true;
      },
      child: DraggableScrollableSheet(
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
                  // 선택된 이벤트가 있으면 아이템 개수는 2개(핸들 + 오버뷰 카드),
                  // 없으면 (핸들 + 전체 리스트 개수)
                  itemCount: selectedEvent != null ? 2 : allEvents.length + 1,
                  itemBuilder: (context, index) {
                    // 첫 번째 아이템은 항상 핸들
                    if (index == 0) {
                      return _buildHandle();
                    }

                    // 선택된 이벤트가 있는 경우 (오버뷰 모드)
                    if (selectedEvent != null) {
                      return EventOverviewCard(
                        event: selectedEvent,
                        onBackToList: () {
                          // Strategy에게 전체 목록을 보여달라고 명령
                          ref
                              .read(feedSheetStrategyProvider.notifier)
                              .showFullList();
                        },
                        onViewDetails: () {
                          context.push('/feed/${selectedEvent.id}');
                        },
                      );
                    }
                    // 선택된 이벤트가 없는 경우 (피드 모드)
                    else {
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

  // 핸들 UI 및 동작을 정의하는 위젯
  Widget _buildHandle() {
    return GestureDetector(
      // 핸들을 탭했을 때의 동작
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
        color: Colors.transparent, // 터치 영역을 넓히기 위해 색은 투명
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
