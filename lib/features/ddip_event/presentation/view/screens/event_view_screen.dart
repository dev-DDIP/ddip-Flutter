import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart'; // 네이버 지도 패키지 import
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/event_view_provider.dart'; // 방금 만든 프로바이더 import

class EventViewScreen extends ConsumerWidget {
  final String eventId;

  const EventViewScreen({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // eventId에 해당하는 상세 데이터의 상태(state)를 감시(watch)합니다.
    final eventState = ref.watch(eventViewProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('요청 정보'),
      ),
      // AsyncValue의 when을 사용하면 로딩/에러/성공 상태를 깔끔하게 처리할 수 있습니다.
      body: eventState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('오류가 발생했습니다: $error'),
        ),
        data: (event) {
          // DdipEvent에서 위치 정보를 가져와 NLatLng 객체 생성
          final position = NLatLng(event.latitude, event.longitude);


          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(event.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),

                // 보상 및 작성자 정보
                Row(
                  children: [
                    const Icon(Icons.monetization_on_outlined, size: 18, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text('보상: ${event.reward}원', style: const TextStyle(fontSize: 16)),
                    const Spacer(),
                    const Icon(Icons.person_outline, size: 18, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text('작성자: ${event.requesterId}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
                const Divider(height: 32),

                // 내용
                Text(
                  event.content,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 24),

                // 좌표 정보
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: NaverMap(
                      options: NaverMapViewOptions(
                        initialCameraPosition: NCameraPosition(
                          target: position,
                          zoom: 16,
                        ),
                        // 3. 지도가 독립적으로 표시되므로 스크롤 제스처를 다시 활성화합니다.
                        scrollGesturesEnable: true,
                      ),
                      onMapReady: (controller) {
                        final marker = NMarker(
                          id: event.id,
                          position: position,
                        );
                        controller.addOverlay(marker);
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
                        // onPressed와 같이 사용자가 직접 액션을 취하는 곳에서는 'ref.read'를 사용합니다.
                        // 'ref.watch'는 build 메서드 안에서 값의 변화를 계속 감시할 때 사용합니다.
                        ref.read(eventViewProvider(eventId).notifier).acceptEvent();
                      },
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                else if (event.status == 'in_progress')
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('사진 찍고 완료하기'),
                      onPressed: () {
                        // TODO: 다음 단계에서 '요청 완료' 기능을 여기에 연결합니다.
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green, // 진행 중 상태는 다른 색으로 표시
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }
      )
    );
  }
}