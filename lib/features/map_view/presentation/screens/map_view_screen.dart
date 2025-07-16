import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  // 지도 동작을 제어할 컨트롤러
  late NaverMapController _mapController;
  NLatLng? _initialPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 3. 위젯이 생성될 때 현재 위치를 가져오는 함수 호출
    _determinePosition();
  }

  // 4. geolocator를 사용하여 현재 위치를 가져오는 로직
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 기기의 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화되어 있으면 기본 위치(경북대)로 설정
      _setDefaultLocation();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치 서비스가 비활성화되어 있습니다.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 권한이 거부되면 기본 위치로 설정
        _setDefaultLocation();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('위치 정보 접근 권한이 거부되었습니다.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 권한이 영구적으로 거부된 경우
      _setDefaultLocation();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 권한을 허용해주세요.')),
        );
      }
      return;
    }

    // 권한이 허용되면 현재 위치를 가져옵니다.
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _initialPosition = NLatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      // 위치를 가져오는 데 실패하면 기본 위치로 설정
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    setState(() {
      _initialPosition = const NLatLng(35.890, 128.612); // 경북대학교 IT대학
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위치 선택'),
        // 선택 완료 버튼
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : () async {
              // TODO: 현재 카메라 중앙 위치를 이전 화면으로 반환하는 로직 추가
              final cameraPosition = await _mapController.getCameraPosition();
              if (mounted) {
                Navigator.of(context).pop(cameraPosition.target);
              }
            },
          ),
        ],
      ),
      // 로딩 상태이거나, _initialPosition이 아직 null일 경우 로딩 화면을 보여줍니다.
      body: _isLoading || _initialPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // 1. 실제 지도를 보여주는 NaverMap 위젯
          NaverMap(
            options: NaverMapViewOptions(
              // 지도의 초기 위치와 줌 레벨을 설정합니다.
              initialCameraPosition: NCameraPosition(
                // 이 시점에는 _initialPosition이 null이 아님이 보장되므로,
                // ! (null check operator)를 사용하여 컴파일러를 안심시킵니다.
              target: _initialPosition!,
                zoom: 16,
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