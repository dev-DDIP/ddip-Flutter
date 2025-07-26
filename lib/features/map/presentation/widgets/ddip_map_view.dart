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
  bool _initialCameraFitted = false; // 초기 카메라 조정 여부 플래그

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<MapState>>(mapMarkerNotifierProvider, (_, next) {
      next.when(
        data: (mapState) {
          if (_mapController != null && mounted) {
            _mapController!.clearOverlays();
            _mapController!.addOverlayAll(mapState.markers.values.toSet());
            _mapController!.addOverlayAll(mapState.polylines.values.toSet());

            // [수정] 카메라 제어 로직이 View로 이동
            if (!_initialCameraFitted && mapState.markers.length >= 2) {
              final positions =
                  mapState.markers.values.map((m) => m.position).toList();
              final bounds = NLatLngBounds.from(positions);
              _mapController!.updateCamera(
                NCameraUpdate.fitBounds(
                  bounds,
                  padding: const EdgeInsets.all(80),
                ),
              );
              _initialCameraFitted = true;
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
      onMapReady: (controller) async {
        _mapController = controller;
        final initialPosition = await controller.getCameraPosition();
        ref
            .read(mapMarkerNotifierProvider.notifier)
            .updateOverlays(
              context: context,
              events: widget.events,
              zoom: initialPosition.zoom,
              onPhotoMarkerTap: (eventId, photoId) {
                context.push('/feed/$eventId/photo/$photoId');
              },
            );
      },
      onCameraIdle: () async {
        if (_initialCameraFitted && _mapController != null) {
          final position = await _mapController!.getCameraPosition();
          ref
              .read(mapMarkerNotifierProvider.notifier)
              .updateOverlays(
                context: context,
                events: widget.events,
                zoom: position.zoom,
                onPhotoMarkerTap: (eventId, photoId) {
                  context.push('/feed/$eventId/photo/$photoId');
                },
              );
        }
      },
      // onCameraIdle은 클러스터링 등 추가 기능 구현 시 활용 가능
    );
  }
}
