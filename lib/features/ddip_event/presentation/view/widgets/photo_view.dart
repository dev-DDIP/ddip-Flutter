import 'dart:io';

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotoView extends ConsumerStatefulWidget {
  final DdipEvent event;

  const PhotoView({super.key, required this.event});

  @override
  ConsumerState<PhotoView> createState() => _PhotoViewState();
}

class _PhotoViewState extends ConsumerState<PhotoView> {
  String? _processingPhotoId;

  // ✨ [수정] 함수 정의를 이름 기반(named) 파라미터로 변경
  Future<void> _updateStatus({
    required String photoId,
    required PhotoStatus status,
    MessageCode? messageCode,
  }) async {
    if (_processingPhotoId != null) return;
    setState(() {
      _processingPhotoId = photoId;
    });
    try {
      // ✨ [수정] Notifier 호출 시 이름 기반 파라미터 사용
      await ref
          .read(ddipEventsNotifierProvider.notifier)
          .updatePhotoStatus(widget.event.id, photoId, status, messageCode);
      if (mounted) {
        final message =
            status == PhotoStatus.approved
                ? '사진을 승인했습니다. 거래가 완료됩니다.'
                : '사진을 거절하고 재요청했습니다.';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류가 발생했습니다: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _processingPhotoId = null);
      }
    }
  }

  void _showRejectionReasons(String photoId) {
    final rejectionCodes = [
      MessageCode.blurred,
      MessageCode.tooFar,
      MessageCode.wrongSubject,
    ];

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children:
                rejectionCodes.map((code) {
                  return ListTile(
                    leading: Icon(_getIconForMessageCode(code)),
                    title: Text(_getTextForMessageCode(code)),
                    onTap: () {
                      Navigator.pop(context);
                      // ✨ [수정] 함수 호출을 이름 기반 파라미터 형식으로 변경 (이 부분은 이미 올바르게 되어 있었음)
                      _updateStatus(
                        photoId: photoId,
                        status: PhotoStatus.rejected,
                        messageCode: code,
                      );
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  String _getTextForMessageCode(MessageCode code) {
    switch (code) {
      case MessageCode.blurred:
        return "사진이 흐려요. 다시 찍어주세요.";
      case MessageCode.tooFar:
        return "너무 멀어요. 가까이서 찍어주세요.";
      case MessageCode.wrongSubject:
        return "요청한 대상이 아니에요.";
      default:
        return "기타";
    }
  }

  IconData _getIconForMessageCode(MessageCode code) {
    switch (code) {
      case MessageCode.blurred:
        return Icons.blur_on;
      case MessageCode.tooFar:
        return Icons.zoom_in;
      case MessageCode.wrongSubject:
        return Icons.wrong_location;
      default:
        return Icons.help_outline;
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
                // ✨ [수정] 함수 호출을 이름 기반 파라미터로 변경하고, messageCode는 필요 없으므로 생략
                onPressed:
                    () => _updateStatus(
                      photoId: photo.id,
                      status: PhotoStatus.approved,
                    ),
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
                // ✨ [수정] 거절 버튼은 Bottom Sheet를 띄우는 `_showRejectionReasons` 함수를 호출하도록 수정
                onPressed: () => _showRejectionReasons(photo.id),
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
