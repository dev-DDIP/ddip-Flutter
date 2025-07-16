import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventViewScreen extends ConsumerWidget {
  final int eventId;

  const EventViewScreen({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('요청 정보'),
      ),
      body: Center(
        child: Text('요청 ID: $eventId 의 정보를 표시할 화면입니다.'),
      ),
    );
  }
}