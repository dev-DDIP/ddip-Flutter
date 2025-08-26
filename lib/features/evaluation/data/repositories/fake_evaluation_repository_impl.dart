// lib/features/evaluation/data/repositories/fake_evaluation_repository_impl.dart

import 'package:ddip/features/evaluation/domain/entities/evaluation.dart';
import 'package:ddip/features/evaluation/domain/repositories/evaluation_repository.dart';

class FakeEvaluationRepositoryImpl implements EvaluationRepository {
  // ▼▼▼ 제출된 평가를 저장할 가상 데이터베이스를 추가합니다. ▼▼▼
  final List<Evaluation> _submittedEvaluations = [];
  // ▲▲▲ 제출된 평가를 저장할 가상 데이터베이스를 추가합니다. ▲▲▲

  @override
  Future<void> submitEvaluation(Evaluation evaluation) async {
    await Future.delayed(const Duration(seconds: 1));

    // ▼▼▼ 콘솔에 출력하는 대신, 가상 데이터베이스에 평가 기록을 저장합니다. ▼▼▼
    _submittedEvaluations.add(evaluation);
    print('--- [Fake Repository] 평가 제출 완료 및 저장 ---');
    print('미션 ID: ${evaluation.missionId}, 평가자: ${evaluation.evaluatorId}');
    // ▲▲▲ 콘솔에 출력하는 대신, 가상 데이터베이스에 평가 기록을 저장합니다. ▲▲▲
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
