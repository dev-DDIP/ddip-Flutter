import 'dart:io';

import 'package:ddip/features/camera/camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart'; // 네이버 지도 패키지 import
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/event_view_provider.dart'; // 방금 만든 프로바이더 import

class EventViewScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventViewScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventViewScreen> createState() => _EventViewScreenState();
}

class _EventViewScreenState extends ConsumerState<EventViewScreen> {
  // 2. 전체 화면 이미지 표시 여부를 기억할 상태 변수 추가
  bool _showFullScreenImage = false;

  @override
  Widget build(BuildContext context) {
    // ConsumerStatefulWidget에서는 widget.eventId로 접근해야 합니다.
    final eventState = ref.watch(eventViewProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('요청 정보')),
      body: eventState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('오류가 발생했습니다: $error')),
        data: (event) {
          final requestPosition = NLatLng(event.latitude, event.longitude);
          final responsePosition =
              event.responsePhotoUrl != null
                  ? NLatLng(
                    event.latitude,
                    event.longitude,
                  ) // TODO: 실제 응답 위치 위도/경도로 수정
                  : null;

          // [수정] Stack 위젯으로 UI 전체를 감싸 오버레이를 띄울 수 있게 합니다.
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on_outlined,
                          size: 18,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '보상: ${event.reward}원',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.person_outline,
                          size: 18,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '작성자: ${event.requesterId}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    Text(
                      event.content,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: NaverMap(
                          options: NaverMapViewOptions(
                            initialCameraPosition: NCameraPosition(
                              target: requestPosition,
                              zoom: 16,
                            ),
                            scrollGesturesEnable: true,
                          ),
                          onMapReady: (controller) {
                            final requestMarker = NMarker(
                              id: event.id,
                              position: requestPosition,
                            );
                            controller.addOverlay(requestMarker);

                            if (responsePosition != null) {
                              final responseMarker = NMarker(
                                id: 'response_marker',
                                position: responsePosition,
                              );
                              // 생성된 마커 객체에 setOnTap 메서드로 탭 이벤트를 설정합니다.
                              responseMarker.setOnTap((overlay) {
                                setState(() {
                                  _showFullScreenImage = true;
                                });
                              });

                              final cameraUpdate = NCameraUpdate.fitBounds(
                                NLatLngBounds(
                                  southWest: requestPosition,
                                  northEast: responsePosition,
                                ),
                                padding: const EdgeInsets.all(80),
                              );
                              controller.updateCamera(cameraUpdate);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (event.status == 'open')
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('참여하기'),
                          onPressed: () {
                            ref
                                .read(
                                  eventViewProvider(widget.eventId).notifier,
                                )
                                .acceptEvent();
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else if (event.status == 'in_progress')
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text('사진 찍고 완료하기'),
                          onPressed: () async {
                            final imagePath = await Navigator.push<String>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CameraScreen(),
                              ),
                            );
                            if (imagePath != null && context.mounted) {
                              ref
                                  .read(
                                    eventViewProvider(widget.eventId).notifier,
                                  )
                                  .completeEvent(imagePath);
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    else // 'completed' 또는 다른 상태일 경우
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('완료된 요청'),
                          onPressed: null, // 버튼 비활성화
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 전체 화면 이미지 표시를 위한 오버레이 위젯
              if (_showFullScreenImage && event.responsePhotoUrl != null)
                GestureDetector(
                  onTap: () => setState(() => _showFullScreenImage = false),
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    alignment: Alignment.center,
                    child: Image.file(File(event.responsePhotoUrl!)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
