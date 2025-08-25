// ▼▼▼ lib/features/ddip_event/presentation/detail/screens/event_detail_screen.dart (최종 전체 코드) ▼▼▼
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/detail/viewmodels/event_detail_view_model.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/CommandBar.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/mission_briefing_header.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/mission_control_header.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/mission_location_map.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/predictive_progress_bar.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/sliver_sticky_header_delegate.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  final GlobalKey _commandBarKey = GlobalKey();
  double _commandBarHeight = 120.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _commandBarKey.currentContext != null) {
        final RenderBox renderBox =
            _commandBarKey.currentContext!.findRenderObject() as RenderBox;
        if (_commandBarHeight != renderBox.size.height) {
          setState(() {
            _commandBarHeight = renderBox.size.height;
          });
        }
      }
    });
  }

  void _showCancelConfirmationDialog(
    BuildContext context,
    EventDetailViewModel viewModel,
  ) {
    final currentUser = ref.read(authProvider);
    final event = viewModel.state.event.value;
    if (currentUser == null || event == null) return;
    final isRequester = event.requesterId == currentUser.id;
    final hasPhotoBeenSubmitted = event.photos.isNotEmpty;

    String title = '';
    String content = '';

    if (isRequester) {
      title = '미션 중단하기';
      if (hasPhotoBeenSubmitted) {
        content =
            '지금 중단하면 미션이 실패 처리되고, 수행자의 기여도를 고려하여 보상금의 일부가 지급됩니다. 정말 중단하시겠습니까?';
      } else {
        content =
            '지금 중단하면 미션이 실패 처리됩니다. 아직 수행자가 활동을 시작하지 않아 별도의 보상금은 지급되지 않습니다. 정말 중단하시겠습니까?';
      }
    } else {
      if (hasPhotoBeenSubmitted) {
        title = '미션 중단하기';
        content =
            '여기까지 진행한 미션을 중단하시겠습니까? 지금 중단하면 기여도를 인정받아 보상금의 일부를 지급받을 수 있습니다.';
      } else {
        title = '미션 포기하기';
        content = '정말 미션을 포기하시겠습니까? 지금 포기하면 보상금을 받을 수 없으며, 평판에 영향을 줄 수 있습니다.';
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('확인'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                viewModel.cancelMission(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        final currentUser = ref.read(authProvider);
        bool canCancel = false;
        String cancelMenuText = '미션 중단하기';

        if (currentUser != null &&
            event.status == DdipEventStatus.in_progress) {
          final isRequester = event.requesterId == currentUser.id;
          final isSelectedResponder =
              event.selectedResponderId == currentUser.id;
          if (isRequester || isSelectedResponder) {
            canCancel = true;
            if (isSelectedResponder && event.photos.isEmpty) {
              cancelMenuText = '미션 포기하기';
            }
          }
        }
        final bool showStickyHeader = viewModelState.stickyHeaderHeight > 0;

        return Scaffold(
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    title: Text(event.title),
                    actions: [
                      if (canCancel)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'cancel') {
                              _showCancelConfirmationDialog(context, viewModel);
                            }
                          },
                          itemBuilder:
                              (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                    PopupMenuItem<String>(
                                      value: 'cancel',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.cancel_outlined,
                                            color: Colors.red.shade700,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            cancelMenuText,
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                        ),
                    ],
                  ),

                  // 1. 스크롤되는 헤더
                  SliverToBoxAdapter(
                    child: MissionBriefingHeader(event: event),
                  ),

                  if (showStickyHeader)
                    // ▼▼▼ [수정] SliverPersistentHeader 메서드 전체 코드 ▼▼▼
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: SliverStickyHeaderDelegate(
                        // ▼▼▼ [수정] ViewModel의 상태 값을 직접 사용합니다.
                        height: viewModelState.stickyHeaderHeight,
                        // ▲▲▲ [수정]
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            PredictiveProgressBar(
                              steps: viewModelState.progressSteps,
                            ),
                            MissionControlHeader(
                              stage: viewModelState.missionStage,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // 3. 나머지 스크롤 콘텐츠
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [MissionLocationMap(event: event)],
                    ),
                  ),
                  ...viewModel.buildMissionLogSlivers(event),
                  SliverToBoxAdapter(
                    child: SizedBox(height: _commandBarHeight),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child:
                    isCommandBarVisible
                        ? CommandBar(key: _commandBarKey, event: event)
                        : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}
