// [리팩토링] 파일 위치 이동 및 클래스 이름 변경 (MapViewScreen -> LocationPickerScreen)
import 'package:ddip/core/permissions/permission_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  NaverMapController? _mapController;
  NLatLng? _initialPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMapLocation();
  }

  Future<void> _initializeMapLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _initialPosition = NLatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialPosition = const NLatLng(35.890, 128.612); // 경북대학교 기본 위치
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionState = ref.watch(permissionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('위치 선택'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed:
                _isLoading ||
                        (permissionState != LocationPermission.whileInUse &&
                            permissionState != LocationPermission.always)
                    ? null
                    : () async {
                      if (_mapController != null) {
                        final cameraPosition =
                            await _mapController!.getCameraPosition();
                        if (mounted) {
                          Navigator.of(context).pop(cameraPosition.target);
                        }
                      }
                    },
          ),
        ],
      ),
      body: switch (permissionState) {
        LocationPermission.denied => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('정확한 위치 선택을 위해 위치 권한이 필요합니다.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(permissionProvider.notifier).requestPermission();
                },
                child: const Text('권한 요청하기'),
              ),
            ],
          ),
        ),
        LocationPermission.deniedForever => const Center(
          child: Text('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 직접 허용해주세요.'),
        ),
        _ =>
          _isLoading || _initialPosition == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                alignment: Alignment.center,
                children: [
                  NaverMap(
                    options: NaverMapViewOptions(
                      initialCameraPosition: NCameraPosition(
                        target: _initialPosition!,
                        zoom: 16,
                      ),
                      locationButtonEnable: true,
                    ),
                    onMapReady: (controller) {
                      _mapController = controller;
                    },
                  ),
                  const Icon(Icons.place, color: Colors.red, size: 50),
                ],
              ),
      },
    );
  }
}
