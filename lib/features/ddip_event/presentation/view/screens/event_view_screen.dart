// lib/features/ddip_event/presentation/view/screens/event_view_screen.dart

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/view/widgets/applicant_list_view.dart';
import 'package:ddip/features/ddip_event/presentation/view/widgets/photo_view.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final eventsAsyncValue = ref.watch(ddipEventsNotifierProvider);

    return eventsAsyncValue.when(
      loading:
          () => Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (err, stack) => Scaffold(
            appBar: AppBar(title: const Text('오류')),
            body: Center(child: Text('오류가 발생했습니다: $err')),
          ),
      data: (events) {
        final event = events.firstWhereOrNull((e) => e.id == widget.eventId);

        if (event == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('오류')),
            body: const Center(child: Text('요청 정보를 찾을 수 없습니다.')),
          );
        }

        final currentUser = ref.watch(authProvider);
        final isRequester = currentUser?.id == event.requesterId;
        final isSelectedResponder =
            currentUser?.id == event.selectedResponderId; // ✨ [추가] 수행자 여부 확인
        final isSelectable = event.status == DdipEventStatus.open;
        final isInProgress = event.status == DdipEventStatus.in_progress;

        // [수정] Scaffold가 Stack을 감싸는 구조로 변경
        return Scaffold(
          body: Stack(
            children: [
              // 1. 배경: 지도가 전체 화면을 차지합니다.
              EventMapView(
                event: event,
                onPhotoMarkerTapped: (photoUrl) {
                  setState(() {
                    _fullScreenImageUrl = photoUrl;
                  });
                },
              ),

              // 2. 전경: 드래그 가능한 상세 정보 시트
              DraggableScrollableSheet(
                initialChildSize: 0.35, // 처음에는 35% 높이로 시작
                minChildSize: 0.15, // 최소 15% 높이
                maxChildSize: 0.9, // 최대로 90%까지 확장
                builder: (
                  BuildContext context,
                  ScrollController scrollController,
                ) {
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
                    // 3. 시트 내부 콘텐츠는 ListView로 스크롤 가능하게 만듭니다.
                    child: ListView(
                      controller: scrollController, // 시트와 스크롤 동기화
                      padding: EdgeInsets.zero,
                      children: [
                        // 시트 상단의 핸들바
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
                        // 4. 기존 위젯들을 시트 안으로 이동
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              EventDetailsView(event: event),
                              if (isSelectable && event.applicants.isNotEmpty)
                                ApplicantListView(
                                  event: event,
                                  isRequester: isRequester,
                                ),
                              // ✨ [수정] PhotoView가 보이는 조건을 '요청자' 또는 '선택된 수행자'로 확장
                              if ((isRequester || isSelectedResponder) &&
                                  event.photos.isNotEmpty)
                                PhotoView(
                                  event: event,
                                  isRequester:
                                      isRequester, // ✨ [추가] 현재 사용자가 요청자인지 여부를 전달
                                ),
                              const SizedBox(height: 24),
                              EventActionButton(event: event),
                              const SizedBox(height: 40), // 시트 하단 여백
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // 5. 전체 화면 이미지 뷰 (기존과 동일)
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

              // 6. 지도 위에 떠있는 뒤로가기 버튼 (AppBar 대체)
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
      },
    );
  }
}
