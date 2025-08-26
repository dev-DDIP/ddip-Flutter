// lib/features/ddip_event/presentation/detail/widgets/CommandBar.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/presentation/detail/viewmodels/event_detail_view_model.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CommandBar extends ConsumerWidget {
  final DdipEvent event;

  const CommandBar({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    if (currentUser == null) return const SizedBox.shrink();

    // ★★★ [오류 수정] ViewModel의 상태를 build 메소드 최상단에서 먼저 가져옵니다. ★★★
    final viewModelState = ref.watch(eventDetailViewModelProvider(event.id));

    // 로딩 중일 경우, 다른 모든 버튼 대신 로딩 인디케이터를 표시합니다.
    if (viewModelState.isProcessing) {
      return Container(
        padding: const EdgeInsets.all(24.0),
        width: double.infinity,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final isRequester = event.requesterId == currentUser.id;
    final isSelectedResponder = event.selectedResponderId == currentUser.id;
    final isMissionFinished =
        event.status == DdipEventStatus.completed ||
        event.status == DdipEventStatus.failed;

    // 1. 미션이 종료된 상태일 경우
    if (isMissionFinished) {
      // 1-1. 이미 평가를 완료했다면, 비활성화된 '평가 완료' 버튼을 보여줍니다.
      if (viewModelState.hasCurrentUserEvaluated) {
        return _buildEvaluationBar(
          context: context,
          ref: ref,
          text: '평가 완료',
          icon: Icons.check_circle,
          isEnabled: false,
        );
      }
      // 1-2. 아직 평가하지 않았다면, '평가하기' 버튼을 보여줍니다.
      else if (isRequester) {
        return _buildEvaluationBar(
          context: context,
          ref: ref,
          text: '수행자 평가하기',
          icon: Icons.rate_review_outlined,
        );
      } else if (isSelectedResponder) {
        return _buildEvaluationBar(
          context: context,
          ref: ref,
          text: '요청자 평가하기',
          icon: Icons.rate_review_outlined,
        );
      }
    }

    // 2. 미션이 진행 중인 상태일 경우 (기존 로직)
    return isRequester
        ? _buildForRequester(context, ref)
        : _buildForResponder(context, ref);
  }

  // 요청자를 위한 커맨드 바
  Widget _buildForRequester(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(eventDetailViewModelProvider(event.id).notifier);
    final viewModelState = ref.watch(eventDetailViewModelProvider(event.id));

    final bool isMissionOngoing = event.status == DdipEventStatus.in_progress;
    final bool hasPhotoBeenSubmitted = event.photos.isNotEmpty;

    if (isMissionOngoing && hasPhotoBeenSubmitted) {
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
    return const SizedBox.shrink();
  }

  // 수행자를 위한 커맨드 바
  Widget _buildForResponder(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(eventDetailViewModelProvider(event.id).notifier);
    final currentUser = ref.watch(authProvider);

    final isSelectedResponder = event.selectedResponderId == currentUser?.id;
    final hasApplied = event.applicants.contains(currentUser?.id);
    final hasPendingPhoto = event.photos.any(
      (p) => p.status == PhotoStatus.pending,
    );

    Widget actionWidget;

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
          actionWidget = const SizedBox.shrink();
        }
        break;
      default:
        actionWidget = const SizedBox.shrink();
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

  // 평가하기 버튼 UI를 위한 헬퍼 메소드
  Widget _buildEvaluationBar({
    required BuildContext context,
    required WidgetRef ref,
    required String text,
    required IconData icon,
    bool isEnabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      color: Colors.transparent,
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          icon: Icon(icon),
          label: Text(text),
          onPressed:
              isEnabled
                  ? () {
                    ref
                        .read(eventDetailViewModelProvider(event.id).notifier)
                        .navigateToEvaluation(context);
                  }
                  : null,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor:
                isEnabled ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ),
      ),
    );
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
