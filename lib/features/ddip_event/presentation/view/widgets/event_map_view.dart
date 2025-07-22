// lib/features/ddip_event/presentation/view/widgets/event_map_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo_feedback.dart';

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
  Widget _buildMarkerIcon({required IconData icon, required Color color}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        // [경고 수정] withOpacity(0.8) -> withAlpha(204) (80% of 255)
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
            zoom: 16,
          ),
        ),
        onMapReady: (controller) async {
          final requestMarkerIcon = await NOverlayImage.fromWidget(
            widget: _buildMarkerIcon(
              icon: Icons.flag_outlined,
              color: Colors.blue,
            ),
            context: context,
          );
          final approvedPhotoIcon = await NOverlayImage.fromWidget(
            widget: _buildMarkerIcon(
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            context: context,
          );
          final rejectedPhotoIcon = await NOverlayImage.fromWidget(
            widget: _buildMarkerIcon(icon: Icons.cancel, color: Colors.red),
            context: context,
          );
          final pendingPhotoIcon = await NOverlayImage.fromWidget(
            widget: _buildMarkerIcon(
              icon: Icons.photo_camera,
              color: Colors.orange,
            ),
            context: context,
          );

          controller.clearOverlays();
          final List<NMarker> markers = [];

          final requestMarker = NMarker(
            id: widget.event.id,
            position: NLatLng(widget.event.latitude, widget.event.longitude),
            icon: requestMarkerIcon,
          );
          markers.add(requestMarker);

          for (final photo in widget.event.photos) {
            NOverlayImage icon;
            switch (photo.status) {
              case FeedbackStatus.approved:
                icon = approvedPhotoIcon;
                break;
              case FeedbackStatus.rejected:
                icon = rejectedPhotoIcon;
                break;
              case FeedbackStatus.pending:
                icon = pendingPhotoIcon;
                break;
            }

            final photoMarker = NMarker(
              id: photo.photoId,
              position: NLatLng(photo.latitude, photo.longitude),
              icon: icon,
            );

            // [오류 수정] setOnTap -> setOnTapListener
            photoMarker.setOnTapListener((_) {
              widget.onPhotoMarkerTapped(photo.photoUrl);
            });
            markers.add(photoMarker);
          }

          // [오류 수정] addOverlays(List) -> addOverlayAll(Set)
          controller.addOverlayAll(markers.toSet());

          if (markers.length > 1) {
            final latLngs = markers.map((m) => m.position).toList();
            controller.updateCamera(
              NCameraUpdate.fitBounds(
                NLatLngBounds.from(latLngs),
                padding: const EdgeInsets.all(80),
              ),
            );
          }
        },
      ),
    );
  }
}
