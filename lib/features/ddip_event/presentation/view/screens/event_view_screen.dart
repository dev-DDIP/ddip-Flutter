import 'dart:io';

import 'package:ddip/features/camera/camera_screen.dart';
import 'package:ddip/features/ddip_event/domain/entities/completion_payload.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../providers/event_view_provider.dart';

class EventViewScreen extends ConsumerStatefulWidget {
  final String eventId;

  const EventViewScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventViewScreen> createState() => _EventViewScreenState();
}

class _EventViewScreenState extends ConsumerState<EventViewScreen> {
  bool _showFullScreenImage = false;

  @override
  Widget build(BuildContext context) {
    final eventState = ref.watch(eventViewProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('요청 정보')),
      body: eventState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('오류가 발생했습니다: $error')),
        data: (event) {
          final requestPosition = NLatLng(event.latitude, event.longitude);

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
                          ),

                          onMapTapped: (point, latLng) {
                            // 응답 마커가 없으면 아무것도 하지 않음
                            if (event.responsePhotoUrl == null ||
                                event.responseLatitude == null ||
                                event.responseLongitude == null) {
                              return;
                            }

                            final responsePosition = NLatLng(
                              event.responseLatitude!,
                              event.responseLongitude!,
                            );

                            // 탭된 위치와 응답 마커 사이의 거리를 미터(m) 단위로 계산
                            final distance = Geolocator.distanceBetween(
                              latLng.latitude,
                              latLng.longitude,
                              responsePosition.latitude,
                              responsePosition.longitude,
                            );

                            // 거리가 25미터보다 가까우면 마커를 탭한 것으로 간주
                            if (distance < 25) {
                              setState(() {
                                _showFullScreenImage = true;
                              });
                            }
                          },

                          onMapReady: (controller) {
                            // onMapReady는 기존처럼 마커를 화면에 표시하는 역할만 합니다.
                            controller.clearOverlays();
                            final requestMarker = NMarker(
                              id: event.id,
                              position: requestPosition,
                            );
                            controller.addOverlay(requestMarker);

                            if (event.responsePhotoUrl != null &&
                                event.responseLatitude != null &&
                                event.responseLongitude != null) {
                              final responsePosition = NLatLng(
                                event.responseLatitude!,
                                event.responseLongitude!,
                              );
                              final responseMarker = NMarker(
                                id: 'response_marker',
                                position: responsePosition,
                              );
                              controller.addOverlay(responseMarker);

                              controller.updateCamera(
                                NCameraUpdate.fitBounds(
                                  NLatLngBounds.from([
                                    requestPosition,
                                    responsePosition,
                                  ]),
                                  padding: const EdgeInsets.all(80),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBottomButton(event),
                  ],
                ),
              ),
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

  // 하단 버튼 UI 코드는 가독성을 위해 별도 메서드로 분리했습니다.
  Widget _buildBottomButton(DdipEvent event) {
    if (event.status == 'open') {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          icon: const Icon(Icons.check),
          label: const Text('참여하기'),
          onPressed: () {
            ref.read(eventViewProvider(widget.eventId).notifier).acceptEvent();
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else if (event.status == 'in_progress') {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text('사진 찍고 완료하기'),
          onPressed: () async {
            // 1. 위치 정보 먼저 획득
            NLatLng? currentLocation;
            try {
              // 위치 권한 및 서비스 확인/요청 로직이 필요합니다.
              final position = await Geolocator.getCurrentPosition();
              currentLocation = NLatLng(position.latitude, position.longitude);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('위치 정보를 가져오는 데 실패했습니다: $e')),
                );
              }
              return; // 위치 정보 없이는 진행 불가
            }

            if (!context.mounted || currentLocation == null) return;

            // 2. 위치 정보를 얻은 후 카메라 화면으로 이동
            final imagePath = await Navigator.push<String>(
              context,
              MaterialPageRoute(builder: (context) => const CameraScreen()),
            );

            // 3. 사진 경로와 위치 정보를 '꾸러미'로 묶어서 전달
            if (imagePath != null && context.mounted) {
              final payload = CompletionPayload(
                imagePath: imagePath,
                location: currentLocation,
              );
              ref
                  .read(eventViewProvider(widget.eventId).notifier)
                  .completeEvent(payload);
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
      );
    } else {
      // 'completed'
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('완료된 요청'),
          onPressed: null,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }
}
