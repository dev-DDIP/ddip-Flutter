// lib/features/evaluation/domain/repositories/evaluation_repository.dart

import 'package:ddip/features/evaluation/domain/entities/evaluation.dart';

abstract class EvaluationRepository {
  /// 사용자가 제출한 평가 내용을 서버(또는 데이터 소스)로 전송합니다.
  Future<void> submitEvaluation(Evaluation evaluation);
}
