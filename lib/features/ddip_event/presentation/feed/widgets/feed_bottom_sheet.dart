// lib/features/ddip_event/presentation/feed/widgets/feed_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/ddip_list_item.dart';

// FeedBottomSheet 위젯 정의
class FeedBottomSheet extends ConsumerStatefulWidget {
  const FeedBottomSheet({super.key});

  @override
  ConsumerState<FeedBottomSheet> createState() => _FeedBottomSheetState();
}

// FeedBottomSheet의 상태를 관리하는 State 클래스
class _FeedBottomSheetState extends ConsumerState<FeedBottomSheet> {
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();

  // 시트의 높이를 나타내는 값들을 상수로 관리하여 명확성을 높입니다.
  static const double _peekFraction = 0.15;
  static const double _overviewFraction = 0.25;
  static const double _fullListFraction = 0.85;

  @override
  void initState() {
    super.initState();
    // 복잡성과 버그의 원인이었던 _scrollController.addListener는 완전히 제거되었습니다.
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod 상태 변경을 감지하여 시트의 높이를 애니메이션으로 조절하는 핵심 로직입니다.
    // 이 리스너는 이제 지도 마커 탭, 핸들 탭 등 외부의 '명령'에만 반응하는 명확한 역할을 가집니다.
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

      // Future.microtask를 사용해 애니메이션 명령을 현재 빌드 사이클 직후에 실행합니다.
      // 이를 통해 위젯 리빌드와 애니메이션 시작 간의 충돌을 방지하여 애니메이션이 끊기지 않게 합니다.
      Future.microtask(() {
        if (mounted && _scrollController.isAttached) {
          // 현재 위치와 목표 위치가 다를 때만 애니메이션을 실행합니다.
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

    final allEvents = ref.watch(ddipFeedProvider);

    return DraggableScrollableSheet(
      controller: _scrollController,
      initialChildSize: _peekFraction,
      minChildSize: _peekFraction,
      maxChildSize: _fullListFraction,
      snap: true,
      snapSizes: const [_peekFraction, _fullListFraction],
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
            ],
          ),
          // [핵심 개선] 이제 ListView는 어떤 상태이든 항상 '전체 이벤트 목록'을 표시합니다.
          // 복잡한 분기 로직을 제거하여 탭/드래그 시 화면이 달라지는 문제를 원천적으로 해결합니다.
          child: ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.zero,
            itemCount: allEvents.length + 1, // +1 for the handle
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildHandle();
              }
              final event = allEvents[index - 1];
              return DdipListItem(event: event);
            },
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return GestureDetector(
      // [핵심 개선] 핸들 탭 로직이 매우 단순하고 명확해졌습니다.
      onTap: () {
        final notifier = ref.read(feedBottomSheetStateProvider.notifier);
        final currentState = ref.read(feedBottomSheetStateProvider);

        // 시트가 완전히 펼쳐져 있으면(fullList) -> 닫고(peek)
        // 그렇지 않으면 -> 완전히 펼치도록(fullList) 상태를 변경합니다.
        // 이 상태 변경은 위 ref.listen이 감지하여 애니메이션을 실행시킵니다.
        notifier.state =
            currentState == FeedBottomSheetState.fullList
                ? FeedBottomSheetState.peek
                : FeedBottomSheetState.fullList;
      },
      child: Container(
        width: double.infinity,
        color: Colors.transparent, // 터치 영역을 넓히기 위해 색상은 투명으로 설정
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
