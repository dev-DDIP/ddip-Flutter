// lib/features/ddip_event/presentation/view/widgets/photo_feedback_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo_feedback.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';

/// 제출된 사진 목록과 피드백(승인/거절) 버튼을 제공하는 UI 위젯입니다.
class PhotoFeedbackView extends ConsumerStatefulWidget {
  final DdipEvent event;

  const PhotoFeedbackView({super.key, required this.event});

  @override
  ConsumerState<PhotoFeedbackView> createState() => _PhotoFeedbackViewState();
}

class _PhotoFeedbackViewState extends ConsumerState<PhotoFeedbackView> {
  String? _processingPhotoId;

  Future<void> _updateFeedback(String photoId, FeedbackStatus feedback) async {
    if (_processingPhotoId != null) return;

    setState(() {
      _processingPhotoId = photoId;
    });

    try {
      await ref
          .read(ddipEventsNotifierProvider.notifier)
          .updatePhotoFeedback(widget.event.id, photoId, feedback);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              feedback == FeedbackStatus.approved
                  ? '사진을 승인했습니다. 거래가 완료됩니다.'
                  : '사진을 거절했습니다. 수행자에게 재요청합니다.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _processingPhotoId = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 16.0, bottom: 8.0),
          child: Text(
            '제출된 사진 (${widget.event.photos.length}개)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.event.photos.length,
          itemBuilder: (context, index) {
            final photo = widget.event.photos[index];
            final isProcessing = _processingPhotoId == photo.photoId;

            return Card(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  Image.file(
                    File(photo.photoUrl),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildFeedbackSection(photo, isProcessing),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  /// 사진의 상태에 따라 다른 UI(버튼 또는 상태 칩)를 반환하는 헬퍼 메서드
  Widget _buildFeedbackSection(PhotoFeedback photo, bool isProcessing) {
    if (isProcessing) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (photo.status) {
      case FeedbackStatus.pending:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.thumb_up_alt_outlined),
                label: const Text('승인'),
                onPressed:
                    () =>
                        _updateFeedback(photo.photoId, FeedbackStatus.approved),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.thumb_down_alt_outlined),
                label: const Text('거절'),
                onPressed:
                    () =>
                        _updateFeedback(photo.photoId, FeedbackStatus.rejected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        );
      case FeedbackStatus.approved:
        return const Chip(
          label: Text('승인됨'),
          backgroundColor: Colors.green,
          labelStyle: TextStyle(color: Colors.white),
          avatar: Icon(Icons.check_circle, color: Colors.white),
        );
      case FeedbackStatus.rejected:
        return const Chip(
          label: Text('거절됨'),
          backgroundColor: Colors.red,
          labelStyle: TextStyle(color: Colors.white),
          avatar: Icon(Icons.cancel, color: Colors.white),
        );
    }
  }
}
