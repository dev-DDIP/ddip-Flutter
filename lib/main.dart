// lib/main.dart

import 'package:ddip/features/ddip_event/presentation/creation/screens/ddip_creation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  // 1. 앱 전체를 ProviderScope로 감싸서 Riverpod를 사용할 수 있도록 합니다.
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '띱(DDIP)',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 2. 앱의 첫 화면을 기본 카운터 앱 대신 우리가 만든 DdipCreationScreen으로 설정합니다.
      home: const DdipCreationScreen(),
    );
  }
}