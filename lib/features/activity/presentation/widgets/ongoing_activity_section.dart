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
        if (events.isEmpty) {
          return const SizedBox.shrink();
        }
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
                  return OngoingListItem(event: events[index]);
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
