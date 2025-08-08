import 'package:ddip/common/utils/time_utils.dart';
import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EventOverviewCard extends ConsumerWidget {
  final DdipEvent event;
  final VoidCallback onBackToList;
  final VoidCallback onViewDetails;

  const EventOverviewCard({
    super.key,
    required this.event,
    required this.onBackToList,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsers = ref.watch(mockUsersProvider);
    final requester = allUsers.firstWhere(
      (user) => user.id == event.requesterId,
      orElse: () => User(id: event.requesterId, name: '알 수 없는 작성자'),
    );

    // [핵심 수정] Column을 Stack으로 변경하여 레이아웃 충돌을 해결합니다.
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          // 1. 콘텐츠 영역 (제목, 내용 등 버튼을 제외한 모든 부분)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 뒤로가기 버튼과 제목
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: onBackToList,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Expanded(
                    child: Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const Divider(height: 24),

              // 요청자 정보 및 보상
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Text(
                      '${requester.name} · ${formatTimeAgo(event.createdAt)}',
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.monetization_on_outlined,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text('${NumberFormat('#,###').format(event.reward)}원'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 요청 내용
              Card(
                elevation: 0,
                color: Colors.grey[100],
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    event.content,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 4,
                    style: TextStyle(color: Colors.grey[800], height: 1.5),
                  ),
                ),
              ),
              // 버튼이 들어갈 공간 확보
              const SizedBox(height: 80),
            ],
          ),

          // 2. [핵심 수정] '자세히 보기' 버튼을 Positioned로 하단에 고정
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onViewDetails,
                child: const Text('자세히 보기'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
