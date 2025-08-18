// lib/features/ddip_event/presentation/detail/widgets/mission_location_map.dart

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MissionLocationMap extends StatelessWidget {
  final DdipEvent event;

  const MissionLocationMap({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final eventPosition = NLatLng(event.latitude, event.longitude);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '미션 위치',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            height: 200,
            clipBehavior: Clip.antiAlias, // borderRadius를 적용하기 위해 필요
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: NaverMap(
              options: NaverMapViewOptions(
                // --- 지도 초기 설정 ---
                initialCameraPosition: NCameraPosition(
                  target: eventPosition,
                  zoom: 16,
                ),
                // --- 모든 상호작용 제스처 비활성화 ---
                rotationGesturesEnable: false,
                scrollGesturesEnable: false,
                tiltGesturesEnable: false,
                zoomGesturesEnable: false,
                stopGesturesEnable: false,
                // --- 기타 UI 요소 비활성화 ---
                locationButtonEnable: false,
                scaleBarEnable: false,
                logoClickEnable: false,
              ),
              onMapReady: (controller) {
                // 지도가 준비되면 마커를 추가합니다.
                final marker = NMarker(id: event.id, position: eventPosition);
                controller.addOverlay(marker);
              },
            ),
          ),
        ],
      ),
    );
  }
}
