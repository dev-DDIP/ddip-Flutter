// ▼▼▼ lib/features/profile/providers/profile_providers.dart ▼▼▼
import 'package:ddip/features/profile/domain/entities/profile.dart';
import 'package:ddip/features/profile/domain/repositories/fake_profile_repository_impl.dart';
import 'package:ddip/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// [수정] Provider가 상태를 가질 수 있도록 Singleton으로 만듭니다.
// 앱이 실행되는 동안 단 하나의 FakeProfileRepositoryImpl 인스턴스만 존재하게 됩니다.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return FakeProfileRepositoryImpl();
});

// [핵심 변경] FutureProvider -> StateNotifierProvider
// 이제 프로필 데이터는 '한 번만 로드되는 미래 값'이 아니라 '지속적으로 변경될 수 있는 상태'가 됩니다.
final profileProvider = StateNotifierProvider.autoDispose
    .family<ProfileNotifier, AsyncValue<Profile>, String>((ref, userId) {
      final repository = ref.watch(profileRepositoryProvider);
      return ProfileNotifier(repository, userId);
    });

// 프로필 상태를 관리하는 Notifier 클래스
class ProfileNotifier extends StateNotifier<AsyncValue<Profile>> {
  final ProfileRepository _repository;
  final String _userId;

  ProfileNotifier(this._repository, this._userId)
    : super(const AsyncValue.loading()) {
    _fetchProfile(); // Notifier가 생성되자마자 프로필 로드 시작
  }

  // 프로필 데이터를 비동기적으로 가져오는 메서드
  Future<void> _fetchProfile() async {
    try {
      final profile = await _repository.getProfile(_userId);
      state = AsyncValue.data(profile);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}
