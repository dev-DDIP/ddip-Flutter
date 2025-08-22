// lib/features/ddip_event/presentation/detail/screens/full_screen_photo_view.dart

import 'dart:io';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ▼▼▼ [수정 시작] 이 클래스 전체를 아래 코드로 교체해주세요. ▼▼▼
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
  late SystemUiOverlayStyle _originalSystemUiStyle;

  // ✨ [핵심 수정] 위치를 제어하고 초기화하기 위해 TransformationController를 다시 사용합니다.
  final TransformationController _transformationController =
      TransformationController();

  bool _isUiVisible = true; // 처음부터 코멘트가 보이도록 true로 시작

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _originalSystemUiStyle = SystemUiOverlayStyle(
        statusBarColor: Theme.of(context).appBarTheme.backgroundColor,
        systemNavigationBarColor: Colors.black,
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(_originalSystemUiStyle);
    _transformationController.dispose(); // 컨트롤러 정리
    super.dispose();
  }

  // ✨ [핵심 로직] 사용자가 화면에서 손을 뗄 때 호출되는 함수
  void _onInteractionEnd(ScaleEndDetails details) {
    // 현재 변환 상태(매트릭스)를 가져옵니다.
    final matrix = _transformationController.value;
    // 매트릭스에서 현재 줌 배율을 추출합니다.
    final currentScale = matrix.getMaxScaleOnAxis();

    // 사용자가 줌 아웃하여 배율이 1.0 이하가 되면,
    if (currentScale <= 1.0) {
      // 컨트롤러의 값을 기본값(Matrix4.identity())으로 리셋합니다.
      // 이것이 이미지를 중앙으로 '스냅' 시키는 역할을 합니다.
      _transformationController.value = Matrix4.identity();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        // 기존: Colors.transparent
        // 수정: 반투명한 검은색으로 변경하여 은은하게 어둡게 만듭니다.
        systemNavigationBarColor: Colors.black.withOpacity(0.1),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    final event = ref.watch(eventDetailProvider(widget.eventId));

    if (event == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final photo = event.photos.firstWhereOrNull((p) => p.id == widget.photoId);

    if (photo == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(
          child: Text('사진을 찾을 수 없습니다.', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. 블러 처리된 배경 이미지
          Image.file(
            File(photo.url),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),

          InteractiveViewer(
            transformationController: _transformationController,
            onInteractionEnd: _onInteractionEnd,
            panEnabled: true,
            minScale: 1.0,
            maxScale: 4.0,
            boundaryMargin: EdgeInsets.zero,
            // boundaryMargin은 사진 전체를 볼 수 있도록 zero로 설정
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isUiVisible = !_isUiVisible;
                });
              },
              child: Center(
                // 이미지를 중앙에 배치하기 위해 Center 위젯 사용
                child: Image.file(File(photo.url), fit: BoxFit.contain),
              ),
            ),
          ),

          // 3. AppBar (닫기 버튼) - 이전 단계에서 수정한 구조 유지
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            // UI가 보이지 않을 때( !_isUiVisible ) 터치 이벤트를 무시(ignoring: true)합니다.
            child: IgnorePointer(
              ignoring: !_isUiVisible,
              child: AnimatedOpacity(
                opacity: _isUiVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
            ),
          ),

          // 4. 코멘트 오버레이 (코멘트가 있을 때만 위젯을 빌드합니다)
          if (photo.responderComment != null &&
              photo.responderComment!.isNotEmpty)
            _buildCommentOverlay(photo.responderComment!),
        ],
      ),
    );
  }

  Widget _buildCommentOverlay(String comment) {
    return IgnorePointer(
      ignoring: !_isUiVisible,
      child: AnimatedOpacity(
        opacity: _isUiVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).padding.bottom + 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.0),
                ],
              ),
            ),
            child: Text(
              comment,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ▲▲▲ 4. 코멘트를 화면 하단에 표시하는 새로운 메서드를 추가합니다. ▲▲▲
}
