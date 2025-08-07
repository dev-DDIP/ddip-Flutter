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
    // 1. ViewModel을 구독(watch)하여 데이터 변경 시 UI가 자동으로 다시 그려지도록 합니다.
    final eventDetailState = ref.watch(eventDetailViewModelProvider(event.id));
    final viewModel = ref.read(eventDetailViewModelProvider(event.id).notifier);

    // 2. AsyncValue를 사용하여 로딩, 에러, 데이터 상태를 안전하게 처리합니다.
    return eventDetailState.event.when(
      data:
          (currentEvent) => Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    // 미션 브리핑 헤더
                    SliverToBoxAdapter(
                      child: MissionBriefingHeader(event: currentEvent),
                    ),
                    // ViewModel의 builder를 호출하여 동적 Sliver 목록을 가져옴
                    ...viewModel.buildMissionLogSlivers(currentEvent),
                  ],
                ),
              ),
              // 커맨드 바
              CommandBar(event: currentEvent),
            ],
          ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('오류가 발생했습니다: $error')),
    );
  }
}
