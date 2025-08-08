// lib/features/profile/presentation/providers/profile_provider.dart

import 'package:collection/collection.dart';
import 'package:ddip/features/profile/data/mock_user_profile_data.dart';
import 'package:ddip/features/profile/domain/entities/user_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'profile_provider.g.dart'; // build_runner 실행 후 생성될 파일

@riverpod
Future<UserProfile> userProfile(UserProfileRef ref, String userId) async {
  // 실제 앱에서는 여기서 Repository를 통해 서버 API를 호출합니다.
  // 지금은 가짜 데이터를 사용해 비동기 통신을 흉내 냅니다.
  await Future.delayed(const Duration(milliseconds: 500)); // 0.5초 딜레이로 로딩 흉내

  final profile = mockUserProfiles.firstWhereOrNull((p) => p.userId == userId);

  if (profile != null) {
    return profile;
  } else {
    // 요청된 ID의 유저가 없으면 에러를 발생시킵니다.
    throw Exception('User not found');
  }
}
