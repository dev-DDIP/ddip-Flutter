// ▼▼▼ lib/features/activity/presentation/widgets/login_prompt.dart (새 파일) ▼▼▼
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPrompt extends StatelessWidget {
  const LoginPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              '로그인이 필요한 서비스입니다.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '나의 활동 내역을 보려면 먼저 로그인해주세요.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.go('/feed');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
              ),
              child: const Text('로그인하러 가기'),
            ),
          ],
        ),
      ),
    );
  }
}

// ▲▲▲ lib/features/activity/presentation/widgets/login_prompt.dart (새 파일) ▲▲▲
