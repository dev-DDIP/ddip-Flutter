import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController? _controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // 화면이 생성될 때 카메라 초기화를 시작합니다.
  }

  Future<void> _initializeCamera() async {
    try {
      // 1. 사용 가능한 카메라 목록을 가져옵니다.
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        print("사용 가능한 카메라가 없습니다.");
        return;
      }

      // 2. CameraController를 생성합니다. (아직 하드웨어와 연결 전)
      final cameraController = CameraController(
        cameras.first, // 첫 번째 카메라(보통 후면)를 사용
        ResolutionPreset.high,
        enableAudio: false, // 오디오는 필요 없으므로 비활성화
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // 3. 컨트롤러를 실제 하드웨어와 연결(초기화)합니다.
      await cameraController.initialize();

      await cameraController.lockCaptureOrientation(
        DeviceOrientation.portraitUp,
      );

      // 4. 초기화가 성공적으로 끝나면, setState를 호출하여 위젯을 다시 빌드합니다.
      //    mounted 체크는 비동기 작업 후 setState를 안전하게 호출하기 위한 좋은 습관입니다.
      if (mounted) {
        setState(() {
          _controller = cameraController;
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      // 에러가 발생하면 콘솔에 출력합니다.
      print("카메라 초기화 오류: $e");
    }
  }

  @override
  void dispose() {
    // 화면이 사라질 때 컨트롤러를 반드시 dispose하여 리소스를 해제합니다.
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    // 컨트롤러가 준비되지 않았으면 아무것도 하지 않습니다.
    if (_controller == null || !_controller!.value.isInitialized) {
      print('카메라가 준비되지 않았습니다.');
      return;
    }

    try {
      // 사진 촬영 직전에 현재 기기 방향에 맞춰 촬영 방향을 설정합니다.
      // 이렇게 하면 사용자가 폰을 가로로 눕혀 찍어도 사진이 올바르게 저장됩니다.
      final orientation = MediaQuery.of(context).orientation;
      if (orientation == Orientation.landscape) {
        await _controller!.lockCaptureOrientation(
          DeviceOrientation.landscapeLeft,
        );
      } else {
        await _controller!.lockCaptureOrientation(DeviceOrientation.portraitUp);
      }

      // 사진을 찍고, 결과물(XFile)을 받습니다.
      final image = await _controller!.takePicture();

      // TODO: 찍은 사진 처리 (지금은 경로 출력 및 화면 닫기)
      print('사진 찍힘: ${image.path}');
      if (mounted) {
        Navigator.pop(context, image.path);
      }
    } catch (e) {
      print("사진 촬영 오류: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 카메라가 초기화되지 않았다면 로딩 화면을 보여줍니다.
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        // SizedBox.expand를 사용해 자식이 부모의 전체 영역을 차지하도록 함
        child: FittedBox(
          // FittedBox를 사용해 자식의 비율을 유지하면서 부모 영역에 맞춤
          fit: BoxFit.cover, // BoxFit.cover는 비율을 유지하며 꽉 채움 (일부 잘릴 수 있음)
          child: SizedBox(
            // SizedBox로 카메라 프리뷰의 크기를 강제함
            width: _controller!.value.previewSize!.height,
            height: _controller!.value.previewSize!.width,
            child: CameraPreview(_controller!),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture,
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
