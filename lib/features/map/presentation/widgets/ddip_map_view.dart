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
    // onMapReady에서 초기 마커를 로드하므로 initState에서는 비워둡니다.
  }

  Future<void> _updateMarkers() async {
    if (_mapController == null || !mounted) return;
    ref
        .read(mapStateNotifierProvider.notifier)
        .fetchMarkers(mapController: _mapController!, context: context);
  }

  @override
  Widget build(BuildContext context) {
    // [핵심 로직] selectedEventIdProvider의 변경을 감지하여 pivot을 사용한 단일 애니메이션 실행
    ref.listen<String?>(selectedEventIdProvider, (previous, next) {
      if (_mapController == null || next == null || next == previous) return;

      final selectedEvent = widget.events.firstWhereOrNull((e) => e.id == next);
      if (selectedEvent == null) return;

      // --- ✨ [최종 완성] pivot을 사용한 단일 카메라 업데이트 ✨ ---

      // 1. 바텀시트를 제외한 순수 지도 영역의 세로 중앙 지점을 계산합니다.
      //    화면 상단이 0.0, 하단이 1.0일 때,
      //    가시 영역(상위 60%)의 중앙은 Y좌표 0.3에 해당합니다.
      final pivot = NPoint(
        0.5,
        (1.0 - overviewFraction) / 2.0,
      ); // NPoint(0.5, 0.3)

      // 2. scrollAndZoomTo로 목표 좌표와 줌 레벨을 설정하는 NCameraUpdate 객체를 생성합니다.
      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: NLatLng(selectedEvent.latitude, selectedEvent.longitude),
        zoom: 16,
      );

      // 3. 생성된 객체에 setPivot()과 setAnimation()을 연달아 적용(chaining)합니다.
      cameraUpdate
        ..setPivot(pivot)
        ..setAnimation(
          animation: NCameraAnimation.easing,
          duration: const Duration(milliseconds: 800),
        );

      // 4. 모든 설정이 완료된 cameraUpdate 객체로 카메라를 단 한 번만 업데이트합니다.
      _mapController!.updateCamera(cameraUpdate);
    });

    // --- (이하 나머지 코드는 이전과 동일) ---
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

    final strategy = ref.read(feedSheetStrategyProvider.notifier);
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
        ),
        onMapReady: (controller) {
          _mapController = controller;
          _updateMarkers();
        },
        onMapTapped: (point, latLng) {
          strategy.minimize();
          ref.read(selectedEventIdProvider.notifier).state = null;
        },
        onCameraChange: (reason, animated) {
          if (reason == NCameraUpdateReason.gesture) {
            strategy.minimize();
          }
        },
        onCameraIdle: _updateMarkers,
      ),
    );
  }
}
