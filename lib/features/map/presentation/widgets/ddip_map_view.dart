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
  String? _pendingCameraAdjustmentForEventId;

  @override
  void initState() {
    super.initState();
    _fetchMyLocationOnce();
  }

  Future<void> _fetchMyLocationOnce() async {
    _updateMarkers();
  }

  Future<void> _updateMarkers() async {
    if (_mapController == null) return;

    ref
        .read(mapStateNotifierProvider.notifier)
        .fetchMarkers(mapController: _mapController!, context: context);
  }

  Future<void> _performFinalCameraAdjustment(String eventId) async {
    if (_mapController == null) return;

    final selectedEvent = widget.events.firstWhereOrNull(
      (e) => e.id == eventId,
    );
    if (selectedEvent == null) return;

    final markerLatLng = NLatLng(
      selectedEvent.latitude,
      selectedEvent.longitude,
    );
    final screenHeight = MediaQuery.of(context).size.height;
    final pixelOffset = (screenHeight * overviewFraction) / 2;

    final markerScreenPoint = await _mapController!.latLngToScreenLocation(
      markerLatLng,
    );

    final newCameraCenterScreenPoint = NPoint(
      markerScreenPoint.x,
      markerScreenPoint.y + pixelOffset,
    );

    final newCameraTargetLatLng = await _mapController!.screenLocationToLatLng(
      newCameraCenterScreenPoint,
    );

    final currentCameraPosition = await _mapController!.getCameraPosition();
    _mapController!.updateCamera(
      NCameraUpdate.scrollAndZoomTo(
        target: newCameraTargetLatLng,
        zoom: currentCameraPosition.zoom, // 현재 줌 레벨 유지
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(selectedEventIdProvider, (previous, next) {
      if (_mapController == null) return;
      if (next != null && next != previous) {
        final selectedEvent = widget.events.firstWhereOrNull(
          (e) => e.id == next,
        );
        if (selectedEvent == null) return;

        _pendingCameraAdjustmentForEventId = next; // 플래그 설정!

        _mapController!.updateCamera(
          NCameraUpdate.scrollAndZoomTo(
            target: NLatLng(selectedEvent.latitude, selectedEvent.longitude),
            zoom: 16,
          ),
        );
      }
    });

    ref.listen<AsyncValue<MapState>>(mapStateNotifierProvider, (_, next) {
      next.when(
        data: (mapState) {
          if (_mapController != null && mounted) {
            _mapController!.clearOverlays();
            _mapController!.addOverlayAll(mapState.markers.values.toSet());

            // ▼▼▼ [핵심 수정] '최초의 역사'를 기록하는 로직을 추가합니다. ▼▼▼
            if (!_initialCameraFitted && mapState.markers.isNotEmpty) {
              final positions =
                  mapState.markers.values.map((m) => m.position).toList();
              final initialBounds = NLatLngBounds.from(positions);

              // 1. Notifier에 최초의 역사를 기록해달라고 요청합니다.
              ref
                  .read(mapStateNotifierProvider.notifier)
                  .initializeHistory(initialBounds);

              // 2. 카메라를 최초의 전체 뷰로 이동시킵니다.
              _mapController!.updateCamera(
                NCameraUpdate.fitBounds(
                  initialBounds,
                  padding: const EdgeInsets.all(80),
                ),
              );
              _initialCameraFitted = true;
            }
            // ▲▲▲ [핵심 수정] '최초의 역사'를 기록하는 로직을 추가합니다. ▲▲▲
            else if (mapState.bounds != null) {
              // 이후의 모든 카메라 이동은 '명령'이 있을 때만 수행됩니다.
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
      // 현재 탐색 경로가 최상위('root')일 때만 앱이 닫히도록 허용합니다.
      canPop: (mapState.valueOrNull?.drillDownPath.length ?? 0) <= 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _pendingCameraAdjustmentForEventId = null;
          mapNotifier.drillUp();
        }
      },
      child: NaverMap(
        // ▲▲▲ [추가] 스마트폰의 뒤로가기 버튼을 감지하는 위젯입니다. ▲▲▲
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target:
                widget.events.isNotEmpty
                    ? NLatLng(
                      widget.events.first.latitude,
                      widget.events.first.longitude,
                    )
                    : const NLatLng(35.890, 128.612), // 경북대학교 기본 위치
            zoom: 15,
          ),
          locationButtonEnable: true,
        ),
        onMapReady: (controller) {
          _mapController = controller;
          _updateMarkers();
        },
        onMapTapped: (point, latLng) {
          // Strategy에게 바텀시트를 최소화하라고 명령합니다.
          strategy.minimize();
          // [추가] 지도 탭 시 선택된 마커를 해제합니다.
          ref.read(selectedEventIdProvider.notifier).state = null;
        },
        onCameraChange: (NCameraUpdateReason reason, bool animated) {
          if (reason == NCameraUpdateReason.gesture) {
            _pendingCameraAdjustmentForEventId = null; // 사용자가 직접 움직이면 보정 작업 취소
            strategy.minimize();
          }
        },
        onCameraIdle: () {
          if (_pendingCameraAdjustmentForEventId != null) {
            final eventId = _pendingCameraAdjustmentForEventId!;
            _pendingCameraAdjustmentForEventId = null; // 플래그 초기화
            _performFinalCameraAdjustment(eventId);
          } else {
            // 일반적인 상황에서는 마커 목록만 업데이트합니다.
            _updateMarkers();
          }
        },
      ),
    );
  }
}
