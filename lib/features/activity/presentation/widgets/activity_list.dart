// ▼▼▼ lib/features/activity/presentation/widgets/activity_list.dart (새 파일) ▼▼▼
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/ddip_list_item.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// '_'를 제거하여 다른 파일에서 접근 가능한 공용 위젯으로 변경합니다.
class ActivityList extends ConsumerWidget {
  final String userId;
  final UserActivityType type;
  const ActivityList({super.key, required this.userId, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(
      userActivityProvider((userId: userId, type: type)),
    );

    return activityAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('목록을 불러올 수 없습니다: $err')),
      data: (events) {
        if (events.isEmpty) {
          return const Center(
            child: Text(
              '해당 활동 기록이 없습니다.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }
        return ListView.separated(
          itemCount: events.length,
          itemBuilder: (context, index) {
            return DdipListItem(event: events[index]);
          },
          separatorBuilder: (context, index) => const Divider(height: 1),
        );
      },
    );
  }
}

// ▲▲▲ lib/features/activity/presentation/widgets/activity_list.dart (새 파일) ▲▲▲
