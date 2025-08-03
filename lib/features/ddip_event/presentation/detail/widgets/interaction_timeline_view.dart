import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class InteractionTimelineView extends ConsumerWidget {
  final DdipEvent event;

  const InteractionTimelineView({super.key, required this.event});

  String _getSystemMessage(Interaction interaction) {
    switch (interaction.actionType) {
      case ActionType.expire:
        return '⏳ 30분 동안 지원자가 없어 요청이 만료되었습니다.';
      case ActionType.rewardPaid:
        return '💰 미션이 완료되어 수행자에게 보상이 지급되었습니다.';
      case ActionType.selectResponder:
        final responderName =
            mockUsers
                .firstWhere(
                  (user) => user.id == event.selectedResponderId,
                  orElse:
                      () => User(
                        id: event.selectedResponderId!,
                        name: '알 수 없는 수행자',
                      ),
                )
                .name;
        return '🤝 $responderName 님과 매칭되었습니다. 지금부터 미션을 시작해주세요!';
      default:
        return '시스템 알림이 도착했습니다.';
    }
  }

  String _getChatMessage(Interaction interaction) {
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
    initializeDateFormatting('ko_KR');
    final currentUser = ref.watch(authProvider);
    if (currentUser == null || event.interactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedInteractions = List<Interaction>.from(event.interactions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text('대화 기록', style: Theme.of(context).textTheme.titleMedium),
        ),
        ...sortedInteractions.map((interaction) {
          switch (interaction.actorRole) {
            case ActorRole.system:
              return _SystemMessage(message: _getSystemMessage(interaction));
            case ActorRole.requester:
            case ActorRole.responder:
              final bool isPhotoAttached =
                  (interaction.actionType == ActionType.submitPhoto ||
                      interaction.actionType == ActionType.reportSituation) &&
                  interaction.relatedPhotoId != null;

              if (isPhotoAttached) {
                return GestureDetector(
                  onTap: () {
                    context.push(
                      '/feed/${event.id}/photo/${interaction.relatedPhotoId}',
                    );
                  },
                  child: _PhotoChatBubble(
                    interaction: interaction,
                    message: _getChatMessage(interaction),
                    isMe: interaction.actorId == currentUser.id,
                  ),
                );
              }
              final bool isMe = interaction.actorId == currentUser.id;
              final String message = _getChatMessage(interaction);
              if (interaction.actionType == ActionType.selectResponder) {
                return const SizedBox.shrink();
              }
              return _ChatBubble(
                interaction: interaction,
                message: message,
                isMe: isMe,
              );
            default:
              return const SizedBox.shrink();
          }
        }).toList(),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final Interaction interaction;
  final String message;
  final bool isMe;

  const _ChatBubble({
    required this.interaction,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat(
      'a h:mm',
      'ko_KR',
    ).format(interaction.timestamp);
    return Align(
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

class _SystemMessage extends StatelessWidget {
  final String message;

  const _SystemMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
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

// 사진 제출 메시지를 위한 새로운 스타일의 말풍선 위젯을 추가합니다.
class _PhotoChatBubble extends StatelessWidget {
  final Interaction interaction;
  final String message;
  final bool isMe;

  const _PhotoChatBubble({
    required this.interaction,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat(
      'a h:mm',
      'ko_KR',
    ).format(interaction.timestamp);

    // 기존 _ChatBubble 위젯을 복사하여 UI를 꾸밉니다.
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          border: Border.all(
            color: Colors.blue.shade300,
            width: 1.5,
          ), // 강조를 위한 테두리 추가
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
            // 아이콘과 텍스트를 함께 보여줍니다.
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.photo_camera_back_outlined,
                  size: 18,
                  color: Colors.black54,
                ),
                const SizedBox(width: 8),
                Text(message, style: const TextStyle(fontSize: 15)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "탭하여 사진 확인",
              style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
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
