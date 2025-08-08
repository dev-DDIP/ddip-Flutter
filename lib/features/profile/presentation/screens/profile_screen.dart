// ▼▼▼ lib/features/profile/presentation/screens/profile_screen.dart ▼▼▼
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/ddip_list_item.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/profile/domain/entities/profile.dart'
    as profile_entity;
import 'package:ddip/features/profile/domain/entities/profile.dart';
import 'package:ddip/features/profile/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. userId를 사용하여 profileProvider를 watch합니다.
    // Provider가 비동기 데이터를 가져오는 동안 로딩/에러 상태를 자동으로 관리합니다.
    final profileAsync = ref.watch(profileProvider(userId));

    return Scaffold(
      // 2. AsyncValue.when을 사용하여 상태별로 다른 UI를 보여줍니다.
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('프로필을 불러올 수 없습니다: $err')),
        data:
            (profile) => CustomScrollView(
              slivers: [
                // 3. 프로필 헤더 (SliverAppBar로 구현)
                _ProfileHeader(profile: profile),
                // 4. 나머지 콘텐츠 (SliverList로 구현)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (profile.certificationMark != null)
                          _CertificationMarkCard(
                            mark: profile.certificationMark!,
                          ),
                        const SizedBox(height: 24),
                        _ReputationCard(profile: profile),
                        const SizedBox(height: 24),
                        _SectionTitle(
                          title: '획득 뱃지 (${profile.badges.length}개)',
                        ),
                        _BadgeCarousel(badges: profile.badges),
                        const SizedBox(height: 24),
                        _SectionTitle(title: '최근 활동 태그'),
                        _TagCloud(tags: profile.tags),

                        _SectionTitle(title: '나의 활동 기록'),
                        _ActivityHistoryCard(userId: userId),
                        // TODO: 활동 기록, 활동 시간대 등 추가 컴포넌트 배치
                      ],
                    ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

// MARK: - UI Components

/// 프로필 상단 영역을 담당하는 SliverAppBar 기반 헤더 위젯
class _ProfileHeader extends StatelessWidget {
  final Profile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 1,
      surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        title: Text(
          profile.nickname,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        background: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40), // Status bar height
            CircleAvatar(
              radius: 45,
              backgroundImage: NetworkImage(profile.profileImageUrl),
            ),
            const SizedBox(height: 12),
            Text(
              profile.oneLineIntro,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '요청 ${profile.totalRequestCount}회 | 수행 ${profile.totalExecutionCount}회',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 40), // For title spacing
          ],
        ),
      ),
    );
  }
}

/// 학기별 인증 마크를 표시하는 카드 위젯
class _CertificationMarkCard extends StatelessWidget {
  final CertificationMark mark;

  const _CertificationMarkCard({required this.mark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.amber.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified, color: Colors.amber.shade800),
          const SizedBox(width: 12),
          Column(
            children: [
              Text(
                mark.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
              Text(
                mark.semester,
                style: TextStyle(fontSize: 12, color: Colors.amber.shade800),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 요청자/수행자 평판을 탭으로 보여주는 위젯
class _ReputationCard extends StatelessWidget {
  final Profile profile;

  const _ReputationCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: '수행자 평판'), Tab(text: '요청자 평판')]),
          SizedBox(
            height: 90,
            child: TabBarView(
              children: [
                _buildReputationGrid(
                  context,
                  metrics: {
                    '사진 승인율':
                        '${profile.responderReputation.photoApprovalRate}%',
                    '평균 응답 시간':
                        '${profile.responderReputation.avgResponseTimeMinutes}분',
                    '미션 포기율': '${profile.responderReputation.abandonmentRate}%',
                  },
                ),
                _buildReputationGrid(
                  context,
                  metrics: {
                    '사진 승인율':
                        '${profile.requesterReputation.photoApprovalRate}%',
                    '평균 선택 시간':
                        '${profile.requesterReputation.avgSelectionTimeMinutes}분',
                    '수행자 만족도':
                        '★ ${profile.requesterReputation.responderSatisfaction.toStringAsFixed(1)}',
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReputationGrid(
    BuildContext context, {
    required Map<String, String> metrics,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            metrics.entries.map((entry) {
              return Column(
                children: [
                  Text(
                    entry.value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(entry.key, style: Theme.of(context).textTheme.bodySmall),
                ],
              );
            }).toList(),
      ),
    );
  }
}

/// 뱃지 목록을 가로로 스크롤하여 보여주는 위젯
class _BadgeCarousel extends StatelessWidget {
  final List<profile_entity.Badge> badges;

  const _BadgeCarousel({required this.badges});

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text("아직 획득한 뱃지가 없어요.")),
      );
    }
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          return SizedBox(
            width: 80,
            child: Column(
              children: [
                Image.network(badge.imageUrl, height: 50, width: 50),
                const SizedBox(height: 8),
                Text(
                  badge.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
        separatorBuilder: (context, index) => const SizedBox(width: 16),
      ),
    );
  }
}

/// 활동 태그를 유동적으로 보여주는 Wrap 위젯
class _TagCloud extends StatelessWidget {
  final List<profile_entity.Tag> tags;

  const _TagCloud({required this.tags});

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) {
      return const Center(child: Text("아직 활동 태그가 없어요."));
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children:
          tags.map((tag) {
            return Chip(
              label: Text('${tag.name} (${tag.count})'),
              backgroundColor: Colors.grey.shade100,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            );
          }).toList(),
    );
  }
}

/// 각 섹션의 제목을 표시하는 간단한 위젯
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// 탭(TabBar)과 탭에 해당하는 콘텐츠(TabBarView)를 포함하는 카드 위젯
/// StatefulWidget으로 만들어 TabController를 관리합니다.
class _ActivityHistoryCard extends ConsumerStatefulWidget {
  final String userId;

  const _ActivityHistoryCard({required this.userId});

  @override
  ConsumerState<_ActivityHistoryCard> createState() =>
      _ActivityHistoryCardState();
}

class _ActivityHistoryCardState extends ConsumerState<_ActivityHistoryCard>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '진행중'),
            Tab(text: '나의 요청'),
            Tab(text: '나의 수행'),
          ],
        ),
        SizedBox(
          // TabBarView의 높이를 고정하여 UI가 깨지는 것을 방지합니다.
          // 내용이 많아지면 내부에서 스크롤됩니다.
          height: 300,
          child: TabBarView(
            controller: _tabController,
            children: [
              _ActivityList(
                userId: widget.userId,
                type: UserActivityType.ongoing,
              ),
              _ActivityList(
                userId: widget.userId,
                type: UserActivityType.requested,
              ),
              _ActivityList(
                userId: widget.userId,
                type: UserActivityType.responded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 특정 타입의 활동 목록을 비동기적으로 불러와 표시하는 위젯
class _ActivityList extends ConsumerWidget {
  final String userId;
  final UserActivityType type;

  const _ActivityList({required this.userId, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ▼▼▼ 3단계에서 만든 Provider를 사용하여 데이터를 가져오는 로직을 완성합니다. ▼▼▼
    // Provider에 userId와 type을 담은 record를 파라미터로 전달합니다.
    final activityAsync = ref.watch(
      userActivityProvider((userId: userId, type: type)),
    );

    // AsyncValue.when을 사용하여 로딩, 에러, 데이터 상태를 처리합니다.
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
        // 피드 화면에서 사용했던 DdipListItem을 재사용하여 목록을 만듭니다.
        return ListView.separated(
          itemCount: events.length,
          itemBuilder: (context, index) {
            return DdipListItem(event: events[index]);
          },
          separatorBuilder: (context, index) => const Divider(height: 1),
        );
      },
    );
    // ▲▲▲ 3단계에서 만든 Provider를 사용하여 데이터를 가져오는 로직을 완성합니다. ▲▲▲
  }
}

// ▲▲▲ lib/features/profile/presentation/screens/profile_screen.dart ▲▲▲
