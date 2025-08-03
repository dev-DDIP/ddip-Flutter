// lib/features/map/presentation/widgets/marker_factory.dart
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ddip/features/map/presentation/widgets/cluster_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

/// 지도에 사용될 모든 종류의 마커(NOverlayImage)를 생성하고 캐싱하는 책임을 가지는 클래스입니다.
/// Canvas API와 같은 복잡한 로직을 UI 위젯으로부터 캡슐화합니다.
class MarkerFactory {
  final Map<String, NOverlayImage> _markerIconCache = {};
  final Map<int, NOverlayImage> _clusterIconCache = {};

  // 이벤트 마커 아이콘 생성 로직
  Future<Uint8List> _createFlagMarkerBitmap({required bool isSelected}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final size = const Size(100, 100);
    final color = isSelected ? Colors.purple : Colors.blue;

    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    final borderPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 3,
      borderPaint,
    );

    final icon = Icons.flag;
    final textPainter =
        TextPainter(textDirection: TextDirection.ltr)
          ..text = TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontSize: 50,
              fontFamily: icon.fontFamily,
              color: Colors.white,
            ),
          )
          ..layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  // 사진 마커 아이콘 생성 로직
  Future<Uint8List> _createPhotoMarkerBitmap() async {
    // 사진 마커를 위한 비트맵 생성 로직 (깃발 마커와 유사하게 작성)
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final size = const Size(80, 80);
    final paint =
        Paint()
          ..color = Colors.deepOrange
          ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    final borderPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 2.5,
      borderPaint,
    );

    final icon = Icons.photo_camera;
    final textPainter =
        TextPainter(textDirection: TextDirection.ltr)
          ..text = TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontSize: 40,
              fontFamily: icon.fontFamily,
              color: Colors.white,
            ),
          )
          ..layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  /// 타입과 선택 여부에 따라 마커 아이콘을 가져오거나, 없으면 생성 후 캐싱합니다.
  Future<NOverlayImage> getOrCacheMarkerIcon({
    required String type,
    bool isSelected = false,
  }) async {
    final cacheKey =
        type == 'photo'
            ? 'photo_marker'
            : (isSelected ? 'selected_flag' : 'default_flag');
    if (_markerIconCache.containsKey(cacheKey)) {
      return _markerIconCache[cacheKey]!;
    }

    final iconBitmap =
        type == 'photo'
            ? await _createPhotoMarkerBitmap()
            : await _createFlagMarkerBitmap(isSelected: isSelected);
    final iconImage = await NOverlayImage.fromByteArray(iconBitmap);
    _markerIconCache[cacheKey] = iconImage;
    return iconImage;
  }

  /// 클러스터 마커 아이콘을 가져오거나, 없으면 생성 후 캐싱합니다.
  Future<NOverlayImage> getClusterIcon(int count, BuildContext context) async {
    if (_clusterIconCache.containsKey(count)) {
      return _clusterIconCache[count]!;
    }
    final image = await NOverlayImage.fromWidget(
      widget: Directionality(
        textDirection: TextDirection.ltr,
        child: Material(
          type: MaterialType.transparency,
          child: ClusterMarker(count: count, showText: true),
        ),
      ),
      context: context,
    );
    _clusterIconCache[count] = image;
    return image;
  }
}
