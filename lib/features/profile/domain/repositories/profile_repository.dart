// ▼▼▼ lib/features/profile/domain/repositories/profile_repository.dart ▼▼▼
import 'package:ddip/features/profile/domain/entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile(String userId);
}

// ▲▲▲ lib/features/profile/domain/repositories/profile_repository.dart ▲▲▲
