// lib/features/ddip_event/presentation/detail/widgets/event_detail_tab_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/applicant_list_view.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/event_details_view.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/interaction_timeline_view.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/event_detail_header.dart'; // 방금 만든 헤더 Import

/// 상세 화면의 탭 레이아웃과 컨텐츠를 구성하는 모든 책임을 가지는 위젯입니다.
class EventDetailTabView extends ConsumerWidget {
  final DdipEvent event;
  final ScrollController scrollController;

  const EventDetailTabView({
    super.key,
    required this.event,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    final isRequester = currentUser?.id == event.requesterId;

    // 이벤트 상태에 따라 탭과 뷰를 동적으로 구성합니다.
    final tabs =
        event.status == DdipEventStatus.open
            ? <Widget>[
              const Tab(text: '상세 정보'),
              Tab(text: '지원자 목록 (${event.applicants.length})'),
            ]
            : <Widget>[const Tab(text: '상세 정보'), const Tab(text: '진행 현황')];

    final tabViews =
        event.status == DdipEventStatus.open
            ? [
              EventDetailsView(event: event),
              ApplicantListView(event: event, isRequester: isRequester),
            ]
            : [
              EventDetailsView(event: event),
              InteractionTimelineView(event: event),
            ];

    return DefaultTabController(
      length: tabs.length,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          // 1단계에서 분리한 헤더를 여기에 배치합니다.
          SliverToBoxAdapter(child: EventDetailHeader(event: event)),
          // 탭 바
          SliverPersistentHeader(
            delegate: _SliverTabBarDelegate(TabBar(tabs: tabs)),
            pinned: true,
          ),
          // 탭 컨텐츠
          SliverFillRemaining(child: TabBarView(children: tabViews)),
        ],
      ),
    );
  }
}

// SliverPersistentHeaderDelegate는 TabView와 항상 함께 사용되므로 여기에 둡니다.
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  const _SliverTabBarDelegate(this._tabBar);

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
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
