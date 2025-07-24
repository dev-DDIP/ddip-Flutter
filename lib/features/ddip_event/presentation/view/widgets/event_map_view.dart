// lib/features/ddip_event/presentation/view/widgets/event_map_view.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

// PulsingMarkerIcon 위젯 (변경 없음)
class PulsingMarkerIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final bool hasNewUpdate;

  const PulsingMarkerIcon({
    super.key,
    required this.icon,
    required this.color,
    this.hasNewUpdate = false,
  });

  @override
  State<PulsingMarkerIcon> createState() => _PulsingMarkerIconState();
}

class _PulsingMarkerIconState extends State<PulsingMarkerIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.hasNewUpdate) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant PulsingMarkerIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasNewUpdate != oldWidget.hasNewUpdate) {
      if (widget.hasNewUpdate) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor =
        widget.hasNewUpdate ? Colors.orangeAccent : Colors.white;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.hasNewUpdate)
          FadeTransition(
            opacity: _animationController.drive(
              CurveTween(curve: Curves.easeOut),
            ),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.5),
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: borderColor, width: 3),
          ),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(widget.icon, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}

class EventMapView extends ConsumerStatefulWidget {
  final DdipEvent event;
  final Set<String> viewedPhotoIds;

  const EventMapView({
    super.key,
    required this.event,
    required this.viewedPhotoIds,
  });

  @override
  ConsumerState<EventMapView> createState() => _EventMapViewState();
}

class _EventMapViewState extends ConsumerState<EventMapView> {
  NLatLng? _currentPosition;
  NaverMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void didUpdateWidget(covariant EventMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.event != oldWidget.event ||
        widget.viewedPhotoIds != oldWidget.viewedPhotoIds) {
      _updateMarkers();
    }
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

    final currentUser = ref.read(authProvider);
    final isRequester = currentUser?.id == widget.event.requesterId;

    const requestMarkerIconWidget = PulsingMarkerIcon(
      icon: Icons.flag_outlined,
      color: Colors.blue,
    );
    const myLocationIconWidget = PulsingMarkerIcon(
      icon: Icons.my_location,
      color: Colors.purple,
    );

    final requestMarkerIcon = await NOverlayImage.fromWidget(
      widget: requestMarkerIconWidget,
      context: context,
    );
    final myLocationIcon = await NOverlayImage.fromWidget(
      widget: myLocationIconWidget,
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
      IconData iconData;
      Color color;
      bool hasNewUpdate =
          isRequester &&
          photo.status == PhotoStatus.pending &&
          !widget.viewedPhotoIds.contains(photo.id);

      switch (photo.status) {
        case PhotoStatus.approved:
          iconData = Icons.check_circle;
          color = Colors.green;
          break;
        case PhotoStatus.rejected:
          iconData = Icons.cancel;
          color = Colors.red;
          break;
        case PhotoStatus.pending:
          iconData = Icons.photo_camera;
          color = Colors.orange;
          break;
      }

      final photoMarkerWidget = PulsingMarkerIcon(
        icon: iconData,
        color: color,
        hasNewUpdate: hasNewUpdate,
      );
      final photoMarkerIcon = await NOverlayImage.fromWidget(
        widget: photoMarkerWidget,
        context: context,
      );

      final photoMarker = NMarker(
        id: photo.id,
        position: NLatLng(photo.latitude, photo.longitude),
        icon: photoMarkerIcon,
      );
      photoMarker.setZIndex(20);

      photoMarker.setOnTapListener((_) {
        context.push('/feed/${widget.event.id}/photo/${photo.id}');
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
