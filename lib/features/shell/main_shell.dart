// lib/features/shell/main_shell.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 1. StatefulWidget -> ConsumerWidget으로 변경하여 ref에 접근
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  // 2. 탭 정보를 별도의 데이터 클래스나 상수로 관리하여 확장성 확보
  static const _tabs = [
    _NavigationTab(
      initialLocation: '/feed',
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: '홈',
    ),
    _NavigationTab(
      initialLocation: '/activity',
      icon: Icon(Icons.history_edu_outlined),
      activeIcon: Icon(Icons.history_edu),
      label: '활동 내역',
    ),
    _NavigationTab(
      initialLocation: '/profile', // 프로필 탭의 기본 경로
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: '내 프로필',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = GoRouterState.of(context).uri.path;
    final currentUser = ref.watch(authProvider);

    // 3. 현재 경로를 기반으로 선택된 인덱스를 더 안전하게 계산
    final selectedIndex = _tabs.indexWhere(
      (tab) => currentPath.startsWith(tab.initialLocation),
    );

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        // selectedIndex가 -1(일치하는 탭 없음)일 경우 0으로 안전하게 처리
        currentIndex: selectedIndex == -1 ? 0 : selectedIndex,
        onTap: (index) {
          // 4. 아이템 탭 로직 개선
          if (index == 2) {
            // '내 프로필' 탭인 경우
            if (currentUser != null) {
              context.go('/profile/${currentUser.id}');
            } else {
              // 로그인하지 않은 사용자에 대한 처리 (예: 로그인 화면으로 보내기 또는 스낵바 표시)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('프로필을 보려면 로그인이 필요합니다.')),
              );
            }
          } else {
            context.go(_tabs[index].initialLocation);
          }
        },
        items: _tabs, // 5. List.map 대신 _tabs 리스트 직접 사용
      ),
    );
  }
}

// 6. 탭 데이터를 구조화하기 위한 내부 클래스 (BottomNavigationBarItem 상속)
class _NavigationTab extends BottomNavigationBarItem {
  final String initialLocation;

  const _NavigationTab({
    required this.initialLocation,
    required super.icon,
    super.activeIcon,
    super.label,
  });
}
