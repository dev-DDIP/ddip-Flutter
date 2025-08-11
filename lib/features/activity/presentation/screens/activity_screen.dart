// ▼▼▼ lib/features/activity/presentation/screens/activity_screen.dart ▼▼▼
import 'package:ddip/features/activity/presentation/widgets/activity_list.dart';
import 'package:ddip/features/activity/presentation/widgets/login_prompt.dart';
import 'package:ddip/features/activity/presentation/widgets/ongoing_activity_section.dart';
import 'package:ddip/features/activity/presentation/widgets/sliver_tab_bar_delegate.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('나의 활동 내역')),
        body: const LoginPrompt(), // 분리된 위젯 사용
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              title: const Text('나의 활동 내역'),
              pinned: false,
              floating: true,
              forceElevated: innerBoxIsScrolled,
            ),
            SliverToBoxAdapter(
              child: OngoingActivitySection(
                userId: currentUser.id,
              ), // 분리된 위젯 사용
            ),
            SliverPersistentHeader(
              delegate: SliverTabBarDelegate(
                // 이름 변경
                TabBar(
                  controller: _tabController,
                  tabs: const [Tab(text: '나의 요청'), Tab(text: '나의 수행')],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            ActivityList(
              userId: currentUser.id,
              type: UserActivityType.requested,
            ),
            ActivityList(
              userId: currentUser.id,
              type: UserActivityType.responded,
            ),
          ],
        ),
      ),
    );
  }
}

// ▲▲▲ lib/features/activity/presentation/screens/activity_screen.dart ▲▲▲
