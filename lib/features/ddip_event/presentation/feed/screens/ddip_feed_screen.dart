// lib/features/ddip_event/presentation/feed/screens/ddip_feed_screen.dart

import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/presentation/creation/screens/ddip_creation_screen.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/ddip_list_item.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/map/presentation/widgets/ddip_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DdipFeedScreen extends ConsumerWidget {
  const DdipFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(ddipFeedProvider);
    final eventsState = ref.watch(ddipEventsNotifierProvider);
    final currentUser = ref.watch(authProvider);
    final selectedEventId = ref.watch(feedViewInteractionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentUser == null ? '띱! 요청 목록' : '${currentUser.name}님 환영합니다!',
        ),
        actions: [
          DropdownButton<User?>(
            value: currentUser,
            hint: const Text('로그인'),
            items: [
              const DropdownMenuItem(value: null, child: Text('로그아웃')),
              ...mockUsers.map(
                (user) => DropdownMenuItem(value: user, child: Text(user.name)),
              ),
            ],
            onChanged: (user) {
              ref.read(authProvider.notifier).state = user;
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final user = ref.read(authProvider);
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('로그인이 필요한 기능입니다. (추후 회원가입 화면으로 이동)'),
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const DdipCreationScreen(),
              ),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Stack(
        children: [
          // 1. 배경: 지도 뷰
          eventsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('지도 로딩 오류: $err')),
            data: (allEvents) => DdipMapView(events: allEvents),
          ),

          // 2. 전경: 드래그 가능한 바텀 시트
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.15,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                // ✨ [수정] 괄호 오류가 발생했던 부분입니다.
                // Column으로 손잡이와 리스트를 묶고, ListView는 Expanded로 감싸줍니다.
                child: Column(
                  children: [
                    // 리스트 뷰
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: events.length + 1,
                        itemBuilder: (context, index) {
                          // [핵심] index가 0일 때는 손잡이를, 그 외에는 이벤트 아이템을 반환합니다.
                          if (index == 0) {
                            // 첫 번째 아이템으로 손잡이 위젯을 반환합니다.
                            return Center(
                              child: Container(
                                width: 40,
                                height: 5,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 12.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }

                          // 손잡이(index 0)를 제외한 실제 이벤트 데이터의 인덱스는 index - 1 입니다.
                          final eventIndex = index - 1;
                          final event = events[eventIndex];
                          final isSelected = event.id == selectedEventId;

                          return GestureDetector(
                            onTap: () {
                              ref
                                  .read(feedViewInteractionProvider.notifier)
                                  .state = event.id;
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Colors.blue.withOpacity(0.1)
                                        : null,
                                border:
                                    isSelected
                                        ? Border(
                                          left: BorderSide(
                                            color: Colors.blue,
                                            width: 4,
                                          ),
                                        )
                                        : null,
                              ),
                              child: DdipListItem(event: event),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
