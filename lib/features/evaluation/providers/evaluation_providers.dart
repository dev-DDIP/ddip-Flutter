// lib/features/evaluation/providers/evaluation_providers.dart

import 'package:ddip/features/evaluation/data/repositories/fake_evaluation_repository_impl.dart';
import 'package:ddip/features/evaluation/domain/repositories/evaluation_repository.dart';
import 'package:ddip/features/evaluation/presentation/notifiers/evaluation_notifier.dart';
import 'package:ddip/features/profile/providers/profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Data Layer
final evaluationRepositoryProvider = Provider<EvaluationRepository>((ref) {
  // [핵심] ProfileRepository를 읽어와서 EvaluationRepository 생성자에 주입합니다.
  final profileRepository = ref.watch(profileRepositoryProvider);
  return FakeEvaluationRepositoryImpl(profileRepository);
});

// 2. Presentation Layer
final evaluationNotifierProvider =
    StateNotifierProvider.autoDispose<EvaluationNotifier, EvaluationState>((
      ref,
    ) {
      final evalRepo = ref.watch(evaluationRepositoryProvider);
      return EvaluationNotifier(evalRepo, ref); // [수정] ref를 넘겨주도록 변경
    });
