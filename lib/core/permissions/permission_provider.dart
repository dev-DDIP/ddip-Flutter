// lib/core/permissions/permission_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// PermissionNotifier: 위치 권한 상태를 전문적으로 관리하는 '중앙 관제탑' 클래스.
///
/// 이 클래스는 StateNotifier를 상속받아, 'LocationPermission'이라는 특정 타입의 상태를 관리합니다.
/// 상태가 변경되면, 이 상태를 지켜보고(watch) 있는 UI는 자동으로 업데이트됩니다.
class PermissionNotifier extends StateNotifier<LocationPermission> {
  // Notifier가 처음 생성될 때, 초기 상태를 설정합니다.
  // super() 안에서 _checkPermission()을 호출하여, 생성과 동시에 현재 권한 상태를 확인하고
  // 그 결과를 첫 번째 상태로 즉시 설정합니다.
  PermissionNotifier() : super(LocationPermission.denied) {
    _init();
  }

  // 비동기 초기화 메서드
  Future<void> _init() async {
    await _checkPermission();
  }

  /// 현재 위치 권한 상태를 확인하고, 그 결과를 state에 업데이트하는 내부 메서드.
  Future<void> _checkPermission() async {
    // Geolocator를 사용해 현재 권한 상태를 시스템으로부터 가져옵니다.
    final permission = await Geolocator.checkPermission();
    // 가져온 권한 상태로 현재 상태(state)를 업데이트합니다.
    state = permission;
  }

  /// 사용자에게 위치 권한을 요청하는 외부 공개 메서드.
  /// UI의 '권한 요청' 버튼 등에서 이 메서드를 호출하게 됩니다.
  Future<void> requestPermission() async {
    // Geolocator를 통해 사용자에게 권한 요청 팝업을 띄웁니다.
    final permission = await Geolocator.requestPermission();
    // 사용자의 선택 결과를 새로운 상태(state)로 업데이트합니다.
    state = permission;
  }
}

/// permissionProvider: 위에서 만든 PermissionNotifier를 UI와 연결해주는 프로바이더.
///
/// StateNotifierProvider는 StateNotifier 클래스를 관리하기 위한 전용 프로바이더입니다.
/// .autoDispose는 이 프로바이더를 지켜보는 위젯이 하나도 없을 때,
/// 자동으로 소멸시켜 불필요한 메모리 차지를 막는 효율적인 기능입니다.
final permissionProvider =
    StateNotifierProvider.autoDispose<PermissionNotifier, LocationPermission>(
      (ref) => PermissionNotifier(),
    );
