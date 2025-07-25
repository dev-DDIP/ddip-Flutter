// [최종 개선] Notifier의 역할을 존중하도록 View를 최대한 단순하게 변경
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class DdipMapView extends ConsumerStatefulWidget {
  final List<DdipEvent> events;

  const DdipMapView({super.key, required this.events});

  @override
  ConsumerState<DdipMapView> createState() => _DdipMapViewState();
}

class _DdipMapViewState extends ConsumerState<DdipMapView> {
  NaverMapController? _mapController;
  bool _isInitialCameraMoveDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(mapMarkerNotifierProvider.notifier).setContext(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<MapState>>(mapMarkerNotifierProvider, (
      previous,
      next,
    ) {
      next.when(
        data: (mapState) {
          if (_mapController != null && mounted) {
            _mapController!.clearOverlays();
            _mapController!.addOverlayAll(mapState.markers);

            if (!_isInitialCameraMoveDone &&
                mapState.bounds != null &&
                mapState.markers.length > 1) {
              _mapController!.updateCamera(
                NCameraUpdate.fitBounds(
                  mapState.bounds!,
                  padding: const EdgeInsets.all(80),
                ),
              );
              _isInitialCameraMoveDone = true;
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
                  : const NLatLng(35.890, 128.612),
          zoom: 15,
        ),
      ),
      // [수정] async 키워드 추가
      onMapReady: (controller) async {
        _mapController = controller;

        // [수정] GPS 위치를 가져오는 로직을 다시 추가합니다.
        Position? currentPosition;
        try {
          currentPosition = await Geolocator.getCurrentPosition();
        } catch (e) {
          print("맵 준비 중 위치 파악 실패: $e");
        }

        // [수정] 가져온 currentPosition을 파라미터로 전달합니다.
        ref
            .read(mapMarkerNotifierProvider.notifier)
            .loadInitialMarkers(
              events: widget.events,
              currentPosition: currentPosition, // 이 부분이 누락되었습니다.
              onPhotoMarkerTap: (eventId, photoId) {
                context.push('/feed/$eventId/photo/$photoId');
              },
            );
      },
      onCameraIdle: () {
        if (_mapController != null) {
          ref
              .read(mapMarkerNotifierProvider.notifier)
              .updateMarkersForIdle(
                cameraPosition: _mapController!.nowCameraPosition,
              );
        }
      },
    );
  }
}
