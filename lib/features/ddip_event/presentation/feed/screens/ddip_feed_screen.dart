// lib/features/ddip_event/presentation/feed/screens/ddip_feed_screen.dart

import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/presentation/creation/screens/ddip_creation_screen.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/feed_bottom_sheet.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/map/presentation/widgets/ddip_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DdipFeedScreen extends ConsumerWidget {
  const DdipFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsState = ref.watch(ddipEventsNotifierProvider);
    final currentUser = ref.watch(authProvider);

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
      body: eventsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터 로딩 오류: $err')),
        data:
            (allEvents) => Stack(
              children: [
                // 1. 지도 뷰
                DdipMapView(events: allEvents),

                // 2. 커스텀 바텀 시트
                const FeedBottomSheet(),
              ],
            ),
      ),
    );
  }
}
