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

// ✨ [신설] 카드 내부의 입력 모드를 관리하기 위한 Enum
enum _InputMode { none, askingQuestion, requestingRevision }

/// '띱' 이벤트의 모든 상호작용을 서사적 타임라인 형태로 보여주는 Sliver 위젯입니다.
class CommunicationLogSliver extends ConsumerWidget {
  final DdipEvent event;

  const CommunicationLogSliver({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. 시스템 메시지(매칭 등)와 사진을 시간순으로 정렬하기 위한 리스트를 생성합니다.
    final allUsers = ref.watch(mockUsersProvider);
    final List<dynamic> timelineItems = [];

    // 1-1. 사진과 직접 관련 없는 시스템 상호작용을 타임라인에 추가합니다.
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
        timelineItems.add(
          _SystemMessage(
            message: '🤝 $responderName 님과 매칭되었습니다. 지금부터 미션을 시작해주세요!',
            timestamp: interaction.timestamp,
          ),
        );
      }
    }

    // 1-2. 모든 사진을 타임라인에 추가합니다.
    timelineItems.addAll(event.photos);

    // 1-3. 타임스탬프를 기준으로 모든 아이템을 시간순으로 정렬합니다.
    timelineItems.sort((a, b) {
      final aTime = a is Photo ? a.timestamp : (a as _SystemMessage).timestamp;
      final bTime = b is Photo ? b.timestamp : (b as _SystemMessage).timestamp;
      return aTime.compareTo(bTime);
    });

    // 2. 타임라인이 비어있다면 '빈 상태 가이드' UI를 표시합니다.
    if (timelineItems.isEmpty) {
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

    // 3. 정렬된 타임라인 아이템 목록을 기반으로 SliverList를 생성합니다.
    return SliverList.separated(
      itemCount: timelineItems.length,
      itemBuilder: (context, index) {
        final item = timelineItems[index];

        if (item is Photo) {
          // 아이템이 사진이면, 강화된 _PhotoSubmissionCard를 렌더링합니다.
          return _PhotoSubmissionCard(event: event, photo: item);
        } else if (item is _SystemMessage) {
          // 아이템이 시스템 메시지이면 그대로 렌더링합니다.
          return item;
        }
        return const SizedBox.shrink(); // 예외 처리
      },
      separatorBuilder: (context, index) => const SizedBox(height: 8),
    );
  }
}

/// 사진 제출과 관련된 모든 정보(사진, 코멘트, Q&A)를 담는 카드 위젯
class _PhotoSubmissionCard extends ConsumerStatefulWidget {
  final DdipEvent event;
  final Photo photo;

  const _PhotoSubmissionCard({required this.event, required this.photo});

  @override
  ConsumerState<_PhotoSubmissionCard> createState() =>
      _PhotoSubmissionCardState();
}

class _PhotoSubmissionCardState extends ConsumerState<_PhotoSubmissionCard> {
  // 코멘트 입력창을 보여줄지 여부를 관리하는 내부 상태
  late bool _isEditingComment;
  final _commentController = TextEditingController();
  _InputMode _inputMode = _InputMode.none;
  final _inlineInputController = TextEditingController();
  final _inlineInputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 사진에 코멘트가 없으면 편집 모드로 시작
    _isEditingComment = widget.photo.responderComment == null;
    // 만약 코멘트가 이미 있다면, 컨트롤러의 초기 텍스트로 설정
    if (widget.photo.responderComment != null) {
      _commentController.text = widget.photo.responderComment!;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _inlineInputController.dispose(); // ✨ [추가] 컨트롤러 dispose
    _inlineInputFocusNode.dispose(); // ✨ [추가] 포커스 노드 dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);
    final isRequester = currentUser?.id == widget.event.requesterId;
    final isMyPhoto = widget.event.selectedResponderId == currentUser?.id;
    final timeString = DateFormat(
      'a h:mm',
      'ko_KR',
    ).format(widget.photo.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 카드 헤더, 사진, 코멘트 등은 이전과 동일 ---
            Text(
              '📸 수행자가 $timeString 에 사진을 제출했습니다.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap:
                  () => context.push(
                    '/feed/${widget.event.id}/photo/${widget.photo.id}',
                  ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(widget.photo.url)),
              ),
            ),
            if (_isEditingComment && isMyPhoto)
              _buildCommentEditor()
            else if (widget.photo.responderComment != null &&
                widget.photo.responderComment!.isNotEmpty)
              _buildCommentDisplay(widget.photo.responderComment!),

            if (widget.photo.requesterQuestion != null)
              _buildQnAThread(widget.photo),

            // ✅ [핵심 변경] _inputMode 상태에 따라 UI를 분기 처리합니다.
            if (isRequester && widget.photo.status == PhotoStatus.pending)
              _inputMode == _InputMode.none
                  // 1. 기본 상태: 액션 링크 표시
                  ? _buildActionLinks()
                  // 2. 입력 상태: 인라인 입력창 표시
                  : _buildInlineInputField(),

            if (widget.photo.status != PhotoStatus.pending)
              _buildFeedbackDisplay(widget.photo),
          ],
        ),
      ),
    );
  }

  Widget _buildActionLinks() {
    return Column(
      children: [
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInlineAction(
              context,
              icon: Icons.question_answer_outlined,
              label: '사진 내용 질문',
              onTap: () {
                // 버튼을 누르면 setState를 통해 입력 모드로 전환
                setState(() {
                  _inputMode = _InputMode.askingQuestion;
                  _inlineInputFocusNode.requestFocus(); // 입력창에 자동으로 포커스
                });
              },
            ),
            _buildInlineAction(
              context,
              icon: Icons.sync_problem_outlined,
              label: '사진 재요청',
              onTap: () {
                // 버튼을 누르면 setState를 통해 입력 모드로 전환
                setState(() {
                  _inputMode = _InputMode.requestingRevision;
                  _inlineInputFocusNode.requestFocus(); // 입력창에 자동으로 포커스
                });
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
    );
  }

  // 코멘트 입력 UI
  Widget _buildCommentEditor() {
    final viewModel = ref.read(
      eventDetailViewModelProvider(widget.event.id).notifier,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        children: [
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: '사진에 대한 부연 설명을 남겨주세요.',
              isDense: true,
            ),
            maxLines: 2,
            autofocus: true,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () {
                viewModel.addCommentToPhoto(
                  widget.photo.id,
                  _commentController.text,
                );
                // 코멘트 등록 후에는 UI가 편집 모드에서 보기 모드로 전환되도록 상태 변경
                setState(() {
                  _isEditingComment = false;
                });
              },
              child: const Text('코멘트 등록'),
            ),
          ),
        ],
      ),
    );
  }

  // 등록된 코멘트 표시 UI
  Widget _buildCommentDisplay(String comment) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '"${comment}"',
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      ),
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

  // ✨ [신설] 질의응답(Q&A) 스레드를 그리는 위젯
  Widget _buildQnAThread(Photo photo) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 질문 ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Q.',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(photo.requesterQuestion ?? '')),
              ],
            ),
            const SizedBox(height: 12),
            // --- 답변 ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A.',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  // 답변이 아직 없다면 안내 문구를 표시합니다.
                  child: Text(
                    photo.responderAnswer ?? '수행자의 답변을 기다리고 있습니다...',
                    style: TextStyle(
                      color: photo.responderAnswer == null ? Colors.grey : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ✨ [신설] 최종 피드백을 상세하게 표시하는 위젯 (기존 _buildFeedbackChip 대체)
  Widget _buildFeedbackDisplay(Photo photo) {
    final bool isApproved = photo.status == PhotoStatus.approved;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color:
                isApproved
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isApproved
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    color:
                        isApproved
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isApproved ? '요청자가 사진을 승인했습니다.' : '요청자가 사진을 반려했습니다.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          isApproved
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                    ),
                  ),
                ],
              ),
              // 반려되었고, 반려 사유가 있다면 표시합니다.
              if (!isApproved &&
                  photo.rejectionReason != null &&
                  photo.rejectionReason!.isNotEmpty) ...[
                const Divider(height: 16),
                Text(
                  '"${photo.rejectionReason}"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
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

  // ✨ [신설] 인라인 입력창 UI를 그리는 메소드
  Widget _buildInlineInputField() {
    final viewModel = ref.read(
      eventDetailViewModelProvider(widget.event.id).notifier,
    );
    final isAsking = _inputMode == _InputMode.askingQuestion;

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        children: [
          TextField(
            controller: _inlineInputController,
            focusNode: _inlineInputFocusNode,
            // 포커스 노드 연결
            decoration: InputDecoration(
              hintText:
                  isAsking ? '사진에 대해 궁금한 점을 질문하세요.' : '재요청 사유를 명확하게 작성해주세요.',
              isDense: true,
            ),
            maxLines: 3,
            minLines: 1,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                child: const Text('취소'),
                onPressed: () {
                  setState(() {
                    _inputMode = _InputMode.none;
                    _inlineInputController.clear();
                    FocusScope.of(context).unfocus(); // 키보드 내리기
                  });
                },
              ),
              const SizedBox(width: 8),
              FilledButton(
                child: const Text('제출'),
                onPressed: () {
                  final inputText = _inlineInputController.text;
                  if (inputText.trim().isEmpty) return; // 빈 내용은 제출 방지

                  if (isAsking) {
                    viewModel.askQuestion(context, widget.photo.id, inputText);
                  } else {
                    viewModel.rejectPhotoWithReason(
                      context,
                      widget.photo.id,
                      inputText,
                    );
                  }

                  // 제출 후 입력창 닫기 및 초기화
                  setState(() {
                    _inputMode = _InputMode.none;
                    _inlineInputController.clear();
                    FocusScope.of(context).unfocus(); // 키보드 내리기
                  });
                },
              ),
            ],
          ),
        ],
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
