// lib/features/ddip_event/presentation/feed/screens/ddip_feed_screen.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/presentation/creation/screens/ddip_creation_screen.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/feed_bottom_sheet.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/map/presentation/widgets/ddip_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DdipFeedScreen extends ConsumerWidget {
  const DdipFeedScreen({super.key});

  // ▼▼▼ [신규] 로그인 팝업을 표시하는 함수 ▼▼▼
  void _showLoginDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('로그인할 사용자를 선택하세요'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: mockUsers.length,
              itemBuilder: (context, index) {
                final user = mockUsers[index];
                return ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(user.name),
                  onTap: () {
                    // Riverpod의 ref를 사용하여 authProvider 상태 업데이트
                    ref.read(authProvider.notifier).state = user;
                    Navigator.of(dialogContext).pop(); // 팝업 닫기
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${user.name}님으로 로그인되었습니다.')),
                    );
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  // ▼▼▼ [신규] 로그아웃 확인 팝업을 표시하는 함수 ▼▼▼
  void _showLogoutConfirmDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말로 로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                ref.read(authProvider.notifier).state = null;
                Navigator.of(dialogContext).pop(); // 팝업 닫기
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('로그아웃 되었습니다.')));
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsState = ref.watch(ddipEventsNotifierProvider);
    final currentUser = ref.watch(authProvider);

    return Scaffold(
      // ▼▼▼ [수정] Drawer UI를 로그인 상태에 따라 동적으로 변경 ▼▼▼
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // --- Drawer 헤더: 로그인 상태에 따라 다르게 표시 ---
            if (currentUser != null)
              UserAccountsDrawerHeader(
                accountName: Text(
                  currentUser.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                accountEmail: const Text('포인트: 1,000 P'), // TODO: 실제 포인트 연동
                currentAccountPicture: const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 50, color: Colors.blue),
                ),
                decoration: BoxDecoration(color: Colors.blue.shade300),
              )
            else
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.grey),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '로그인이 필요합니다',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '로그인하고 띱 서비스를 이용해보세요!',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),

            // --- Drawer 메뉴: 로그인 상태에 따라 다른 메뉴 표시 ---
            if (currentUser == null) ...[
              ListTile(
                leading: const Icon(Icons.login, color: Colors.blue),
                title: const Text('로그인', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context); // Drawer를 먼저 닫고
                  _showLoginDialog(context, ref); // 로그인 팝업을 띄웁니다.
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.blueAccent,
                ),
                title: const Text(
                  '새 띱 요청하기',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context); // Drawer를 먼저 닫고
                  Navigator.of(context).push(
                    // 새 글 작성 화면으로 이동
                    MaterialPageRoute(
                      builder: (context) => const DdipCreationScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('나의 띱 기록'),
                onTap: () {
                  /* TODO: 나의 띱 기록 화면으로 이동 */
                },
              ),
              ListTile(
                leading: const Icon(Icons.monetization_on_outlined),
                title: const Text('포인트 관리'),
                onTap: () {
                  /* TODO: 포인트 관리 화면으로 이동 */
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context); // Drawer를 먼저 닫고
                  _showLogoutConfirmDialog(context, ref); // 로그아웃 확인 팝업을 띄웁니다.
                },
              ),
            ],
          ],
        ),
      ),
      body: eventsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('데이터 로딩 오류: $err')),
        data:
            (allEvents) => Stack(
              children: [
                // 1. 지도 뷰 (화면 전체 차지)
                DdipMapView(events: allEvents),

                // 2. 커스텀 바텀 시트 (지도 위에 겹쳐짐)
                const FeedBottomSheet(),

                // ▼▼▼ [추가] 햄버거 메뉴(Drawer)를 열기 위한 버튼 ▼▼▼
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10, // 상태 표시줄 아래
                  left: 10,
                  child: Builder(
                    builder:
                        (context) => FloatingActionButton(
                          mini: true, // 작은 사이즈의 버튼
                          onPressed:
                              () =>
                                  Scaffold.of(
                                    context,
                                  ).openDrawer(), // Drawer 열기
                          backgroundColor: Colors.white,
                          child: const Icon(
                            Icons.menu,
                            color: Colors.black, // 아이콘 색상을 검은색으로 지정
                          ),
                        ),
                  ),
                ),
              ],
            ),
      ),
    );
  }
}
