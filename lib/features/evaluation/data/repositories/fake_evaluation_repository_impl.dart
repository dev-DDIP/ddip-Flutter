// lib/features/evaluation/data/repositories/fake_evaluation_repository_impl.dart

import 'package:ddip/features/evaluation/domain/entities/evaluation.dart';
import 'package:ddip/features/evaluation/domain/repositories/evaluation_repository.dart';

class FakeEvaluationRepositoryImpl implements EvaluationRepository {
  @override
  Future<void> submitEvaluation(Evaluation evaluation) async {
    // 실제 서버 API 호출을 흉내 내기 위해 1초 지연
    await Future.delayed(const Duration(seconds: 1));

    // 실제로는 여기서 서버로 evaluation 객체를 JSON 형태로 변환하여 전송합니다.
    // 지금은 개발을 위해 콘솔에 출력하는 것으로 대체합니다.
    print('--- [Fake Repository] 평가 제출 ---');
    print('미션 ID: ${evaluation.missionId}');
    print('평가자: ${evaluation.evaluatorId}');
    print('피평가자: ${evaluation.evaluateeId}');
    print('별점: ${evaluation.rating}');
    print('칭찬 태그: ${evaluation.tags.map((t) => t.name).toList()}');
    print('한줄평: ${evaluation.comment}');
    print('----------------------------------');

    // 성공적으로 제출되었다고 가정하고 void를 반환합니다.
    // 만약 서버 에러가 발생하면 여기서 Exception을 던질 수 있습니다.
    // throw Exception('평가 제출에 실패했습니다.');
  }
}
