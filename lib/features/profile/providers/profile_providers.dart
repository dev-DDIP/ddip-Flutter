// ▼▼▼ lib/features/profile/providers/profile_providers.dart ▼▼▼
import 'package:ddip/features/profile/domain/entities/profile.dart';
import 'package:ddip/features/profile/domain/repositories/fake_profile_repository_impl.dart';
import 'package:ddip/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data 계층의 Repository 구현체를 제공하는 Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  // TODO: 추후 실제 서버 API를 사용하는 RealProfileRepositoryImpl로 교체해야 합니다.
  return FakeProfileRepositoryImpl();
});

// Presentation 계층(UI)에서 사용할 최종 데이터를 제공하는 Provider
// FutureProvider.family를 사용하여 userId를 파라미터로 받아
// 해당 유저의 프로필 정보를 비동기적으로 로드합니다.
final profileProvider = FutureProvider.autoDispose.family<Profile, String>((
  ref,
  userId,
) {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getProfile(userId);
});
// ▲▲▲ lib/features/profile/providers/profile_providers.dart ▲▲▲
