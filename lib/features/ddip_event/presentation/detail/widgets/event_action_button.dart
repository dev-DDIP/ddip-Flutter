import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/camera/camera_screen.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/presentation/detail/viewmodels/event_detail_view_model.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';

/// 상세 화면의 하단에 위치하여, 현재 이벤트와 사용자 상태에 맞는 핵심 행동을 수행하는 버튼 위젯입니다.
/// 이 위젯은 UI 흐름(화면 이동, 다이얼로그 표시)을 제어하고,
/// 그 결과물을 ViewModel에 전달하여 실제 비즈니스 로직 처리를 위임하는 역할만 합니다.
class EventActionButton extends ConsumerWidget {
  final DdipEvent event;
  const EventActionButton({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. ViewModel의 상태를 구독하여 UI를 그리는 데 필요한 모든 정보를 받습니다.
    final viewModelState = ref.watch(eventDetailViewModelProvider(event.id));
    // 2. ViewModel의 메서드를 호출하기 위해 notifier를 읽습니다.
    final viewModel = ref.read(eventDetailViewModelProvider(event.id).notifier);

    // 3. ViewModel이 로딩 중이라고 알려주면, 로딩 인디케이터를 표시합니다.
    if (viewModelState.isProcessing) {
      return const Center(child: CircularProgressIndicator());
    }

    // 4. ViewModel이 버튼을 표시할 필요가 없다고 알려주면, 아무것도 그리지 않습니다.
    if (viewModelState.buttonText == null) {
      return const SizedBox.shrink();
    }

    // 5. ViewModel이 제공하는 상태값에 따라 버튼의 모양과 행동을 결정합니다.
    return FilledButton.icon(
      icon: _getButtonIcon(event.status),
      label: Text(viewModelState.buttonText!),
      onPressed:
          viewModelState.buttonIsEnabled
              ? () async {
                // 6. 버튼 클릭 시, 어떤 액션을 할지 결정하고 UI 흐름을 시작합니다.
                if (event.status == DdipEventStatus.open) {
                  // '지원하기' 로직은 ViewModel에 완전히 위임합니다.
                  await viewModel.applyToEvent();
                } else if (event.status == DdipEventStatus.in_progress) {
                  // '사진 제출'은 View가 UI 흐름을 담당합니다.
                  // 6-1. 카메라 화면을 띄우고 결과(imagePath)를 받습니다.
                  final imagePath = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraScreen(),
                    ),
                  );
                  if (imagePath == null || !context.mounted) return;

                  // 6-2. 제출 옵션 다이얼로그를 띄우고 결과(submissionResult)를 받습니다.
                  final submissionResult = await _showSubmissionOptionsDialog(
                    context,
                  );
                  if (submissionResult == null) return;

                  // 6-3. 수집된 결과물들을 ViewModel에 전달하여 나머지 로직 처리를 위임합니다.
                  await viewModel.submitPhoto(
                    imagePath: imagePath,
                    submissionResult: submissionResult,
                  );
                }
              }
              : null,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: viewModelState.buttonColor, // 버튼 색상도 ViewModel이 제어
      ),
    );
  }

  /// 이벤트 상태에 따라 적절한 아이콘을 반환하는 헬퍼 함수
  Icon _getButtonIcon(DdipEventStatus status) {
    switch (status) {
      case DdipEventStatus.open:
        return const Icon(Icons.pan_tool_outlined);
      case DdipEventStatus.in_progress:
        return const Icon(Icons.camera_alt_outlined);
      case DdipEventStatus.completed:
        return const Icon(Icons.check_circle_outline);
      case DdipEventStatus.failed:
        return const Icon(Icons.error_outline);
    }
  }

  /// 사진 제출 옵션 다이얼로그를 표시하는 헬퍼 함수
  /// BuildContext가 필요하므로 위젯 내에 위치합니다.
  Future<Map<String, dynamic>?> _showSubmissionOptionsDialog(
    BuildContext context,
  ) async {
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
}
