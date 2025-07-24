// lib/features/ddip_event/presentation/view/screens/event_view_screen.dart

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/view/widgets/applicant_list_view.dart';
import 'package:ddip/features/ddip_event/presentation/view/widgets/event_action_button.dart';
import 'package:ddip/features/ddip_event/presentation/view/widgets/event_details_view.dart';
import 'package:ddip/features/ddip_event/presentation/view/widgets/event_map_view.dart';
import 'package:ddip/features/ddip_event/presentation/view/widgets/photo_view.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventViewScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventViewScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventViewScreen> createState() => _EventViewScreenState();
}

class _EventViewScreenState extends ConsumerState<EventViewScreen> {
  // 사진을 전체 화면으로 보기 위한 상태 변수
  String? _fullScreenImageUrl;

  @override
  Widget build(BuildContext context) {
    // 상세 화면에 필요한 특정 이벤트 하나만 가져오는 provider를 watch
    final event = ref.watch(eventDetailProvider(widget.eventId));

    // event가 로딩 중이거나 아직 없는 경우
    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 현재 로그인한 사용자와의 관계 파악
    final currentUser = ref.watch(authProvider);
    final isRequester = currentUser?.id == event.requesterId;
    final isSelectable = event.status == DdipEventStatus.open;
    final isInProgress = event.status == DdipEventStatus.in_progress;

    return Scaffold(
      body: Stack(
        children: [
          // 배경에 지도를 표시하는 위젯
          EventMapView(
            event: event,
            onPhotoMarkerTapped: (photoUrl) {
              setState(() {
                _fullScreenImageUrl = photoUrl;
              });
            },
          ),
          // 아래에서 위로 드래그하여 상세 정보를 볼 수 있는 시트
          DraggableScrollableSheet(
            initialChildSize: 0.35, // 처음 보일 때의 높이
            minChildSize: 0.15, // 최소 높이
            maxChildSize: 0.9, // 최대 높이
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    // 시트 상단의 드래그 핸들
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 이벤트 제목, 내용, 작성자 등 기본 정보 표시
                          EventDetailsView(event: event),

                          // [조건부 렌더링] 지원자가 있고, 선택 가능한 상태일 때만 지원자 목록 표시
                          if (isSelectable && event.applicants.isNotEmpty)
                            ApplicantListView(
                              event: event,
                              isRequester: isRequester,
                            ),

                          // [조건부 렌더링] 요청자이고, 진행중이며, 제출된 사진이 있을 때만 사진 뷰 표시
                          if (isRequester &&
                              isInProgress &&
                              event.photos.isNotEmpty)
                            PhotoView(event: event),

                          const SizedBox(height: 24),
                          // 이벤트 상태에 따라 다른 버튼을 보여주는 위젯
                          EventActionButton(event: event),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          // 전체 화면 사진 뷰
          if (_fullScreenImageUrl != null)
            GestureDetector(
              onTap: () => setState(() => _fullScreenImageUrl = null),
              child: Container(
                color: Colors.black.withOpacity(0.85),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.file(File(_fullScreenImageUrl!)),
                ),
              ),
            ),
          // 뒤로가기 버튼
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
