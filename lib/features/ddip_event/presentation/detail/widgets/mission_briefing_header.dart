// lib/features/ddip_event/presentation/detail/widgets/mission_briefing_header.dart

import 'package:ddip/common/utils/time_utils.dart';
import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// 상세 화면의 모든 헤더 정보를 표시하는 책임을 가지는 독립된 위젯입니다.
/// DdipEvent 객체 하나만 받아서 '미션 브리핑' 섹션 전체를 그립니다.
class MissionBriefingHeader extends ConsumerWidget {
  final DdipEvent event;

  const MissionBriefingHeader({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. 역할 및 상태 확인 로직
    final allUsers = ref.watch(mockUsersProvider);
    final currentUser = ref.watch(authProvider);
    final viewModelState = ref.watch(eventDetailViewModelProvider(event.id));

    final bool isRequester = currentUser?.id == event.requesterId;
    final bool isResponderSelected = event.selectedResponderId != null;

    // 표시할 유저와 역할 텍스트를 담을 변수
    User displayUser;
    String displayRoleText;

    // 2. 조건에 따라 표시할 유저와 텍스트를 결정
    //    - 내가 요청자이고 수행자가 선택되었다면 "수행자 정보"를 표시
    //    - 그 외의 모든 경우(내가 수행자, 제3자, 아직 수행자 미선택)는 "요청자 정보"를 표시
    if (isRequester && isResponderSelected) {
      displayRoleText = '수행자 정보';
      displayUser = allUsers.firstWhere(
        (user) => user.id == event.selectedResponderId,
        orElse: () => User(id: event.selectedResponderId!, name: '알 수 없는 수행자'),
      );
    } else {
      displayRoleText = '요청자 정보';
      displayUser = allUsers.firstWhere(
        (user) => user.id == event.requesterId,
        orElse: () => User(id: event.requesterId, name: '알 수 없는 요청자'),
      );
    }

    // 3. 결정된 정보로 UI를 그립니다.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 및 상태 뱃지 (기존과 동일)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              _buildStatusChip(event.status),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Text(
              '${formatTimeAgo(event.createdAt)}에 요청됨',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),

          // ▼▼▼ 4. 역할 텍스트(Section Title)와 유저 정보 카드 수정 ▼▼▼
          // "요청자 정보" 또는 "수행자 정보" 텍스트 추가
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              displayRoleText,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
            ),
          ),
          // 유저 정보 카드
          GestureDetector(
            onTap: () {
              // 표시된 유저(displayUser)의 프로필로 이동
              context.push('/profile/${displayUser.id}');
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          // 표시된 유저(displayUser)의 이름
                          displayUser.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6.0,
                          runSpacing: 4.0,
                          children: [
                            _buildReputationChip(
                              Icons.star,
                              "4.8",
                              Colors.amber,
                            ),
                            _buildReputationChip(
                              Icons.check_circle,
                              "12회 완료",
                              Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${NumberFormat('#,###').format(event.reward)}원',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ▲▲▲ 4. 역할 텍스트와 유저 정보 카드 수정 완료 ▲▲▲
          const SizedBox(height: 16),
          _buildProgressBar(context, event),

          const SizedBox(height: 16),
          const Divider(height: 1),
        ],
      ),
    );
  }

  // 평판 정보를 보여주는 작은 칩 위젯
  Widget _buildReputationChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, color: color, size: 14),
      label: Text(label),
      labelStyle: TextStyle(fontSize: 11, color: Colors.grey[800]),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.shade300),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  // 이벤트 상태에 따라 다른 색상과 텍스트의 뱃지를 생성
  Widget _buildStatusChip(DdipEventStatus status) {
    Color chipColor;
    String label;
    switch (status) {
      case DdipEventStatus.open:
        chipColor = Colors.blue;
        label = '지원 가능';
        break;
      case DdipEventStatus.in_progress:
        chipColor = Colors.green;
        label = '진행중';
        break;
      case DdipEventStatus.completed:
        chipColor = Colors.grey;
        label = '완료';
        break;
      case DdipEventStatus.failed:
        chipColor = Colors.red;
        label = '실패';
        break;
    }
    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }

  // 미션 진행 상태를 시각적으로 보여주는 스테퍼 위젯
  Widget _buildProgressBar(BuildContext context, DdipEvent event) {
    final steps = ['모집', '진행', '확인', '완료/실패'];
    int currentStep;
    bool isFailed = false;

    switch (event.status) {
      case DdipEventStatus.open:
        currentStep = 0;
        break;
      case DdipEventStatus.in_progress:
        currentStep = 1;
        if (event.photos.any((p) => p.status == PhotoStatus.pending)) {
          currentStep = 2;
        }
        break;
      case DdipEventStatus.completed:
        currentStep = 3;
        break;
      case DdipEventStatus.failed:
        currentStep = 3;
        isFailed = true;
        break;
    }

    return Row(
      children: List.generate(steps.length, (index) {
        final bool isActive = index <= currentStep;
        final bool isCurrent = index == currentStep;
        final Color color =
            isFailed && isCurrent
                ? Colors.red
                : (isActive
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade300);

        Widget icon;
        if (isFailed && isCurrent) {
          icon = const Icon(Icons.close, color: Colors.white, size: 16);
        } else if (isActive) {
          icon = const Icon(Icons.check, color: Colors.white, size: 16);
        } else {
          icon = Text(
            '${index + 1}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          );
        }

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child:
                        index == 0
                            ? Container()
                            : Container(
                              height: 2,
                              color:
                                  isActive || index == currentStep
                                      ? color
                                      : Colors.grey.shade300,
                            ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                    child: Center(child: icon),
                  ),
                  Expanded(
                    child:
                        index == steps.length - 1
                            ? Container()
                            : Container(
                              height: 2,
                              color:
                                  isActive && !isCurrent
                                      ? color
                                      : Colors.grey.shade300,
                            ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                steps[index],
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.black : Colors.grey,
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _TimerDisplay extends StatelessWidget {
  final Stream<Duration> countdownStream;

  const _TimerDisplay({required this.countdownStream});

  @override
  Widget build(BuildContext context) {
    const totalSeconds = 180; // 3분

    return StreamBuilder<Duration>(
      stream: countdownStream,
      builder: (context, snapshot) {
        final remaining =
            snapshot.data ?? const Duration(seconds: totalSeconds);
        final remainingSeconds = remaining.inSeconds;
        final progress = (remainingSeconds / totalSeconds).clamp(0.0, 1.0);

        final minutes = remaining.inMinutes
            .remainder(60)
            .toString()
            .padLeft(2, '0');
        final seconds = remaining.inSeconds
            .remainder(60)
            .toString()
            .padLeft(2, '0');
        final timeString = '$minutes:$seconds';

        final barColor =
            progress < 0.2
                ? Colors.red
                : (progress < 0.5 ? Colors.orange : Colors.blue);

        return Row(
          children: [
            Icon(Icons.timer_outlined, color: Colors.grey.shade600, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              timeString,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        );
      },
    );
  }
}
