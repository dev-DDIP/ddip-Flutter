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
    final hasPendingPhoto = event.photos.any(
      (p) => p.status == PhotoStatus.pending,
    );

    if (isRequester) {
      // 요청자 입장
      if (event.status == DdipEventStatus.in_progress && !hasPendingPhoto) {
        text = '수행자의 첫 사진을 기다리고 있습니다...';
        icon = Icons.hourglass_empty_rounded;
        color = Colors.blue;
      } else if (hasPendingPhoto) {
        text = '사진을 확인하고 피드백을 남겨주세요!';
        icon = Icons.rate_review_outlined;
        color = Colors.orange;
      }
    } else {
      // 수행자 입장
      if (event.selectedResponderId == currentUserId && !hasPendingPhoto) {
        text = '현장으로 이동하여 사진을 제출해주세요.';
        icon = Icons.camera_alt_outlined;
        color = Colors.green;
      } else if (event.selectedResponderId == currentUserId &&
          hasPendingPhoto) {
        text = '요청자의 피드백을 기다리고 있습니다.';
        icon = Icons.hourglass_bottom_rounded;
        color = Colors.grey;
      }
    }

    // 표시할 텍스트가 없으면 빈 위젯을 반환하여 배너를 숨깁니다.
    if (text == null) {
      return const SizedBox.shrink(key: ValueKey('empty'));
    }

    // 가이드 문구를 표시할 컨테이너 위젯
    return Container(
      key: ValueKey(text), // 애니메이션이 내용을 구분하도록 key를 부여합니다.
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: color?.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color?.withOpacity(0.3) ?? Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
