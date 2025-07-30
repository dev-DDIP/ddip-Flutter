// lib/features/map/presentation/widgets/ddip_map_view.dart

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
  // 💡 1. 상세 화면을 위해 특정 이벤트 목록만 받을 수 있는 선택적 파라미터를 추가합니다.
  final List<DdipEvent>? eventsToShow;

  const DdipMapView({super.key, this.eventsToShow});

  @override
  ConsumerState<DdipMapView> createState() => _DdipMapViewState();
}

class _DdipMapViewState extends ConsumerState<DdipMapView> {
  NaverMapController? _mapController;

  // 생성된 NOverlayImage 객체를 저장할 Map을 선언합니다.
  final Map<String, NOverlayImage> _markerIconCache = {};

  // 마커 객체들을 상태로 관리하기 위한 Map 추가
  final Map<String, NClusterableMarker> _currentMarkers = {};

  // 클러스터 아이콘을 캐싱하기 위한 Map 추가
  final Map<int, NOverlayImage> _clusterIconCache = {};

  @override
  void initState() {
    super.initState();
    _getOrCacheMarkerIcon(isSelected: true);
    _getOrCacheMarkerIcon(isSelected: false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Uint8List> _createFlagMarkerBitmap({required bool isSelected}) async {
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

    // 깃발 아이콘 그리기 (Icons.flag)
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

  Future<NOverlayImage> _getOrCacheMarkerIcon({
    required bool isSelected,
  }) async {
    // 캐시 키를 정의합니다 (예: 'default_flag', 'selected_flag')
    final cacheKey = isSelected ? 'selected_flag' : 'default_flag';

    // 1. 캐시에 이미 아이콘이 있는지 확인합니다.
    if (_markerIconCache.containsKey(cacheKey)) {
      // 2. 캐시에 있다면, 즉시 반환합니다. (빠름)
      return _markerIconCache[cacheKey]!;
    }

    // 3. 캐시에 없다면, 비트맵을 새로 생성합니다. (느림, 최초 한 번만 실행됨)
    final iconBitmap = await _createFlagMarkerBitmap(isSelected: isSelected);
    final iconImage = await NOverlayImage.fromByteArray(iconBitmap);

    // 4. 생성된 아이콘을 캐시에 저장합니다.
    _markerIconCache[cacheKey] = iconImage;

    // 5. 생성된 아이콘을 반환합니다.
    return iconImage;
  }

  Future<void> _updateVisibleMarkers({List<DdipEvent>? events}) async {
    if (_mapController == null) return;

    // 파라미터로 받은 events가 있으면 그것을 사용하고, 없으면 Provider에서 전체 목록을 가져옵니다.
    final eventsToDraw =
        events ?? ref.read(ddipEventsNotifierProvider).value ?? [];

    // 💥 기존 마커를 모두 지워 깨끗한 상태에서 시작합니다.
    _mapController!.clearOverlays();
    _currentMarkers.clear();

    if (eventsToDraw.isEmpty) {
      return; // 그릴 마커가 없으면 여기서 종료
    }

    final markers = await Future.wait(
      eventsToDraw.map((event) => _createMarker(event, isSelected: false)),
    );

    for (var marker in markers) {
      _currentMarkers[marker.info.id] = marker;
    }

    _mapController!.addOverlayAll(_currentMarkers.values.toSet());
  }

  Future<NClusterableMarker> _createMarker(
    DdipEvent event, {
    required bool isSelected,
  }) async {
    final iconImage = await _getOrCacheMarkerIcon(isSelected: isSelected);
    final marker = NClusterableMarker(
      id: event.id,
      position: NLatLng(event.latitude, event.longitude),
      icon: iconImage,
    );
    marker.setZIndex(isSelected ? 1 : 0);
    marker.setOnTapListener((_) {
      final currentSelectedId = ref.read(selectedEventIdProvider);
      if (currentSelectedId == event.id) {
        ref.read(feedSheetStrategyProvider.notifier).minimize();
      } else {
        ref.read(feedSheetStrategyProvider.notifier).showOverview(event.id);
      }
    });
    return marker;
  }

  Future<void> _updateMarkerSelection(
    String? previousId,
    String? nextId,
  ) async {
    // 이전 선택 마커를 비선택 상태로 되돌림
    if (previousId != null && _currentMarkers.containsKey(previousId)) {
      final marker = _currentMarkers[previousId]!;
      marker.setIcon(await _getOrCacheMarkerIcon(isSelected: false));
      marker.setZIndex(0);
    }
    // 새 선택 마커를 선택 상태로 변경
    if (nextId != null && _currentMarkers.containsKey(nextId)) {
      final marker = _currentMarkers[nextId]!;
      marker.setIcon(await _getOrCacheMarkerIcon(isSelected: true));
      marker.setZIndex(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 💡 데이터 로딩이 완료되는 시점을 감지하여 마커를 업데이트합니다. (레이스 컨디션 해결)
    ref.listen<AsyncValue<List<DdipEvent>>>(ddipEventsNotifierProvider, (
      previous,
      next,
    ) {
      // 데이터 로딩이 성공적으로 완료되었을 때 한번만 마커를 업데이트합니다.
      if (previous is! AsyncData && next is AsyncData) {
        // 상세 화면처럼 eventsToShow 파라미터가 주어진 경우는 이 로직을 실행하지 않습니다.
        if (widget.eventsToShow == null) {
          _updateVisibleMarkers();
        }
      }
    });

    // 💡 선택된 이벤트 ID가 변경되면 해당 마커 위치로 카메라를 이동시키기 위해 listen합니다.
    ref.listen<String?>(selectedEventIdProvider, (previousId, nextId) {
      if (previousId == nextId) return;
      _updateMarkerSelection(previousId, nextId);
      if (_mapController == null || nextId == null) return;

      final allEvents = ref.read(ddipEventsNotifierProvider).value ?? [];
      final selectedEvent = allEvents.firstWhereOrNull((e) => e.id == nextId);

      if (selectedEvent == null) return;
      final markerLatLng = NLatLng(
        selectedEvent.latitude,
        selectedEvent.longitude,
      );
      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: markerLatLng,
        zoom: 16,
      );

      cameraUpdate.setAnimation(
        animation: NCameraAnimation.easing,
        duration: const Duration(milliseconds: 500),
      );
      _mapController!.updateCamera(cameraUpdate);
    });

    // 💡 MapStateNotifier의 상태를 감시하여, 드릴다운/업에 따른 카메라 이동 및 마커 업데이트를 처리합니다.
    ref.listen<AsyncValue<MapState>>(mapStateNotifierProvider, (_, next) {
      next.whenData((mapState) {
        if (_mapController == null) return;

        // switch 문을 사용하여 상태별로 동작을 명확히 정의합니다.
        switch (mapState) {
          case MapStateRoot():
            // Root 상태일 경우, 전체 마커를 다시 그리고, 저장된 전체 뷰로 카메라 이동
            _updateVisibleMarkers(); // 파라미터 없이 호출 -> 전체 마커
            final rootBounds =
                ref.read(mapStateNotifierProvider.notifier).rootBounds;
            if (rootBounds != null) {
              _mapController!.updateCamera(
                NCameraUpdate.fitBounds(
                  rootBounds,
                  padding: const EdgeInsets.all(50),
                ),
              );
            }
            break;
          case MapStateDrilledDown():
            // DrilledDown 상태일 경우, 클러스터 내부 마커만 그리고, 해당 영역으로 카메라 이동
            _updateVisibleMarkers(
              events: mapState.eventsInCluster,
            ); // 파라미터 전달 -> 일부 마커
            _mapController!.updateCamera(
              NCameraUpdate.fitBounds(
                mapState.bounds,
                padding: const EdgeInsets.all(80),
              ),
            );
            break;
        }
      });
    });

    // 💡 바텀시트 높이 계산 로직
    final sheetFraction = ref.watch(feedSheetStrategyProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomSheetHeight = sheetFraction * screenHeight;

    // 💡 PopScope와 NaverMap 옵션에서 사용할 상태 및 변수들
    final mapState = ref.watch(mapStateNotifierProvider);
    final allEvents =
        widget.eventsToShow ?? ref.read(ddipEventsNotifierProvider).value ?? [];

    return PopScope(
      // Pop 가능 여부도 상태 객체의 타입으로 간단하게 확인할 수 있습니다.
      canPop: mapState.valueOrNull is! MapStateDrilledDown,
      onPopInvoked: (didPop) {
        if (!didPop) {
          ref.read(mapStateNotifierProvider.notifier).drillUp();
        }
      },
      child: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target:
                allEvents.isNotEmpty
                    ? NLatLng(
                      allEvents.first.latitude,
                      allEvents.first.longitude,
                    )
                    : const NLatLng(35.890, 128.612),
            zoom: 15,
          ),
          locationButtonEnable: true,
          // 계산된 높이값을 contentPadding에 직접 적용
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
          clusterMarkerBuilder: (clusterInfo, clusterMarker) async {
            // ... 클러스터 마커 아이콘 생성 로직 ...
            final count = clusterInfo.size;
            NOverlayImage image;
            if (_clusterIconCache.containsKey(count)) {
              image = _clusterIconCache[count]!;
            } else {
              image = await NOverlayImage.fromWidget(
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
            }
            clusterMarker.setIcon(image);
            clusterMarker.setAlpha(1);

            clusterMarker.setOnTapListener((overlay) {
              final List<String> eventIdsInCluster =
                  clusterInfo.children
                      .map((markerInfo) => markerInfo.id)
                      .toList();

              final List<DdipEvent> eventsInCluster =
                  allEvents
                      .where((event) => eventIdsInCluster.contains(event.id))
                      .toList();

              ref
                  .read(mapStateNotifierProvider.notifier)
                  .drillDownToCluster(eventsInCluster);
            });
          },
        ),
        onMapReady: (controller) {
          _mapController = controller;
          // 맵이 준비되면 현재 상태에 맞는 마커를 즉시 그립니다.
          _updateVisibleMarkers();
          // 맵이 준비되면 현재 보이는 영역을 Root 영역으로 저장합니다.
          controller.getContentBounds().then((bounds) {
            ref
                .read(mapStateNotifierProvider.notifier)
                .initializeHistory(bounds);
          });
        },
        onMapTapped: (point, latLng) {
          ref.read(feedSheetStrategyProvider.notifier).minimize();
        },
        onCameraChange: (reason, animated) {
          if (reason == NCameraUpdateReason.gesture) {
            ref.read(feedSheetStrategyProvider.notifier).minimize();
          }
        },
        onCameraIdle: () {
          // 비워둡니다.
        },
      ),
    );
  }
}
