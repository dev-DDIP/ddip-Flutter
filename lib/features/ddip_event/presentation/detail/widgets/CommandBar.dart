// lib/features/ddip_event/presentation/detail/widgets/command_bar.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/presentation/detail/viewmodels/event_detail_view_model.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 상세 화면 하단에 고정되어, 현재 상황에 맞는 핵심 행동(CTA)을 제시하는 버튼 바 위젯.
class CommandBar extends ConsumerWidget {
  final DdipEvent event;

  const CommandBar({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ViewModel을 구독하여 로딩 상태(isProcessing)를 가져옴
    final viewModelState = ref.watch(eventDetailViewModelProvider(event.id));
    // ViewModel의 메서드를 호출하기 위해 notifier를 읽음
    final viewModel = ref.read(eventDetailViewModelProvider(event.id).notifier);
    final currentUser = ref.watch(authProvider);

    // 로딩 중일 때는 인디케이터 표시
    if (viewModelState.isProcessing) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // 현재 사용자와 이벤트 상태에 따라 표시할 버튼 위젯을 동적으로 결정
    final Widget actionButton = _buildActionButton(
      context,
      ref,
      viewModel,
      currentUser?.id,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // 하단 여백 추가
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: actionButton,
    );
  }

  // 복잡한 버튼 생성 로직을 별도 메서드로 분리하여 build 메서드를 깔끔하게 유지
  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    EventDetailViewModel viewModel,
    String? currentUserId,
  ) {
    final bool isRequester = event.requesterId == currentUserId;
    final bool isSelectedResponder = event.selectedResponderId == currentUserId;
    final bool hasApplied = event.applicants.contains(currentUserId);
    final bool hasPendingPhoto = event.photos.any(
      (p) => p.status == PhotoStatus.pending,
    );

    // 설계안 v2.0의 상태별 버튼 규칙 적용
    switch (event.status) {
      case DdipEventStatus.open:
        if (isRequester) {
          // 요청자는 지원자가 있을 때만 '수행자 선택' 버튼 활성화
          return FilledButton(
            onPressed:
                event.applicants.isNotEmpty
                    ? () => viewModel.handleButtonPress(context)
                    : null,
            child: const Text('수행자 선택하기'),
          );
        } else if (hasApplied) {
          // 이미 지원한 사용자는 '지원 취소' 버튼 비활성화 상태로 표시
          return const FilledButton(onPressed: null, child: Text('지원 처리됨'));
        } else {
          // 방문자는 '미션 지원하기'
          return FilledButton(
            onPressed: () => viewModel.handleButtonPress(context),
            child: const Text('미션 지원하기'),
          );
        }

      case DdipEventStatus.in_progress:
        if (isSelectedResponder && !hasPendingPhoto) {
          // 선택된 수행자는 '증거 사진 제출'
          return FilledButton.icon(
            onPressed: () => viewModel.handleButtonPress(context),
            icon: const Icon(Icons.camera_alt),
            label: const Text('증거 사진 제출하기'),
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
          );
        } else if (isRequester && hasPendingPhoto) {
          // 요청자는 사진 확인 대기 중일 때 두 개의 버튼 표시
          // 참고: ViewModel에 approveMission, requestRevision 같은 세분화된 메서드 추가 필요
          return Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      () => print('수정 요청 버튼 클릭'), // TODO: ViewModel에 메서드 연결
                  child: const Text('수정 요청'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed:
                      () => print('미션 승인 버튼 클릭'), // TODO: ViewModel에 메서드 연결
                  child: const Text('미션 승인'),
                  style: FilledButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ),
            ],
          );
        }
        break; // 다른 역할의 사용자는 버튼 없음

      case DdipEventStatus.completed:
      case DdipEventStatus.failed:
        // 미션 종료 후 '평가 남기기' 버튼
        return ElevatedButton(
          onPressed: () => print('평가 남기기 버튼 클릭'), // TODO: 평가 시스템 연동
          child: const Text('평가 남기기'),
        );
    }

    // 위 조건에 해당하지 않는 모든 경우 버튼을 표시하지 않음
    return const SizedBox.shrink();
  }
}
