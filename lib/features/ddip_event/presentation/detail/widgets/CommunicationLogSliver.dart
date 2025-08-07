// lib/features/ddip_event/presentation/detail/widgets/communication_log_sliver.dart

import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// '커뮤니케이션 로그' UI를 그리는 모든 책임을 가지는 전용 Sliver 위젯입니다.
class CommunicationLogSliver extends ConsumerWidget {
  final DdipEvent event;

  const CommunicationLogSliver({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (event.interactions.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final sortedInteractions = List<Interaction>.from(event.interactions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return SliverList.separated(
      itemCount: sortedInteractions.length,
      itemBuilder: (context, index) {
        final interaction = sortedInteractions[index];
        return _buildChatBubbleFromInteraction(
          context,
          ref,
          event,
          interaction,
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
  }

  /// Interaction 객체를 적절한 채팅 버블 위젯으로 변환하는 헬퍼 메서드
  Widget _buildChatBubbleFromInteraction(
    BuildContext context,
    WidgetRef ref,
    DdipEvent event,
    Interaction interaction,
  ) {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return const SizedBox.shrink();

    final message = _getChatMessage(ref, interaction, event);
    final isMe = interaction.actorId == currentUser.id;

    switch (interaction.actorRole) {
      case ActorRole.system:
        return _SystemMessage(message: message);
      case ActorRole.requester:
      case ActorRole.responder:
        final isPhotoAttached = interaction.relatedPhotoId != null;
        if (isPhotoAttached) {
          return GestureDetector(
            onTap: () {
              context.push(
                '/feed/${event.id}/photo/${interaction.relatedPhotoId}',
              );
            },
            child: _PhotoChatBubble(
              interaction: interaction,
              message: message,
              isMe: isMe,
            ),
          );
        }
        return _ChatBubble(
          interaction: interaction,
          message: message,
          isMe: isMe,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // Interaction 객체로부터 표시할 메시지 텍스트를 생성
  String _getChatMessage(
    WidgetRef ref,
    Interaction interaction,
    DdipEvent event,
  ) {
    switch (interaction.actionType) {
      case ActionType.selectResponder:
        final responderName =
            ref
                .watch(mockUsersProvider)
                .firstWhere(
                  (user) => user.id == event.selectedResponderId,
                  orElse: () => User(id: '', name: '수행자'),
                )
                .name;
        return '🤝 $responderName 님과 매칭되었습니다. 지금부터 미션을 시작해주세요!';
      case ActionType.submitPhoto:
        return '사진을 제출했어요. 확인해주세요!';
      case ActionType.approve:
        return '사진을 확인했어요. 미션 완료!';
      default:
        return '새로운 활동이 기록되었습니다.';
    }
  }
}

// ▼▼▼ 아래는 기존 InteractionTimelineView에 있던 채팅 버블 위젯들입니다. 이 파일 안으로 옮겨옵니다. ▼▼▼

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
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          border: Border.all(color: Colors.blue.shade300, width: 1.5),
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
