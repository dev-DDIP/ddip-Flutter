// lib/features/ddip_event/presentation/view/widgets/event_action_button.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/camera/camera_screen.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo_feedback.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class EventActionButton extends ConsumerStatefulWidget {
  final DdipEvent event;

  const EventActionButton({super.key, required this.event});

  @override
  ConsumerState<EventActionButton> createState() => _EventActionButtonState();
}

class _EventActionButtonState extends ConsumerState<EventActionButton> {
  bool _isProcessing = false;

  // 버튼 클릭 시 비동기 작업을 처리하는 공통 함수
  Future<void> _handleAction(Future<void> Function() action) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 현재 로그인한 사용자와 Notifier를 가져옵니다.
    final currentUser = ref.watch(authProvider);
    final notifier = ref.read(ddipEventsNotifierProvider.notifier);

    // 로그인하지 않은 사용자에게는 아무 버튼도 보여주지 않습니다.
    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    // 현재 사용자와 이벤트의 관계를 파악합니다.
    final bool isRequester = widget.event.requesterId == currentUser.id;
    final bool isSelectedResponder =
        widget.event.selectedResponderId == currentUser.id;

    // 공통 버튼 스타일
    final buttonStyle = FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      minimumSize: const Size(double.infinity, 50),
    );

    // 로딩 중일 때 보여줄 위젯
    if (_isProcessing) {
      return const Center(child: CircularProgressIndicator());
    }

    // 이벤트 상태에 따라 다른 버튼을 렌더링합니다.
    switch (widget.event.status) {
      case DdipEventStatus.open:
        if (!isRequester && !widget.event.applicants.contains(currentUser.id)) {
          return FilledButton.icon(
            icon: const Icon(Icons.pan_tool_outlined),
            label: const Text('지원하기'),
            onPressed:
                () =>
                    _handleAction(() => notifier.applyToEvent(widget.event.id)),
            style: buttonStyle,
          );
        }
        // 요청자거나 이미 지원한 경우, 이 버튼은 보이지 않습니다.
        // (지원자 선택은 EventViewScreen의 다른 위젯에서 처리)
        return const SizedBox.shrink();

      case DdipEventStatus.in_progress:
        if (isSelectedResponder) {
          final hasPendingPhoto = widget.event.photos.any(
            (p) => p.status == FeedbackStatus.pending,
          );

          // 피드백 대기 중인 사진이 있으면 버튼 대신 안내문 표시
          if (hasPendingPhoto) {
            return const Card(
              color: Colors.amberAccent,
              child: ListTile(
                leading: Icon(Icons.hourglass_top_outlined),
                title: Text('요청자의 피드백을 기다리는 중입니다.'),
                subtitle: Text('피드백 이후 다음 사진을 보낼 수 있습니다.'),
              ),
            );
          }

          return FilledButton.icon(
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('사진 찍고 제출하기'),
            onPressed: () async {
              // 카메라 화면으로 이동하여 사진 경로를 받아옵니다.
              final imagePath = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (context) => const CameraScreen()),
              );

              if (imagePath != null) {
                // TODO: 현재 위치 정보 가져오는 로직 추가
                final newPhoto = PhotoFeedback(
                  photoId: const Uuid().v4(),
                  photoUrl: imagePath,
                  latitude: 35.890,
                  // 임시 위도
                  longitude: 128.612,
                  // 임시 경도
                  timestamp: DateTime.now(),
                );
                await _handleAction(
                  () => notifier.addPhoto(widget.event.id, newPhoto),
                );
              }
            },
            style: buttonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all(Colors.green),
            ),
          );
        }
        // 요청자인 경우, 사진 피드백 버튼은 사진 옆에 위치하는 것이 더 적합하므로
        // 이 공용 버튼 위치에서는 아무것도 보여주지 않습니다.
        return const SizedBox.shrink();

      case DdipEventStatus.completed:
        return FilledButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('완료된 요청'),
          onPressed: null, // 비활성화
          style: buttonStyle,
        );

      case DdipEventStatus.failed:
        return FilledButton.icon(
          icon: const Icon(Icons.error_outline),
          label: const Text('실패한 요청'),
          onPressed: null, // 비활성화
          style: buttonStyle.copyWith(
            backgroundColor: MaterialStateProperty.all(Colors.red[700]),
          ),
        );

      // 'pending_selection' 등 다른 상태에서는 이 버튼이 특정 동작을 하지 않으므로 숨깁니다.
      default:
        return const SizedBox.shrink();
    }
  }
}
