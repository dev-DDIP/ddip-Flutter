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
    final position = await _mapController!.getCameraPosition();
    final selectedEventId = ref.read(selectedEventIdProvider);
    final strategy = ref.read(feedSheetStrategyProvider.notifier);

    ref
        .read(mapMarkerNotifierProvider.notifier)
        .updateOverlays(
          mapController: _mapController!,
          context: context,
          events: widget.events,
          zoom: position.zoom,
          myLocation: _myLocation,
          onPhotoMarkerTap: (eventId, photoId) {
            context.push('/feed/$eventId/photo/$photoId');
          },
          onEventMarkerTap: (String eventId) {
            // Strategy에게 오버뷰를 보여달라고 간단히 명령합니다.
            strategy.showOverview(eventId);
          },
          selectedEventId: selectedEventId,
        );
  }

  @override
  Widget build(BuildContext context) {
    // 선택된 이벤트가 바뀌면 카메라를 해당 위치로 이동시킵니다.
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

    // 마커 데이터가 갱신되면 지도 위에 다시 그립니다.
    ref.listen<AsyncValue<MapState>>(mapMarkerNotifierProvider, (_, next) {
      next.when(
        data: (mapState) {
          if (_mapController != null && mounted) {
            _mapController!.clearOverlays();
            _mapController!.addOverlayAll(mapState.markers.values.toSet());

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

    final strategy = ref.read(feedSheetStrategyProvider.notifier);

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
        locationButtonEnable: true,
      ),
      onMapReady: (controller) async {
        _mapController = controller;
        _updateMarkers();
      },
      onMapTapped: (point, latLng) {
        // Strategy에게 바텀시트를 최소화하라고 명령합니다.
        strategy.minimize();
      },
      onCameraChange: (NCameraUpdateReason reason, bool animated) {
        // 사용자의 제스처(드래그, 줌 등)로 인해 카메라가 움직였을 때만
        if (reason == NCameraUpdateReason.gesture) {
          strategy.minimize();
        }
      },
      onCameraIdle: () async {
        if (_mapController != null) {
          _updateMarkers();
        }
      },
    );
  }
}
