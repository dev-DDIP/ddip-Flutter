// lib/features/ddip_event/presentation/view/screens/event_view_screen.dart

import 'dart:io';

import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/event_action_button.dart';
import '../widgets/event_details_view.dart';
import '../widgets/event_map_view.dart';

// [수정] ConsumerStatefulWidget으로 변경하여, 화면 자체의 상태(이미지 전체화면)와
// Riverpod의 상태를 모두 사용할 수 있도록 합니다.
class EventViewScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventViewScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventViewScreen> createState() => _EventViewScreenState();
}

class _EventViewScreenState extends ConsumerState<EventViewScreen> {
  // 전체화면으로 표시할 사진의 URL을 저장하는 상태 변수
  String? _fullScreenImageUrl;

  @override
  Widget build(BuildContext context) {
    // [수정] 새로운 eventDetailProvider를 사용하여 특정 이벤트의 데이터를 가져옵니다.
    final event = ref.watch(eventDetailProvider(widget.eventId));

    // [수정] 데이터가 로딩 중이거나, 없거나, 오류가 발생했을 경우 로딩 화면을 표시합니다.
    if (event == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('요청 정보 불러오는 중...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('요청 정보')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                EventDetailsView(event: event),
                const SizedBox(height: 16),
                Expanded(
                  child: EventMapView(
                    event: event,
                    // [수정] 지도에서 사진 마커가 탭되면, 해당 사진의 URL을 상태에 저장하여
                    // 전체화면으로 표시하도록 합니다. (EventMapView의 수정이 필요합니다)
                    onPhotoMarkerTapped: (photoUrl) {
                      setState(() {
                        _fullScreenImageUrl = photoUrl;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // [수정] EventActionButton은 이제 event 객체만 받아서
                // 내부에서 필요한 모든 상태(로그인 사용자 등)를 직접 확인하고 로직을 처리합니다.
                EventActionButton(event: event),
              ],
            ),
          ),
          // [수정] 전체화면으로 표시할 이미지 URL이 있을 경우에만 오버레이로 이미지를 보여줍니다.
          if (_fullScreenImageUrl != null)
            GestureDetector(
              onTap: () {
                // 화면을 탭하면 전체화면 이미지를 닫습니다.
                setState(() {
                  _fullScreenImageUrl = null;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.85),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  // File 위젯은 실제 파일 시스템 경로가 필요합니다.
                  // 웹 URL이라면 Image.network()를 사용해야 합니다.
                  child: Image.file(File(_fullScreenImageUrl!)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
