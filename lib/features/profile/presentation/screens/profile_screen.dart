// lib/features/profile/presentation/screens/profile_screen.dart

import 'package:ddip/features/profile/presentation/providers/profile_provider.dart';
import 'package:ddip/features/profile/presentation/widgets/key_metrics_card.dart';
import 'package:ddip/features/profile/presentation/widgets/profile_header.dart';
import 'package:ddip/features/profile/presentation/widgets/responder_stats_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ConsumerWidget으로 만들어 Riverpod의 Provider를 사용할 수 있도록 합니다.
class ProfileScreen extends ConsumerWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsyncValue = ref.watch(userProfileProvider(userId));

    return Scaffold(
      // ▼▼▼ AppBar 수정 및 전체 레이아웃 변경 ▼▼▼
      appBar: AppBar(
        // 프로필 데이터 로딩이 완료되면 유저 닉네임을 제목으로 표시
        title: Text(profileAsyncValue.valueOrNull?.nickname ?? '프로필'),
      ),
      body: profileAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('프로필을 불러오는 데 실패했습니다.\n$err')),
        data: (profile) {
          // 데이터 로딩 성공 시 표시될 UI
          return DefaultTabController(
            length: 3, // 탭 개수 (수행자, 뱃지, 요청자)
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                // 스크롤 시 상단에 고정되지 않고 함께 스크롤될 부분
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        // 1. 프로필 핵심 정보 헤더
                        ProfileHeader(profile: profile),
                        const SizedBox(height: 16),
                        // 2. 핵심 성과 지표 카드
                        KeyMetricsCard(stats: profile.stats),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  // 스크롤 시 상단에 고정될 탭 바
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      const TabBar(
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.normal,
                        ),
                        tabs: [
                          Tab(text: '수행 기록'),
                          Tab(text: '뱃지'),
                          Tab(text: '요청 기록'),
                        ],
                      ),
                    ),
                    pinned: true, // 상단에 고정
                  ),
                ];
              },
              // 탭 선택에 따라 보여줄 내용
              body: TabBarView(
                children: [
                  // 수행자 기록 탭
                  ResponderStatsView(
                    stats: profile.stats.responderStats,
                    activityAreas: profile.activityAreas,
                  ),
                  // 뱃지 탭 (임시)
                  Center(child: Text('뱃지 목록이 표시됩니다.')),
                  // 요청자 기록 탭 (임시)
                  Center(child: Text('요청자 기록이 표시됩니다.')),
                ],
              ),
            ),
          );
        },
      ),
      // ▲▲▲ AppBar 수정 및 전체 레이아웃 변경 ▲▲▲
    );
  }
}

// TabBar를 Sliver에 고정시키기 위한 Helper 클래스 (변경 없음)
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
