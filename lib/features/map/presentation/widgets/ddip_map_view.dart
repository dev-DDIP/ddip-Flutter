// lib/features/map/presentation/widgets/ddip_map_view.dart
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
  bool _initialCameraFitted = false; // 초기 카메라 조정 여부 플래그
  Position? _myLocation;

  @override
  void initState() {
    super.initState();
    // 위젯이 생성될 때 딱 한 번만 내 위치를 가져옵니다.
    _fetchMyLocationOnce();
  }

  // 내 위치를 한 번만 가져오는 함수
  Future<void> _fetchMyLocationOnce() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _myLocation = position;
        });
        // 위치를 성공적으로 가져온 후, 마커를 다시 그리도록 요청
        _updateMarkers();
      }
    } catch (e) {
      print("최초 사용자 위치 로딩 실패: $e");
    }
  }

  // 마커 업데이트 로직을 별도 함수로 분리
  Future<void> _updateMarkers() async {
    if (_mapController == null) return;
    final position = await _mapController!.getCameraPosition();
    ref
        .read(mapMarkerNotifierProvider.notifier)
        .updateOverlays(
          context: context,
          events: widget.events,
          zoom: position.zoom,
          myLocation: _myLocation,
          // 저장된 내 위치를 전달
          onPhotoMarkerTap: (eventId, photoId) {
            context.push('/feed/$eventId/photo/$photoId');
          },
        );
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
        _updateMarkers();
      },
      onCameraIdle: () async {
        if (_mapController != null) {
          // 카메라 이동 시 마커 업데이트 (GPS 호출 없음)
          _updateMarkers();
        }
      },
      // onCameraIdle은 클러스터링 등 추가 기능 구현 시 활용 가능
    );
  }
}
