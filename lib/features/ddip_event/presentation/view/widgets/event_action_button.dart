// lib/features/ddip_event/presentation/view/widgets/event_action_button.dart

import 'package:ddip/core/permissions/permission_provider.dart';
import 'package:ddip/features/camera/camera_screen.dart';
import 'package:ddip/features/ddip_event/domain/entities/completion_payload.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/view/providers/event_view_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

// ConsumerStatefulWidget은 위젯 스스로 상태를 가질 수 있게 해줍니다.
class EventActionButton extends ConsumerStatefulWidget {
  final DdipEvent event;

  const EventActionButton({super.key, required this.event});

  @override
  ConsumerState<EventActionButton> createState() => _EventActionButtonState();
}

class _EventActionButtonState extends ConsumerState<EventActionButton> {
  // 1. '지금 처리 중인가?'를 기억하는 변수를 만듭니다. (초기값은 false)
  // 이 변수가 버튼의 활성화/비활성화를 제어하는 스위치 역할을 합니다.
  bool _isProcessing = false;

  // '참여하기' 버튼을 눌렀을 때 실행될 함수
  void _acceptEvent() async {
    // 2. 함수가 시작되자마자 '처리 중' 상태로 바꾸고 화면을 새로고침합니다.
    //    이 코드가 실행되는 즉시 버튼은 비활성화되고 로딩 아이콘으로 바뀝니다.
    setState(() => _isProcessing = true);

    try {
      // 3. 실제 비동기 작업(상태 업데이트 요청)을 실행합니다.
      await ref.read(eventViewProvider(widget.event.id).notifier).acceptEvent();
    } finally {
      // 4. 작업이 성공하든, 실패해서 오류가 나든, '무조건' 실행되는 부분입니다.
      //    작업이 끝났으니 '처리 중 아님' 상태로 되돌려 버튼을 다시 활성화합니다.
      //    (mounted 체크는 위젯이 화면에서 사라진 후에 setState가 호출되는 에러를 방지합니다.)
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // '사진 찍고 완료하기' 버튼을 눌렀을 때 실행될 함수
  void _completeEvent() async {
    // 실제 작업을 시작하기 전에, 먼저 중앙 관제탑에게 현재 권한 상태를 물어봅니다.
    final permission = ref.read(permissionProvider);

    // 만약 권한이 거부된(denied) 상태라면,
    if (permission == LocationPermission.denied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진 촬영 위치 기록을 위해 권한이 필요합니다.')),
        );
      }
      // 사용자에게 다시 권한을 요청합니다.
      await ref.read(permissionProvider.notifier).requestPermission();
      return; // 일단 현재 작업은 중단합니다. 사용자가 권한을 허용하면 다시 버튼을 누를 것입니다.
    }

    // 만약 권한이 영구적으로 거부된(deniedForever) 상태라면,
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 권한이 영구 거부되었습니다. 앱 설정에서 허용해주세요.')),
        );
      }
      return; // 더 이상 진행할 수 없으므로 작업을 중단합니다.
    }

    setState(() => _isProcessing = true);
    try {
      // 기존 사진 촬영 및 완료 로직은 그대로 여기에 둡니다.
      NLatLng? currentLocation;
      try {
        final position = await Geolocator.getCurrentPosition();
        currentLocation = NLatLng(position.latitude, position.longitude);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('위치 정보를 가져오는 데 실패했습니다: $e')));
        }
        return; // 위치 정보 없이는 진행 불가
      }

      if (!mounted || currentLocation == null) return;

      final imagePath = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => const CameraScreen()),
      );

      if (imagePath != null && mounted) {
        final payload = CompletionPayload(
          imagePath: imagePath,
          location: currentLocation,
        );
        await ref
            .read(eventViewProvider(widget.event.id).notifier)
            .completeEvent(payload);
      }
    } finally {
      // 작업이 모두 끝나면 다시 '처리 중 아님' 상태로 복원합니다.
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );

    // 이벤트 상태가 'open'일 때의 버튼 UI
    if (widget.event.status == 'open') {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          icon: const Icon(Icons.check),
          // 5. _isProcessing 값에 따라 버튼에 보여줄 내용을 결정합니다.
          //    true이면 로딩 아이콘, false이면 '참여하기' 텍스트를 보여줍니다.
          label:
              _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('참여하기'),
          // 6. _isProcessing이 true이면 onPressed에 null을 전달하여 버튼을 비활성화하고,
          //    false이면 _acceptEvent 함수를 연결하여 버튼을 활성화합니다.
          onPressed: _isProcessing ? null : _acceptEvent,
          style: buttonStyle,
        ),
      );
    }

    // 이벤트 상태가 'in_progress'일 때의 버튼 UI (위와 동일한 로직 적용)
    if (widget.event.status == 'in_progress') {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          icon: const Icon(Icons.camera_alt_outlined),
          label:
              _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('사진 찍고 완료하기'),
          onPressed: _isProcessing ? null : _completeEvent,
          style: buttonStyle.copyWith(
            backgroundColor: MaterialStateProperty.all(Colors.green),
          ),
        ),
      );
    }

    // 'completed' 상태일 때는 항상 비활성화된 버튼을 보여줍니다.
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('완료된 요청'),
        onPressed: null,
        style: buttonStyle.copyWith(
          backgroundColor: MaterialStateProperty.all(Colors.grey),
        ),
      ),
    );
  }
}
