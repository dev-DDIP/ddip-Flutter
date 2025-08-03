// lib/features/ddip_event/presentation/detail/screens/event_detail_screen.dart
import 'package:ddip/features/ddip_event/presentation/detail/widgets/event_bottom_sheet.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/map/presentation/widgets/ddip_map_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsyncValue = ref.watch(eventStreamProvider(eventId));
    final sheetFraction = ref.watch(detailSheetStrategyProvider);
    final bottomPadding = MediaQuery.of(context).size.height * sheetFraction;

    final event = ref.watch(eventDetailProvider(eventId));

    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: eventAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류가 발생했습니다: $err')),
        data: (event) {
          // 데이터가 성공적으로 로드되면 기존 UI를 그립니다.
          return Stack(
            children: [
              DdipMapView(
                eventsToShow: [event],
                photosToShow: event.photos,
                bottomPadding: bottomPadding,
                onMapInteraction:
                    () =>
                        ref
                            .read(detailSheetStrategyProvider.notifier)
                            .minimize(),
              ),
              EventBottomSheet(event: event), // 이제 이 위젯을 대대적으로 수정할 차례입니다.
              // 뒤로가기 버튼 (수정 없음)
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
          );
        },
      ),
    );
  }
}
