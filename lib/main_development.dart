// lib/main_development.dart
import 'package:ddip/core/navigation/router.dart';
import 'package:ddip/core/providers/core_providers.dart';
import 'package:ddip/core/services/real_proximity_service_impl.dart';
import 'package:ddip/features/ddip_event/data/datasources/fake_web_socket_data_source.dart';
import 'package:ddip/features/ddip_event/data/datasources/web_socket_data_source.dart';
import 'package:ddip/features/ddip_event/data/repositories/fake_ddip_event_repository_impl.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/evaluation/providers/evaluation_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

// ------------------- 백그라운드 FCM 핸들러 -------------------
// main.dart와 동일하게 최상위 레벨에 핸들러를 정의합니다.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("백그라운드 메시지 수신 (개발): ${message.messageId}");
}

// ------------------- 로컬 알림 플러그인 인스턴스 -------------------
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ------------------- 개발 환경용 메인 시작점 -------------------
void main() async {
  // `runApp` 전에 Flutter 엔진과 위젯 바인딩을 초기화합니다.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // --- 1단계: 필수 서비스 초기화 (main.dart와 동일) ---
    // 개발 환경에서도 Firebase, Naver Map 등 핵심 SDK는 동일하게 초기화되어야 합니다.
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await dotenv.load(fileName: ".env");
    final naverMapClientId = dotenv.env['NAVER_MAP_CLIENT_ID'];
    if (naverMapClientId == null || naverMapClientId.isEmpty) {
      throw Exception('.env 파일에 NAVER_MAP_CLIENT_ID가 설정되지 않았습니다.');
    }
    await FlutterNaverMap().init(
      clientId: naverMapClientId,
      onAuthFailed: (ex) => print('네이버 지도 인증 실패: $ex'),
    );

    await initializeDateFormatting('ko_KR');

    // --- 2단계: 알림 시스템 설정 (main.dart와 동일) ---
    void handleNotificationTap(String? eventId) {
      if (eventId != null) {
        router.go('/feed/$eventId');
      }
    }

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationTap(initialMessage.data['eventId'] as String?);
    }
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationTap(message.data['eventId'] as String?);
    });

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (response) => handleNotificationTap(response.payload),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // --- 3단계: 의존성 주입(DI) 설정 (🔥 개발 환경용 설정) ---
    // 이 부분이 main.dart와 유일하게 다른 부분입니다.
    // 실제 서버 대신 가짜(Fake) 데이터 소스와 레포지토리를 주입합니다.
    final overrides = [
      webSocketDataSourceProvider.overrideWithValue(FakeWebSocketDataSource()),

      // DdipEventRepository가 필요한 곳에는 FakeDdipEventRepositoryImpl을 주입합니다.
      ddipEventRepositoryProvider.overrideWith((ref) {
        // evaluationRepository를 주입받도록 수정합니다.
        final webSocketDataSource = ref.watch(webSocketDataSourceProvider);
        final evaluationRepository = ref.watch(evaluationRepositoryProvider);

        return FakeDdipEventRepositoryImpl(
          ref,
          webSocketDataSource: webSocketDataSource,
          evaluationRepository: evaluationRepository, // 주입
        );
      }),

      proximityServiceProvider.overrideWith((ref) => RealProximityService()),
    ];

    // --- 4단계: 앱 실행 ---
    runApp(ProviderScope(overrides: overrides, child: const MyApp()));
  } catch (e) {
    // 초기화 과정에서 오류 발생 시, 에러 화면을 보여줍니다.
    runApp(ErrorApp(error: e.toString()));
  }
}

// 참고: 아래 위젯들은 main.dart에도 정의되어 있습니다.
// 향후 프로젝트가 더 커지면 별도의 파일(예: app.dart)로 분리하여 코드 중복을 줄일 수 있습니다.

/// 앱의 루트 위젯. MaterialApp.router를 설정합니다.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: '띱(DDIP) - Dev', // 개발 버전임을 명시
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ), // 개발 버전 테마 색상
        useMaterial3: true,
      ),
    );
  }
}

/// 앱 초기화 실패 시 표시될 에러 화면 위젯입니다.
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
              '개발자 모드에서 앱 초기화 실패 (Dev):\n$error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
