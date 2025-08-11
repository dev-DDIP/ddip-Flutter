// ▼▼▼ lib/features/activity/presentation/widgets/ongoing_list_item.dart ▼▼▼
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OngoingListItem extends ConsumerWidget {
  final DdipEvent event;
  const OngoingListItem({super.key, required this.event});

  // build 메소드 전체를 아래의 완전한 코드로 교체합니다.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    final isRequester = event.requesterId == currentUser?.id;

    // 진행률 계산 로직
    final steps = ['모집', '진행', '확인', '완료'];
    int currentStep = 0;
    if (event.status == DdipEventStatus.in_progress) {
      currentStep = 1;
      if (event.photos.any((p) => p.status == PhotoStatus.pending)) {
        currentStep = 2;
      }
    } else if (event.status == DdipEventStatus.completed ||
        event.status == DdipEventStatus.failed) {
      currentStep = 3;
    }
    final progress = (currentStep) / (steps.length - 1);
    final progressText = '${(progress * 100).toInt()}%';

    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.amber.shade50,
      child: InkWell(
        onTap: () => context.push('/feed/${event.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // --- 생략되었던 Column의 children 부분을 복원합니다 ---
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. 제목, 보상 ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${event.reward}원',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // --- 2. 역할과 상태 뱃지 ---
              Row(
                children: [
                  Chip(
                    label: Text(isRequester ? '내가 요청' : '내가 수행'),
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    backgroundColor:
                        isRequester
                            ? Colors.red.shade400
                            : Colors.green.shade400,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '| 신청자: ${event.applicants.length}명',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- 3. 진행률 바와 텍스트 ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '진행률',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  Text(
                    progressText,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.orange.shade400,
                ),
                minHeight: 10,
                borderRadius: BorderRadius.circular(5),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  steps[currentStep],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ▲▲▲ lib/features/activity/presentation/widgets/ongoing_list_item.dart ▲▲▲
