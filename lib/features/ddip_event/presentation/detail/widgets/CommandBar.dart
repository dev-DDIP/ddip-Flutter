// lib/features/ddip_event/presentation/detail/widgets/CommandBar.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ▼▼▼ [수정] 위젯 전체를 아래 코드로 교체합니다. ▼▼▼
class CommandBar extends ConsumerWidget {
  final DdipEvent event;

  const CommandBar({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    final isRequester = event.requesterId == currentUser?.id;

    // [핵심] 요청자와 수행자(그 외)의 UI를 완전히 분리하여 렌더링
    return isRequester
        ? _buildForRequester(context, ref)
        : _buildForResponder(context, ref);
  }

  // 1. 요청자를 위한 커맨드 바
  Widget _buildForRequester(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(eventDetailViewModelProvider(event.id).notifier);
    final viewModelState = ref.watch(eventDetailViewModelProvider(event.id));

    // --- 렌더링 조건 ---
    final bool isMissionOngoing =
        event.status == DdipEventStatus.open ||
        event.status == DdipEventStatus.in_progress;
    // [수정] 첫 사진이 제출된 이후에만 버튼이 보이도록 조건 추가
    final bool hasPhotoBeenSubmitted = event.photos.isNotEmpty;

    // 미션이 진행중이고, 사진이 한 장이라도 제출되었다면 '완료' 버튼 표시
    if (isMissionOngoing && hasPhotoBeenSubmitted) {
      if (viewModelState.isProcessing) {
        return const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        color: Colors.transparent,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('이대로 미션 완료하기'),
            onPressed: () => viewModel.completeMission(context),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: Colors.green.shade600,
            ),
          ),
        ),
      );
    }

    // 그 외의 경우 (미션 시작 전, 미션 종료 후)에는 아무것도 표시하지 않음
    return const SizedBox.shrink();
  }

  // 2. 수행자를 위한 커맨드 바 (기존 로직 복원 및 개선)
  Widget _buildForResponder(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(eventDetailViewModelProvider(event.id).notifier);
    final viewModelState = ref.watch(eventDetailViewModelProvider(event.id));
    final currentUser = ref.watch(authProvider);

    // --- 역할 및 상태 판단 ---
    final isSelectedResponder = event.selectedResponderId == currentUser?.id;
    final hasApplied = event.applicants.contains(currentUser?.id);
    final hasPendingPhoto = event.photos.any(
      (p) => p.status == PhotoStatus.pending,
    );

    Widget actionWidget;

    if (viewModelState.isProcessing) {
      actionWidget = const Center(child: CircularProgressIndicator());
    } else {
      switch (event.status) {
        case DdipEventStatus.open:
          if (hasApplied) {
            actionWidget = const _StatusIndicator(
              icon: Icons.check_circle_outline,
              text: '지원 완료! 요청자가 선택할 때까지 기다려주세요.',
            );
          } else {
            actionWidget = _buildStyledButton(
              text: '미션 지원하기',
              onPressed: () => viewModel.handleButtonPress(context),
              backgroundColor: Colors.blue,
            );
          }
          break;
        case DdipEventStatus.in_progress:
          if (isSelectedResponder) {
            actionWidget =
                hasPendingPhoto
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
          } else {
            // 선택되지 않은 다른 지원자 또는 로그인 안한 유저
            actionWidget = const SizedBox.shrink();
          }
          break;
        default:
          // 완료 또는 실패 시
          actionWidget = const SizedBox.shrink();
      }
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      color: Colors.transparent,
      child: actionWidget,
    );
  }

  // 버튼 스타일을 위한 헬퍼 메소드
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

// 상태 표시를 위한 내부 위젯
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
        borderRadius: BorderRadius.circular(50),
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

// ▲▲▲ [수정] 위젯 전체를 아래 코드로 교체합니다. ▲▲▲
