// lib/features/map/presentation/widgets/ddip_map_view.dart

import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
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
    final selectedEventId = ref.read(selectedEventIdProvider);

    ref
        .read(mapMarkerNotifierProvider.notifier)
        .updateOverlays(
          // ✨ [수정] pixel-based 클러스터링 계산을 위해 mapController를 전달합니다.
          mapController: _mapController!,
          context: context,
          events: widget.events,
          zoom: position.zoom,
          myLocation: _myLocation,
          onPhotoMarkerTap: (eventId, photoId) {
            context.push('/feed/$eventId/photo/$photoId');
          },
          onEventMarkerTap: (String eventId) {
            print('✅ [DEBUG] 1. 마커 탭됨: Event ID = $eventId');
            // 1. 선택된 이벤트 ID를 업데이트합니다.
            ref.read(selectedEventIdProvider.notifier).state = eventId;
            // 2. 바텀 시트를 '개요' 상태로 변경합니다.
            ref.read(feedBottomSheetStateProvider.notifier).state =
                FeedBottomSheetState.overview;
          },
          selectedEventId: selectedEventId,
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(selectedEventIdProvider, (previous, next) {
      if (next != null && next != previous) {
        final selectedEvent = widget.events.firstWhereOrNull(
          (e) => e.id == next,
        );
        if (selectedEvent != null && _mapController != null) {
          _mapController!.updateCamera(
            NCameraUpdate.scrollAndZoomTo(
              target: NLatLng(selectedEvent.latitude, selectedEvent.longitude),
              zoom: 16,
            ),
          );
        }
      }
    });

    ref.listen<AsyncValue<MapState>>(mapMarkerNotifierProvider, (_, next) {
      next.when(
        data: (mapState) {
          if (_mapController != null && mounted) {
            _mapController!.clearOverlays();
            _mapController!.addOverlayAll(mapState.markers.values.toSet());

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
      onMapTapped: (point, latLng) {
        // ✨ 현재 선택된 이벤트가 있는지 확인
        final selectedEvent = ref.read(selectedEventIdProvider);

        if (selectedEvent != null) {
          // ✨ 이벤트가 선택된 상태에서 지도를 탭하면 peekOverview 상태로 전환
          ref.read(feedBottomSheetStateProvider.notifier).state =
              FeedBottomSheetState.peekOverview;
        } else {
          // ✨ 선택된 이벤트가 없으면 기존 peek 상태로 전환
          ref.read(feedBottomSheetStateProvider.notifier).state =
              FeedBottomSheetState.peek;
        }
      },
      onCameraIdle: () async {
        if (_mapController != null) {
          // 카메라 이동 시 마커 업데이트 (GPS 호출 없음)
          final position = await _mapController!.getCameraPosition();
          print('Current Zoom Level: ${position.zoom}');
          _updateMarkers();
        }
      },
      // onCameraIdle은 클러스터링 등 추가 기능 구현 시 활용 가능
    );
  }
}
