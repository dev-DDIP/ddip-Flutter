// lib/features/ddip_event/presentation/view/widgets/photo_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';

class PhotoView extends ConsumerStatefulWidget {
  final DdipEvent event;
  const PhotoView({super.key, required this.event});

  @override
  ConsumerState<PhotoView> createState() => _PhotoViewState();
}

class _PhotoViewState extends ConsumerState<PhotoView> {
  String? _processingPhotoId;

  /// 사진의 상태를 업데이트하는 함수. (승인/거절)
  /// 거절 시에는 선택적으로 messageCode를 함께 전달합니다.
  Future<void> _updateStatus(
    String photoId,
    PhotoStatus status, {
    MessageCode? messageCode,
  }) async {
    if (_processingPhotoId != null) return;

    setState(() {
      _processingPhotoId = photoId;
    });

    try {
      // Notifier를 호출하여 상태 업데이트를 요청합니다.
      await ref
          .read(ddipEventsNotifierProvider.notifier)
          .updatePhotoStatus(
            widget.event.id,
            photoId,
            status,
            messageCode: messageCode,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == PhotoStatus.approved
                  ? '사진을 승인했습니다. 거래가 완료됩니다.'
                  : '사진 거절 및 재요청 사유를 전달했습니다.',
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

  /// 사진 거절 사유를 선택하는 다이얼로그를 띄우는 함수.
  /// 사용자가 선택한 MessageCode를 반환하거나, 취소 시 null을 반환합니다.
  Future<MessageCode?> _showRejectionReasonDialog() async {
    return await showDialog<MessageCode>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('사진 거절 사유 선택'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('사진이 흐려요'),
                  onTap: () => Navigator.pop(context, MessageCode.blurred),
                ),
                ListTile(
                  title: const Text('너무 멀리서 찍었어요'),
                  onTap: () => Navigator.pop(context, MessageCode.tooFar),
                ),
                ListTile(
                  title: const Text('요청한 대상이 아니에요'),
                  onTap: () => Navigator.pop(context, MessageCode.wrongSubject),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.pop(context, null);
              },
            ),
          ],
        );
      },
    );
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
            final isProcessing = _processingPhotoId == photo.id;

            return Card(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  Image.file(
                    File(photo.url),
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

  /// 사진의 상태에 따라 다른 UI (버튼 또는 칩)를 보여주는 위젯 빌더
  Widget _buildFeedbackSection(Photo photo, bool isProcessing) {
    if (isProcessing) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (photo.status) {
      case PhotoStatus.pending:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.thumb_up_alt_outlined),
                label: const Text('승인'),
                onPressed: () => _updateStatus(photo.id, PhotoStatus.approved),
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
                onPressed: () async {
                  final reason = await _showRejectionReasonDialog();
                  if (reason != null) {
                    _updateStatus(
                      photo.id,
                      PhotoStatus.rejected,
                      messageCode: reason,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        );
      case PhotoStatus.approved:
        return const Chip(
          label: Text('승인됨'),
          backgroundColor: Colors.green,
          labelStyle: TextStyle(color: Colors.white),
          avatar: Icon(Icons.check_circle, color: Colors.white),
        );
      case PhotoStatus.rejected:
        return const Chip(
          label: Text('거절됨'),
          backgroundColor: Colors.red,
          labelStyle: TextStyle(color: Colors.white),
          avatar: Icon(Icons.cancel, color: Colors.white),
        );
    }
  }
}
