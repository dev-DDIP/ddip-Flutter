// ▼▼▼ lib/features/profile/data/repositories/fake_profile_repository_impl.dart ▼▼▼
import 'package:ddip/features/profile/data/repositories/mock_profile_data.dart';
import 'package:ddip/features/profile/domain/entities/profile.dart';
import 'package:ddip/features/profile/domain/repositories/profile_repository.dart';

class FakeProfileRepositoryImpl implements ProfileRepository {
  @override
  Future<Profile> getProfile(String userId) async {
    // 실제 서버 API 호출을 흉내 내기 위해 약간의 지연을 줍니다.
    await Future.delayed(const Duration(milliseconds: 500));

    // 만약 해당 userId의 목업 데이터가 없다면, requester_3(신입) 데이터를 기본값으로 사용합니다.
    final userData =
        mockUserProfileData[userId] ?? mockUserProfileData['requester_3']!;
    return Profile.fromJson(userData);
  }
}
