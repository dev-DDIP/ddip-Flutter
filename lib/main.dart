// lib/main.dart
import 'dart:io';

import 'package:ddip/core/providers/core_providers.dart';
import 'package:ddip/core/services/proximity_service.dart';
import 'package:ddip/features/ddip_event/presentation/creation/screens/ddip_creation_screen.dart';
import 'package:ddip/features/ddip_event/presentation/feed/screens/ddip_feed_screen.dart';
import 'package:ddip/features/ddip_event/presentation/view/screens/event_view_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

// 백그라운드 메시지 핸들러
// 이 함수는 반드시 클래스 외부에, 최상위 레벨에 존재해야 합니다.
// 앱이 꺼져있을 때 FCM 메시지가 오면, 이 함수가 격리된 환경(Isolate)에서 실행됩니다.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 여기서 알림을 받으면 로컬 알림을 띄우는 등의 작업을 할 수 있습니다.
  // 예를 들어, 받은 메시지 내용을 flutter_local_notifications을 사용해 표시합니다.
  print("Handling a background message: ${message.messageId}");
  // _showLocalNotification 함수를 재사용할 수 있습니다. (필요 시 일부 수정)
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  // 앱 시작전 설정 과정에서 오류가 발생할 수 있으므로 try-catch로 감싸줍니다.
  try {
    print('현재 작업 디렉토리: ${Directory.current.path}');
    WidgetsFlutterBinding.ensureInitialized();

    // Firebase 앱 초기화
    // Firebase 관련 기능을 사용하기 전에 반드시 먼저 호출되어야 합니다.
    await Firebase.initializeApp();
    // 백그라운드 핸들러 등록

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

    // ▼▼▼ [추가] 앱의 위젯 트리가 실행되기 전에 Provider를 사용하기 위한 설정 ▼▼▼
    // 1. Provider들을 담을 수 있는 전역 컨테이너를 생성합니다.
    final container = ProviderContainer();
    // 2. 컨테이너를 통해 우리가 만든 ProximityService를 가져옵니다.
    final proximityService = container.read(proximityServiceProvider);
    // 3. 앱이 시작됨과 동시에 서비스를 실행시킵니다.
    await proximityService.start();

    // 4. 서비스의 알림 통로를 구독하고, 알림이 올 때마다 OS 시스템 알림을 띄우도록 설정합니다.
    proximityService.notificationStream.listen((notification) {
      _showLocalNotification(notification);
    });

    // 5. ProviderScope에 위에서 만든 컨테이너를 전달하여 앱 전체에서 공유하도록 합니다.

    // 모든 과정이 성공하면, 기존과 동일하게 앱을 실행합니다.
    // ProviderScope에 위에서 만든 컨테이너를 전달하여 앱 전체에서 공유하도록 합니다.
    runApp(
      UncontrolledProviderScope(container: container, child: const MyApp()),
    );
  } catch (e) {
    // 만약 위 과정에서 에러가 발생하면, 하얀 화면 대신 에러 메시지를 보여주는 앱을 실행합니다.
    runApp(ErrorApp(error: e.toString()));
  }
}

Future<void> _showLocalNotification(DdipNotification notification) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'ddip_channel_id', // 채널 ID
    '띱 근처 요청 알림', // 채널 이름
    channelDescription: '주변에 새로운 띱 요청이 있을 때 알림을 받습니다.',
    importance: Importance.max,
    priority: Priority.high,
  );
  const NotificationDetails platformDetails = NotificationDetails(
    android: androidDetails,
  );
  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch.remainder(100000), // 알림 ID
    notification.title, // 알림 제목
    notification.body, // 알림 본문
    platformDetails,
  );
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
