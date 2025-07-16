// lib/main.dart

import 'package:ddip/features/ddip_event/presentation/creation/screens/ddip_creation_screen.dart';
import 'package:ddip/features/ddip_event/presentation/feed/screens/ddip_feed_screen.dart';
import 'package:ddip/features/ddip_event/presentation/view/screens/event_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  // 1. 앱 전체를 ProviderScope로 감싸서 Riverpod를 사용할 수 있도록 합니다.
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// GoRouter 설정 변수
final GoRouter _router = GoRouter(
  initialLocation: '/feed',
  routes: <RouteBase>[
    GoRoute(
      path: '/feed',
      builder: (context, state) => const DdipFeedScreen(),
      routes: [
        GoRoute(
          path: 'create', //  /feed/create
          builder: (context, state) => const DdipCreationScreen(),
        ),
        // 2. 여기에 새로운 경로를 추가합니다.
        GoRoute(
          path: ':eventId', // /feed/123 과 같은 동적 경로
          builder: (context, state) {
            // state.pathParameters를 통해 경로의 파라미터를 가져옵니다.
            final eventId = int.tryParse(state.pathParameters['eventId'] ?? '') ?? 0;
            return EventViewScreen(eventId: eventId);
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: '띱(DDIP)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
