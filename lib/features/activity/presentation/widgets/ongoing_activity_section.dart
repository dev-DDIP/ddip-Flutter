// ▼▼▼ lib/features/activity/presentation/widgets/ongoing_activity_section.dart ▼▼▼
import 'package:ddip/features/activity/presentation/widgets/ongoing_list_item.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OngoingActivitySection extends ConsumerWidget {
  final String userId;
  const OngoingActivitySection({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // '진행중'인 활동 목록을 가져오는 로직은 기존과 동일합니다.
    final ongoingActivityAsync = ref.watch(
      userActivityProvider((userId: userId, type: UserActivityType.ongoing)),
    );

    return ongoingActivityAsync.when(
      loading:
          () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (err, stack) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('진행 중인 활동을 불러오는데 실패했습니다: $err'),
          ),
      data: (events) {
        // 진행 중인 활동이 없으면 아무것도 표시하지 않습니다.
        if (events.isEmpty) {
          return const SizedBox.shrink();
        }

        // --- 여기부터 UI를 그리는 방식이 변경됩니다 ---
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    '현재 진행중',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      '${events.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  // ★★★ 핵심 변경점 ★★★
                  // 1. 목록에서 원본 event 데이터를 가져옵니다.
                  final event = events[index];
                  // 2. 2단계에서 만든 '엔진'을 호출하여, 현재 이벤트에 대한 UI 요약본을 가져옵니다.
                  final summary = ref.watch(
                    ongoingMissionSummaryProvider(event),
                  );
                  // 3. 3단계에서 만든 새로운 UI 카드에 요약본을 전달하여 화면을 그립니다.
                  return OngoingListItem(summary: summary);
                },
                separatorBuilder:
                    (context, index) => const SizedBox(height: 12),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

// ▲▲▲ lib/features/activity/presentation/widgets/ongoing_activity_section.dart ▲▲▲
