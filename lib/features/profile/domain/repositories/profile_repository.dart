// lib/features/profile/domain/repositories/profile_repository.dart
import 'package:ddip/features/evaluation/domain/entities/evaluation.dart';
import 'package:ddip/features/profile/domain/entities/profile.dart';

abstract class ProfileRepository {
  Future<Profile> getProfile(String userId);

  // [추가] 평가 결과를 프로필에 반영하기 위한 메서드
  Future<void> updateProfileWithEvaluation(Evaluation evaluation);
}
