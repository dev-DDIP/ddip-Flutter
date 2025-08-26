// lib/features/evaluation/domain/repositories/evaluation_repository.dart

import 'package:ddip/features/evaluation/domain/entities/evaluation.dart';

abstract class EvaluationRepository {
  /// 사용자가 제출한 평가 내용을 서버(또는 데이터 소스)로 전송합니다.
  Future<void> submitEvaluation(Evaluation evaluation);

  /// 특정 사용자가 특정 미션에 대한 평가를 제출했는지 확인합니다.
  Future<bool> hasUserEvaluatedMission({
    required String userId,
    required String missionId,
  });
}
