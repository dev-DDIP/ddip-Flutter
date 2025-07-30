import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/map/presentation/widgets/cluster_marker.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DdipMapView extends ConsumerStatefulWidget {
  final List<DdipEvent>? eventsToShow;

  const DdipMapView({super.key, this.eventsToShow});

  @override
  ConsumerState<DdipMapView> createState() => _DdipMapViewState();
}

class _DdipMapViewState extends ConsumerState<DdipMapView> {
  NaverMapController? _mapController;
  final Map<String, NOverlayImage> _markerIconCache = {};
  final Map<int, NOverlayImage> _clusterIconCache = {};

  // 📌 개별 마커의 선택 상태를 업데이트하기 위해 마커 객체 참조를 저장하는 Map이 다시 필요합니다.
  final Map<String, NClusterableMarker> _currentMarkers = {};

  @override
  void initState() {
    super.initState();
    _getOrCacheMarkerIcon(isSelected: true);
    _getOrCacheMarkerIcon(isSelected: false);
  }

  // =======================================================================
  // #region 마커 아이콘 생성 및 캐싱 헬퍼 메서드 (수정 없음)
  // =======================================================================
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

  Future<NOverlayImage> _getOrCacheMarkerIcon({
    required bool isSelected,
  }) async {
    final cacheKey = isSelected ? 'selected_flag' : 'default_flag';
    if (_markerIconCache.containsKey(cacheKey)) {
      return _markerIconCache[cacheKey]!;
    }
    final iconBitmap = await _createFlagMarkerBitmap(isSelected: isSelected);
    final iconImage = await NOverlayImage.fromByteArray(iconBitmap);
    _markerIconCache[cacheKey] = iconImage;
    return iconImage;
  }

  Future<NOverlayImage> _getClusterIcon(int count, BuildContext context) async {
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

  // #endregion
  // =======================================================================

  // =======================================================================
  // #region 마커 상태 관리 메서드
  // =======================================================================
  Future<void> _drawInitialMarkers(List<DdipEvent> events) async {
    if (_mapController == null) return;
    _mapController!.clearOverlays();
    _currentMarkers.clear();

    final markers = await Future.wait(
      events.map((event) async {
        final icon = await _getOrCacheMarkerIcon(isSelected: false);
        final marker = NClusterableMarker(
          id: event.id,
          position: NLatLng(event.latitude, event.longitude),
          icon: icon,
        );
        marker.setOnTapListener((_) {
          ref.read(feedSheetStrategyProvider.notifier).showOverview(event.id);
        });
        return marker;
      }),
    );

    for (var marker in markers) {
      _currentMarkers[marker.info.id] = marker;
    }
    _mapController!.addOverlayAll(_currentMarkers.values.toSet());
  }

  // 📌 목록에서 이벤트를 선택했을 때 마커 아이콘을 변경하기 위한 메서드
  Future<void> _updateMarkerSelection(
    String? previousId,
    String? nextId,
  ) async {
    if (previousId != null && _currentMarkers.containsKey(previousId)) {
      final marker = _currentMarkers[previousId]!;
      marker.setIcon(await _getOrCacheMarkerIcon(isSelected: false));
      marker.setZIndex(0);
    }
    if (nextId != null && _currentMarkers.containsKey(nextId)) {
      final marker = _currentMarkers[nextId]!;
      marker.setIcon(await _getOrCacheMarkerIcon(isSelected: true));
      marker.setZIndex(1);
    }
  }

  // #endregion
  // =======================================================================

  @override
  Widget build(BuildContext context) {
    // ------------------- Provider Listeners for Side Effects -------------------
    ref.listen<AsyncValue<List<DdipEvent>>>(ddipEventsNotifierProvider, (
      prev,
      next,
    ) {
      if (_mapController != null && next is AsyncData) {
        if (widget.eventsToShow == null) {
          _drawInitialMarkers(next.value ?? []);
        }
      }
    });

    ref.listen<String?>(selectedEventIdProvider, (previousId, nextId) {
      if (previousId == nextId) return;
      _updateMarkerSelection(previousId, nextId);

      if (_mapController == null || nextId == null) return;
      final allEvents = ref.read(ddipEventsNotifierProvider).value ?? [];
      final selectedEvent = allEvents.firstWhereOrNull((e) => e.id == nextId);
      if (selectedEvent == null) return;

      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: NLatLng(selectedEvent.latitude, selectedEvent.longitude),
        zoom: 16,
      )..setAnimation(
        animation: NCameraAnimation.easing,
        duration: const Duration(milliseconds: 500),
      );
      _mapController!.updateCamera(cameraUpdate);
    });

    ref.listen<MapState>(mapStateNotifierProvider, (previous, next) {
      if (next.cameraTargetBounds != null) {
        final cameraUpdate = NCameraUpdate.fitBounds(
          next.cameraTargetBounds!,
          padding: const EdgeInsets.all(80),
        )..setAnimation(
          animation: NCameraAnimation.easing,
          duration: const Duration(milliseconds: 300),
        );
        _mapController?.updateCamera(cameraUpdate);
        ref.read(mapStateNotifierProvider.notifier).completeCameraMove();
      }
    });
    // -------------------------------------------------------------------------

    final allEvents =
        widget.eventsToShow ??
        ref.watch(ddipEventsNotifierProvider).value ??
        [];
    final sheetFraction = ref.watch(feedSheetStrategyProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = sheetFraction * screenHeight;

    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target:
              allEvents.isNotEmpty
                  ? NLatLng(allEvents.first.latitude, allEvents.first.longitude)
                  : const NLatLng(35.890, 128.612),
          zoom: 15,
        ),
        locationButtonEnable: true,
        contentPadding: EdgeInsets.only(bottom: bottomSheetHeight),
      ),
      clusterOptions: NaverMapClusteringOptions(
        enableZoomRange: const NInclusiveRange(0, 15),
        mergeStrategy: NClusterMergeStrategy(
          willMergedScreenDistance: const {
            NInclusiveRange(15, 15): 70,
            NInclusiveRange(14, 14): 85,
            NInclusiveRange(13, 13): 100,
            NInclusiveRange(12, 12): 120,
            NInclusiveRange(0, 11): 160,
          },
        ),
        clusterMarkerBuilder: (clusterInfo, clusterMarker) {
          // [수정 1] 깜빡임 문제 해결: 빌더가 호출되는 즉시 마커를 투명하게 만듭니다.
          clusterMarker.setAlpha(0);
          // [수정 2] 숫자 겹침 문제 해결: SDK 기본 캡션을 빈 값으로 덮어씁니다.
          clusterMarker.setCaption(const NOverlayCaption(text: ''));

          // 📌 탭 리스너를 동기적으로 먼저 설정
          clusterMarker.setOnTapListener((overlay) {
            final currentEvents =
                ref.read(ddipEventsNotifierProvider).value ?? [];
            final eventIdsInCluster =
                clusterInfo.children.map((c) => c.id).toList();
            final eventsInCluster =
                currentEvents
                    .where((e) => eventIdsInCluster.contains(e.id))
                    .toList();

            if (eventsInCluster.isNotEmpty) {
              ref
                  .read(mapStateNotifierProvider.notifier)
                  .drillDownToCluster(eventsInCluster);
            }
          });
          // 📌 아이콘 설정은 비동기적으로 나중에 처리
          _getClusterIcon(clusterInfo.size, context).then((image) {
            if (clusterMarker.isAdded) {
              clusterMarker.setIcon(image);
              // [수정 3] 깜빡임 문제 해결: 커스텀 아이콘 준비가 끝나면 다시 불투명하게 만듭니다.
              clusterMarker.setAlpha(1);
            }
          });
        },
      ),
      onMapReady: (controller) async {
        _mapController = controller;
        final initialEvents =
            widget.eventsToShow ??
            ref.read(ddipEventsNotifierProvider).value ??
            [];
        if (initialEvents.isNotEmpty) {
          _drawInitialMarkers(initialEvents);
        }
      },
      onMapTapped: (point, latLng) {
        ref.read(feedSheetStrategyProvider.notifier).minimize();
      },
      onCameraChange: (reason, animated) {
        if (reason == NCameraUpdateReason.gesture) {
          ref.read(feedSheetStrategyProvider.notifier).minimize();
        }
      },
    );
  }
}
