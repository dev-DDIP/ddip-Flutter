import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_view_provider.dart'; // 방금 만든 프로바이더 import

class EventViewScreen extends ConsumerWidget {
  final String eventId;

  const EventViewScreen({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // eventId에 해당하는 상세 데이터의 상태(state)를 감시(watch)합니다.
    final eventState = ref.watch(eventViewProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('요청 정보'),
      ),
      // AsyncValue의 when을 사용하면 로딩/에러/성공 상태를 깔끔하게 처리할 수 있습니다.
      body: eventState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('오류가 발생했습니다: $error'),
        ),
        data: (event) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('보상: ${event.reward}원'),
                const Divider(height: 32),
                Text(event.content),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      // Todo: 여기에 이벤트 참여 로직을 추가합니다.
                    },
                    child: const Text('참여하기'),
                ),
                ),
              ],
            ),
          );
        }
      )
    );
  }
}