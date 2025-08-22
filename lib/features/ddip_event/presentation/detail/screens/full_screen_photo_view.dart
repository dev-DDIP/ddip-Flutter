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
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 블러 배경 이미지는 동일
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
            transformationController: _transformationController, // 컨트롤러 연결
            onInteractionEnd: _onInteractionEnd, // ✨ [핵심 수정] 인터랙션 종료 콜백 연결
            panEnabled: true,
            minScale: 1.0,
            maxScale: 4.0,
            boundaryMargin: EdgeInsets.only(
              top:
                  AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top,
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            child: Image.file(File(photo.url), fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }
}

// ▲▲▲ [수정 종료] ▲▲▲
