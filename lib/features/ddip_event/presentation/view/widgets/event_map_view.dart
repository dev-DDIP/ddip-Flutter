// lib/features/ddip_event/presentation/view/widgets/event_map_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';

class EventMapView extends StatelessWidget {
  final DdipEvent event;
  final VoidCallback onMarkerTapped; // 전체 화면 이미지를 띄우기 위한 콜백

  const EventMapView({
    super.key,
    required this.event,
    required this.onMarkerTapped,
  });

  @override
  Widget build(BuildContext context) {
    final requestPosition = NLatLng(event.latitude, event.longitude);

    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: requestPosition,
            zoom: 16,
          ),
        ),
        onMapTapped: (point, latLng) {
          _handleMapTap(latLng);
        },
        onMapReady: (controller) {
          _setupMarkers(controller, requestPosition);
        },
      ),
    );
  }

  void _handleMapTap(NLatLng latLng) {
    if (event.responsePhotoUrl == null ||
        event.responseLatitude == null ||
        event.responseLongitude == null) {
      return;
    }

    final responsePosition = NLatLng(
      event.responseLatitude!,
      event.responseLongitude!,
    );

    final distance = Geolocator.distanceBetween(
      latLng.latitude,
      latLng.longitude,
      responsePosition.latitude,
      responsePosition.longitude,
    );

    if (distance < 25) {
      // 25미터 이내를 탭하면 마커 탭으로 간주
      onMarkerTapped();
    }
  }

  void _setupMarkers(NaverMapController controller, NLatLng requestPosition) {
    controller.clearOverlays();
    final requestMarker = NMarker(id: event.id, position: requestPosition);
    controller.addOverlay(requestMarker);

    if (event.responsePhotoUrl != null &&
        event.responseLatitude != null &&
        event.responseLongitude != null) {
      final responsePosition = NLatLng(
        event.responseLatitude!,
        event.responseLongitude!,
      );
      final responseMarker = NMarker(
        id: 'response_marker',
        position: responsePosition,
      );
      controller.addOverlay(responseMarker);

      controller.updateCamera(
        NCameraUpdate.fitBounds(
          NLatLngBounds.from([requestPosition, responsePosition]),
          padding: const EdgeInsets.all(80),
        ),
      );
    }
  }
}
