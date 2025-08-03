// lib/features/ddip_event/presentation/detail/screens/event_detail_screen.dart
import 'package:ddip/features/ddip_event/presentation/detail/widgets/event_bottom_sheet.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/map/presentation/widgets/ddip_map_view.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
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

    return eventAsyncValue.when(
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
      data: (event) {
        // ProviderScope는 이 위젯 트리 안에서만 특정 Provider의 값을 재정의하는
        // 특별한 공간을 만들어줍니다.
        return ProviderScope(
          overrides: [
            // mapEventsProvider의 기본값(전체 목록) 대신,
            // 이 화면의 이벤트 하나만 담긴 목록을 반환하도록 재정의합니다.
            mapEventsProvider.overrideWithValue([event]),
          ],
          child: Scaffold(
            body: Stack(
              children: [
                // 이제 DdipMapView는 부모에게 데이터를 받지 않습니다.
                // ProviderScope 덕분에 DdipMapView 내부의 MapViewModel이
                // 재정의된 mapEventsProvider를 읽어 오직 하나의 마커만 그리게 됩니다.
                DdipMapView(
                  bottomPadding: bottomPadding,
                  onMapInteraction:
                      () =>
                          ref
                              .read(detailSheetStrategyProvider.notifier)
                              .minimize(),
                ),
                EventBottomSheet(event: event),
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
          ),
        );
      },
    );
  }
}
