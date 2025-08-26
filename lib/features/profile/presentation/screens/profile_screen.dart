import 'package:ddip/features/evaluation/domain/entities/evaluation.dart';
import 'package:ddip/features/profile/domain/entities/profile.dart';
import 'package:ddip/features/profile/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider(userId));

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('프로필을 불러올 수 없습니다: $err')),
        data:
            (profile) => CustomScrollView(
              slivers: [
                // 1. 프로필 헤더
                _ProfileHeader(profile: profile),

                // 2. 나머지 콘텐츠 (인증 및 평판 섹션)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (profile.certifiedSchoolName != null) ...[
                          _CertificationCard(
                            schoolName: profile.certifiedSchoolName!,
                          ),
                          const SizedBox(height: 24),
                        ],
                        _ReputationSection(profile: profile),
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

// =============================================================================
// MARK: - UI Components
// =============================================================================

/// 프로필 상단 영역을 담당하는 SliverAppBar
class _ProfileHeader extends StatelessWidget {
  final Profile profile;
  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      // [오류 수정] 콘텐츠를 충분히 담을 수 있도록 높이 확장
      expandedHeight: 240.0,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 1,
      surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 72, 20, 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. 프로필 사진, 이름, 한 줄 소개 (가로 배치)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(profile.profileImageUrl),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.nickname,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.oneLineIntro,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade700),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // 2. 요청, 수행 횟수
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCountItem(context, '요청', profile.totalRequestCount),
                    SizedBox(
                      height: 24,
                      child: VerticalDivider(color: Colors.grey.shade300),
                    ),
                    _buildCountItem(context, '수행', profile.totalExecutionCount),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // [단순화] _ActivityInfoRow 위젯 대신 작은 빌드 메서드로 통합
  Widget _buildCountItem(BuildContext context, String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

/// 학교 인증 정보를 보여주는 카드
class _CertificationCard extends StatelessWidget {
  final String schoolName;
  const _CertificationCard({required this.schoolName});
  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_rounded, color: primaryColor),
          const SizedBox(width: 12),
          Text(
            '$schoolName 인증 완료',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

/// 요청자/수행자 평판을 탭으로 보여주는 섹션 (StatefulWidget 유지)
class _ReputationSection extends StatefulWidget {
  final Profile profile;
  const _ReputationSection({required this.profile});

  @override
  State<_ReputationSection> createState() => _ReputationSectionState();
}

class _ReputationSectionState extends State<_ReputationSection>
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
    const responderTags = {
      PraiseTag.photoClarity: '사진이 선명해요 📸',
      PraiseTag.goodComprehension: '요청을 정확히 이해했어요 👍',
      PraiseTag.kindAndPolite: '친절하고 매너가 좋아요 😊',
      PraiseTag.sensibleExtraInfo: '센스있는 추가 정보 ✨',
    };
    const requesterTags = {
      PraiseTag.clearRequest: '요청사항이 명확했어요 🎯',
      PraiseTag.fastFeedback: '빠른 확인과 피드백 ✅',
      PraiseTag.politeAndKind: '매너있고 친절해요 🙏',
      PraiseTag.reasonableRequest: '합리적인 요구사항 🤝',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: '사용자 평판'),
        TabBar(
          controller: _tabController,
          tabs: const [Tab(text: '수행자로서'), Tab(text: '요청자로서')],
        ),
        const SizedBox(height: 16),
        // [단순화] _ReputationDetails 위젯을 제거하고 TabBarView 내부에 직접 UI 구현
        SizedBox(
          height: 220,
          child: TabBarView(
            controller: _tabController,
            children: [
              // 수행자 평판 탭
              Column(
                children: [
                  _buildRatingDisplay(
                    rating: widget.profile.responderAverageRating,
                    count: widget.profile.totalExecutionCount,
                  ),
                  const SizedBox(height: 16),
                  _PraiseTagGraph(
                    availableTags: responderTags,
                    tagCounts: widget.profile.responderPraiseTags,
                  ),
                ],
              ),
              // 요청자 평판 탭
              Column(
                children: [
                  _buildRatingDisplay(
                    rating: widget.profile.requesterAverageRating,
                    count: widget.profile.totalRequestCount,
                  ),
                  const SizedBox(height: 16),
                  _PraiseTagGraph(
                    availableTags: requesterTags,
                    tagCounts: widget.profile.requesterPraiseTags,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // [단순화] _RatingDisplay 위젯 대신 작은 빌드 메서드로 통합
  Widget _buildRatingDisplay({required double? rating, required int count}) {
    final hasRating = rating != null && rating > 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Icon(
          Icons.star_rounded,
          color: hasRating ? Colors.amber : Colors.grey.shade300,
          size: 40,
        ),
        const SizedBox(width: 8),
        Text(
          hasRating ? rating!.toStringAsFixed(1) : 'N/A',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: hasRating ? Colors.black87 : Colors.grey.shade400,
          ),
        ),
        const SizedBox(width: 8),
        if (hasRating)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              '($count명)',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ),
      ],
    );
  }
}

/// 칭찬 태그 그래프 위젯 (복잡도가 있으므로 유지)
class _PraiseTagGraph extends StatelessWidget {
  final Map<PraiseTag, String> availableTags;
  final Map<PraiseTag, int> tagCounts;

  const _PraiseTagGraph({required this.availableTags, required this.tagCounts});

  @override
  Widget build(BuildContext context) {
    if (tagCounts.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.tag_faces_outlined,
                size: 32,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 8),
              const Text(
                "받은 칭찬 태그가 없어요.",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final maxCount = tagCounts.values.fold(0, (prev, e) => e > prev ? e : prev);
    final primaryColor = Theme.of(context).primaryColor;

    return Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        children:
            availableTags.entries.map((entry) {
              final tag = entry.key;
              final label = entry.value;
              final count = tagCounts[tag] ?? 0;
              final ratio = maxCount > 0 ? count / maxCount : 0.0;

              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 6.0,
                  horizontal: 8.0,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(label, style: const TextStyle(fontSize: 13)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            primaryColor.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 35,
                      child: Text(
                        ' $count',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}

/// 섹션 제목 위젯
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
