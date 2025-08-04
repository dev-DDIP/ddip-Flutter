// lib/features/ddip_event/presentation/detail/widgets/event_detail_header.dart

// --- ▼▼▼ [신규] 독립된 헤더 위젯 코드 ▼▼▼ ---

import 'package:ddip/features/auth/domain/entities/user.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// 상세 화면의 모든 헤더 정보를 표시하는 책임을 가지는 독립된 위젯입니다.
/// DdipEvent 객체 하나만 받아서 헤더 전체를 그립니다.
class EventDetailHeader extends ConsumerWidget {
  final DdipEvent event;

  const EventDetailHeader({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requester = ref
        .watch(mockUsersProvider)
        .firstWhere(
          (user) => user.id == event.requesterId,
          orElse: () => User(id: event.requesterId, name: '알 수 없는 작성자'),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 제목과 상태 뱃지
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
          const SizedBox(height: 16),

          // 2. 요청자 정보와 보상
          Row(
            children: [
              const Icon(Icons.person_outline, size: 18, color: Colors.black54),
              const SizedBox(width: 4),
              Text(
                '요청자: ${requester.name}',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const Text('4.8', style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              const Icon(
                Icons.monetization_on_outlined,
                size: 18,
                color: Colors.black54,
              ),
              const SizedBox(width: 4),
              Text(
                '보상: ${NumberFormat('#,###').format(event.reward)}원',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // 3. 진행률 표시줄
          _buildProgressBar(context, event.status),

          // 4. 사진 검토 현황
          _buildPhotoReviewStatus(context, event),

          // 5. 헤더와 탭 바를 구분하는 선
          const Divider(height: 1),
        ],
      ),
    );
  }

  /// 이벤트 상태에 따라 다른 색상과 텍스트의 뱃지를 생성하는 위젯
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

  Widget _buildProgressBar(BuildContext context, DdipEventStatus status) {
    final steps = ['모집 중', '진행 중', '사진 검토', '완료/실패'];
    int currentStep;
    bool isFailed = false;

    switch (status) {
      case DdipEventStatus.open:
        currentStep = 0;
        break;
      case DdipEventStatus.in_progress:
        currentStep = 1;
        // 사진 제출 여부에 따라 2단계로 넘어갈지 결정
        if (event.photos.any((p) => p.status == PhotoStatus.pending)) {
          currentStep = 2;
        }
        break;
      case DdipEventStatus.completed:
        currentStep = 3;
        break;
      case DdipEventStatus.failed:
        currentStep = 3;
        isFailed = true;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          final bool isActive = index <= currentStep;
          final Color color =
              isFailed && index == currentStep
                  ? Colors.red
                  : isActive
                  ? Theme.of(context).primaryColor
                  : Colors.grey.shade300;

          return Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                child: Center(
                  child:
                      isActive && !isFailed
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                          : isFailed && index == currentStep
                          ? const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          )
                          : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[index],
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? Colors.black : Colors.grey,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  /// 사진 검증 상태를 3개의 아이콘으로 시각화하는 위젯을 생성합니다.
  Widget _buildPhotoReviewStatus(BuildContext context, DdipEvent event) {
    // 사진 검토와 관련된 상태일 때만 위젯을 보여줍니다.
    if (event.status != DdipEventStatus.in_progress &&
        event.status != DdipEventStatus.completed &&
        event.status != DdipEventStatus.failed) {
      return const SizedBox.shrink(); // 해당 없으면 아무것도 그리지 않음
    }

    final photos = event.photos;
    List<Widget> statusIcons = [];

    // 제출된 사진 개수만큼 아이콘을 생성합니다.
    for (int i = 0; i < photos.length; i++) {
      final photo = photos[i];
      IconData icon;
      Color color;

      switch (photo.status) {
        case PhotoStatus.approved:
          icon = Icons.check_circle;
          color = Colors.green;
          break;
        case PhotoStatus.rejected:
          icon = Icons.cancel;
          color = Colors.red;
          break;
        case PhotoStatus.pending:
          icon = Icons.watch_later;
          color = Colors.orange;
          break;
      }
      statusIcons.add(Icon(icon, color: color, size: 28));
    }

    // 3번의 기회를 시각적으로 보여주기 위해 남은 공간을 빈 아이콘으로 채웁니다.
    int remainingSlots = 3 - photos.length;
    if (remainingSlots > 0) {
      for (int i = 0; i < remainingSlots; i++) {
        statusIcons.add(
          Icon(Icons.radio_button_unchecked, color: Colors.grey[300], size: 28),
        );
      }
    }

    // 만약 3번을 초과하여 제출했다면, 초과분을 텍스트로 표시합니다.
    if (photos.length > 3) {
      statusIcons.add(
        Text(
          '+${photos.length - 3}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '사진 검토 현황: ',
            style: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          // 아이콘들 사이에 간격을 주기 위해 Wrap 대신 Row와 SizedBox 사용
          ...List.generate(statusIcons.length, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: statusIcons[index],
            );
          }),
        ],
      ),
    );
  }
}

// --- ▲▲▲ [신규] 독립된 헤더 위젯 코드 ▲▲▲ ---
