// lib/features/profile/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ConsumerWidget으로 만들어 Riverpod의 Provider를 사용할 수 있도록 합니다.
class ProfileScreen extends ConsumerWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 나중에 이 userId를 사용하여 Riverpod Provider로 실제 프로필 데이터를 가져옵니다.

    return Scaffold(
      appBar: AppBar(
        title: Text('$userId님의 프로필'), // 어떤 유저의 프로필인지 제목에 표시
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_pin, size: 100, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              '여기에 $userId 님의\n성장 앨범과 명예의 전당이\n표시될 예정입니다.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}
