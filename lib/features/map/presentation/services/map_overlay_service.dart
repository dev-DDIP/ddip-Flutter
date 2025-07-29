// lib/features/map/presentation/services/map_overlay_service.dart

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/map/domain/entities/cluster_or_marker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';

class MapOverlayService {
  final BuildContext _context;
  final Map<String, Uint8List> _bitmapCache = {};

  MapOverlayService(this._context);

  /// 지도에 표시될 모든 오버레이를 생성하는 메인 함수
  Future<Map<String, NMarker>> buildOverlays({
    required List<ClusterOrMarker> clustersOrMarkers,
    required void Function(Cluster cluster) onClusterMarkerTap,
    required void Function(String eventId) onEventMarkerTap,
    String? selectedEventId,
  }) async {
    final newMarkers = <String, NMarker>{};

    for (final item in clustersOrMarkers) {
      switch (item) {
        case final Cluster cluster:
          final clusterMarker = await _createClusterMarker(
            cluster,
            () => onClusterMarkerTap(cluster),
          );
          newMarkers[clusterMarker.info.id] = clusterMarker;
          break;
        case final IndividualMarker individualMarker:
          final event = individualMarker.event;
          final isSelected = event.id == selectedEventId;
          final eventMarker = await _createEventMarker(
            event,
            onEventMarkerTap,
            isSelected,
          );
          newMarkers[eventMarker.info.id] = eventMarker;
          break;
      }
    }
    return newMarkers;
  }

  /// 클러스터 마커(숫자 뱃지)를 생성하는 함수
  Future<NMarker> _createClusterMarker(
    Cluster cluster,
    VoidCallback onTap,
  ) async {
    final String cacheKey = 'cluster_${cluster.count}';

    // 1. 캐시에 이미 비트맵 데이터가 있는지 확인
    Uint8List? imageBytes = _bitmapCache[cacheKey];

    // 2. 캐시에 없다면 (최초 생성 시)
    if (imageBytes == null) {
      // 코드로 직접 마커를 그리는 함수 호출
      imageBytes = await _createClusterBitmap(cluster.count);
      // 생성된 비트맵 데이터를 캐시에 저장하여 재사용 준비
      _bitmapCache[cacheKey] = imageBytes;
    }

    // 3. 비트맵 데이터를 사용해 오버레이 이미지 생성 (핵심 변경점)
    final clusterIcon = await NOverlayImage.fromByteArray(imageBytes);

    final markerId = 'cluster_${cluster.events.first.id}';
    final marker = NMarker(
      id: markerId,
      position: cluster.position,
      icon: clusterIcon,
    );
    marker.setOnTapListener((overlay) => onTap());
    return marker;
  }

  Future<Uint8List> _createClusterBitmap(int count) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final size = const Size(120, 120); // 렌더링할 이미지의 해상도

    // 원 배경 그리기
    final paint =
        Paint()
          ..color = Colors.teal
          ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    // 흰색 테두리 그리기
    final borderPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 4,
      borderPaint,
    );

    // 숫자 텍스트 그리기
    final textSpan = TextSpan(
      text: count.toString(),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 52,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    // Canvas에 그린 내용을 이미지로 변환
    final ui.Image image = await pictureRecorder.endRecording().toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final ByteData? byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return byteData!.buffer.asUint8List();
  }

  // --- 헬퍼 함수들 ---

  Future<NMarker> _createEventMarker(
    DdipEvent event,
    void Function(String eventId) onTap,
    bool isSelected,
  ) async {
    final cacheKey =
        isSelected ? 'event_marker_selected' : 'event_marker_default';

    Uint8List? imageBytes = _bitmapCache[cacheKey];

    if (imageBytes == null) {
      imageBytes = await _createEventBitmap(isSelected: isSelected);
      _bitmapCache[cacheKey] = imageBytes;
    }

    final icon = await NOverlayImage.fromByteArray(imageBytes);

    final marker = NMarker(
      id: event.id,
      position: NLatLng(event.latitude, event.longitude),
      icon: icon,
    );
    marker.setZIndex(isSelected ? 15 : 10);
    marker.setOnTapListener((_) => onTap(event.id));
    return marker;
  }

  Future<Uint8List> _createEventBitmap({required bool isSelected}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final size = const Size(100, 100);

    final color = isSelected ? Colors.purple : Colors.blue;

    // 원 배경 그리기
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    // 흰색 테두리 그리기
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

    // 아이콘 그리기 (Icons.flag)
    final icon = Icons.flag;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 50,
        fontFamily: icon.fontFamily,
        color: Colors.white,
      ),
    );
    textPainter.layout();
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

  Future<NMarker> _createMyLocationMarker(Position position) async {
    const cacheKey = 'my_location';
    Uint8List? imageBytes = _bitmapCache[cacheKey];

    if (imageBytes == null) {
      imageBytes = await _createMyLocationBitmap();
      _bitmapCache[cacheKey] = imageBytes;
    }

    final icon = await NOverlayImage.fromByteArray(imageBytes);

    final marker = NMarker(
      id: 'my_location',
      position: NLatLng(position.latitude, position.longitude),
      icon: icon,
    );
    marker.setZIndex(0); // 다른 마커들보다 아래에 있도록 Z-Index를 낮게 설정
    return marker;
  }

  Future<Uint8List> _createMyLocationBitmap() async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final size = const Size(80, 80);

    // 반투명한 보라색 원 그리기 (Pulsing 효과 대신)
    final paint =
        Paint()
          ..color = Colors.purple.withOpacity(0.5)
          ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    // 진한 보라색 테두리
    final borderPaint =
        Paint()
          ..color = Colors.purple
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 2.5,
      borderPaint,
    );

    // 아이콘 그리기 (Icons.my_location)
    final icon = Icons.my_location;
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 40,
        fontFamily: icon.fontFamily,
        color: Colors.purple,
      ),
    );
    textPainter.layout();
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
}
