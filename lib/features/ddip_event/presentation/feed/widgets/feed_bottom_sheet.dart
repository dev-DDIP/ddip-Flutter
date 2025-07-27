import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/ddip_list_item.dart';
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

  double _peekFraction = 0.15;
  double _overviewFraction = 0.25;
  final double _fullListFraction = 0.85;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final currentSize = _scrollController.size;
      final notifier = ref.read(feedBottomSheetStateProvider.notifier);
      final currentState = ref.read(feedBottomSheetStateProvider);

      if ((currentSize - _fullListFraction).abs() < 0.01 &&
          currentState != FeedBottomSheetState.fullList) {
        // fullList 상태로 변경되었음을 Riverpod에 알림
        notifier.state = FeedBottomSheetState.fullList;
      } else if ((currentSize - _peekFraction).abs() < 0.01 &&
          currentState != FeedBottomSheetState.peek) {
        // peek 상태로 변경되었음을 Riverpod에 알림
        notifier.state = FeedBottomSheetState.peek;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    _peekFraction = (120.0 + bottomPadding) / screenHeight;
    _overviewFraction = (160.0 + bottomPadding) / screenHeight;

    // Riverpod 상태 변경을 감지하고, 컨트롤러를 이용해 시트 애니메이션 실행
    ref.listen<FeedBottomSheetState>(feedBottomSheetStateProvider, (
      prev,
      next,
    ) {
      if (!mounted || !_scrollController.isAttached) return;

      double targetFraction = switch (next) {
        FeedBottomSheetState.peek => _peekFraction,
        FeedBottomSheetState.overview => _overviewFraction,
        FeedBottomSheetState.fullList => _fullListFraction,
      };

      if ((_scrollController.size - targetFraction).abs() > 0.01) {
        _scrollController.animateTo(
          targetFraction,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
        );
      }
    });

    final allEvents = ref.watch(ddipFeedProvider);
    final selectedEventId = ref.watch(selectedEventIdProvider);
    final sheetState = ref.watch(feedBottomSheetStateProvider);

    return DraggableScrollableSheet(
      controller: _scrollController,
      initialChildSize: _peekFraction,
      minChildSize: _peekFraction,
      maxChildSize: _fullListFraction,
      snap: true,
      // 1. overview에서 아래로 내렸을 때 peek으로 돌아가도록 snapSizes에 peekFraction 추가
      snapSizes: [_peekFraction, _fullListFraction],
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
            ],
          ),
          // 2. 핸들을 ListView의 첫 번째 아이템으로 통합하여 핸들 드래그 문제 해결
          child: ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.zero,
            itemCount: _getItemCount(sheetState, allEvents),
            itemBuilder: (context, index) {
              // --- Index 0: 핸들러 ---
              if (index == 0) {
                return _buildHandle(sheetState);
              }

              // --- 리스트 아이템 ---
              final event = _getEventForIndex(
                sheetState,
                allEvents,
                selectedEventId,
                index,
              );
              if (event == null) return const SizedBox.shrink();

              // peek 상태에서는 첫 아이템 외에는 보이지 않도록 함
              if (sheetState == FeedBottomSheetState.peek && (index - 1) > 0) {
                return const SizedBox.shrink();
              }

              return GestureDetector(
                onTap: () => context.push('/feed/${event.id}'),
                child: DdipListItem(
                  event: event,
                  isPeek: sheetState == FeedBottomSheetState.peek,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHandle(FeedBottomSheetState state) {
    return GestureDetector(
      onTap: () {
        final notifier = ref.read(feedBottomSheetStateProvider.notifier);
        if (state == FeedBottomSheetState.fullList) {
          notifier.state = FeedBottomSheetState.peek;
        } else {
          notifier.state = FeedBottomSheetState.fullList;
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

  int _getItemCount(FeedBottomSheetState state, List<DdipEvent> allEvents) {
    switch (state) {
      case FeedBottomSheetState.overview:
        return 2; // 핸들러 + 1개 아이템
      case FeedBottomSheetState.peek:
      case FeedBottomSheetState.fullList:
        return allEvents.length + 1; // 핸들러 + 전체 아이템
    }
  }

  DdipEvent? _getEventForIndex(
    FeedBottomSheetState state,
    List<DdipEvent> allEvents,
    String? selectedEventId,
    int index,
  ) {
    if (state == FeedBottomSheetState.overview) {
      return allEvents.firstWhereOrNull((e) => e.id == selectedEventId);
    }
    return allEvents[index - 1];
  }
}
