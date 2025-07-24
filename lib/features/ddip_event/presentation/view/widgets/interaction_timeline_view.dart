// lib/features/ddip_event/presentation/view/widgets/interaction_timeline_view.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// 말풍선 UI를 위한 재사용 위젯
class _ChatBubble extends StatelessWidget {
  final Interaction interaction;
  final String message;
  final bool isMe; // 내가 보낸 메시지인지 여부 (오른쪽 정렬)

  const _ChatBubble({
    required this.interaction,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    // 시간 포맷을 '오후 2:30' 과 같이 변경
    final timeString = DateFormat(
      'a h:mm',
      'ko_KR',
    ).format(interaction.timestamp);

    return Align(
      // isMe 값에 따라 정렬 방향 결정
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight:
                isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(message, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 4),
            Text(
              timeString,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

// 시스템 메시지 UI를 위한 재사용 위젯
class _SystemMessage extends StatelessWidget {
  final String message;

  const _SystemMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[300], // 시스템 메시지 배경색
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: Colors.grey[800]),
      ),
    );
  }
}

/// 이벤트의 모든 상호작용 기록을 타임라인 형태로 보여주는 위젯
class InteractionTimelineView extends ConsumerWidget {
  final DdipEvent event;

  const InteractionTimelineView({super.key, required this.event});

  // ActorRole이 'SYSTEM'일 때 표시할 메시지를 생성하는 함수
  String _getSystemMessage(Interaction interaction) {
    switch (interaction.actionType) {
      case ActionType.expire:
        return '⏳ 30분 동안 지원자가 없어 요청이 만료되었습니다.';
      case ActionType.rewardPaid:
        return '💰 미션이 완료되어 수행자에게 보상이 지급되었습니다.';
      case ActionType
          .selectResponder: // 이 액션은 요청자가 하지만, 시스템 알림으로 보여주는 것이 더 자연스러움
        final responderName =
            mockUsers
                .firstWhere((user) => user.id == event.selectedResponderId)
                .name;
        return '🤝 ${responderName}님과 매칭되었습니다. 지금부터 미션을 시작해주세요!';
      default:
        return '시스템 알림이 도착했습니다.';
    }
  }

  // 사용자(requester, responder)가 보낸 메시지 내용을 생성하는 함수
  String _getChatMessage(Interaction interaction) {
    final actorName =
        mockUsers.firstWhere((user) => user.id == interaction.actorId).name;
    switch (interaction.actionType) {
      case ActionType.create:
        return '제가 이 요청을 생성했어요.';
      case ActionType.apply:
        return '제가 이 요청에 지원했어요.';
      case ActionType.submitPhoto:
        return '사진을 제출했어요. 확인해주세요!';
      case ActionType.approve:
        return '사진을 확인했어요. 미션 완료!';
      case ActionType.requestRevision:
        final reason = _formatMessageCode(interaction.messageCode);
        return '사진을 다시 찍어주시겠어요?\n- 사유: "$reason"';
      case ActionType.reportSituation:
        final situation = _formatMessageCode(interaction.messageCode);
        return '현장 상황을 보고드려요.\n- 내용: "$situation"';
      default:
        return '새로운 활동이 기록되었습니다.';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 한국 시간 포맷을 위해 초기화
    initializeDateFormatting('ko_KR');

    // 현재 로그인한 사용자 정보를 가져옵니다.
    final currentUser = ref.watch(authProvider);
    if (currentUser == null || event.interactions.isEmpty) {
      return const SizedBox.shrink();
    }

    // 상호작용 목록을 시간순으로 정렬 (오래된 것이 위로)
    final sortedInteractions = List<Interaction>.from(event.interactions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 24.0, bottom: 8.0),
          child: Text('대화 기록', style: Theme.of(context).textTheme.titleMedium),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedInteractions.length,
          itemBuilder: (context, index) {
            final interaction = sortedInteractions[index];

            // ActorRole에 따라 다른 위젯을 반환합니다.
            switch (interaction.actorRole) {
              case ActorRole.system:
                // 시스템이 보낸 메시지일 경우
                return _SystemMessage(message: _getSystemMessage(interaction));

              case ActorRole.requester:
              case ActorRole.responder:
                // 요청자 또는 응답자가 보낸 메시지일 경우
                final bool isMe = interaction.actorId == currentUser.id;
                final String message = _getChatMessage(interaction);

                // 수행자 선택(selectResponder)은 시스템 메시지로 처리했으므로 여기서는 건너뜁니다.
                if (interaction.actionType == ActionType.selectResponder) {
                  return const SizedBox.shrink();
                }

                return _ChatBubble(
                  interaction: interaction,
                  message: message,
                  isMe: isMe,
                );

              default:
                return const SizedBox.shrink(); // 혹시 모를 예외 처리
            }
          },
        ),
      ],
    );
  }
}
