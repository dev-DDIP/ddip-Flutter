// lib/features/ddip_event/presentation/view/widgets/applicant_list_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';

class ApplicantListView extends ConsumerStatefulWidget {
  final DdipEvent event;

  const ApplicantListView({super.key, required this.event});

  @override
  ConsumerState<ApplicantListView> createState() => _ApplicantListViewState();
}

class _ApplicantListViewState extends ConsumerState<ApplicantListView> {
  String? _processingApplicantId;

  Future<void> _selectResponder(String applicantId) async {
    if (_processingApplicantId != null) return;

    setState(() {
      _processingApplicantId = applicantId;
    });

    try {
      await ref
          .read(ddipEventsNotifierProvider.notifier)
          .selectResponder(widget.event.id, applicantId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수행자를 선택했습니다! 미션이 시작됩니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingApplicantId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.event.applicants.isEmpty) {
      return const Card(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: Icon(Icons.person_search_outlined, color: Colors.grey),
          title: Text('아직 지원자가 없습니다.'),
          subtitle: Text('조금만 더 기다려주세요!'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 16.0, bottom: 8.0),
          child: Text(
            '지원자 목록 (${widget.event.applicants.length}명)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.event.applicants.length,
          itemBuilder: (context, index) {
            final applicantId = widget.event.applicants[index];

            // ▼▼▼ 1. orElse를 사용하여 applicant가 null이 되지 않도록 보장 ▼▼▼
            final User applicant = mockUsers.firstWhere(
              (user) => user.id == applicantId,
              // 만약 mockUsers 리스트에 해당 ID가 없으면, 기본 User 객체를 반환
              orElse: () => User(id: applicantId, name: '알 수 없는 사용자'),
            );

            final isProcessing = _processingApplicantId == applicantId;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                // ▼▼▼ 2. 이제 applicant는 null이 아니므로 .name 접근이 안전합니다. ▼▼▼
                title: Text(applicant.name),
                trailing:
                    isProcessing
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: () => _selectResponder(applicantId),
                          child: const Text('선택'),
                        ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
