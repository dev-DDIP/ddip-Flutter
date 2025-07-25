// lib/features/map/presentation/widgets/pulsing_marker_icon.dart
import 'package:flutter/material.dart';

// [신규] 로딩 상태를 표시할 수 있는 새로운 마커 아이콘 위젯
class PulsingMarkerIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isLoading;

  const PulsingMarkerIcon({
    super.key,
    required this.icon,
    required this.color,
    this.isLoading = false,
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
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      // isLoading 값에 따라 로딩 인디케이터 또는 아이콘을 표시
      child:
          isLoading
              ? const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
              : Icon(icon, color: Colors.white, size: 20),
    );
  }
}
