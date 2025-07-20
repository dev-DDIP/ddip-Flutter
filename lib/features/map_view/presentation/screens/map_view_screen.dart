// lib/features/map_view/presentation/screens/map_view_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. 6단계에서 만든 중앙 권한 관제탑(permissionProvider)을 import 합니다.
import 'package:ddip/core/permissions/permission_provider.dart';

// 2. StatefulWidget -> ConsumerStatefulWidget으로 변경하여 ref를 사용할 수 있게 합니다.
class MapViewScreen extends ConsumerStatefulWidget {
  const MapViewScreen({super.key});

  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  NaverMapController? _mapController;
  NLatLng? _initialPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // 3. 복잡했던 _determinePosition() 함수 대신, 지도의 초기 위치를 설정하는
    //    단순한 함수를 호출합니다.
    _initializeMapLocation();
  }

  // 4. 기존의 복잡한 권한 처리 로직(_determinePosition)은 모두 사라지고,
  //    단순히 '현재 위치를 가져와 지도를 설정하는' 로직만 남습니다.
  Future<void> _initializeMapLocation() async {
    try {
      // Geolocator를 사용하여 현재 위치를 가져옵니다.
      // 이 시점에는 권한이 이미 허용되었을 것으로 '가정'합니다.
      // 권한 처리는 이제 build 메서드와 PermissionNotifier가 담당합니다.
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _initialPosition = NLatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      // 위치 가져오기에 실패하면 기본 위치(경북대학교)로 설정합니다.
      setState(() {
        _initialPosition = const NLatLng(35.890, 128.612);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 5. ref.watch를 통해 중앙 관제탑의 '권한 상태'를 실시간으로 감시합니다.
    //    만약 사용자가 설정에서 권한을 바꾸고 앱으로 돌아오면, 이 화면은 자동으로 새로고침됩니다.
    final permissionState = ref.watch(permissionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('위치 선택'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            // 6. 권한이 허용된 상태가 아니면 '완료' 버튼을 비활성화합니다.
            onPressed:
                _isLoading || permissionState != LocationPermission.whileInUse
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
      // 7. 감시하고 있는 '권한 상태'에 따라 전혀 다른 화면을 보여줍니다.
      body: switch (permissionState) {
        // 7-1. 권한이 '거부된' 상태일 경우:
        LocationPermission.denied => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('정확한 위치 선택을 위해 위치 권한이 필요합니다.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // 중앙 관제탑에게 '권한을 요청해달라'고 명령합니다.
                  // 이 화면은 권한 요청의 실제 로직을 전혀 알 필요가 없습니다.
                  ref.read(permissionProvider.notifier).requestPermission();
                },
                child: const Text('권한 요청하기'),
              ),
            ],
          ),
        ),
        // 7-2. 권한이 '영구적으로 거부된' 상태일 경우:
        LocationPermission.deniedForever => const Center(
          child: Text('위치 권한이 영구적으로 거부되었습니다. 앱 설정에서 직접 허용해주세요.'),
        ),
        // 7-3. 권한이 '허용된' 상태일 경우 (기존 로직과 동일):
        _ =>
          _isLoading || _initialPosition == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
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
                  const Center(
                    child: Icon(Icons.place, color: Colors.red, size: 50),
                  ),
                ],
              ),
      },
    );
  }
}
