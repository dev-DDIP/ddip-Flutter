// lib/core/navigation/router.dart

import 'package:ddip/features/activity/presentation/screens/activity_screen.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/creation/screens/ddip_creation_screen.dart';
import 'package:ddip/features/ddip_event/presentation/detail/screens/event_detail_screen.dart';
import 'package:ddip/features/ddip_event/presentation/detail/screens/full_screen_photo_view.dart';
import 'package:ddip/features/ddip_event/presentation/feed/screens/ddip_feed_screen.dart';
import 'package:ddip/features/evaluation/presentation/screens/evaluation_screen.dart';
import 'package:ddip/features/profile/presentation/screens/profile_screen.dart';
import 'package:ddip/features/shell/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/feed',
  routes: <RouteBase>[
    GoRoute(
      // 부모 경로가 없으므로 고유한 경로로 새로 정의합니다.
      path: '/photo-view/:eventId/:photoId',
      builder: (context, state) {
        final eventId = state.pathParameters['eventId'] ?? '0';
        final photoId = state.pathParameters['photoId'] ?? '0';
        return FullScreenPhotoView(eventId: eventId, photoId: photoId);
      },
    ),
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainShell(child: child);
      },
      routes: <RouteBase>[
        // --- 1. 홈 탭 ---
        GoRoute(
          path: '/feed',
          builder: (context, state) => const DdipFeedScreen(),
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) => const DdipCreationScreen(),
            ),
            GoRoute(
              path: ':eventId',
              builder: (context, state) {
                final eventId = state.pathParameters['eventId'] ?? '0';
                return EventDetailScreen(eventId: eventId);
              },
              routes: [
                GoRoute(
                  path: 'evaluate',
                  builder: (context, state) {
                    // 이전 화면(EventDetailScreen)에서 DdipEvent 객체를 extra로 전달받습니다.
                    final event = state.extra as DdipEvent;
                    return EvaluationScreen(event: event);
                  },
                ),
              ],
            ),
          ],
        ),

        // --- 2. 현재 활동 탭 ---
        GoRoute(
          path: '/activity',
          builder: (context, state) => const ActivityScreen(), // 실제 화면으로 변경
        ),

        // --- 3. 프로필 탭 ---
        // '/profile/:userId' 경로는 이곳에 단 한 번만 정의되어야 합니다.
        GoRoute(
          path: '/profile/:userId',
          builder: (context, state) {
            final userId = state.pathParameters['userId']!;
            return ProfileScreen(userId: userId);
          },
        ),
      ],
    ),

    // --- ShellRoute 외부에 있는 중복된 GoRoute를 삭제했습니다 ---
  ],
);
