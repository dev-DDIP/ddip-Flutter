// lib/features/ddip_event/presentation/view/widgets/photo_detail_panel.dart

import 'dart:io';

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/interaction.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PhotoDetailPanel extends ConsumerStatefulWidget {
  final Photo photo;
  final DdipEvent event;
  final VoidCallback onClose;
  final ScrollController scrollController;

  const PhotoDetailPanel({
    super.key,
    required this.photo,
    required this.event,
    required this.onClose,
    required this.scrollController,
  });

  @override
  ConsumerState<PhotoDetailPanel> createState() => _PhotoDetailPanelState();
}

class _PhotoDetailPanelState extends ConsumerState<PhotoDetailPanel> {
  String? _processingPhotoId;

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
        // 패널을 닫아 이전 화면으로 돌아감
        widget.onClose();
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
    final currentUser = ref.watch(authProvider);
    final isRequester = currentUser?.id == widget.event.requesterId;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: widget.onClose,
                ),
                const Text(
                  "사진 확인",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.photo.url),
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_processingPhotoId == widget.photo.id)
                      const Center(child: CircularProgressIndicator())
                    else if (isRequester &&
                        widget.photo.status == PhotoStatus.pending)
                      _buildActionButtons()
                    else
                      _buildStatusChip(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.thumb_up_alt_outlined),
            label: const Text('승인'),
            onPressed:
                () => _updateStatus(widget.photo.id, PhotoStatus.approved),
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
                  widget.photo.id,
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
  }

  Widget _buildStatusChip() {
    switch (widget.photo.status) {
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
      case PhotoStatus.pending:
      default:
        return const Chip(
          label: Text('요청자 확인 중'),
          backgroundColor: Colors.orange,
          labelStyle: TextStyle(color: Colors.white),
          avatar: Icon(Icons.hourglass_empty, color: Colors.white),
        );
    }
  }
}
