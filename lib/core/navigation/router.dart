// lib/core/navigation/router.dart

import 'package:ddip/features/ddip_event/presentation/creation/screens/ddip_creation_screen.dart';
import 'package:ddip/features/ddip_event/presentation/detail/screens/event_detail_screen.dart';
import 'package:ddip/features/ddip_event/presentation/detail/screens/full_screen_photo_view.dart';
import 'package:ddip/features/ddip_event/presentation/feed/screens/ddip_feed_screen.dart';
import 'package:ddip/features/profile/presentation/screens/profile_screen.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/feed',
  routes: <RouteBase>[
    GoRoute(
      path: '/feed',
      builder: (context, state) => const DdipFeedScreen(),
      routes: [
        GoRoute(
          path: 'create', // /feed/create
          builder: (context, state) => const DdipCreationScreen(),
        ),
        GoRoute(
          path: ':eventId', // /feed/{eventId}
          builder: (context, state) {
            final eventId = state.pathParameters['eventId'] ?? '0';
            return EventDetailScreen(eventId: eventId);
          },
          routes: [
            // ▼▼▼ 사진 상세 페이지를 위한 경로 추가 ▼▼▼
            GoRoute(
              path: 'photo/:photoId', // /feed/{eventId}/photo/{photoId}
              builder: (context, state) {
                final eventId = state.pathParameters['eventId'] ?? '0';
                final photoId = state.pathParameters['photoId'] ?? '0';
                return FullScreenPhotoView(eventId: eventId, photoId: photoId);
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/profile/:userId', // 예: /profile/requester_1
      builder: (context, state) {
        // URL 경로에서 ':userId' 부분의 값을 추출합니다.
        final userId = state.pathParameters['userId']!;
        // 추출한 userId를 ProfileScreen 위젯에 파라미터로 전달합니다.
        return ProfileScreen(userId: userId);
      },
    ),
  ],
);
