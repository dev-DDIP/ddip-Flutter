// lib/features/ddip_event/presentation/detail/screens/event_detail_screen.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/detail/viewmodels/event_detail_view_model.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/CommandBar.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/mission_briefing_header.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/mission_control_header.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/mission_location_map.dart';
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

  /// 미션 중단 확인 다이얼로그를 표시하는 메서드
  void _showCancelConfirmationDialog(
    BuildContext context,
    EventDetailViewModel viewModel,
  ) {
    // 현재 로그인한 유저와 이벤트 정보를 가져옵니다.
    final currentUser = ref.read(authProvider);
    final event = viewModel.state.event.value;
    if (currentUser == null || event == null) return;

    final isRequester = event.requesterId == currentUser.id;
    final hasPhotoBeenSubmitted = event.photos.isNotEmpty;

    // 역할과 상황에 따라 다른 UI 텍스트와 정책을 설정합니다.
    String title = '';
    String content = '';

    if (isRequester) {
      title = '미션 중단하기';
      if (hasPhotoBeenSubmitted) {
        // [정책 변경] 1차 사진 전송 후: 일부 보상
        content =
            '지금 중단하면 미션이 실패 처리되고, 수행자의 기여도를 고려하여 보상금의 일부가 지급됩니다. 정말 중단하시겠습니까?';
      } else {
        // [정책 변경] 1차 사진 전송 전: 보상 없음
        content =
            '지금 중단하면 미션이 실패 처리됩니다. 아직 수행자가 활동을 시작하지 않아 별도의 보상금은 지급되지 않습니다. 정말 중단하시겠습니까?';
      }
    } else {
      // 수행자의 경우
      if (hasPhotoBeenSubmitted) {
        // [신규] 1차 사진 전송 후: '중단'으로 표현, 일부 보상
        title = '미션 중단하기';
        content =
            '여기까지 진행한 미션을 중단하시겠습니까? 지금 중단하면 기여도를 인정받아 보상금의 일부를 지급받을 수 있습니다.';
      } else {
        // [기존] 1차 사진 전송 전: '포기'로 표현, 보상 없음
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
            // [UI 개선] 확인 버튼에 빨간색 배경과 아이콘을 적용하여 위험한 동작임을 강조
            FilledButton.icon(
              icon: const Icon(Icons.warning_amber_rounded),
              label: const Text('확인'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // 다이얼로그 닫기
                viewModel.cancelMission(context); // ViewModel의 cancelMission 호출
              },
            ),
          ],
        );
      },
    );
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
        final currentUser = ref.read(authProvider);
        bool canCancel = false;
        // [UI 개선] 수행자의 상황에 따라 다른 메뉴 텍스트를 보여주기 위한 변수
        String cancelMenuText = '미션 중단하기';

        if (currentUser != null &&
            event.status == DdipEventStatus.in_progress) {
          final isRequester = event.requesterId == currentUser.id;
          final isSelectedResponder =
              event.selectedResponderId == currentUser.id;

          if (isRequester || isSelectedResponder) {
            canCancel = true;
            // [UI 개선] 수행자이고, 사진 제출 전이면 메뉴 텍스트를 '미션 포기하기'로 변경
            if (isSelectedResponder && event.photos.isEmpty) {
              cancelMenuText = '미션 포기하기';
            }
          }
        }

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
                                            cancelMenuText, // 상황에 맞는 텍스트 사용
                                            style: TextStyle(
                                              color: Colors.red.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // TODO: 여기에 다른 메뉴(예: 신고하기) 추가 가능
                                  ],
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
