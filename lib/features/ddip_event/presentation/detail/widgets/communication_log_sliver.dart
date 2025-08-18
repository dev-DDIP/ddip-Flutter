// lib/features/ddip_event/presentation/detail/widgets/communication_log_sliver.dart

import 'dart:io';

import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// '띱' 이벤트의 모든 상호작용을 서사적 타임라인 형태로 보여주는 Sliver 위젯입니다.
class CommunicationLogSliver extends ConsumerWidget {
  final DdipEvent event;

  const CommunicationLogSliver({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 시스템 메시지와 사진 카드를 시간순으로 정렬하기 위해 하나의 리스트로 합칩니다.
    final timelineItems = _buildTimelineItems(event, ref);

    if (timelineItems.isEmpty) {
      // 사진 제출 전 '빈 상태 가이드' UI
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  '수행자가 미션을 수락했습니다.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '곧 현장 사진이 여기에 표시될 거에요.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 타임라인 아이템들을 리스트로 표시합니다.
    return SliverList.separated(
      itemCount: timelineItems.length,
      itemBuilder: (context, index) => timelineItems[index],
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
  }

  /// 이벤트 데이터를 기반으로 타임라인에 표시될 위젯 목록을 생성합니다.
  List<Widget> _buildTimelineItems(DdipEvent event, WidgetRef ref) {
    final List<Widget> items = [];
    final allUsers = ref.watch(mockUsersProvider);

    // 1. 사진과 관련 없는 시스템 상호작용을 필터링하여 시스템 메시지로 추가
    final systemInteractions = event.interactions.where(
      (i) => i.relatedPhotoId == null,
    );
    for (final interaction in systemInteractions) {
      if (interaction.actionType == ActionType.selectResponder) {
        final responderName =
            allUsers
                .firstWhere(
                  (user) => user.id == event.selectedResponderId,
                  orElse: () => User(id: '', name: '수행자'),
                )
                .name;
        items.add(
          _SystemMessage(
            message: '🤝 $responderName 님과 매칭되었습니다. 지금부터 미션을 시작해주세요!',
            timestamp: interaction.timestamp,
          ),
        );
      }
    }

    // 2. 각 사진을 '사진 제출 카드' 위젯으로 변환하여 추가
    for (final photo in event.photos) {
      items.add(_PhotoSubmissionCard(event: event, photo: photo));
    }

    // 3. 타임스탬프를 기준으로 모든 아이템을 정렬
    // items.sort((a, b) => (b.key as ValueKey<DateTime>).value.compareTo((a.key as ValueKey<DateTime>).value));

    return items;
  }
}

/// 사진 제출과 관련된 모든 정보(사진, 코멘트, Q&A)를 담는 카드 위젯
class _PhotoSubmissionCard extends ConsumerWidget {
  final DdipEvent event;
  final Photo photo;

  const _PhotoSubmissionCard({required this.event, required this.photo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    final viewModel = ref.read(eventDetailViewModelProvider(event.id).notifier);
    final isRequester = currentUser?.id == event.requesterId;
    final timeString = DateFormat('a h:mm', 'ko_KR').format(photo.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카드 헤더
            Text(
              '📸 수행자가 $timeString 에 사진을 제출했습니다.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),

            // 사진 썸네일
            GestureDetector(
              onTap: () => context.push('/feed/${event.id}/photo/${photo.id}'),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(photo.url)),
              ),
            ),
            const SizedBox(height: 12),

            // 요청자에게만 보이는 인라인 액션
            if (isRequester && photo.status == PhotoStatus.pending) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInlineAction(
                    context,
                    icon: Icons.question_answer_outlined,
                    label: '사진 내용 질문',
                    onTap: () async {
                      // 질문 입력 다이얼로그를 띄웁니다.
                      final question = await _showQuestionDialog(context);
                      if (question != null && question.isNotEmpty) {
                        // ViewModel의 메서드를 호출합니다.
                        viewModel.askQuestion(photo.id, question);
                      }
                    },
                  ),
                  _buildInlineAction(
                    context,
                    icon: Icons.sync_problem_outlined,
                    label: '사진 재요청',
                    onTap: () async {
                      // 재요청 사유 입력 다이얼로그를 띄웁니다.
                      final reason = await _showRevisionDialog(context);
                      if (reason != null && reason.isNotEmpty) {
                        // ViewModel의 메서드를 호출합니다.
                        viewModel.requestRevision(photo.id, reason);
                      }
                    },
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "※ 사진 내용이 궁금하면 '질문', 다른 사진이 필요하면 '재요청'을 선택하세요.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ],

            // 최종 피드백 상태 표시
            if (photo.status != PhotoStatus.pending)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: _buildFeedbackChip(photo.status),
              ),
          ],
        ),
      ),
    );
  }

  // '사진 내용 질문' 다이얼로그
  Future<String?> _showQuestionDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('사진에 대한 질문 입력'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '예: 사진 왼쪽 줄도 매장 줄인가요?',
              helperText: "⚠️ 수행자가 찍은 사진에 대한 질문을 하는 공간이에요.",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('질문 제출'),
            ),
          ],
        );
      },
    );
  }

  // '사진 재요청(반려)' 다이얼로그
  Future<String?> _showRevisionDialog(BuildContext context) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('사진 재요청 및 반려 사유'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: '예: 전체 줄이 아니라, 키오스크 앞 줄만 찍어주실래요?',
              helperText: "어떤 사진이 필요한지 명확하게 작성해야 수행자가 원하는 요청대로 수행할 수 있어요!",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('재요청하기'),
            ),
          ],
        );
      },
    );
  }

  // 사진 카드 하단의 인라인 액션 버튼 UI
  Widget _buildInlineAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 최종 피드백 상태를 보여주는 칩
  Widget _buildFeedbackChip(PhotoStatus status) {
    final isApproved = status == PhotoStatus.approved;
    return Center(
      child: Chip(
        avatar: Icon(
          isApproved ? Icons.check_circle : Icons.cancel,
          color: Colors.white,
          size: 18,
        ),
        label: Text(isApproved ? '요청자가 사진을 승인했습니다.' : '요청자가 사진을 반려했습니다.'),
        labelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: isApproved ? Colors.green : Colors.red,
      ),
    );
  }
}

/// 시스템 메시지를 표시하는 위젯
class _SystemMessage extends StatelessWidget {
  final String message;
  final DateTime timestamp;

  const _SystemMessage({required this.message, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      child: Text(
        '${DateFormat('M/d a h:mm', 'ko_KR').format(timestamp)} - $message',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
    );
  }
}
