import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DdipListItem extends StatelessWidget {
  final DdipEvent event;

  const DdipListItem({super.key, required this.event});

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
  Widget build(BuildContext context) {
    // 참여할 수 없는 상태(진행중, 완료, 실패)인지 여부를 결정
    final bool isInactive =
        event.status == DdipEventStatus.in_progress ||
        event.status == DdipEventStatus.completed ||
        event.status == DdipEventStatus.failed;

    return Opacity(
      // 비활성화된 항목은 반투명하게 처리
      opacity: isInactive ? 0.5 : 1.0,
      child: ListTile(
        title: Text(
          event.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('보상: ${event.reward}원'),
        // 우측에 상태 뱃지를 표시
        trailing: _buildStatusChip(event.status),
        // 비활성화된 항목은 탭 기능을 null로 설정하여 막음
        onTap:
            isInactive
                ? null
                : () {
                  context.push('/feed/${event.id}');
                },
      ),
    );
  }
}
