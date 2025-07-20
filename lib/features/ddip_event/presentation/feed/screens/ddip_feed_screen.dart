// lib/features/ddip_event/presentation/feed/screens/ddip_feed_screen.dart

// 1. 필요한 파일들을 import 합니다.
//    새로 만든 공용 배너 위젯 파일을 import 합니다.
import 'package:ddip/common/widgets/permission_status_banner.dart';
import 'package:ddip/features/ddip_event/presentation/creation/screens/ddip_creation_screen.dart';
import 'package:ddip/features/ddip_event/presentation/feed/providers/ddip_feed_provider.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/ddip_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DdipFeedScreen extends ConsumerWidget {
  const DdipFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // '띱' 목록의 상태를 감시합니다.
    final feedState = ref.watch(ddipFeedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('띱! 요청 목록')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DdipCreationScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      // 2. body를 Column으로 구성하여 위젯을 세로로 쌓습니다.
      body: Column(
        children: [
          // 3. 맨 위에는 우리가 만든 공용 '상태 표시줄' 위젯을 배치합니다.
          const PermissionStatusBanner(),

          // 4. 남은 모든 공간은 Expanded 위젯을 사용하여 '띱' 목록이 차지하도록 합니다.
          Expanded(
            child: feedState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stackTrace) =>
                      Center(child: Text('오류가 발생했습니다: $error')),
              data: (events) {
                if (events.isEmpty) {
                  return const Center(child: Text('아직 등록된 요청이 없어요!'));
                }
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return DdipListItem(event: event);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
