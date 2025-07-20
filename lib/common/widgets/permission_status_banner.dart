// lib/common/widgets/permission_status_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ddip/core/permissions/permission_provider.dart';

/// 권한 상태에 따라 다른 UI를 보여주는 재사용 가능한 배너 위젯입니다.
/// 이제 public 클래스(PermissionStatusBanner)가 되었으므로, 앱의 다른 곳에서도 사용할 수 있습니다.
class PermissionStatusBanner extends ConsumerWidget {
  const PermissionStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 중앙 관제탑(permissionProvider)의 상태를 실시간으로 감시(watch)합니다.
    final permission = ref.watch(permissionProvider);

    // 권한 상태에 따라 다른 디자인의 배너를 반환합니다.
    switch (permission) {
      // 1. 권한이 거부된 상태일 경우:
      case LocationPermission.denied:
        return _Banner(
          backgroundColor: Colors.orange.shade100,
          icon: Icons.warning_amber_rounded,
          iconColor: Colors.orange,
          text: '주변 요청 알림을 받으려면 위치 권한을 허용해주세요.',
          buttonText: '허용하기',
          onButtonPressed: () {
            // 버튼을 누르면 중앙 관제탑에게 권한을 요청하도록 명령합니다.
            ref.read(permissionProvider.notifier).requestPermission();
          },
        );
      // 2. 권한이 영구적으로 거부된 상태일 경우:
      case LocationPermission.deniedForever:
        return _Banner(
          backgroundColor: Colors.red.shade100,
          icon: Icons.error_outline,
          iconColor: Colors.red,
          text: '권한이 영구 거부되었습니다. 앱 설정에서 직접 허용해야 합니다.',
        );
      // 3. 권한이 허용된 상태일 경우:
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return _Banner(
          backgroundColor: Colors.green.shade100,
          icon: Icons.check_circle_outline,
          iconColor: Colors.green,
          text: '주변 요청을 정상적으로 감시하고 있습니다.',
        );
      // 그 외의 경우는 아무것도 보여주지 않습니다.
      default:
        return const SizedBox.shrink();
    }
  }
}

/// 배너 UI의 재사용을 위한 내부 위젯
class _Banner extends StatelessWidget {
  const _Banner({
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
    required this.text,
    this.buttonText,
    this.onButtonPressed,
  });

  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;
  final String text;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
            if (buttonText != null) ...[
              const SizedBox(width: 12),
              TextButton(onPressed: onButtonPressed, child: Text(buttonText!)),
            ],
          ],
        ),
      ),
    );
  }
}
