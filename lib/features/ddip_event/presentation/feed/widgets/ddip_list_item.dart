// lib/features/ddip_event/presentation/feed/widgets/ddip_list_item.dart

import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ConsumerWidget으로 변경하여 ref를 사용할 수 있도록 함
class DdipListItem extends ConsumerWidget {
  final DdipEvent event;
  final bool isPeek;

  const DdipListItem({super.key, required this.event, this.isPeek = false});

  // 상태(Status)에 따라 뱃지(Chip)의 색상과 텍스트를 결정하는 헬퍼 메서드
  Widget _buildStatusChip(DdipEventStatus status) {
    Color chipColor;
    String label;

    switch (status) {
      case DdipEventStatus.open:
        chipColor = Colors.blue;
        label = '지원 가능';
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
    // 현재 로그인한 사용자와 작성자 정보를 가져옴
    final currentUser = ref.watch(authProvider);
    final requester = mockUsers.firstWhere(
      (user) => user.id == event.requesterId,
      orElse: () => User(id: event.requesterId, name: '알 수 없는 작성자'),
    );

    // 접근 가능 여부를 결정하는 로직
    bool canAccessDetail = false;
    // 기본적으로는 접근 불가
    if (event.status == DdipEventStatus.open) {
      // '지원 가능' 상태는 누구나 접근 가능
      canAccessDetail = true;
    } else if (currentUser != null) {
      // 로그인한 경우, 내가 요청자이거나 선택된 수행자이면 접근 가능
      if (event.requesterId == currentUser.id ||
          event.selectedResponderId == currentUser.id) {
        canAccessDetail = true;
      }
    }

    // 참여할 수 없는 상태(완료, 실패)인지 여부
    final bool isFinished =
        event.status == DdipEventStatus.completed ||
        event.status == DdipEventStatus.failed;

    return Opacity(
      opacity: !canAccessDetail || isFinished ? 0.5 : 1.0,
      // isPeek 상태일 때는 배경색을 투명하게 처리
      child: Container(
        color: isPeek ? Colors.transparent : null,
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text(
            event.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('작성자: ${requester.name} | 보상: ${event.reward}원'),
          trailing: _buildStatusChip(event.status),
          onTap:
              canAccessDetail
                  ? () {
                    context.push('/feed/${event.id}');
                  }
                  : null,
        ),
      ),
    );
  }
}
