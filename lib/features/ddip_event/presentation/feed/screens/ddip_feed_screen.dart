// lib/features/ddip_event/presentation/feed/screens/ddip_feed_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ddip/common/widgets/permission_status_banner.dart';
import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/presentation/creation/screens/ddip_creation_screen.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/ddip_list_item.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';

class DdipFeedScreen extends ConsumerWidget {
  const DdipFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // [수정] 새로운 필터링된 프로바이더를 watch
    final events = ref.watch(filteredDdipFeedProvider);
    // [추가] 로딩/에러 상태를 확인하기 위해 원본 Notifier도 watch
    final eventsState = ref.watch(ddipEventsNotifierProvider);
    // [추가] 현재 로그인한 사용자 정보
    final currentUser = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentUser == null ? '띱! 요청 목록' : '${currentUser.name}님 환영합니다!',
        ),
        actions: [
          // [추가] 가상 로그인/로그아웃 드롭다운 메뉴
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
        onPressed:
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const DdipCreationScreen(),
              ),
            ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          const PermissionStatusBanner(),
          Expanded(
            // [수정] 원본 Notifier의 상태에 따라 로딩, 에러, 데이터 표시
            child: eventsState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('오류: $err')),
              data: (_) {
                // 데이터는 filteredDdipFeedProvider의 것을 사용
                if (events.isEmpty) {
                  return const Center(child: Text('표시할 요청이 없어요!'));
                }
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return DdipListItem(event: events[index]);
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
