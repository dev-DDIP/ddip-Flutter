// lib/features/ddip_event/presentation/view/widgets/event_map_view.dart

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo_feedback.dart';
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

  @override
  void initState() {
    super.initState();
    // 3. 위젯이 생성될 때 현재 위치를 가져오는 함수 호출
    _getCurrentLocation();
  }

  // 4. 현재 위치를 비동기적으로 가져오는 함수
  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _currentPosition = NLatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      print("현재 위치를 가져오는 데 실패했습니다: $e");
      // 위치 가져오기 실패 시 기본 처리 (예: 에러 메시지 표시 또는 기본 위치 설정)
    }
  }

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
          final myLocationIcon = await NOverlayImage.fromWidget(
            widget: _buildMarkerIcon(
              icon: Icons.my_location,
              color: Colors.purple,
            ),
            context: context,
          );

          controller.clearOverlays();
          final List<NMarker> markers = [];

          // --- 현재 위치 마커 추가 ---
          if (_currentPosition != null) {
            final myLocationMarker = NMarker(
              id: 'my_location',
              position: _currentPosition!,
              icon: myLocationIcon,
            );
            myLocationMarker.setZIndex(0); // zIndex를 가장 낮게 설정하여 항상 뒤에 있도록 함
            markers.add(myLocationMarker);
          }

          // --- 요청 위치 마커 추가 ---
          final requestMarker = NMarker(
            id: widget.event.id,
            position: NLatLng(widget.event.latitude, widget.event.longitude),
            icon: requestMarkerIcon,
          );
          requestMarker.setZIndex(10); // 사진 마커보다는 뒤, 내 위치 마커보다는 앞에 오도록 설정
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
            photoMarker.setZIndex(20);

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
