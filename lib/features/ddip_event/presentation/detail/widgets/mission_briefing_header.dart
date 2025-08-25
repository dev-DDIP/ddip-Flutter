// ▼▼▼ lib/features/ddip_event/presentation/detail/widgets/mission_briefing_header.dart (전체 코드) ▼▼▼
import 'package:ddip/common/utils/time_utils.dart';
import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class MissionBriefingHeader extends ConsumerWidget {
  final DdipEvent event;
  const MissionBriefingHeader({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsers = ref.watch(mockUsersProvider);
    final currentUser = ref.watch(authProvider);
    final bool isRequester = currentUser?.id == event.requesterId;
    final bool isResponderSelected = event.selectedResponderId != null;

    User displayUser;
    String displayRoleText;

    if (isRequester && isResponderSelected) {
      displayRoleText = '수행자 정보';
      displayUser = allUsers.firstWhere(
        (user) => user.id == event.selectedResponderId,
        orElse: () => User(id: event.selectedResponderId!, name: '알 수 없는 수행자'),
      );
    } else {
      displayRoleText = '요청자 정보';
      displayUser = allUsers.firstWhere(
        (user) => user.id == event.requesterId,
        orElse: () => User(id: event.requesterId, name: '알 수 없는 요청자'),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              _buildStatusChip(event.status),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Text(
              '${formatTimeAgo(event.createdAt)}에 요청됨',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              displayRoleText,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade700),
            ),
          ),
          GestureDetector(
            onTap: () {
              context.push('/profile/${displayUser.id}');
            },
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(child: Icon(Icons.person)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayUser.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6.0,
                          runSpacing: 4.0,
                          children: [
                            _buildReputationChip(
                              Icons.star,
                              "4.8",
                              Colors.amber,
                            ),
                            _buildReputationChip(
                              Icons.check_circle,
                              "12회 완료",
                              Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${NumberFormat('#,###').format(event.reward)}원',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
        ],
      ),
    );
  }

  Widget _buildReputationChip(IconData icon, String label, Color color) {
    return Chip(
      avatar: Icon(icon, color: color, size: 14),
      label: Text(label),
      labelStyle: TextStyle(fontSize: 11, color: Colors.grey[800]),
      backgroundColor: Colors.white,
      side: BorderSide(color: Colors.grey.shade300),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

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
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
    );
  }
}

// ▲▲▲ lib/features/ddip_event/presentation/detail/widgets/mission_briefing_header.dart (전체 코드) ▲▲▲
