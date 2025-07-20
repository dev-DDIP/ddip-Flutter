// lib/features/ddip_event/presentation/view/widgets/event_map_view.dart

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

class EventMapView extends StatefulWidget {
  final DdipEvent event;
  final VoidCallback onMarkerTapped;

  const EventMapView({
    super.key,
    required this.event,
    required this.onMarkerTapped,
  });

  @override
  State<EventMapView> createState() => _EventMapViewState();
}

class _EventMapViewState extends State<EventMapView> {
  NaverMapController? _controller;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildMarkerIcon({required IconData icon, required Color color}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  void _handleMapTap(NLatLng latLng) async {
    if (widget.event.responsePhotoUrl == null || _controller == null) {
      return;
    }

    final cameraPosition = await _controller!.getCameraPosition();
    final currentZoom = cameraPosition.zoom;

    double allowedDistance;
    if (currentZoom > 15) {
      allowedDistance = 25;
    } else if (currentZoom > 12) {
      allowedDistance = 75;
    } else {
      allowedDistance = 150;
    }

    final responsePosition = NLatLng(
      widget.event.responseLatitude!,
      widget.event.responseLongitude!,
    );

    final distance = Geolocator.distanceBetween(
      latLng.latitude,
      latLng.longitude,
      responsePosition.latitude,
      responsePosition.longitude,
    );

    if (distance < allowedDistance) {
      widget.onMarkerTapped();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(widget.event.latitude, widget.event.longitude),
            zoom: 16,
          ),
        ),
        onMapTapped: (point, latLng) {
          _handleMapTap(latLng);
        },
        onMapReady: (controller) async {
          _controller = controller;

          final requestMarkerIcon = await NOverlayImage.fromWidget(
            widget: _buildMarkerIcon(icon: Icons.pan_tool, color: Colors.blue),
            context: context,
          );

          final responseMarkerIcon = await NOverlayImage.fromWidget(
            widget: _buildMarkerIcon(
              icon: Icons.photo_camera,
              color: Colors.green,
            ),
            context: context,
          );

          controller.clearOverlays();

          final requestMarker = NMarker(
            id: widget.event.id,
            position: NLatLng(widget.event.latitude, widget.event.longitude),
            icon: requestMarkerIcon,
          );
          controller.addOverlay(requestMarker);

          if (widget.event.responsePhotoUrl != null) {
            final responsePosition = NLatLng(
              widget.event.responseLatitude!,
              widget.event.responseLongitude!,
            );
            final responseMarker = NMarker(
              id: 'response_marker',
              position: responsePosition,
              icon: responseMarkerIcon,
            );
            controller.addOverlay(responseMarker);

            controller.updateCamera(
              NCameraUpdate.fitBounds(
                NLatLngBounds.from([
                  requestMarker.position,
                  responseMarker.position,
                ]),
                padding: const EdgeInsets.all(80),
              ),
            );
          }
        },
      ),
    );
  }
}
