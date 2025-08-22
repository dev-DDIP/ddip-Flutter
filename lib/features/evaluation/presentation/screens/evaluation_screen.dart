// lib/features/evaluation/presentation/screens/evaluation_screen.dart

import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/evaluation/domain/entities/evaluation.dart';
import 'package:ddip/features/evaluation/providers/evaluation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EvaluationScreen extends ConsumerStatefulWidget {
  final DdipEvent event;

  const EvaluationScreen({super.key, required this.event});

  @override
  ConsumerState<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends ConsumerState<EvaluationScreen> {
  int _rating = 0;
  final Set<PraiseTag> _selectedTags = {};
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider)!;
    final isRequester = widget.event.requesterId == currentUser.id;

    // 평가 대상 유저 정보 찾기
    final allUsers = ref.watch(mockUsersProvider);
    final evaluateeId =
        isRequester
            ? widget.event.selectedResponderId!
            : widget.event.requesterId;
    final User evaluatee = allUsers.firstWhere(
      (user) => user.id == evaluateeId,
      orElse: () => User(id: evaluateeId, name: '상대방'),
    );

    final Map<PraiseTag, String> availableTags =
        isRequester
            ? {
              PraiseTag.photoClarity: '사진이 선명해요 📸',
              PraiseTag.goodComprehension: '요청을 정확히 이해했어요 👍',
              PraiseTag.kindAndPolite: '친절하고 매너가 좋아요 😊',
              PraiseTag.sensibleExtraInfo: '센스있는 추가 정보 ✨',
            }
            : {
              PraiseTag.clearRequest: '요청사항이 명확했어요 🎯',
              PraiseTag.fastFeedback: '빠른 확인과 피드백 ✅',
              PraiseTag.politeAndKind: '매너있고 친절해요 🙏',
              PraiseTag.reasonableRequest: '합리적인 요구사항 🤝',
            };

    final notifier = ref.read(evaluationNotifierProvider.notifier);
    final state = ref.watch(evaluationNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('평가하기')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '"${evaluatee.name}"님과의 미션은\n어떠셨나요?',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('종합 만족도 (필수)'),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < _rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 40,
                    ),
                    onPressed: () => setState(() => _rating = index + 1),
                  );
                }),
              ),
            ),
            const Divider(height: 48),
            _buildSectionTitle('어떤 점이 특히 좋았나요? (선택)'),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children:
                  availableTags.entries.map((entry) {
                    final isSelected = _selectedTags.contains(entry.key);
                    return FilterChip(
                      label: Text(entry.value),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedTags.add(entry.key);
                          } else {
                            _selectedTags.remove(entry.key);
                          }
                        });
                      },
                    );
                  }).toList(),
            ),
            const Divider(height: 48),
            _buildSectionTitle('한줄평 남기기 (선택)'),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: '자유롭게 의견을 남겨주세요. (최대 100자)',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FilledButton(
          onPressed:
              (_rating == 0 || state.isSubmitting)
                  ? null
                  : () async {
                    final evaluation = Evaluation(
                      missionId: widget.event.id,
                      evaluatorId: currentUser.id,
                      evaluateeId: evaluateeId,
                      rating: _rating,
                      tags: _selectedTags.toList(),
                      comment: _commentController.text,
                    );

                    final success = await notifier.submitEvaluation(evaluation);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success ? '평가가 제출되었습니다.' : '오류가 발생했습니다.',
                          ),
                        ),
                      );
                      if (success) {
                        context.pop();
                      }
                    }
                  },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child:
              state.isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                    '평가 제출하기',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}
