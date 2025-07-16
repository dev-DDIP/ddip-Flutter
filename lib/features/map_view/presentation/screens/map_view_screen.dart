import 'package:flutter/material.dart';

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('위치 선택'),
      ),
      body: const Center(
        child: Text('지도가 여기에 표시될 예정입니다.'),
      ),
    );
  }
}