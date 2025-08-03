import 'dart:async';

import 'package:ddip/features/map/presentation/notifiers/map_state_notifier.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class DdipMapView extends ConsumerStatefulWidget {
  final double bottomPadding;
  final VoidCallback? onMapInteraction;

  const DdipMapView({super.key, this.bottomPadding = 0, this.onMapInteraction});

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
    _initializeMapLocation();
  }

  Future<void> _initializeMapLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _initialPosition = NLatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialPosition = const NLatLng(35.890, 128.612); // 경북대학교 기본 위치
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapOverlays = ref.watch(
      mapViewModelProvider.select((state) => state.overlays),
    );

    // 2. cameraUpdate와 같은 '일회성 명령'은 listen을 사용하여 부수 효과(Side Effect)만 처리합니다.
    ref.listen<NCameraUpdate?>(
      mapViewModelProvider.select((state) => state.cameraUpdate),
      (_, next) {
        if (next != null && _mapController != null) {
          _mapController!.updateCamera(next);
          // View가 명령을 수행한 후, ViewModel에 완료되었음을 알립니다.
          ref.read(mapViewModelProvider.notifier).onCameraMoveCompleted();
        }
      },
    );

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

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
        clusterMarkerBuilder: (clusterInfo, clusterMarker) {
          clusterMarker.setAlpha(0);
          clusterMarker.setCaption(const NOverlayCaption(text: ''));

          clusterMarker.setOnTapListener((overlay) {
            ref
                .read(mapStateForViewModelProvider.notifier)
                .drillDownToClusterByInfo(clusterInfo);
          });

          ref
              .read(markerFactoryProvider)
              .getClusterIcon(clusterInfo.size, context)
              .then((image) {
                if (clusterMarker.isAdded) {
                  clusterMarker.setIcon(image);
                  clusterMarker.setAlpha(1);
                }
              });
        },
      ),
      onMapReady: (controller) {
        _mapController = controller;

        // 지도 준비가 완료되면, ViewModel의 현재 오버레이 상태를 즉시 지도에 반영합니다.
        final initialOverlays = ref.read(mapViewModelProvider).overlays;
        controller.addOverlayAll(initialOverlays);

        // 그 이후, ViewModel의 overlays 상태가 변경될 때마다 지도를 업데이트하도록 리스너를 설정합니다.
        ref.listen<Set<NAddableOverlay>>(
          mapViewModelProvider.select((state) => state.overlays),
          (previous, next) {
            // controller가 null이 아닐 때만 실행되도록 보장합니다.
            if (_mapController != null) {
              _mapController!.clearOverlays(); // 이전 오버레이를 모두 지우고
              _mapController!.addOverlayAll(next); // 새로운 오버레이를 모두 추가합니다.
            }
          },
        );
      },
      onMapTapped: (point, latLng) {
        widget.onMapInteraction?.call();
      },
      onCameraChange: (reason, animated) {
        if (reason == NCameraUpdateReason.gesture) {
          widget.onMapInteraction?.call();
        }
      },
    );
  }
}

extension on MapStateNotifier {
  void drillDownToClusterByInfo(NClusterInfo clusterInfo) {
    final bounds = NLatLngBounds.from(
      clusterInfo.children.map((c) => c.position),
    );
    state = MapStateForViewModel(cameraTargetBounds: bounds);
  }
}
