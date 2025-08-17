// lib/features/ddip_event/presentation/detail/widgets/command_bar.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/presentation/detail/viewmodels/event_detail_view_model.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 상세 화면 하단에 고정되어, 현재 상황에 맞는 핵심 행동(CTA)을 제시하는 버튼 바 위젯.
class CommandBar extends ConsumerWidget {
  final DdipEvent event;

  const CommandBar({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelState = ref.watch(eventDetailViewModelProvider(event.id));
    final viewModel = ref.read(eventDetailViewModelProvider(event.id).notifier);
    final currentUser = ref.watch(authProvider);

    final Widget actionWidget = _buildActionButton(
      context,
      ref,
      viewModel,
      currentUser?.id,
    );

    if (viewModelState.isProcessing) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // [핵심 수정] Container에서 decoration(배경)을 완전히 제거합니다.
    // 이제 이 Container의 역할은 오직 '버튼 주변의 안전 여백' 뿐입니다.
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      // 배경 관련 코드(decoration)가 완전히 사라졌습니다.
      child: actionWidget,
    );
  }

  /// 현재 미션 상태와 사용자 역할에 따라 적절한 위젯(버튼 또는 상태 표시)을 반환합니다.
  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    EventDetailViewModel viewModel,
    String? currentUserId,
  ) {
    final isRequester = event.requesterId == currentUserId;
    final isSelectedResponder = event.selectedResponderId == currentUserId;
    final hasApplied = event.applicants.contains(currentUserId);

    // [수정] 상태별 로직을 새로운 워크플로우에 맞게 재구성
    switch (event.status) {
      case DdipEventStatus.open:
        // ... (기존과 동일한 지원/선택 로직)
        return const SizedBox.shrink(); // 예시로 비워둠

      case DdipEventStatus.in_progress:
        // 진행중 상태일 때, 마지막으로 제출된 pending 상태의 사진을 찾습니다.
        final pendingPhoto = event.photos.lastWhere(
          (p) => p.status == PhotoStatus.pending,
          orElse:
              () => Photo(
                id: '',
                url: '',
                latitude: 0,
                longitude: 0,
                timestamp: DateTime.now(),
              ), // orElse에 기본값 제공
        );

        // pending 상태의 사진이 없는 경우 (아직 사진 제출 전)
        if (pendingPhoto.id.isEmpty) {
          if (isSelectedResponder) {
            return _buildStyledButton(
              text: '증거 사진 제출하기',
              icon: Icons.camera_alt,
              onPressed:
                  () => viewModel.handleButtonPress(
                    context,
                  ), // ViewModel의 사진 제출 로직 호출
              backgroundColor: Colors.green,
            );
          } else if (isRequester) {
            return const _StatusIndicator(
              icon: Icons.directions_run_rounded,
              text: '수행자가 미션을 진행하고 있습니다.',
            );
          }
        }
        // [핵심] pending 상태의 사진이 있는 경우, 대화 상태에 따라 분기
        else {
          if (isRequester) {
            // 요청자의 질문이 아직 없다면 -> 질문 가능
            if (pendingPhoto.requesterQuestion == null) {
              return Row(
                children: [
                  Expanded(
                    child: _buildStyledButton(
                      text: '반려',
                      onPressed:
                          () => viewModel.rejectPhotoWithReason(
                            context,
                            pendingPhoto.id,
                          ),
                      backgroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStyledButton(
                      text: '질문',
                      onPressed:
                          () => viewModel.askQuestion(context, pendingPhoto.id),
                      backgroundColor: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStyledButton(
                      text: '승인',
                      onPressed: () {
                        /* Notifier 호출 */
                      },
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              );
            }
            // 요청자가 질문했고, 수행자의 답변이 있다면 -> 최종 결정만 가능
            else if (pendingPhoto.responderAnswer != null) {
              return Row(
                children: [
                  Expanded(
                    child: _buildStyledButton(
                      text: '반려',
                      onPressed:
                          () => viewModel.rejectPhotoWithReason(
                            context,
                            pendingPhoto.id,
                          ),
                      backgroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStyledButton(
                      text: '승인',
                      onPressed: () {
                        /* Notifier 호출 */
                      },
                      backgroundColor: Colors.green,
                    ),
                  ),
                ],
              );
            }
            // 그 외 (요청자가 질문했고, 수행자 답변 대기중)
            else {
              return const _StatusIndicator(
                icon: Icons.hourglass_top_rounded,
                text: '수행자의 답변을 기다리고 있습니다.',
              );
            }
          } else if (isSelectedResponder) {
            // 요청자의 질문이 있고, 내 답변이 아직 없다면 -> 답변해야 함
            if (pendingPhoto.requesterQuestion != null &&
                pendingPhoto.responderAnswer == null) {
              return _buildStyledButton(
                text: '질문에 답변하기',
                icon: Icons.question_answer,
                onPressed:
                    () => viewModel.answerQuestion(context, pendingPhoto.id),
              );
            }
            // 그 외 (내 할일은 끝남)
            else {
              return const _StatusIndicator(
                icon: Icons.hourglass_top_rounded,
                text: '요청자가 확인 중입니다.',
              );
            }
          }
        }
        break;

      case DdipEventStatus.completed:
      case DdipEventStatus.failed:
        // ... (기존과 동일한 완료/실패 로직)
        return const SizedBox.shrink(); // 예시로 비워둠
    }
    return const SizedBox.shrink();
  }

  // ▲▲▲ 2. _buildActionButton 메서드 전체를 여기까지의 코드로 교체합니다. ▲▲▲

  // ▼▼▼ 3. 새로운 헬퍼 메서드(_buildStyledButton)를 CommandBar 클래스 내부에 추가합니다. ▼▼▼
  /// 일관된 스타일의 '플로팅' 버튼을 생성하는 헬퍼 메서드입니다.
  Widget _buildStyledButton({
    required String text,
    required VoidCallback? onPressed,
    IconData? icon,
    Color? backgroundColor,
  }) {
    final buttonContent =
        icon != null
            ? FilledButton.icon(
              icon: Icon(icon),
              label: Text(text),
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                elevation: 4,
                backgroundColor: backgroundColor,
              ),
            )
            : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                elevation: 4,
                backgroundColor: backgroundColor,
              ),
              child: Text(text),
            );

    // 버튼이 여러개일 경우를 대비하여 Row로 감싸고 Expanded를 사용합니다.
    // 현재는 버튼이 하나이므로, Sizedbox로 감싸서 전체 너비를 차지하게 만듭니다.
    return SizedBox(width: double.infinity, child: buttonContent);
  }

  // ▲▲▲ 3. 새로운 헬퍼 메서드(_buildStyledButton)를 여기까지 추가합니다. ▲▲▲
}

// ▼▼▼ 4. 새로운 헬퍼 위젯(_StatusIndicator)을 CommandBar 클래스 외부에 추가합니다. ▼▼▼
/// 버튼 대신 현재 상태를 알려주는 UI 위젯입니다.
class _StatusIndicator extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StatusIndicator({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(50), // 둥근 알약 형태
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
