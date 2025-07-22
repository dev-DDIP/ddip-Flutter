// lib/features/ddip_event/presentation/view/widgets/event_details_view.dart

import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ConsumerWidget으로 변경하여 ref를 사용할 수 있도록 함
class EventDetailsView extends ConsumerWidget {
  final DdipEvent event;

  const EventDetailsView({super.key, required this.event});

  // 상태(Status)에 따라 뱃지(Chip)의 색상과 텍스트를 결정하는 헬퍼 메서드
  Widget _buildStatusChip(DdipEventStatus status) {
    Color chipColor;
    String label;

    switch (status) {
      case DdipEventStatus.open:
        chipColor = Colors.blue;
        label = '지원 가능';
        break;
      case DdipEventStatus.pending_selection:
        chipColor = Colors.orange;
        label = '선택 대기중';
        break;
      case DdipEventStatus.in_progress:
        chipColor = Colors.green;
        label = '진행중';
        break;
      case DdipEventStatus.completed:
        chipColor = Colors.grey;
        label = '완료';
        break;
      case DdipEventStatus.failed:
        chipColor = Colors.red;
        label = '실패';
        break;
    }
    return Chip(
      label: Text(label),
      backgroundColor: chipColor.withOpacity(0.15),
      labelStyle: TextStyle(color: chipColor, fontWeight: FontWeight.bold),
      side: BorderSide(color: chipColor.withOpacity(0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ID를 이름으로 변환하기 위해 사용자 정보를 가져옴
    final requester = mockUsers.firstWhere(
      (user) => user.id == event.requesterId,
      orElse: () => User(id: event.requesterId, name: '알 수 없는 작성자'),
    );

    User? selectedResponder;
    if (event.selectedResponderId != null) {
      selectedResponder = mockUsers.firstWhere(
        (user) => user.id == event.selectedResponderId,
        orElse: () => User(id: event.selectedResponderId!, name: '알 수 없는 수행자'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목과 상태 뱃지를 함께 표시
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                event.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(width: 16),
            _buildStatusChip(event.status),
          ],
        ),
        const SizedBox(height: 12),

        // 작성자, 보상, 선택된 수행자 정보 표시
        Row(
          children: [
            const Icon(Icons.person_outline, size: 18, color: Colors.black54),
            const SizedBox(width: 4),
            Text(
              '작성자: ${requester.name}',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            const Icon(
              Icons.monetization_on_outlined,
              size: 18,
              color: Colors.black54,
            ),
            const SizedBox(width: 4),
            Text('보상: ${event.reward}원', style: const TextStyle(fontSize: 16)),
          ],
        ),
        if (selectedResponder != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.handshake_outlined,
                size: 18,
                color: Colors.black54,
              ),
              const SizedBox(width: 4),
              Text(
                '수행자: ${selectedResponder.name}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],

        const Divider(height: 32),
        Text(event.content, style: const TextStyle(fontSize: 16, height: 1.5)),
        const SizedBox(height: 24),
      ],
    );
  }
}
