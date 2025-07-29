// lib/features/map/presentation/widgets/ddip_map_view.dart

import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
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
  bool _initialCameraFitted = false;
  bool _mapMovedByUser = false;

  EdgeInsets? _currentPadding;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updateMarkers() {
    if (_mapController != null && mounted) {
      ref
          .read(mapStateNotifierProvider.notifier)
          .fetchMarkers(mapController: _mapController!, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<double>(feedSheetStrategyProvider, (previous, next) {
      if (!mounted) return;

      final screenHeight = MediaQuery.of(context).size.height;
      final newPadding = EdgeInsets.only(bottom: next * screenHeight);

      // 불필요한 재빌드를 막기 위해 패딩 값이 실제로 변경되었을 때만 setState를 호출합니다.
      if (_currentPadding != newPadding) {
        setState(() {
          _currentPadding = newPadding;
        });
      }
    });

    ref.listen<String?>(selectedEventIdProvider, (previous, next) {
      if (_mapController == null || next == null || next == previous) return;
      final selectedEvent = widget.events.firstWhereOrNull((e) => e.id == next);
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

    ref.listen<AsyncValue<MapState>>(mapStateNotifierProvider, (_, next) {
      next.when(
        data: (mapState) {
          if (_mapController != null && mounted) {
            _mapController!.clearOverlays();
            _mapController!.addOverlayAll(mapState.markers.values.toSet());
            if (!_initialCameraFitted && mapState.markers.isNotEmpty) {
              final positions =
                  mapState.markers.values.map((m) => m.position).toList();
              final initialBounds = NLatLngBounds.from(positions);
              ref
                  .read(mapStateNotifierProvider.notifier)
                  .initializeHistory(initialBounds);
              _mapController!.updateCamera(
                NCameraUpdate.fitBounds(
                  initialBounds,
                  padding: const EdgeInsets.all(80),
                ),
              );
              _initialCameraFitted = true;
            } else if (mapState.bounds != null) {
              _mapController!.updateCamera(
                NCameraUpdate.fitBounds(
                  mapState.bounds!,
                  padding: const EdgeInsets.all(80),
                ),
              );
            }
          }
        },
        loading: () {},
        error: (e, s) => print("Marker Loading Error: $e"),
      );
    });

    final mapNotifier = ref.read(mapStateNotifierProvider.notifier);
    final mapState = ref.watch(mapStateNotifierProvider);

    _currentPadding ??= EdgeInsets.only(
      bottom:
          ref.read(feedSheetStrategyProvider) *
          MediaQuery.of(context).size.height,
    );

    return PopScope(
      canPop: (mapState.valueOrNull?.drillDownPath.length ?? 0) <= 1,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          mapNotifier.drillUp();
        }
      },
      child: NaverMap(
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
        onMapReady: (controller) {
          _mapController = controller;
          _updateMarkers();
        },
        onMapTapped: (point, latLng) {
          ref.read(feedSheetStrategyProvider.notifier).minimize();
          ref.read(selectedEventIdProvider.notifier).state = null;
        },
        onCameraChange: (reason, animated) {
          if (reason == NCameraUpdateReason.gesture) {
            ref.read(feedSheetStrategyProvider.notifier).minimize();
            _mapMovedByUser = true;
          }
        },
        onCameraIdle: () {
          if (_mapMovedByUser) {
            _updateMarkers();
            _mapMovedByUser = false;
          }
        },
      ),
    );
  }
}
