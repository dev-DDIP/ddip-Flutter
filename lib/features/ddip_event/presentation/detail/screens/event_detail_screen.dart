// lib/features/ddip_event/presentation/detail/screens/event_detail_screen.dart

import 'package:ddip/features/ddip_event/presentation/detail/widgets/CommandBar.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/communication_log_sliver.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/detailed_request_card.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/mission_briefing_header.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/mission_control_header.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/mission_location_map.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/situational_guide_banner.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ConsumerWidget을 ConsumerStatefulWidget으로 변경하여 위젯의 생명주기를 관리합니다.
class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  // CommandBar의 크기를 측정하고 참조하기 위한 GlobalKey 생성
  final GlobalKey _commandBarKey = GlobalKey();

  // 측정된 높이를 저장할 상태 변수 (초기 추정치 제공)
  double _commandBarHeight = 120.0;

  @override
  void initState() {
    super.initState();
    // 위젯이 렌더링된 직후에 CommandBar의 높이를 측정하는 콜백을 등록합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _commandBarKey.currentContext != null) {
        final RenderBox renderBox =
            _commandBarKey.currentContext!.findRenderObject() as RenderBox;
        // 측정된 높이가 현재 상태와 다를 경우에만 상태를 업데이트하여 불필요한 재빌드를 방지합니다.
        if (_commandBarHeight != renderBox.size.height) {
          setState(() {
            _commandBarHeight = renderBox.size.height;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // StatefulWidget에서는 widget.eventId로 파라미터에 접근합니다.

    final viewModel = ref.read(
      eventDetailViewModelProvider(widget.eventId).notifier,
    );

    final viewModelState = ref.watch(
      eventDetailViewModelProvider(widget.eventId),
    );

    final isCommandBarVisible = ref.watch(commandBarVisibilityProvider);

    return viewModelState.event.when(
      loading:
          () => Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (err, stack) => Scaffold(
            appBar: AppBar(
              title: const Text('오류'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: Center(child: Text('오류가 발생했습니다: $err')),
          ),
      data: (event) {
        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    title: Text(event.title),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: MissionBriefingHeader(event: event),
                  ),
                  SliverToBoxAdapter(
                    child: MissionControlHeader(
                      stage: viewModelState.missionStage,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [MissionLocationMap(event: event)],
                    ),
                  ),
                  ...viewModel.buildMissionLogSlivers(event),
                  // 고정 값 대신 측정된 높이(_commandBarHeight)를 사용합니다.
                  SliverToBoxAdapter(
                    child: SizedBox(height: _commandBarHeight),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                // CommandBar에 GlobalKey를 할당하여 위젯을 특정하고 크기를 측정할 수 있도록 합니다.
                child:
                    isCommandBarVisible
                        ? CommandBar(key: _commandBarKey, event: event)
                        : const SizedBox.shrink(), // 보이지 않을 때는 빈 위젯 렌더링
              ),
            ],
          ),
        );
      },
    );
  }
}
