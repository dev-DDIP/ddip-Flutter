// lib/features/map/presentation/widgets/ddip_map_view.dart

import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/ddip_event/presentation/strategy/bottom_sheet_strategy.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DdipMapView extends ConsumerStatefulWidget {
  final List<DdipEvent> events;

  const DdipMapView({super.key, required this.events});

  @override
  ConsumerState<DdipMapView> createState() => _DdipMapViewState();
}

class _DdipMapViewState extends ConsumerState<DdipMapView> {
  NaverMapController? _mapController;
  bool _initialCameraFitted = false;

  @override
  void initState() {
    super.initState();
    // onMapReady에서 초기 마커를 로드하므로 initState는 비워둡니다.
  }

  void _updateMarkers() {
    if (_mapController != null && mounted) {
      ref
          .read(mapStateNotifierProvider.notifier)
          .fetchMarkers(mapController: _mapController!, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✨ [수정] 이벤트 선택 시, 단순하게 해당 위치로 카메라를 이동시킵니다.
    // contentPadding이 모든 오프셋 계산을 자동으로 처리해줍니다.
    ref.listen<String?>(selectedEventIdProvider, (previous, next) {
      if (_mapController == null || next == null || next == previous) return;

      final selectedEvent = widget.events.firstWhereOrNull((e) => e.id == next);
      if (selectedEvent == null) return;

      final markerLatLng = NLatLng(
        selectedEvent.latitude,
        selectedEvent.longitude,
      );

      // ✨ 매우 단순해진 단일 카메라 업데이트
      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: markerLatLng,
        zoom: 16,
      );
      cameraUpdate.setAnimation(
        animation: NCameraAnimation.easing,
        duration: const Duration(milliseconds: 500),
      );
      _mapController!.updateCamera(cameraUpdate);
    });

    // 지도 상태(마커, 클러스터 등) 변경 리스너는 대부분 유지됩니다.
    ref.listen<AsyncValue<MapState>>(mapStateNotifierProvider, (_, next) {
      next.when(
        data: (mapState) {
          if (_mapController != null && mounted) {
            _mapController!.clearOverlays();
            _mapController!.addOverlayAll(mapState.markers.values.toSet());

            if (!_initialCameraFitted && mapState.markers.isNotEmpty) {
              final positions =
                  mapState.markers.values.map((m) => m.position).toList();
              final initialBounds = NLatLngBounds.from(positions);

              ref
                  .read(mapStateNotifierProvider.notifier)
                  .initializeHistory(initialBounds);

              _mapController!.updateCamera(
                NCameraUpdate.fitBounds(
                  initialBounds,
                  padding: const EdgeInsets.all(80),
                ),
              );
              _initialCameraFitted = true;
            } else if (mapState.bounds != null) {
              _mapController!.updateCamera(
                NCameraUpdate.fitBounds(
                  mapState.bounds!,
                  padding: const EdgeInsets.all(80),
                ),
              );
            }
          }
        },
        loading: () {},
        error: (e, s) => print("Marker Loading Error: $e"),
      );
    });

    // ✨ [핵심] 바텀시트의 높이를 감시하여 contentPadding을 동적으로 업데이트합니다.
    final bottomSheetHeight = ref.watch(bottomSheetHeightProvider);
    final mapNotifier = ref.read(mapStateNotifierProvider.notifier);
    final mapState = ref.watch(mapStateNotifierProvider);

    return PopScope(
      canPop: (mapState.valueOrNull?.drillDownPath.length ?? 0) <= 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          mapNotifier.drillUp();
        }
      },
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target:
                widget.events.isNotEmpty
                    ? NLatLng(
                      widget.events.first.latitude,
                      widget.events.first.longitude,
                    )
                    : const NLatLng(35.890, 128.612),
            zoom: 15,
          ),
          locationButtonEnable: true,
          // ✨ [핵심] 동적으로 계산된 바텀시트 높이를 contentPadding으로 설정
          contentPadding: EdgeInsets.only(bottom: bottomSheetHeight),
        ),
        onMapReady: (controller) {
          _mapController = controller;
          _updateMarkers();
        },
        onMapTapped: (point, latLng) {
          ref.read(feedSheetStrategyProvider.notifier).minimize();
          ref.read(selectedEventIdProvider.notifier).state = null;
        },
        onCameraChange: (reason, animated) {
          if (reason == NCameraUpdateReason.gesture) {
            ref.read(feedSheetStrategyProvider.notifier).minimize();
          }
        },
        onCameraIdle: _updateMarkers,
      ),
    );
  }
}
