import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class DdipMapView extends ConsumerStatefulWidget {
  final List<DdipEvent> events;

  const DdipMapView({super.key, required this.events});

  @override
  ConsumerState<DdipMapView> createState() => _DdipMapViewState();
}

class _DdipMapViewState extends ConsumerState<DdipMapView> {
  NaverMapController? _mapController;
  bool _initialCameraFitted = false;
  Position? _myLocation;

  @override
  void initState() {
    super.initState();
    _fetchMyLocationOnce();
  }

  Future<void> _fetchMyLocationOnce() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _myLocation = position;
        });
        _updateMarkers();
      }
    } catch (e) {
      print("최초 사용자 위치 로딩 실패: $e");
    }
  }

  Future<void> _updateMarkers() async {
    if (_mapController == null) return;

    ref
        .read(mapStateNotifierProvider.notifier)
        .fetchMarkers(mapController: _mapController!, context: context);
  }

  @override
  Widget build(BuildContext context) {
    // 마커 데이터가 갱신되면 지도 위에 다시 그립니다.
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
      onPopInvoked: (didPop) {
        if (!didPop) {
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
          // 사용자의 제스처(드래그, 줌 등)로 인해 카메라가 움직였을 때만
          if (reason == NCameraUpdateReason.gesture) {
            strategy.minimize();
          }
        },
        onCameraIdle: () {
          _updateMarkers();
        },
      ),
    );
  }
}
