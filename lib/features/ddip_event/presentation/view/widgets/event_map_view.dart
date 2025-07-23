// lib/features/ddip_event/presentation/view/widgets/event_map_view.dart

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

class EventMapView extends StatefulWidget {
  final DdipEvent event;
  final void Function(String photoUrl) onPhotoMarkerTapped;

  const EventMapView({
    super.key,
    required this.event,
    required this.onPhotoMarkerTapped,
  });

  @override
  State<EventMapView> createState() => _EventMapViewState();
}

class _EventMapViewState extends State<EventMapView> {
  NLatLng? _currentPosition;
  NaverMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentPosition = NLatLng(position.latitude, position.longitude);
        });
        _updateMarkers();
      }
    } catch (e) {
      print("현재 위치를 가져오는 데 실패했습니다: $e");
    }
  }

  Future<void> _updateMarkers() async {
    if (_mapController == null || !mounted) return;

    final requestMarkerIcon = await NOverlayImage.fromWidget(
      widget: _buildMarkerIcon(icon: Icons.flag_outlined, color: Colors.blue),
      context: context,
    );
    final approvedPhotoIcon = await NOverlayImage.fromWidget(
      widget: _buildMarkerIcon(icon: Icons.check_circle, color: Colors.green),
      context: context,
    );
    final rejectedPhotoIcon = await NOverlayImage.fromWidget(
      widget: _buildMarkerIcon(icon: Icons.cancel, color: Colors.red),
      context: context,
    );
    final pendingPhotoIcon = await NOverlayImage.fromWidget(
      widget: _buildMarkerIcon(icon: Icons.photo_camera, color: Colors.orange),
      context: context,
    );
    final myLocationIcon = await NOverlayImage.fromWidget(
      widget: _buildMarkerIcon(icon: Icons.my_location, color: Colors.purple),
      context: context,
    );

    final List<NMarker> markers = [];

    if (_currentPosition != null) {
      final myLocationMarker = NMarker(
        id: 'my_location',
        position: _currentPosition!,
        icon: myLocationIcon,
      );
      myLocationMarker.setZIndex(0);
      markers.add(myLocationMarker);
    }

    final requestMarker = NMarker(
      id: widget.event.id,
      position: NLatLng(widget.event.latitude, widget.event.longitude),
      icon: requestMarkerIcon,
    );
    requestMarker.setZIndex(10);
    markers.add(requestMarker);

    for (final photo in widget.event.photos) {
      NOverlayImage icon;
      switch (photo.status) {
        case PhotoStatus.approved:
          icon = approvedPhotoIcon;
          break;
        case PhotoStatus.rejected:
          icon = rejectedPhotoIcon;
          break;
        case PhotoStatus.pending:
          icon = pendingPhotoIcon;
          break;
      }
      final photoMarker = NMarker(
        id: photo.id,
        position: NLatLng(photo.latitude, photo.longitude),
        icon: icon,
      );
      photoMarker.setZIndex(20);
      photoMarker.setOnTapListener((_) {
        widget.onPhotoMarkerTapped(photo.url);
      });
      markers.add(photoMarker);
    }

    _mapController!.clearOverlays();
    _mapController!.addOverlayAll(markers.toSet());

    if (markers.length > 1) {
      final latLngs = markers.map((m) => m.position).toList();
      _mapController!.updateCamera(
        NCameraUpdate.fitBounds(
          NLatLngBounds.from(latLngs),
          padding: const EdgeInsets.all(80),
        ),
      );
    }
  }

  Widget _buildMarkerIcon({required IconData icon, required Color color}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withAlpha(204),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: NLatLng(widget.event.latitude, widget.event.longitude),
            zoom: 15,
          ),
        ),
        onMapReady: (controller) {
          _mapController = controller;
          _updateMarkers();
        },
      ),
    );
  }
}
