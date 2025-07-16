// lib/main.dart

import 'package:ddip/features/ddip_event/presentation/creation/screens/ddip_creation_screen.dart';
import 'package:ddip/features/ddip_event/presentation/feed/screens/ddip_feed_screen.dart';
import 'package:ddip/features/ddip_event/presentation/view/screens/event_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // 네이버 지도 SDK를 초기화합니다.
  await FlutterNaverMap().init(
    // .env 파일에서 Client ID를 안전하게 불러옵니다.
    clientId: dotenv.env['NAVER_MAP_CLIENT_ID']!,
    onAuthFailed: (ex) { // 인증 실패 시 에러를 확인하기 위함입니다.
      print('네이버 지도 인증 실패: $ex');
    },
  );

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
            final eventId = state.pathParameters['eventId'] ?? '0'; // id가 없는 경우 기본값
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
