// lib/features/ddip_event/presentation/view/widgets/event_action_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:ddip/features/camera/camera_screen.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/completion_payload.dart';
import 'package:ddip/features/ddip_event/presentation/view/providers/event_view_provider.dart';

class EventActionButton extends ConsumerStatefulWidget {
  final DdipEvent event;

  const EventActionButton({super.key, required this.event});

  @override
  ConsumerState<EventActionButton> createState() => _EventActionButtonState();
}

class _EventActionButtonState extends ConsumerState<EventActionButton> {
  bool _isProcessing = false;

  void _acceptEvent() async {
    setState(() => _isProcessing = true);
    try {
      await ref.read(eventViewProvider(widget.event.id).notifier).acceptEvent();
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _completeEvent() async {
    setState(() => _isProcessing = true);
    try {
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
        return;
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

    if (widget.event.status == 'open') {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          icon: const Icon(Icons.check),
          label:
              _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('참여하기'),
          onPressed: _isProcessing ? null : _acceptEvent,
          style: buttonStyle,
        ),
      );
    }

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

    // 'completed' or other statuses
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
