import 'package:ddip/features/evaluation/domain/entities/evaluation.dart';
import 'package:ddip/features/profile/data/repositories/mock_profile_data.dart';
import 'package:ddip/features/profile/domain/entities/profile.dart';
import 'package:ddip/features/profile/domain/repositories/profile_repository.dart';

class FakeProfileRepositoryImpl implements ProfileRepository {
  // 메모리 내 데이터베이스 역할을 할 private 변수
  late final Map<String, Profile> _inMemoryDb;

  FakeProfileRepositoryImpl() {
    // 생성자에서 목업 데이터를 Profile 객체로 변환하여 DB를 초기화
    _inMemoryDb = Map.fromEntries(
      mockMvpProfileData.entries.map(
        (entry) => MapEntry(entry.key, Profile.fromJson(entry.value)),
      ),
    );
  }

  @override
  Future<Profile> getProfile(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100)); // API 딜레이 흉내

    // 메모리 DB에서 데이터를 조회합니다.
    if (_inMemoryDb.containsKey(userId)) {
      return _inMemoryDb[userId]!;
    } else {
      // 찾는 유저가 없으면 기본 '신입' 유저 프로필을 반환합니다.
      return _inMemoryDb['requester_3']!;
    }
  }

  /// EvaluationRepository가 호출하는 프로필 업데이트 메서드
  @override
  Future<void> updateProfileWithEvaluation(Evaluation evaluation) async {
    final evaluateeId = evaluation.evaluateeId; // 평가받는 사람 ID
    final oldProfile = _inMemoryDb[evaluateeId];

    if (oldProfile == null) return; // 업데이트할 프로필이 없으면 종료

    // 평가받는 사람(evaluatee)의 ID를 보고 역할을 **추론**합니다.
    final bool isResponderBeingEvaluated = evaluateeId.startsWith('responder');

    // if/else 블록 외부에서 변수를 선언하여 전체 메서드에서 접근 가능하도록 합니다.
    double? oldRating;
    int oldCount;
    Map<PraiseTag, int> oldTags;

    if (isResponderBeingEvaluated) {
      // 평가받는 사람이 '수행자'인 경우
      oldRating = oldProfile.responderAverageRating;
      oldCount = oldProfile.totalExecutionCount;
      oldTags = oldProfile.responderPraiseTags;
    } else {
      // 평가받는 사람이 '요청자'인 경우
      oldRating = oldProfile.requesterAverageRating;
      oldCount = oldProfile.totalRequestCount;
      oldTags = oldProfile.requesterPraiseTags;
    }

    // 새 평균 별점 계산: (기존 총점 + 새 점수) / (기존 횟수 + 1)
    double newAverageRating;
    if (oldRating == null || oldCount == 0) {
      newAverageRating = evaluation.rating.toDouble();
    } else {
      newAverageRating =
          ((oldRating * oldCount) + evaluation.rating) / (oldCount + 1);
    }
    // 소수점 한 자리까지만 표시하도록 보정
    newAverageRating = double.parse(newAverageRating.toStringAsFixed(1));

    // 칭찬 태그 카운트 업데이트
    final newTags = Map<PraiseTag, int>.from(oldTags);
    for (var tag in evaluation.tags) {
      newTags.update(tag, (value) => value + 1, ifAbsent: () => 1);
    }

    // `copyWith`를 사용하여 새로운 Profile 객체를 생성합니다.
    final updatedProfile = oldProfile.copyWith(
      // 역할에 따라 적절한 필드를 업데이트합니다.
      responderAverageRating:
          isResponderBeingEvaluated
              ? newAverageRating
              : oldProfile.responderAverageRating,
      requesterAverageRating:
          !isResponderBeingEvaluated
              ? newAverageRating
              : oldProfile.requesterAverageRating,
      responderPraiseTags:
          isResponderBeingEvaluated ? newTags : oldProfile.responderPraiseTags,
      requesterPraiseTags:
          !isResponderBeingEvaluated ? newTags : oldProfile.requesterPraiseTags,
      // 역할에 따라 전체 수행/요청 횟수도 1 증가시킵니다.
      totalExecutionCount:
          isResponderBeingEvaluated
              ? oldCount + 1
              : oldProfile.totalExecutionCount,
      totalRequestCount:
          !isResponderBeingEvaluated
              ? oldCount + 1
              : oldProfile.totalRequestCount,
    );

    // 메모리 DB의 데이터를 업데이트된 새 객체로 교체합니다.
    _inMemoryDb[evaluateeId] = updatedProfile;
    print(
      "✅ Profile Updated for $evaluateeId: New Rating is $newAverageRating",
    );
  }
}
