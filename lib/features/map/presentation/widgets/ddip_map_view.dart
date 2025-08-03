import 'dart:async';

import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/domain/entities/photo.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/map/presentation/manager/map_overlay_manager.dart';
import 'package:ddip/features/map/presentation/viewmodels/map_view_model.dart';
import 'package:ddip/features/map/providers/map_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class DdipMapView extends ConsumerStatefulWidget {
  final List<DdipEvent>? eventsToShow;
  final VoidCallback? onMapInteraction;
  final double bottomPadding;
  final List<Photo>? photosToShow;

  const DdipMapView({
    super.key,
    this.eventsToShow,
    this.onMapInteraction,
    this.bottomPadding = 0,
    this.photosToShow,
  });

  @override
  ConsumerState<DdipMapView> createState() => _DdipMapViewState();
}

class _DdipMapViewState extends ConsumerState<DdipMapView> {
  NaverMapController? _mapController;
  MapOverlayManager? _overlayManager;

  bool _isLoading = true;
  NLatLng? _initialPosition;

  @override
  void initState() {
    super.initState();
    _initializeMapAndLocation();
  }

  @override
  void dispose() {
    _overlayManager?.dispose();
    super.dispose();
  }

  Future<void> _initializeMapAndLocation() async {
    try {
      // 사용자의 현재 위치를 가져옵니다.
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _initialPosition = NLatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
      }
    } catch (e) {
      // 위치를 가져오는 데 실패하면 (예: 권한 거부) 기본 위치(경북대)로 설정합니다.
      if (mounted) {
        setState(() {
          _initialPosition = const NLatLng(35.890, 128.612); // 경북대학교 기본 위치
          _isLoading = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant DdipMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // photosToShow 목록에 변경이 생겼을 때만 사진 마커를 다시 그립니다.
    if (widget.photosToShow != null &&
        !const DeepCollectionEquality().equals(
          widget.photosToShow,
          oldWidget.photosToShow,
        )) {
      _overlayManager?.drawPhotoMarkers(widget.photosToShow!);
    }
  }

  // #endregion
  // =======================================================================

  @override
  Widget build(BuildContext context) {
    // 1. ViewModel의 상태와 notifier를 가져옵니다.
    final mapState = ref.watch(mapViewModelProvider);
    final viewModel = ref.read(mapViewModelProvider.notifier);

    // 2. ViewModel의 상태 변화에 따라 부수 효과(Side Effect)를 처리합니다.
    //    이제 여러 Provider가 아닌, 단 하나의 `mapViewModelProvider`만 감시하면 됩니다.
    ref.listen<MapState>(mapViewModelProvider, (previous, next) {
      // 이벤트 목록이 변경되면 마커를 다시 그립니다.
      if (previous?.events != next.events) {
        _overlayManager?.updateEventMarkers(next.events);
      }
      // 선택된 이벤트가 변경되면 마커 아이콘을 업데이트합니다.
      if (previous?.selectedEventId != next.selectedEventId) {
        _overlayManager?.updateMarkerSelection(
          previous?.selectedEventId,
          next.selectedEventId,
        );
      }
      // 카메라 이동 명령(마커 선택 시)이 있으면 카메라를 움직입니다.
      if (next.cameraUpdate != null) {
        _mapController?.updateCamera(next.cameraUpdate!);
        // 일회성 명령이므로 처리 후 즉시 ViewModel 상태를 초기화합니다.
        viewModel.onCameraMoveCompleted();
      }
      // 카메라 이동 명령(클러스터 탭 시)이 있으면 카메라를 움직입니다.
      if (next.cameraTargetBounds != null) {
        final cameraUpdate = NCameraUpdate.fitBounds(
          next.cameraTargetBounds!,
          padding: const EdgeInsets.all(80),
        )..setAnimation(
          animation: NCameraAnimation.easing,
          duration: const Duration(milliseconds: 300),
        );
        _mapController?.updateCamera(cameraUpdate);
        // 일회성 명령이므로 처리 후 즉시 ViewModel 상태를 초기화합니다.
        viewModel.onCameraMoveCompleted();
      }
    });

    // 3. 초기 위치 로딩 중이면 로딩 인디케이터를 보여줍니다.
    if (_initialPosition == null) {
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
            final eventIdsInCluster =
                clusterInfo.children.map((c) => c.id).toList();
            final eventsInCluster =
                mapState.events
                    .where((e) => eventIdsInCluster.contains(e.id))
                    .toList();

            if (eventsInCluster.isNotEmpty) {
              // 이제 ViewModel을 통해 상태를 변경하는 대신, 기존 Notifier를 직접 호출합니다.
              ref
                  .read(mapStateForViewModelProvider.notifier)
                  .drillDownToCluster(eventsInCluster);
            }
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
      onMapReady: (controller) async {
        _mapController = controller;
        _overlayManager = MapOverlayManager(
          mapController: controller,
          ref: ref,
          markerFactory: ref.read(markerFactoryProvider),
        );

        final locationOverlay = await controller.getLocationOverlay();
        locationOverlay.setIsVisible(true);

        // onMapReady 시점에는 ViewModel의 현재 상태를 사용하여 마커를 그립니다.
        final initialEvents = widget.eventsToShow ?? mapState.events;

        if (initialEvents.isNotEmpty) {
          _overlayManager!.updateEventMarkers(initialEvents);
        }
        if (widget.photosToShow != null && widget.photosToShow!.isNotEmpty) {
          _overlayManager!.drawPhotoMarkers(widget.photosToShow!);
        }
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
