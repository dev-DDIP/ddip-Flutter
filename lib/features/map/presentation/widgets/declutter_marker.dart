// [신규] 겹침 방지 마커 UI를 위한 위젯 (꺾은 선은 NaverMap의 NPolylineOverlay로 그려야 함)
import 'package:flutter/material.dart';

class DeclutterMarker extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Offset offset; // 이 위젯은 마커 아이콘 자체만 그림

  const DeclutterMarker({
    super.key,
    required this.icon,
    required this.color,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
