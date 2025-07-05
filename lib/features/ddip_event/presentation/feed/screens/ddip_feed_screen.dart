import 'package:ddip/features/ddip_event/presentation/creation/screens/ddip_creation_screen.dart';
import 'package:ddip/features/ddip_event/presentation/feed/providers/ddip_feed_provider.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/ddip_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ConsumerWidget을 상속받아 Riverpod 프로바이더를 사용할 수 있게 합니다.
class DdipFeedScreen extends ConsumerWidget {
  const DdipFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ddipFeedProvider의 상태를 감시(watch)합니다.
    final feedState = ref.watch(ddipFeedProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('띱! 요청 목록'),
      ),
      // feedState의 상태에 따라 다른 위젯을 보여줍니다.
      // [추가] 글쓰기 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 글쓰기 화면으로 이동
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DdipCreationScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: feedState.when(
        // 데이터 로딩이 완료되었을 때
        data: (events) {
          // 만약 목록이 비어있다면
          if (events.isEmpty) {
            return const Center(child: Text('아직 등록된 요청이 없어요!'));
          }
          // 목록이 있다면 ListView로 보여줍니다.
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return DdipListItem(event: event);
            },
          );
        },
        // 에러가 발생했을 때
        error: (error, stackTrace) => Center(
          child: Text('오류가 발생했습니다: $error'),
        ),
        // 데이터 로딩 중일 때
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}