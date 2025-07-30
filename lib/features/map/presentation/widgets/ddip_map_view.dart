// lib/features/map/presentation/widgets/ddip_map_view.dart

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/map/presentation/widgets/cluster_marker.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DdipMapView extends ConsumerStatefulWidget {
  final List<DdipEvent> events;

  const DdipMapView({super.key, required this.events});

  @override
  ConsumerState<DdipMapView> createState() => _DdipMapViewState();
}

class _DdipMapViewState extends ConsumerState<DdipMapView> {
  NaverMapController? _mapController;
  EdgeInsets? _currentPadding;

  // 생성된 NOverlayImage 객체를 저장할 Map을 선언합니다.
  final Map<String, NOverlayImage> _markerIconCache = {};

  @override
  void initState() {
    super.initState();
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

  Future<void> _updateAllMarkers() async {
    if (_mapController == null) return;

    // 현재 선택된 이벤트 ID를 가져옵니다.
    final selectedEventId = ref.read(selectedEventIdProvider);

    // Future.wait를 사용하여 모든 마커 아이콘을 병렬로 생성합니다.
    final markers = await Future.wait(
      widget.events.map((event) async {
        final isSelected = event.id == selectedEventId;

        final iconImage = await _getOrCacheMarkerIcon(isSelected: isSelected);

        final marker = NClusterableMarker(
          id: event.id,
          position: NLatLng(event.latitude, event.longitude),
          caption: NOverlayCaption(text: ''),
          // 생성된 깃발 아이콘을 설정합니다.
          icon: iconImage,
        );

        marker.setZIndex(isSelected ? 1 : 0);

        marker.setOnTapListener((_) {
          // 이미 선택된 마커를 다시 탭하면 선택을 해제하고,
          // 다른 마커를 탭하면 해당 마커를 선택합니다.
          if (isSelected) {
            ref.read(selectedEventIdProvider.notifier).state = null;
            ref.read(feedSheetStrategyProvider.notifier).minimize();
          } else {
            ref.read(feedSheetStrategyProvider.notifier).showOverview(event.id);
          }
        });
        return marker;
      }),
    );

    // 기존의 모든 오버레이를 지우고 새로 생성된 마커들을 추가합니다.
    _mapController!.clearOverlays();
    _mapController!.addOverlayAll(markers.toSet());
  }

  @override
  Widget build(BuildContext context) {
    // --- START: 상태 및 프로바이더 감시 ---

    // 바텀시트의 높이가 변할 때마다 지도의 contentPadding을 업데이트하기 위해 listen합니다.
    ref.listen<double>(feedSheetStrategyProvider, (previous, next) {
      if (!mounted) return;

      final screenHeight = MediaQuery.of(context).size.height;
      final newPadding = EdgeInsets.only(bottom: next * screenHeight);

      if (_currentPadding != newPadding) {
        setState(() {
          _currentPadding = newPadding;
        });
      }
    });

    // 선택된 이벤트 ID가 변경되면 해당 마커 위치로 카메라를 이동시키기 위해 listen합니다.
    ref.listen<String?>(selectedEventIdProvider, (previousId, nextId) {
      if (previousId == nextId) return; // 변경이 없으면 무시

      // 마커 아이콘 업데이트
      _updateAllMarkers();

      // 카메라 이동
      if (_mapController == null || nextId == null) return;
      final selectedEvent = widget.events.firstWhereOrNull(
        (e) => e.id == nextId,
      );
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

    // MapStateNotifier의 상태를 감시하여, 드릴다운/업에 따른 카메라 이동을 처리합니다.
    ref.listen<AsyncValue<MapState>>(mapStateNotifierProvider, (_, next) {
      next.whenData((mapState) {
        // bounds 값이 null이 아닐 때만 카메라를 이동시킵니다.
        // 이는 드릴다운/업 같은 특정 '명령'이 있을 때만 카메라를 움직이게 합니다.
        if (_mapController != null && mapState.bounds != null) {
          _mapController!.updateCamera(
            NCameraUpdate.fitBounds(
              mapState.bounds!,
              padding: const EdgeInsets.all(80),
            ),
          );
        }
      });
    });

    // build 메서드 내에서 사용할 현재 상태들을 watch 합니다.
    final mapNotifier = ref.read(mapStateNotifierProvider.notifier);
    final mapState = ref.watch(mapStateNotifierProvider);

    // _currentPadding의 초기값을 설정합니다.
    _currentPadding ??= EdgeInsets.only(
      bottom:
          ref.read(feedSheetStrategyProvider) *
          MediaQuery.of(context).size.height,
    );

    // --- END: 상태 및 프로바이더 감시 ---

    // ================== PopScope: 뒤로가기 제어 ==================
    // 사용자의 뒤로가기 액션을 제어하는 핵심 위젯입니다.
    return PopScope(
      // canPop: 현재 화면을 'pop' (즉, 종료)할 수 있는지 여부를 결정합니다.
      // mapState의 드릴다운 경로가 1개 (최상위 'root') 이하일 때만 pop이 가능합니다.
      // 즉, 클러스터를 파고 들어간 상태에서는 뒤로가기가 앱 종료로 이어지지 않습니다.
      canPop: (mapState.valueOrNull?.drillDownPath.length ?? 0) <= 1,

      // onPopInvoked: 뒤로가기가 시도될 때 호출됩니다.
      // didPop이 false, 즉 canPop이 false라서 화면이 종료되지 않았을 때,
      // 우리는 `mapNotifier.drillUp()`을 호출하여 지도를 이전 뷰(전체 뷰)로 되돌립니다.
      onPopInvoked: (didPop) {
        if (!didPop) {
          mapNotifier.drillUp();
        }
        // TODO: 향후 여기에 '한 번 더 누르면 종료됩니다' 토스트 메시지 로직을 추가할 수 있습니다.
      },
      child: NaverMap(
        // 1. [수정] clusterOptions가 options 밖으로 이동했습니다.
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target:
                widget.events.isNotEmpty
                    ? NLatLng(
                      widget.events.first.latitude,
                      widget.events.first.longitude,
                    )
                    : const NLatLng(35.890, 128.612),
            zoom: 15,
          ),
          locationButtonEnable: true,
          contentPadding: _currentPadding!,
        ),

        // NaverMap 위젯의 독립적인 속성으로 clusterOptions를 배치합니다.
        clusterOptions: NaverMapClusteringOptions(
          // 1단계 요구사항: 상세 뷰에서는 클러스터링 비활성화
          // 네이버 지도의 줌 레벨은 0(가장 멀리) ~ 21(가장 가까이) 입니다.
          // 줌 레벨 0부터 15까지만 클러스터링을 활성화합니다.
          // 즉, 16 이상으로 확대하면 모든 마커가 개별적으로 보입니다.
          enableZoomRange: const NInclusiveRange(0, 15),
          // 2, 3단계 요구사항: 줌 레벨별로 합치는 기준을 다르게 설정
          mergeStrategy: NClusterMergeStrategy(
            // willMergedScreenDistance: 줌 레벨 범위에 따라
            // 마커를 병합할 화면상의 거리(dp)를 다르게 지정합니다.
            // 숫자가 클수록 멀리 있는 마커도 공격적으로 합칩니다.
            willMergedScreenDistance: const {
              NInclusiveRange(15, 15): 70, // 15레벨: 70dp (가장 덜 합침)
              NInclusiveRange(14, 14): 85, // 14레벨: 85dp
              NInclusiveRange(13, 13): 100, // 13레벨: 100dp
              NInclusiveRange(12, 12): 120, // 12레벨: 120dp (점점 더 많이 합침)
              NInclusiveRange(0, 11): 160, // 그 외 낮은 레벨은 가장 공격적으로 합침
            },
          ),
          clusterMarkerBuilder: (clusterInfo, clusterMarker) async {
            // SDK가 자동으로 생성하는 숫자 텍스트(캡션)를 제거합니다.
            // 이렇게 해야 우리가 만든 위젯 아이콘만 깔끔하게 표시됩니다.
            clusterMarker.setIcon(
              await NOverlayImage.fromWidget(
                // ----- START: 텍스트 렌더링 오류 해결 -----
                // Material과 Directionality로 감싸 텍스트 위젯에
                // 올바른 렌더링 컨텍스트를 제공합니다.
                widget: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Material(
                    type: MaterialType.transparency, // 배경이 투명하도록 설정
                    child: ClusterMarker(
                      count: clusterInfo.size,
                      showText: false,
                    ),
                  ),
                ),
                // ----- END: 텍스트 렌더링 오류 해결 -----
                context: context,
              ),
            );

            clusterMarker.setOnTapListener((overlay) {
              final List<String> eventIdsInCluster =
                  clusterInfo.children
                      .map((markerInfo) => markerInfo.id)
                      .toList();

              final List<DdipEvent> events =
                  widget.events
                      .where((event) => eventIdsInCluster.contains(event.id))
                      .toList();

              ref
                  .read(mapStateNotifierProvider.notifier)
                  .drillDownToCluster(events);
            });
            // ----- END: 클러스터 탭 동작 구현 -----
          },
        ),
        onMapReady: (controller) {
          _mapController = controller;
          _updateAllMarkers();
        },
        onMapTapped: (point, latLng) {
          ref.read(feedSheetStrategyProvider.notifier).minimize();
          ref.read(selectedEventIdProvider.notifier).state = null;
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
