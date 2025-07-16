import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  // 지도 동작을 제어할 컨트롤러
  late NaverMapController _mapController;
  // 지도 중앙에 표시될 마커의 위치 (초기값: 경북대학교 IT대학)
  final NLatLng _initialPosition = const NLatLng(35.890, 128.612);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위치 선택'),
        // 선택 완료 버튼
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              // TODO: 현재 카메라 중앙 위치를 이전 화면으로 반환하는 로직 추가
              final cameraPosition = await _mapController.getCameraPosition();
              if (mounted) {
                Navigator.of(context).pop(cameraPosition.target);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. 실제 지도를 보여주는 NaverMap 위젯
          NaverMap(
            options: NaverMapViewOptions(
              // 지도의 초기 위치와 줌 레벨을 설정합니다.
              initialCameraPosition: NCameraPosition(
                target: _initialPosition,
                zoom: 15,
              ),
              // 현위치 버튼을 활성화합니다.
              locationButtonEnable: true,
            ),
            // 지도가 준비되면 컨트롤러를 받아옵니다.
            onMapReady: (controller) {
              _mapController = controller;
              print("네이버 맵 로딩 완료!");
            },
          ),
          // 2. 화면 중앙에 항상 고정된 마커 아이콘
          const Center(
            child: Icon(
              Icons.place,
              color: Colors.red,
              size: 50,
            ),
          ),
        ],
      ),
    );
  }
}