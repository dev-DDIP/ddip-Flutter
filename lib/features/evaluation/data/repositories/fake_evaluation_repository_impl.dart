// lib/features/evaluation/data/repositories/fake_evaluation_repository_impl.dart

import 'package:ddip/features/evaluation/domain/entities/evaluation.dart';
import 'package:ddip/features/evaluation/domain/repositories/evaluation_repository.dart';
import 'package:ddip/features/profile/domain/repositories/profile_repository.dart';

class FakeEvaluationRepositoryImpl implements EvaluationRepository {
  // 1. [핵심] ProfileRepository에 대한 참조를 저장할 변수
  final ProfileRepository _profileRepository;

  final List<Evaluation> _submittedEvaluations = [];

  // 2. 생성자를 통해 ProfileRepository 인스턴스를 주입받음
  FakeEvaluationRepositoryImpl(this._profileRepository);

  @override
  Future<void> submitEvaluation(Evaluation evaluation) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _submittedEvaluations.add(evaluation);

    // 3. [핵심] 주입받은 ProfileRepository의 업데이트 메서드를 호출!
    await _profileRepository.updateProfileWithEvaluation(evaluation);
  }

  // ▼▼▼ 새로 추가된 메소드를 구현합니다. ▼▼▼
  @override
  Future<bool> hasUserEvaluatedMission({
    required String userId,
    required String missionId,
  }) async {
    // 가상 데이터베이스에서 해당 미션 ID와 평가자 ID가 일치하는 기록이 있는지 찾습니다.
    final hasEvaluated = _submittedEvaluations.any(
      (eval) => eval.missionId == missionId && eval.evaluatorId == userId,
    );
    return hasEvaluated;
  }

  // ▲▲▲ 새로 추가된 메소드를 구현합니다. ▲▲▲
}
