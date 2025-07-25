// [리팩토링] EventViewScreen에서 EventDetailScreen으로 변경
import 'package:ddip/features/ddip_event/presentation/detail/widgets/event_bottom_sheet.dart';
import 'package:ddip/features/map/presentation/widgets/ddip_map_view.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // [리팩토링] 상세 화면에 필요한 데이터만 watch
    final event = ref.watch(eventDetailProvider(eventId));

    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      // [리팩토링] body가 Stack으로 변경되어 지도와 BottomSheet를 겹침
      body: Stack(
        children: [
          // [리팩토링] 신규 DdipMapView 위젯 사용. 이제 지도 로직은 모두 저 위젯이 담당.
          DdipMapView(events: [event]),

          // [리팩토링] DraggableScrollableSheet 로직을 별도 위젯으로 분리
          EventBottomSheet(event: event),

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
