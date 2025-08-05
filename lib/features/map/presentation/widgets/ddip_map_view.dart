import 'dart:async';

import 'package:ddip/features/map/presentation/notifiers/map_state_notifier.dart';
import 'package:ddip/features/map/presentation/viewmodels/map_view_model.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class DdipMapView extends ConsumerStatefulWidget {
  final double bottomPadding;
  final VoidCallback? onMapInteraction;
  final AutoDisposeStateNotifierProvider<MapViewModel, MapState>
  viewModelProvider;

  const DdipMapView({
    super.key,
    this.bottomPadding = 0,
    this.onMapInteraction,
    required this.viewModelProvider,
  });

  @override
  ConsumerState<DdipMapView> createState() => _DdipMapViewState();
}

class _DdipMapViewState extends ConsumerState<DdipMapView> {
  NaverMapController? _mapController;
  NLatLng? _initialPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // 1. 지도의 초기 위치를 결정합니다.
    try {
      final position = await Geolocator.getCurrentPosition();
      _initialPosition = NLatLng(position.latitude, position.longitude);
    } catch (e) {
      // 위치를 가져올 수 없을 경우 기본 위치(경북대학교)로 설정합니다.
      _initialPosition = const NLatLng(35.890, 128.612);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. GPS 위치 로딩이 끝나지 않았으면, 무조건 로딩 화면을 보여줍니다.
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. ViewModel의 상태 변화를 감지하여 지도 컨트롤러에 명령을 내리는 리스너를 설정합니다.
    //    build 메서드 안에서 listen을 사용하는 것은 일반적으로 권장되지 않지만,
    //    이 경우엔 화면 전환 시 리스너를 재설정해야 하므로 여기에 두는 것이 더 안정적입니다.
    ref.listen<MapState>(widget.viewModelProvider, (previous, next) {
      if (_mapController == null) return;

      final prev = previous ?? const MapState();

      if (prev.overlays != next.overlays) {
        _mapController!.clearOverlays(); // 1. 일단 모두 지운다.
        if (next.overlays.isNotEmpty) {
          _mapController!.addOverlayAll(
            next.overlays,
          ); // 2. ViewModel이 만든 최신 목록으로 전부 다시 그린다.
        }
      }

      // 카메라 이동 명령 실행
      if (next.cameraUpdate != null) {
        _mapController!.updateCamera(next.cameraUpdate!);
        ref.read(widget.viewModelProvider.notifier).onCameraMoveCompleted();
      }
    });

    final viewModel = ref.read(widget.viewModelProvider.notifier);

    return NaverMap(
      options: NaverMapViewOptions(
        initialCameraPosition: NCameraPosition(
          target: _initialPosition!,
          zoom: 15,
        ),
        locationButtonEnable: true,
        contentPadding: EdgeInsets.only(bottom: widget.bottomPadding),
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
          // 1. 깜빡임 방지를 위해 마커를 먼저 투명하게 만듭니다.
          clusterMarker.setAlpha(0);
          // 2. 숫자 겹침을 방지하기 위해 기본 캡션을 비웁니다.
          clusterMarker.setCaption(const NOverlayCaption(text: ''));

          final markerFactory = ref.read(markerFactoryProvider);
          final markerWidget = markerFactory.createClusterMarkerWidget(
            clusterInfo.size,
          );

          // 탭 이벤트와 같은 비즈니스 로직은 ViewModel에 위임합니다.
          clusterMarker.setOnTapListener((_) {
            ref
                .read(mapStateForViewModelProvider.notifier)
                .drillDownToClusterByInfo(clusterInfo);
          });

          // BuildContext가 필요한 최종 렌더링만 View에서 직접 수행합니다.
          final image = await NOverlayImage.fromWidget(
            widget: markerWidget,
            context: context,
          );

          clusterMarker.setIcon(image);
          clusterMarker.setAlpha(1);
        },
      ),
      onMapReady: (controller) {
        setState(() {
          _mapController = controller;
        });
        // 지도가 준비되면, 현재 ViewModel이 가진 초기 마커들을 바로 그려줍니다.
        final initialState = ref.read(widget.viewModelProvider);
        if (initialState.overlays.isNotEmpty) {
          controller.addOverlayAll(initialState.overlays);
        }
      },
      // 사용자 인터랙션은 ViewModel에 '보고'만 합니다.
      onMapTapped: (point, latLng) => viewModel.onMapTapped(),
      onCameraChange: (reason, animated) => viewModel.onCameraChange(reason),
    );
  }
}

// ViewModel에서 클러스터 정보를 이용해 카메라를 이동시키기 위한 확장 함수
extension on MapStateNotifier {
  void drillDownToClusterByInfo(NClusterInfo clusterInfo) {
    final bounds = NLatLngBounds.from(
      clusterInfo.children.map((c) => c.position),
    );
    state = MapStateForViewModel(cameraTargetBounds: bounds);
  }
}
