// lib/features/ddip_event/presentation/detail/widgets/mission_briefing_header.dart

import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
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
    // Provider를 통해 요청자 정보를 가져옵니다.
    final requester = ref
        .watch(mockUsersProvider)
        .firstWhere(
          (user) => user.id == event.requesterId,
          orElse: () => User(id: event.requesterId, name: '알 수 없는 작성자'),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 제목 및 상태 뱃지
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
          const SizedBox(height: 16),

          // 2. 요청자 정보 (v2.0 강화된 UI)
          GestureDetector(
            onTap: () {
              // TODO: 사용자 프로필 상세 페이지로 이동하는 로직 구현
              // context.push('/profile/${requester.id}');
              print('Requestor tapped: ${requester.id}');
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
                          requester.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Wrap 위젯으로 평판 칩들을 유연하게 표시
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
                            // TODO: 실제 데이터와 연동
                            Chip(
                              label: const Text("북문 지박령"),
                              labelStyle: const TextStyle(
                                fontSize: 11,
                                color: Colors.deepPurple,
                              ),
                              backgroundColor: Colors.deepPurple.withOpacity(
                                0.1,
                              ),
                              side: BorderSide.none,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 보상 정보
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
          const SizedBox(height: 16),
          // 3. 미션 진행률 표시줄
          _buildProgressBar(context, event),
          const SizedBox(height: 16),
          // 4. 헤더와 탭 바를 구분하는 선
          const Divider(height: 1),
        ],
      ),
    );
  }

  /// 평판 정보를 보여주는 작은 칩 위젯
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

  /// 이벤트 상태에 따라 다른 색상과 텍스트의 뱃지를 생성
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

  /// 미션 진행 상태를 시각적으로 보여주는 스테퍼 위젯
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
                : isActive
                ? Theme.of(context).primaryColor
                : Colors.grey.shade300;

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
                  // 첫 번째 스텝이 아니면 왼쪽 라인 그림
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
                  // 마지막 스텝이 아니면 오른쪽 라인 그림
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
