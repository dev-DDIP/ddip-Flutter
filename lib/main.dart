// lib/main.dart

// ------------------- Flutter 및 외부 패키지 Import -------------------
import 'dart:io';
import 'package:ddip/core/providers/core_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ------------------- DDIP 프로젝트 내부 모듈 Import -------------------
// 앱의 최상위 위젯 및 라우팅 설정
import 'package:ddip/app.dart';
import 'package:ddip/core/navigation/router.dart';

// 앱 전반에서 사용되는 서비스 및 Provider (의존성 주입 대상)
import 'package:ddip/core/services/proximity_service.dart';
import 'package:ddip/core/services/real_proximity_service_impl.dart';
import 'package:ddip/features/ddip_event/data/datasources/fake_web_socket_data_source.dart';
import 'package:ddip/features/ddip_event/data/datasources/web_socket_data_source.dart';
import 'package:ddip/features/ddip_event/data/repositories/fake_ddip_event_repository_impl.dart';
import 'package:ddip/features/ddip_event/domain/repositories/ddip_event_repository.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';

// ------------------- 백그라운드 FCM 핸들러 -------------------
/// 앱이 백그라운드 또는 종료된 상태일 때 FCM 메시지를 수신하는 핸들러입니다.
/// 반드시 클래스 외부에 최상위 함수로 존재해야 합니다.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드에서 수신 시 처리할 로직 (예: 데이터 동기화)
  // 지금은 콘솔에 로그만 남깁니다.
  print("백그라운드 메시지 수신: ${message.messageId}");
}

// ------------------- 로컬 알림 플러그인 인스턴스 -------------------
/// 포그라운드 상태에서 알림을 직접 화면에 표시하기 위한 플러그인 인스턴스입니다.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// ------------------- 앱의 메인 시작점 -------------------
void main() async {
  // `runApp`이 호출되기 전에 Flutter 엔진과 위젯 바인딩이 확실히 초기화되도록 보장합니다.
  // `async`를 사용하는 `main` 함수에서는 필수입니다.
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // --- 1단계: 필수 서비스 초기화 ---
    // 이 과정은 앱 실행에 반드시 필요한 서비스들을 준비하는 단계입니다.

    // Firebase 서비스 초기화
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // .env 파일 로드 및 네이버 지도 초기화
    await dotenv.load(fileName: ".env");
    final naverMapClientId = dotenv.env['NAVER_MAP_CLIENT_ID'];
    if (naverMapClientId == null || naverMapClientId.isEmpty) {
      throw Exception('.env 파일에 NAVER_MAP_CLIENT_ID가 설정되지 않았습니다.');
    }
    await FlutterNaverMap().init(
      clientId: naverMapClientId,
      onAuthFailed: (ex) => print('네이버 지도 인증 실패: $ex'),
    );

    // --- 2단계: 알림 시스템 설정 ---
    // 앱이 어떤 상태에 있든 알림을 수신하고 적절히 반응하도록 설정합니다.

    // 알림 클릭 시 특정 화면으로 이동시키는 함수
    void handleNotificationTap(String? eventId) {
      if (eventId != null) {
        router.go('/feed/$eventId');
      }
    }

    // 앱이 종료된 상태에서 알림을 클릭하여 실행된 경우 처리
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationTap(initialMessage.data['eventId'] as String?);
    }

    // 앱이 백그라운드에 있을 때 알림을 클릭한 경우 처리
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      handleNotificationTap(message.data['eventId'] as String?);
    });

    // 로컬 알림 플러그인 초기화
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (response) => handleNotificationTap(response.payload),
    );

    // Android 13 이상에서 알림 권한 요청
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    // --- 3단계: 의존성 주입(Dependency Injection) 설정 ---
    // 앱의 각 부분(Repository, Service 등)이 어떤 구체적인 구현체를 사용할지
    // 앱의 최상위 지점에서 중앙 관리 방식으로 결정합니다.
    final overrides = [
      // WebSocketDataSource가 필요한 곳에는 FakeWebSocketDataSource를 주입합니다.
      webSocketDataSourceProvider.overrideWithValue(FakeWebSocketDataSource()),

      // DdipEventRepository가 필요한 곳에는 FakeDdipEventRepositoryImpl을 주입합니다.
      // 이 Repository는 내부적으로 webSocketDataSourceProvider를 통해 FakeDataSource를 사용하게 됩니다.
      ddipEventRepositoryProvider.overrideWith(
        (ref) => FakeDdipEventRepositoryImpl(
          ref,
          webSocketDataSource: ref.watch(webSocketDataSourceProvider),
        ),
      ),

      // ProximityService가 필요한 곳에는 RealProximityService를 주입합니다.
      proximityServiceProvider.overrideWith((ref) => RealProximityService()),
    ];

    // --- 4단계: 앱 실행 ---
    // 위에서 정의한 의존성(overrides)을 가진 ProviderScope로 앱 전체를 감싸서 실행합니다.
    runApp(ProviderScope(overrides: overrides, child: const MyApp()));
  } catch (e) {
    // 초기화 과정에서 오류 발생 시, 사용자에게 오류 화면을 보여줍니다.
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
    payload: notification.eventId,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
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
