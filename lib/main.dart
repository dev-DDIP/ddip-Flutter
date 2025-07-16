// lib/main.dart
import 'dart:io';
import 'package:ddip/features/ddip_event/presentation/creation/screens/ddip_creation_screen.dart';
import 'package:ddip/features/ddip_event/presentation/feed/screens/ddip_feed_screen.dart';
import 'package:ddip/features/ddip_event/presentation/view/screens/event_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// GoRouter 설정은 그대로 사용합니다.
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
        GoRoute(
          path: ':eventId', // /feed/123 과 같은 동적 경로
          builder: (context, state) {
            final eventId = state.pathParameters['eventId'] ?? '0';
            return EventViewScreen(eventId: eventId);
          },
        ),
      ],
    ),
  ],
);

void main() async {
  // 앱 시작전 설정 과정에서 오류가 발생할 수 있으므로 try-catch로 감싸줍니다.
  try {
    print('현재 작업 디렉토리: ${Directory.current.path}');
    WidgetsFlutterBinding.ensureInitialized();

    await dotenv.load(fileName: ".env");

    // .env 파일에서 ID를 불러와 null 체크를 수행합니다.
    final naverMapClientId = dotenv.env['NAVER_MAP_CLIENT_ID'];
    if (naverMapClientId == null || naverMapClientId.isEmpty) {
      throw Exception('.env 파일에 NAVER_MAP_CLIENT_ID가 설정되지 않았습니다.');
    }

    // null이 아님이 확인된 ID로 네이버 지도를 초기화합니다.
    await FlutterNaverMap().init(
      clientId: naverMapClientId,
      onAuthFailed: (ex) {
        print('네이버 지도 인증 실패: $ex');
      },
    );

    // 모든 과정이 성공하면, 기존과 동일하게 앱을 실행합니다.
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  } catch (e) {
    // 만약 위 과정에서 에러가 발생하면, 하얀 화면 대신 에러 메시지를 보여주는 앱을 실행합니다.
    runApp(ErrorApp(error: e.toString()));
  }
}

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

// 에러 발생 시 에러 내용을 화면에 표시해주는 위젯
class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '앱 초기화 실패:\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
