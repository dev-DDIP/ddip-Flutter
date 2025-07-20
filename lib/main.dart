// lib/main.dart
import 'dart:io';
import 'package:ddip/core/providers/core_providers.dart';
import 'package:ddip/features/ddip_event/presentation/creation/screens/ddip_creation_screen.dart';
import 'package:ddip/features/ddip_event/presentation/feed/screens/ddip_feed_screen.dart';
import 'package:ddip/features/ddip_event/presentation/view/screens/event_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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

    // 안드로이드용 초기화 설정을 정의합니다.
    // '@mipmap/ic_launcher'는 안드로이드 프로젝트의 기본 앱 아이콘을 사용하겠다는 의미입니다.
    // 알림이 올 때 이 아이콘이 상태표시줄에 표시됩니다.
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3-2. iOS용 초기화 설정을 정의합니다. (여기서는 기본값 사용)
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    // 3-3. 위에서 만든 안드로이드와 iOS 설정을 하나로 묶습니다.
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    // 최종적으로 플러그인을 초기화합니다.
    // 이 작업이 성공적으로 끝나야 앱의 다른 곳에서 알림을 생성할 수 있습니다.
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Android 13 이상을 대상으로 알림 권한을 요청합니다.
    // 사용자가 '허용' 또는 '허용 안함'을 선택할 수 있는 팝업이 뜹니다.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // 모든 과정이 성공하면, 기존과 동일하게 앱을 실행합니다.
    runApp(const ProviderScope(child: MyApp()));
  } catch (e) {
    // 만약 위 과정에서 에러가 발생하면, 하얀 화면 대신 에러 메시지를 보여주는 앱을 실행합니다.
    runApp(ErrorApp(error: e.toString()));
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // initState: 앱의 UI가 처음 생성되는 '탄생'의 순간에 단 한 번 호출됩니다.
  @override
  void initState() {
    super.initState();
    // 앱이 탄생하는 바로 이 시점에, 우리가 만든 알림 서비스를 '읽어서(read)'
    // 시동을 겁니다(start).
    // 이제 서비스는 특정 화면이 아닌, 앱 자체의 생명주기를 따라갑니다.
    ref.read(notificationServiceProvider).start();
  }

  // dispose: 앱이 완전히 종료되는 '소멸'의 순간에 호출됩니다.
  @override
  void dispose() {
    // 앱이 종료될 때, 실행 중이던 알림 서비스도 함께 종료(dispose)하여
    // 리소스를 깔끔하게 정리합니다.
    ref.read(notificationServiceProvider).dispose();
    super.dispose();
  }

  // build 메서드는 화면을 그리는 역할로, 기존과 동일합니다.
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
