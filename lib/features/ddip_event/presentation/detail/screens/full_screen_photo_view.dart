// [신규] 리팩토링으로 누락되었던 파일을 올바른 경로에 생성
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FullScreenPhotoView extends ConsumerStatefulWidget {
  final String eventId;
  final String photoId;
  const FullScreenPhotoView({
    super.key,
    required this.eventId,
    required this.photoId,
  });

  @override
  ConsumerState<FullScreenPhotoView> createState() =>
      _FullScreenPhotoViewState();
}

class _FullScreenPhotoViewState extends ConsumerState<FullScreenPhotoView> {
  bool _isProcessing = false;

  Future<void> _updateStatus(
    PhotoStatus status, {
    MessageCode? messageCode,
  }) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      await ref
          .read(ddipEventsNotifierProvider.notifier)
          .updatePhotoStatus(
            widget.eventId,
            widget.photoId,
            status,
            messageCode: messageCode,
          );
      if (mounted) {
        context.pop(); // 처리가 끝나면 뒤로가기
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('오류: $e')));
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<MessageCode?> _showRejectionReasonDialog() async {
    // 거절 사유 선택 다이얼로그 (내용은 기존과 동일)
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
    final event = ref.watch(eventDetailProvider(widget.eventId));
    if (event == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final photo = event.photos.firstWhereOrNull((p) => p.id == widget.photoId);
    if (photo == null) {
      return const Scaffold(body: Center(child: Text('사진을 찾을 수 없습니다.')));
    }

    final currentUser = ref.watch(authProvider);
    final isRequester = currentUser?.id == event.requesterId;

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
        child: Column(
          children: [
            Expanded(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(child: Image.file(File(photo.url))),
              ),
            ),
            if (isRequester && photo.status == PhotoStatus.pending)
              _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      color: Colors.black.withOpacity(0.5),
      child:
          _isProcessing
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.thumb_down_alt_outlined),
                      label: const Text('거절'),
                      onPressed: () async {
                        final reason = await _showRejectionReasonDialog();
                        if (reason != null) {
                          _updateStatus(
                            PhotoStatus.rejected,
                            messageCode: reason,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.thumb_up_alt_outlined),
                      label: const Text('승인'),
                      onPressed: () => _updateStatus(PhotoStatus.approved),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
