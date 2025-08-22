// lib/features/evaluation/providers/evaluation_providers.dart

import 'package:ddip/features/evaluation/data/repositories/fake_evaluation_repository_impl.dart';
import 'package:ddip/features/evaluation/domain/repositories/evaluation_repository.dart';
import 'package:ddip/features/evaluation/presentation/notifiers/evaluation_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Data Layer
final evaluationRepositoryProvider = Provider<EvaluationRepository>((ref) {
  return FakeEvaluationRepositoryImpl();
});

// 2. Presentation Layer
final evaluationNotifierProvider =
    StateNotifierProvider.autoDispose<EvaluationNotifier, EvaluationState>((
      ref,
    ) {
      return EvaluationNotifier(ref.watch(evaluationRepositoryProvider));
    });
