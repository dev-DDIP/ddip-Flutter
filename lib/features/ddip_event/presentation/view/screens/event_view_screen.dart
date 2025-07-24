// lib/features/ddip_event/presentation/view/widgets/event_action_button.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/camera/camera_screen.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

class EventActionButton extends ConsumerStatefulWidget {
  final DdipEvent event;

  const EventActionButton({super.key, required this.event});
  @override
  ConsumerState<EventActionButton> createState() => _EventActionButtonState();
}

class _EventActionButtonState extends ConsumerState<EventActionButton> {
  bool _isProcessing = false;

  /// 버튼 클릭 시 비동기 작업을 처리하는 공통 함수
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

  /// 사진 제출 또는 상황 보고를 위한 다이얼로그를 띄우는 함수
  Future<Map<String, dynamic>?> _showSubmissionOptionsDialog() async {
    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('수행 옵션 선택'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('현장 상황을 선택해주세요.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  child: const Text('단순 사진 제출'),
                  onPressed:
                      () => Navigator.pop(context, {
                        'action': ActionType.submitPhoto,
                      }),
                ),
                const Divider(height: 24),
                const Text('또는, 특별한 상황 보고:'),
                ListTile(
                  title: const Text('재료가 소진되어 마감됐어요.'),
                  onTap:
                      () => Navigator.pop(context, {
                        'action': ActionType.reportSituation,
                        'message': MessageCode.soldOut,
                      }),
                ),
                ListTile(
                  title: const Text('대기 줄이 너무 길어요.'),
                  onTap:
                      () => Navigator.pop(context, {
                        'action': ActionType.reportSituation,
                        'message': MessageCode.longQueue,
                      }),
                ),
                ListTile(
                  title: const Text('요청 장소가 현재 닫혀있어요.'),
                  onTap:
                      () => Navigator.pop(context, {
                        'action': ActionType.reportSituation,
                        'message': MessageCode.placeClosed,
                      }),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.pop(context, null),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);
    final notifier = ref.read(ddipEventsNotifierProvider.notifier);

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    final bool isRequester = widget.event.requesterId == currentUser.id;
    final bool isSelectedResponder =
        widget.event.selectedResponderId == currentUser.id;

    final buttonStyle = FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      minimumSize: const Size(double.infinity, 50),
    );

    if (_isProcessing) {
      return const Center(child: CircularProgressIndicator());
    }

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
        return const SizedBox.shrink();

      case DdipEventStatus.in_progress:
        if (isSelectedResponder) {
          final hasPendingPhoto = widget.event.photos.any(
            (p) => p.status == PhotoStatus.pending,
          );
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
              final imagePath = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (context) => const CameraScreen()),
              );
              if (imagePath == null || !mounted) return;

              final submissionResult = await _showSubmissionOptionsDialog();
              if (submissionResult == null || !mounted) return;

              setState(() => _isProcessing = true);

              try {
                final position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high,
                );

                final newPhoto = Photo(
                  id: const Uuid().v4(),
                  url: imagePath,
                  latitude: position.latitude,
                  longitude: position.longitude,
                  timestamp: DateTime.now(),
                );

                // Notifier의 addPhoto 메서드에 선택된 옵션 전달
                await notifier.addPhoto(
                  widget.event.id,
                  newPhoto,
                  action: submissionResult['action'] as ActionType,
                  messageCode: submissionResult['message'] as MessageCode?,
                );
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
            },
            style: buttonStyle.copyWith(
              backgroundColor: MaterialStateProperty.all(Colors.green),
            ),
          );
        }
        return const SizedBox.shrink();

      case DdipEventStatus.completed:
        return FilledButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('완료된 요청'),
          onPressed: null,
          style: buttonStyle,
        );

      case DdipEventStatus.failed:
        return FilledButton.icon(
          icon: const Icon(Icons.error_outline),
          label: const Text('실패한 요청'),
          onPressed: null,
          style: buttonStyle.copyWith(
            backgroundColor: MaterialStateProperty.all(Colors.red[700]),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
