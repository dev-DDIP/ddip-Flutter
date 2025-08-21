// lib/features/ddip_event/presentation/detail/screens/full_screen_photo_view.dart

import 'dart:io';
import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart'; // [수정] 3번 에러 해결을 위한 import 추가

// ▼▼▼ [수정] 위젯 전체를 아래 코드로 교체합니다. ▼▼▼
class FullScreenPhotoView extends ConsumerWidget {
  final String eventId;
  final String photoId;

  const FullScreenPhotoView({
    super.key,
    required this.eventId,
    required this.photoId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // [수정] .when을 사용하지 않고 직접 event 객체를 가져옵니다. (2, 5번 에러 해결)
    final event = ref.watch(eventDetailProvider(eventId));

    // 로딩 및 에러 처리: event가 아직 로드되지 않았다면 로딩 인디케이터 표시
    if (event == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final photo = event.photos.firstWhereOrNull((p) => p.id == photoId);

    if (photo == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(
          child: Text('사진을 찾을 수 없습니다.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    // [수정] 6번 에러 해결: && 연산자의 피연산자가 명확한 bool 타입이 되도록 수정
    final bool hasComment =
        photo.responderComment != null && photo.responderComment!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                child: Image.file(File(photo.url)),
              ),
            ),
            if (hasComment)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${photo.responderComment!}"',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '수행자가 ${DateFormat('a h:mm', 'ko_KR').format(photo.timestamp)}에 남김',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ▲▲▲ [수정] 위젯 전체를 아래 코드로 교체합니다. ▲▲▲
