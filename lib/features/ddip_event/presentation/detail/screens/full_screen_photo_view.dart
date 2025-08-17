// [신규] 리팩토링으로 누락되었던 파일을 올바른 경로에 생성
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:ddip/features/auth/providers/auth_provider.dart';
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

  // ▼▼▼ _updateStatus 메서드의 전체 코드를 아래 내용으로 교체합니다. ▼▼▼
  Future<void> _updateStatus(
    PhotoStatus status, {
    String? comment, // [수정] messageCode -> comment
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
            comment: comment, // [수정] messageCode -> comment
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
  // ▲▲▲ _updateStatus 메서드의 전체 코드를 여기까지 교체합니다. ▲▲▲

  // ▼▼▼ _showRejectionReasonDialog 메서드의 전체 코드를 아래 내용으로 교체합니다. ▼▼▼
  /// [교체] 반려 사유를 직접 입력받는 다이얼로그
  Future<String?> _showRejectionReasonDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('사진 반려 사유 입력'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '최초 요청사항과 어떻게 다른지 알려주세요.',
              ),
              autofocus: true,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '반려 사유를 반드시 입력해야 합니다.';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('취소'),
              onPressed: () {
                Navigator.pop(context, null);
              },
            ),
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, controller.text);
                }
              },
            ),
          ],
        );
      },
    );
  }
  // ▲▲▲ _showRejectionReasonDialog 메서드의 전체 코드를 여기까지 교체합니다. ▲▲▲

  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(
      eventDetailViewModelProvider(widget.eventId),
    );
    final currentUser = ref.watch(authProvider);

    return viewModelState.event.when(
      loading:
          () => const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          ),
      error:
          (err, stack) => Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                '오류: $err',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
      data: (event) {
        final photo = event.photos.firstWhereOrNull(
          (p) => p.id == widget.photoId,
        );

        if (photo == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                '사진을 찾을 수 없습니다.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

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
      },
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
                      // ▼▼▼ '거절' 버튼의 onPressed 로직을 수정합니다. ▼▼▼
                      onPressed: () async {
                        final reason = await _showRejectionReasonDialog();
                        if (reason != null) {
                          // 사용자가 취소하지 않은 경우
                          _updateStatus(
                            PhotoStatus.rejected,
                            comment: reason, // [수정] 입력받은 텍스트를 comment로 전달
                          );
                        }
                      },
                      // ▲▲▲ '거절' 버튼의 onPressed 로직을 여기까지 수정합니다. ▲▲▲
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
                      onPressed:
                          () => _updateStatus(
                            PhotoStatus.approved,
                          ), // 승인 시에는 코멘트 없음
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
