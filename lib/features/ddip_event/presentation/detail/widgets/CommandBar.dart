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
    // ViewModel의 전체 상태를 감시하여 로딩 상태 등을 반영
    final viewModelState = ref.watch(eventDetailViewModelProvider(event.id));
    final viewModel = ref.read(eventDetailViewModelProvider(event.id).notifier);
    final currentUser = ref.watch(authProvider);

    // ViewModel의 isProcessing 상태가 true이면 로딩 인디케이터를 표시
    if (viewModelState.isProcessing) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // 현재 상황에 맞는 버튼 또는 상태 표시 위젯을 가져옴
    final actionWidget = _buildActionButton(
      context,
      ref,
      viewModel,
      currentUser?.id,
    );

    // Container는 버튼 주변의 안전 여백을 확보하는 역할만 합니다.
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      // 배경색이 없어야 스크롤 뷰 위에 떠 있는 것처럼 보입니다.
      color: Colors.transparent,
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
    // 현재 유저의 역할을 판단하기 위한 boolean 값들
    final isRequester = event.requesterId == currentUserId;
    final isSelectedResponder = event.selectedResponderId == currentUserId;
    final hasApplied = event.applicants.contains(currentUserId);
    final hasPendingPhoto = event.photos.any(
      (p) => p.status == PhotoStatus.pending,
    );

    // switch 구문을 사용하여 각 상태별로 다른 위젯을 반환합니다.
    switch (event.status) {
      case DdipEventStatus.open:
        if (isRequester) {
          return _buildStyledButton(
            text: '수행자 선택하기',
            // 지원자가 있을 때만 버튼 활성화
            onPressed:
                event.applicants.isNotEmpty
                    ? () {
                      // TODO: 지원자 선택 BottomSheet 띄우기 로직 연결
                      print('수행자 선택하기 버튼 클릭');
                    }
                    : null,
          );
        } else if (hasApplied) {
          return const _StatusIndicator(
            icon: Icons.check_circle_outline,
            text: '지원 완료! 요청자가 선택할 때까지 기다려주세요.',
          );
        } else {
          return _buildStyledButton(
            text: '미션 지원하기',
            onPressed: () => viewModel.handleButtonPress(context),
            backgroundColor: Colors.blue,
          );
        }

      case DdipEventStatus.in_progress:
        if (isSelectedResponder) {
          return hasPendingPhoto
              ? const _StatusIndicator(
                icon: Icons.hourglass_top_rounded,
                text: '사진 제출 완료! 요청자가 확인 중입니다.',
              )
              : _buildStyledButton(
                text: '증거 사진 제출하기',
                icon: Icons.camera_alt,
                onPressed: () => viewModel.handleButtonPress(context),
                backgroundColor: Colors.green,
              );
        } else if (isRequester) {
          return hasPendingPhoto
              ? const _StatusIndicator(
                icon: Icons.rate_review_outlined,
                text: '제출된 사진을 확인하고 평가해주세요.',
              )
              : const _StatusIndicator(
                icon: Icons.directions_run_rounded,
                text: '수행자가 미션을 진행하고 있습니다.',
              );
        }
        break;

      case DdipEventStatus.completed:
      case DdipEventStatus.failed:
        // TODO: 평가 시스템 구현 후, 평가를 아직 안했을 경우에만 버튼 표시
        return _buildStyledButton(
          text: '평가 남기기',
          icon: Icons.star_border_rounded,
          onPressed: () {
            /* TODO: 평가 남기기 로직 연결 */
          },
        );
    }

    // 위 조건에 해당하지 않는 모든 경우, 빈 공간을 반환합니다.
    return const SizedBox.shrink();
  }

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

    return SizedBox(width: double.infinity, child: buttonContent);
  }
}

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
