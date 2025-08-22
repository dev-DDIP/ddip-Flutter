// lib/features/ddip_event/presentation/detail/widgets/situational_guide_banner.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SituationalGuideBanner extends ConsumerWidget {
  final DdipEvent event;

  const SituationalGuideBanner({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 로그인된 유저 정보 가져오기
    final currentUser = ref.watch(authProvider);
    if (currentUser == null) {
      return const SizedBox.shrink(); // 로그인하지 않았다면 배너 표시 안함
    }

    // 미션이 진행 중일 때만 배너를 표시합니다.
    if (event.status != DdipEventStatus.open &&
        event.status != DdipEventStatus.in_progress) {
      return const SizedBox.shrink();
    }

    // 역할 및 상태에 따라 표시할 위젯(가이드 문구) 결정
    final guideWidget = _buildGuideWidget(context, currentUser.id);

    // AnimatedSwitcher를 사용해 배너가 나타나거나 내용이 바뀔 때 부드러운 효과를 줍니다.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SizeTransition(sizeFactor: animation, child: child),
        );
      },
      child: guideWidget,
    );
  }

  // 현재 상황에 맞는 가이드 위젯을 생성하는 헬퍼 메서드
  Widget _buildGuideWidget(BuildContext context, String currentUserId) {
    String? text;
    IconData? icon;
    Color? color;

    final isRequester = event.requesterId == currentUserId;
    final isSelectedResponder = event.selectedResponderId == currentUserId;
    final hasPendingPhoto = event.photos.any(
      (p) => p.status == PhotoStatus.pending,
    );
    final hasRejectedPhoto = event.photos.any(
      (p) => p.status == PhotoStatus.rejected,
    );

    // 역할과 상태에 따라 텍스트, 아이콘, 색상을 정의합니다. (메시지 간소화)
    if (isSelectedResponder) {
      // 내가 수행자일 경우
      if (hasRejectedPhoto && !hasPendingPhoto) {
        text = '사진 반려! 다시 제출해주세요.';
        icon = Icons.sync_problem_outlined;
        color = Colors.red.shade600;
      } else if (hasPendingPhoto) {
        text = '⏳ 요청자 확인 중...';
        icon = Icons.hourglass_bottom_rounded;
        color = Colors.grey.shade600;
      } else {
        text = '📸 현장 사진을 제출해주세요.';
        icon = Icons.camera_alt_outlined;
        color = Colors.green.shade600;
      }
    } else if (isRequester) {
      // 내가 요청자일 경우
      if (hasPendingPhoto) {
        text = '👍 사진 확인 후 피드백을 남겨주세요!';
        icon = Icons.rate_review_outlined;
        color = Colors.orange.shade700;
      } else if (event.status == DdipEventStatus.in_progress) {
        text = '⏳ 수행자의 사진을 기다리고 있습니다.';
        icon = Icons.hourglass_empty_rounded;
        color = Colors.blue.shade600;
      }
    }

    if (text == null) {
      return const SizedBox.shrink(key: ValueKey('empty'));
    }

    // 고강조 스타일이 적용된 새로운 Container 위젯
    return Container(
      key: ValueKey(text),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        // ✨ [핵심 수정 1] 단색 배경과 그림자 효과
        color: color, // 옅은 배경 대신 단색을 직접 사용
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color?.withOpacity(0.3) ?? Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ✨ [핵심 수정 2] 아이콘과 텍스트를 모두 흰색으로 변경하여 대비 극대화
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white, // 텍스트 색상을 흰색으로 고정
              ),
            ),
          ),
        ],
      ),
    );
  }
}
