// lib/features/ddip_event/presentation/view/widgets/interaction_timeline_view.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// 이벤트의 모든 상호작용 기록을 타임라인 형태로 보여주는 위젯
class InteractionTimelineView extends ConsumerWidget {
  final DdipEvent event;

  const InteractionTimelineView({super.key, required this.event});

  // 각 Interaction 객체를 사용자 친화적인 텍스트로 변환하는 헬퍼 함수
  String _formatInteractionMessage(Interaction interaction, WidgetRef ref) {
    final actorName =
        mockUsers.firstWhere((user) => user.id == interaction.actorId).name;

    switch (interaction.actionType) {
      case ActionType.create:
        return '$actorName님이 요청을 생성했습니다.';
      case ActionType.apply:
        return '$actorName님이 지원했습니다.';
      case ActionType.selectResponder:
        return '요청자가 $actorName님을 수행자로 선택했습니다.';
      case ActionType.submitPhoto:
        return '$actorName님이 사진을 제출했습니다.';
      case ActionType.approve:
        return '요청자가 제출된 사진을 승인했습니다.';
      case ActionType.requestRevision:
        // 거절 사유(messageCode)가 있는 경우 함께 표시
        final reason = _formatMessageCode(interaction.messageCode);
        return '요청자가 사진 수정을 요청했습니다: "$reason"';
      case ActionType.reportSituation:
        final situation = _formatMessageCode(interaction.messageCode);
        return '$actorName님이 현장 상황을 보고했습니다: "$situation"';
      default:
        return '알 수 없는 활동이 기록되었습니다.';
    }
  }

  // MessageCode Enum을 실제 텍스트로 변환하는 헬퍼 함수
  String _formatMessageCode(MessageCode? code) {
    switch (code) {
      case MessageCode.blurred:
        return '사진이 흐려요';
      case MessageCode.tooFar:
        return '너무 멀리서 찍었어요';
      case MessageCode.wrongSubject:
        return '요청한 대상이 아니에요';
      case MessageCode.soldOut:
        return '재료가 소진되어 마감됐어요';
      case MessageCode.longQueue:
        return '대기 줄이 너무 길어요';
      case MessageCode.placeClosed:
        return '요청 장소가 현재 닫혀있어요';
      default:
        return '사유 미지정';
    }
  }

  // 각 ActionType에 맞는 아이콘을 반환하는 헬퍼 함수
  IconData _getIconForAction(ActionType actionType) {
    switch (actionType) {
      case ActionType.create:
        return Icons.add_circle_outline;
      case ActionType.apply:
        return Icons.pan_tool_outlined;
      case ActionType.selectResponder:
        return Icons.how_to_reg_outlined;
      case ActionType.submitPhoto:
        return Icons.camera_alt_outlined;
      case ActionType.approve:
        return Icons.thumb_up_alt_outlined;
      case ActionType.requestRevision:
        return Icons.thumb_down_alt_outlined;
      case ActionType.reportSituation:
        return Icons.report_problem_outlined;
      default:
        return Icons.history;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 상호작용이 없으면 아무것도 표시하지 않음
    if (event.interactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 24.0, bottom: 8.0),
          child: Text('활동 기록', style: Theme.of(context).textTheme.titleMedium),
        ),
        // 상호작용 목록을 시간순으로 표시
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: event.interactions.length,
          itemBuilder: (context, index) {
            final interaction = event.interactions[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    _getIconForAction(interaction.actionType),
                    size: 20,
                  ),
                ),
                title: Text(_formatInteractionMessage(interaction, ref)),
                subtitle: Text(
                  DateFormat(
                    'yyyy년 MM월 dd일 HH:mm',
                  ).format(interaction.timestamp),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
