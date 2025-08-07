// lib/features/ddip_event/presentation/detail/widgets/mission_control_layout.dart

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/CommandBar.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/MissionBriefingHeader.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MissionControlLayout extends ConsumerWidget {
  final DdipEvent event;
  final ScrollController scrollController;

  const MissionControlLayout({
    super.key,
    required this.event,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventDetailState = ref.watch(eventDetailViewModelProvider(event.id));
    final viewModel = ref.read(eventDetailViewModelProvider(event.id).notifier);

    return eventDetailState.event.when(
      data:
          (currentEvent) => Stack(
            children: [
              // 배경이 될 스크롤 뷰
              CustomScrollView(
                controller: scrollController,
                // [오류 수정] CustomScrollView의 잘못된 padding 속성은 여기서 제거합니다.
                slivers: [
                  // 1. 미션 브리핑 헤더 Sliver
                  SliverToBoxAdapter(
                    child: MissionBriefingHeader(event: currentEvent),
                  ),
                  // 2. 미션 로그 Sliver 목록
                  ...viewModel.buildMissionLogSlivers(currentEvent),

                  // 3. [핵심 수정] 맨 마지막에 '투명한 여백' Sliver를 추가합니다.
                  // 이 SizedBox가 CommandBar의 높이만큼의 공간을 차지하여,
                  // 스크롤의 마지막 내용이 버튼에 가려지는 것을 완벽하게 방지합니다.
                  const SliverToBoxAdapter(child: SizedBox(height: 100.0)),
                ],
              ),
              // 최상단에 위치할 커맨드 바
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CommandBar(event: currentEvent),
              ),
            ],
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('오류가 발생했습니다: $error')),
    );
  }
}
