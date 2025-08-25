// ▼▼▼ lib/features/activity/presentation/widgets/sliver_sticky_header_delegate.dart (새 파일) ▼▼▼
import 'package:flutter/material.dart';

/// SliverPersistentHeader에 위젯을 고정시키기 위한 범용 Delegate 클래스입니다.
class SliverStickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  SliverStickyHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // 위젯이 항상 최상단에 깨끗하게 보이도록 배경색을 입혀줍니다.
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverStickyHeaderDelegate oldDelegate) {
    return oldDelegate.height != height || oldDelegate.child != child;
  }
}

// ▲▲▲ lib/features/activity/presentation/widgets/sliver_sticky_header_delegate.dart (새 파일) ▲▲▲
