import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/ddip_list_item.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/event_overview_card.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
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

  static const double _peekFraction = 0.10;
  static const double _overviewFraction = 0.50;
  static const double _fullListFraction = 0.90;

  @override
  Widget build(BuildContext context) {
    ref.listen<FeedBottomSheetState>(feedBottomSheetStateProvider, (
      prev,
      next,
    ) {
      if (!mounted || !_scrollController.isAttached) return;

      final targetFraction = switch (next) {
        FeedBottomSheetState.peek => _peekFraction,
        FeedBottomSheetState.overview => _overviewFraction,
        FeedBottomSheetState.fullList => _fullListFraction,
      };

      Future.microtask(() {
        if (mounted && _scrollController.isAttached) {
          if ((_scrollController.size - targetFraction).abs() > 0.01) {
            _scrollController.animateTo(
              targetFraction,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        }
      });
    });

    // [핵심 수정] 데이터 로딩 상태를 숨기는 ddipFeedProvider 대신,
    // 로딩/에러 상태를 모두 포함하는 원본 ddipEventsNotifierProvider를 watch합니다.
    final eventsState = ref.watch(ddipEventsNotifierProvider);
    final selectedEventId = ref.watch(selectedEventIdProvider);

    final allEvents = ref.watch(ddipFeedProvider);

    final selectedEvent =
        selectedEventId != null
            ? allEvents.firstWhereOrNull((e) => e.id == selectedEventId)
            : null;

    final List<double> snapSizes =
        selectedEventId != null
            ? const [
              _peekFraction,
              _overviewFraction,
              _fullListFraction,
            ] // 오버뷰 모드: 3단 스냅
            : const [_peekFraction, _fullListFraction]; // 기본 목록 모드: 2단 스냅

    return DraggableScrollableSheet(
      controller: _scrollController,
      initialChildSize: _peekFraction,
      minChildSize: _peekFraction,
      maxChildSize: _fullListFraction,
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
          // [핵심 수정] eventsState.when을 사용하여 로딩, 에러, 데이터 상태를 명확히 분기합니다.
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
                        ref.read(selectedEventIdProvider.notifier).state = null;
                        ref.read(feedBottomSheetStateProvider.notifier).state =
                            FeedBottomSheetState.peek;
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
        final notifier = ref.read(feedBottomSheetStateProvider.notifier);
        final currentState = ref.read(feedBottomSheetStateProvider);
        notifier.state =
            currentState == FeedBottomSheetState.fullList
                ? FeedBottomSheetState.peek
                : FeedBottomSheetState.fullList;
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
