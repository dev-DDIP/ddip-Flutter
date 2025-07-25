// lib/features/map/presentation/widgets/ddip_map_view.dart
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DdipMapView extends ConsumerStatefulWidget {
  final List<DdipEvent> events;

  const DdipMapView({super.key, required this.events});

  @override
  ConsumerState<DdipMapView> createState() => _DdipMapViewState();
}

class _DdipMapViewState extends ConsumerState<DdipMapView> {
  NaverMapController? _mapController;

  @override
  void initState() {
    super.initState();
    // 위젯이 빌드된 후 context를 Notifier에 전달
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(mapMarkerNotifierProvider.notifier).setContext(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // [수정] Notifier의 상태 변화를 감지하고 지도에 반영
    ref.listen<AsyncValue<MapState>>(mapMarkerNotifierProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (mapState) {
          if (_mapController != null && mounted) {
            // 전체를 지우고 다시 그리는 방식으로 단순화하여 상태 불일치 방지
            _mapController!.clearOverlays();
            _mapController!.addOverlayAll(mapState.markers.values.toSet());
            _mapController!.addOverlayAll(mapState.polylines.values.toSet());
            // bounds 정보가 있을 때만 카메라 이동
            if (mapState.bounds != null) {
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

    return NaverMap(
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
      ),
      onMapReady: (controller) {
        _mapController = controller;
        // [수정] 지도가 준비되면 Notifier의 초기화 함수를 호출
        ref
            .read(mapMarkerNotifierProvider.notifier)
            .initialize(
              events: widget.events,
              onPhotoMarkerTap: (eventId, photoId) {
                context.push('/feed/$eventId/photo/$photoId');
              },
            );
      },
      onCameraIdle: () async {
        if (_mapController != null) {
          final position = await _mapController!.getCameraPosition();
          // Notifier에 현재 줌 레벨을 전달하여 오버레이 업데이트를 요청합니다.
          ref
              .read(mapMarkerNotifierProvider.notifier)
              .updateOverlaysForZoom(position.zoom);
        }
      },
      // onCameraIdle은 클러스터링 등 추가 기능 구현 시 활용 가능
    );
  }
}
