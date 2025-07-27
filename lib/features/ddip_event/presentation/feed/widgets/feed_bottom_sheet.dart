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
  static const double _peekOverviewFraction = 0.25;
  static const double _overviewFraction = 0.50;
  static const double _fullListFraction = 0.90;

  @override
  void initState() {
    super.initState();
    // [수정 2] 위젯이 빌드된 후, 상태 변화를 감지하는 리스너 설정
    // initState에서 ref를 직접 사용하면 안되므로, addPostFrameCallback을 사용해 안전하게 호출합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // selectedEventIdProvider의 상태 변화를 '구독'합니다.
      ref.listen<String?>(selectedEventIdProvider, (previous, next) {
        // [핵심 로직] '이벤트 오버뷰' 상태에서 '전체 목록' 상태로 돌아올 때를 감지
        // (previous는 ID가 있었고, next는 ID가 없어졌을 때)
        if (previous != null && next == null) {
          // 컨트롤러를 사용해 바텀 시트를 'peek' 상태로 애니메이션합니다.
          if (_scrollController.isAttached) {
            _scrollController.animateTo(
              _peekFraction, // 목표 높이
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
            );
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // 컨트롤러 리소스 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<FeedBottomSheetState>(feedBottomSheetStateProvider, (
      prev,
      next,
    ) {
      if (!mounted || !_scrollController.isAttached) return;

      final targetFraction = switch (next) {
        FeedBottomSheetState.peek => _peekFraction,
        FeedBottomSheetState.peekOverview => _peekOverviewFraction,
        FeedBottomSheetState.overview => _overviewFraction,
        FeedBottomSheetState.fullList => _fullListFraction,
      };

      // 현재 사이즈와 목표 사이즈가 다를 때만 애니메이션 실행
      if ((_scrollController.size - targetFraction).abs() > 0.01) {
        _scrollController.animateTo(
          targetFraction,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });

    // [핵심 수정] 데이터 로딩 상태를 숨기는 ddipFeedProvider 대신,
    // 로딩/에러 상태를 모두 포함하는 원본 ddipEventsNotifierProvider를 watch합니다.
    final eventsState = ref.watch(ddipEventsNotifierProvider);
    final selectedEventId = ref.watch(selectedEventIdProvider);
    final isEventSelected = selectedEventId != null;

    final List<double> snapSizes =
        selectedEventId != null
            ? const [
              _peekOverviewFraction,
              _overviewFraction,
              _fullListFraction,
            ] // 오버뷰 모드: 3단 스냅
            : const [_peekFraction, _fullListFraction]; // 기본 목록 모드: 2단 스냅
    final minFraction = isEventSelected ? _peekOverviewFraction : _peekFraction;

    return DraggableScrollableSheet(
      controller: _scrollController,
      initialChildSize: minFraction,
      minChildSize: minFraction,
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
                    // ▼▼▼ 여기가 핵심 수정 포인트입니다! ▼▼▼
                    return EventOverviewCard(
                      event: selectedEvent,
                      onBackToList: () {
                        // [1단계] 데이터 상태 변경: 선택된 이벤트를 해제합니다.
                        // 이 코드가 실행되면, 다음 build 사이클에서 isEventSelected가 false가 되고
                        // DraggableScrollableSheet의 minChildSize와 snapSizes가
                        // '전체 목록' 모드에 맞게 변경되도록 예약됩니다.
                        ref.read(selectedEventIdProvider.notifier).state = null;

                        // [2단계] UI 상태 변경: 바텀 시트에게 '전체 목록' 상태로 가라고 명확히 명령합니다.
                        // 이 코드가 실행되면, build 메서드 상단의 ref.listen이 이 상태 변화를 감지하고
                        // 컨트롤러를 사용해 _fullListFraction(0.9) 높이로 애니메이션을 실행합니다.
                        ref.read(feedBottomSheetStateProvider.notifier).state =
                            FeedBottomSheetState.fullList;
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

        // ✨ 탭 핸들러 로직 개선
        final isMinimizable =
            currentState == FeedBottomSheetState.fullList ||
            currentState == FeedBottomSheetState.overview;

        if (isMinimizable) {
          final isEventSelected = ref.read(selectedEventIdProvider) != null;
          notifier.state =
              isEventSelected
                  ? FeedBottomSheetState.peekOverview
                  : FeedBottomSheetState.peek;
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
}
