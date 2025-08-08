// lib/features/profile/data/mock_user_profile_data.dart

import 'package:ddip/features/profile/domain/entities/user_profile.dart';

// 나중에 서버 API로 대체될 가짜 프로필 데이터 목록입니다.
final mockUserProfiles = [
  UserProfile(
    userId: 'requester_1',
    nickname: '김요청',
    profileImageUrl: 'https://example.com/profile1.jpg', // 실제 이미지 URL로 교체 가능
    level: 12,
    title: '북문 지박령',
    stats: const UserProfileStats(
      requesterStats: RoleStats(
        totalCount: 25,
        successCount: 23,
        failCount: 2,
        averageRating: 4.8,
        recentFeedbacks: ['응답이 빨라요', '친절해요'],
      ),
      responderStats: RoleStats(
        totalCount: 5,
        successCount: 4,
        failCount: 1,
        averageRating: 4.5,
        recentFeedbacks: ['사진을 잘 찍어주셨어요'],
      ),
    ),
    badges: [
      Badge(
        badgeId: 'first_ddip',
        name: '첫 띱!',
        description: '첫 번째 요청을 성공적으로 완료했습니다.',
        imageUrl: 'https://example.com/badge1.png',
        achievedAt: DateTime(2025, 5, 1),
      ),
      Badge(
        badgeId: 'north_gate_lover',
        name: '북문 사랑꾼',
        description: '북문에서 10번 이상 활동했습니다.',
        imageUrl: 'https://example.com/badge2.png',
        achievedAt: DateTime(2025, 7, 22),
      ),
    ],
    activityAreas: const [
      ActivityArea(areaName: '북문', count: 18),
      ActivityArea(areaName: '중앙도서관', count: 7),
    ],
  ),
  UserProfile(
    userId: 'responder_1',
    nickname: '이수행',
    profileImageUrl: 'https://example.com/profile2.jpg',
    level: 25,
    title: '번개처럼',
    stats: const UserProfileStats(
      requesterStats: RoleStats(
        totalCount: 10,
        successCount: 10,
        failCount: 0,
        averageRating: 5.0,
        recentFeedbacks: [],
      ),
      responderStats: RoleStats(
        totalCount: 52,
        successCount: 48,
        failCount: 4,
        averageRating: 4.9,
        recentFeedbacks: ['덕분에 헛걸음 안 했어요!', '사진만 봐도 상황 파악 완료!', '최고에요!'],
      ),
    ),
    badges: [
      // ... (이수행 님의 뱃지 데이터)
    ],
    activityAreas: const [
      ActivityArea(areaName: '센트럴파크', count: 25),
      ActivityArea(areaName: 'IT-1호관', count: 15),
      ActivityArea(areaName: '공과대학', count: 12),
    ],
  ),
  // 다른 유저들의 프로필 데이터도 필요에 따라 추가...
];
