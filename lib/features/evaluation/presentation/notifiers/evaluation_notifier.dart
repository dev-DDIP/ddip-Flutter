// lib/features/evaluation/presentation/notifiers/evaluation_notifier.dart

import 'package:ddip/features/evaluation/domain/entities/evaluation.dart';
import 'package:ddip/features/evaluation/domain/repositories/evaluation_repository.dart';
import 'package:ddip/features/profile/providers/profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 평가 화면의 상태를 관리 (제출 중인지 여부)
class EvaluationState {
  final bool isSubmitting;

  EvaluationState({this.isSubmitting = false});
}

class EvaluationNotifier extends StateNotifier<EvaluationState> {
  final EvaluationRepository _repository;
  final Ref _ref; // [추가] Ref를 멤버 변수로 가짐

  EvaluationNotifier(this._repository, this._ref) : super(EvaluationState());

  Future<bool> submitEvaluation(Evaluation evaluation) async {
    if (state.isSubmitting) return false;
    state = EvaluationState(isSubmitting: true);
    try {
      await _repository.submitEvaluation(evaluation);

      // [핵심] 평가 제출 성공 후, 평가받은 사람의 프로필 Provider를 무효화(invalidate) 시킴
      // 이렇게 하면 해당 프로필 화면이 열려있을 경우, 변경된 데이터로 새로고침됩니다.
      _ref.invalidate(profileProvider(evaluation.evaluateeId));

      state = EvaluationState(isSubmitting: false);
      return true; // 성공
    } catch (e) {
      state = EvaluationState(isSubmitting: false);
      return false; // 실패
    }
  }
}
