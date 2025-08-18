// lib/features/camera/photo_preview_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// 촬영 결과(사진 경로 + 코멘트)를 담을 간단한 데이터 클래스
class PhotoSubmissionResult {
  final String imagePath;
  final String? comment;

  PhotoSubmissionResult({required this.imagePath, this.comment});
}

class PhotoPreviewScreen extends StatefulWidget {
  final XFile image;

  const PhotoPreviewScreen({super.key, required this.image});

  @override
  State<PhotoPreviewScreen> createState() => _PhotoPreviewScreenState();
}

class _PhotoPreviewScreenState extends State<PhotoPreviewScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final result = PhotoSubmissionResult(
      imagePath: widget.image.path,
      comment: _commentController.text,
    );
    // 결과를 반환하며 현재 화면을 닫습니다.
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('미리보기 & 전송'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(), // 결과 없이 그냥 닫기
        ),
      ),
      body: Column(
        children: [
          // Expanded 위젯으로 사진이 남은 공간을 모두 차지하도록 함
          Expanded(
            child: InteractiveViewer(
              child: Image.file(File(widget.image.path), fit: BoxFit.contain),
            ),
          ),
          // 하단 코멘트 입력 및 전송 영역
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: '사진에 대한 부연 설명을 남길 수 있습니다. (선택)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('전송하기'),
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
