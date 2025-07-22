// lib/features/ddip_event/presentation/view/screens/event_view_screen.dart

import 'dart:io';

import 'package:collection/collection.dart'; // ◀◀◀ 1. 컬렉션 유틸리티 import
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/view/widgets/applicant_list_view.dart';
import 'package:ddip/features/ddip_event/presentation/view/widgets/photo_feedback_view.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/event_action_button.dart';
import '../widgets/event_details_view.dart';
import '../widgets/event_map_view.dart';

class EventViewScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventViewScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventViewScreen> createState() => _EventViewScreenState();
}

class _EventViewScreenState extends ConsumerState<EventViewScreen> {
  String? _fullScreenImageUrl;

  @override
  Widget build(BuildContext context) {
    // ▼▼▼ 2. 데이터 가져오는 방식을 '전체 목록'을 감시하는 것으로 변경 ▼▼▼
    // 이렇게 하면 '지원하기', '선택하기' 등 상태 변경 시 화면이 자동으로 새로고침됩니다.
    final eventsAsyncValue = ref.watch(ddipEventsNotifierProvider);

    // AsyncValue.when을 사용하여 로딩, 데이터, 에러 상태를 안전하게 처리
    return eventsAsyncValue.when(
      loading:
          () => Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (err, stack) => Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('오류가 발생했습니다: $err')),
          ),
      data: (events) {
        // ▼▼▼ 3. 전체 목록에서 현재 화면에 필요한 '띱' 하나를 찾습니다. ▼▼▼
        final event = events.firstWhereOrNull((e) => e.id == widget.eventId);

        // 데이터가 있지만 일치하는 이벤트를 찾지 못한 경우
        if (event == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('요청 정보를 찾을 수 없습니다.')),
          );
        }

        // ▼▼▼ 4. 사용자 관계 파악 로직 (이제 event가 null이 아님이 보장됨) ▼▼▼
        final currentUser = ref.watch(authProvider);
        final isRequester = currentUser?.id == event.requesterId;
        final isSelectable = event.status == DdipEventStatus.open;
        final isInProgress = event.status == DdipEventStatus.in_progress;

        return Scaffold(
          appBar: AppBar(title: const Text('요청 정보')),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ▼▼▼ 5. 이제 event는 DdipEvent 타입임이 보장되어 에러가 발생하지 않습니다. ▼▼▼
                      EventDetailsView(event: event),
                      const SizedBox(height: 16),

                      if (isSelectable && event.applicants.isNotEmpty)
                        ApplicantListView(
                          event: event,
                          isRequester: isRequester, // isRequester 값을 전달
                        ),

                      if (isRequester &&
                          isInProgress &&
                          event.photos.isNotEmpty)
                        PhotoFeedbackView(event: event),

                      SizedBox(
                        height: 300,
                        child: EventMapView(
                          event: event,
                          onPhotoMarkerTapped: (photoUrl) {
                            setState(() {
                              _fullScreenImageUrl = photoUrl;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      EventActionButton(event: event),
                    ],
                  ),
                ),
              ),
              if (_fullScreenImageUrl != null)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _fullScreenImageUrl = null;
                    });
                  },
                  child: Container(
                    color: Colors.black.withOpacity(0.85),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.file(File(_fullScreenImageUrl!)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
