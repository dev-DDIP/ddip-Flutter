// lib/features/evaluation/presentation/notifiers/evaluation_notifier.dart

import 'package:ddip/features/evaluation/domain/entities/evaluation.dart';
import 'package:ddip/features/evaluation/domain/repositories/evaluation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 평가 화면의 상태를 관리 (제출 중인지 여부)
class EvaluationState {
  final bool isSubmitting;
  EvaluationState({this.isSubmitting = false});
}

class EvaluationNotifier extends StateNotifier<EvaluationState> {
  final EvaluationRepository _repository;

  EvaluationNotifier(this._repository) : super(EvaluationState());

  Future<bool> submitEvaluation(Evaluation evaluation) async {
    if (state.isSubmitting) return false; // 중복 제출 방지
    state = EvaluationState(isSubmitting: true);
    try {
      await _repository.submitEvaluation(evaluation);
      state = EvaluationState(isSubmitting: false);
      return true; // 성공
    } catch (e) {
      state = EvaluationState(isSubmitting: false);
      return false; // 실패
    }
  }
}
