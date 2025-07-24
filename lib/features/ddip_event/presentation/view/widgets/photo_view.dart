import 'dart:io';

import 'package:collection/collection.dart'; // ✨ [추가] firstWhereOrNull을 사용하기 위해 import
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotoView extends ConsumerStatefulWidget {
  final DdipEvent event;
  final bool isRequester;

  const PhotoView({super.key, required this.event, required this.isRequester});

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

            // ✨ [추가] 거절된 사진에 대한 인터랙션 로그를 찾는 로직
            final rejectionInteraction = widget.event.interactions
                .firstWhereOrNull(
                  (interaction) =>
                      interaction.relatedPhotoId == photo.id &&
                      interaction.actionType == ActionType.requestRevision,
                );

            return Card(
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  // ✨ [수정] 이미지를 Stack으로 감싸서 배너를 올릴 수 있도록 함
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.file(
                        File(photo.url),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      // ✨ [추가] 거절 사유가 있을 경우, 정보 배너를 이미지 위에 표시
                      if (rejectionInteraction != null &&
                          rejectionInteraction.messageCode != null)
                        _buildRejectionBanner(
                          rejectionInteraction.messageCode!,
                        ),
                    ],
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

  // ✨ [추가] 거절 사유를 보여주는 배너 위젯
  Widget _buildRejectionBanner(MessageCode code) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconForMessageCode(code),
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  _getTextForMessageCode(code),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(Photo photo, bool isProcessing) {
    if (isProcessing) {
      return const Center(child: CircularProgressIndicator());
    }

    // 현재 사용자가 요청자인 경우에만 버튼을 보여줌
    if (widget.isRequester) {
      switch (photo.status) {
        case PhotoStatus.pending:
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.thumb_up_alt_outlined),
                  label: const Text('승인'),
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
          return const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: Colors.grey, size: 18),
              SizedBox(width: 8),
              Text("피드백이 기록되었습니다.", style: TextStyle(color: Colors.grey)),
            ],
          );
      }
    } else {
      // 수행자인 경우, 버튼 없이 상태 정보만 보여줌
      switch (photo.status) {
        case PhotoStatus.pending:
          return const Chip(
            label: Text('피드백 대기중...'),
            backgroundColor: Colors.orangeAccent,
            labelStyle: TextStyle(color: Colors.white),
            avatar: Icon(Icons.hourglass_top, color: Colors.white),
          );
        case PhotoStatus.approved:
          return const Chip(
            label: Text('승인 완료'),
            backgroundColor: Colors.green,
            labelStyle: TextStyle(color: Colors.white),
            avatar: Icon(Icons.check_circle, color: Colors.white),
          );
        case PhotoStatus.rejected:
          return const Chip(
            label: Text('수정 요청됨'),
            backgroundColor: Colors.red,
            labelStyle: TextStyle(color: Colors.white),
            avatar: Icon(Icons.sync_problem, color: Colors.white),
          );
      }
    }
  }
}
