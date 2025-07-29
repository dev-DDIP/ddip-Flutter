// lib/features/ddip_event/presentation/feed/widgets/feed_bottom_sheet.dart

import 'package:collection/collection.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/ddip_list_item.dart';
import 'package:ddip/features/ddip_event/presentation/feed/widgets/event_overview_card.dart';
import 'package:ddip/features/ddip_event/presentation/providers/feed_view_interaction_provider.dart';
import 'package:ddip/features/ddip_event/presentation/strategy/bottom_sheet_strategy.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class FeedBottomSheet extends ConsumerStatefulWidget {
  const FeedBottomSheet({super.key});

  @override
  ConsumerState<FeedBottomSheet> createState() => _FeedBottomSheetState();
}

class _FeedBottomSheetState extends ConsumerState<FeedBottomSheet> {
  final DraggableScrollableController _scrollController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateSheetHeight);
  }

  void _updateSheetHeight() {
    if (!mounted) return;
    final screenHeight = MediaQuery.of(context).size.height;
    final currentPixelHeight = _scrollController.size * screenHeight;
    ref.read(bottomSheetHeightProvider.notifier).state = currentPixelHeight;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateSheetHeight);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<double>(feedSheetStrategyProvider, (previous, next) {
      if ((_scrollController.size - next).abs() < 0.01) return;
      if (_scrollController.isAttached) {
        _scrollController.animateTo(
          next,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });

    final eventsState = ref.watch(ddipEventsNotifierProvider);
    final selectedEventId = ref.watch(selectedEventIdProvider);
    final isEventSelected = selectedEventId != null;

    return DraggableScrollableSheet(
      controller: _scrollController,
      initialChildSize: ref.read(feedSheetStrategyProvider),
      minChildSize: isEventSelected ? peekOverviewFraction : peekFraction,
      maxChildSize: fullListFraction,
      snap: true,
      snapSizes:
          isEventSelected
              ? [peekOverviewFraction, overviewFraction, fullListFraction]
              : [peekFraction, fullListFraction],
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8),
            ],
          ),
          child: eventsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('오류: $err')),
            data: (allEvents) {
              final selectedEvent =
                  selectedEventId != null
                      ? allEvents.firstWhereOrNull(
                        (e) => e.id == selectedEventId,
                      )
                      : null;
              return ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.zero,
                itemCount: selectedEvent != null ? 2 : allEvents.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildHandle();
                  }
                  if (selectedEvent != null) {
                    return EventOverviewCard(
                      event: selectedEvent,
                      onBackToList: () {
                        ref
                            .read(feedSheetStrategyProvider.notifier)
                            .showFullList();
                      },
                      onViewDetails: () {
                        context.push('/feed/${selectedEvent.id}');
                      },
                    );
                  } else {
                    final event = allEvents[index - 1];
                    return DdipListItem(event: event);
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return GestureDetector(
      onTap: () {
        final strategy = ref.read(feedSheetStrategyProvider.notifier);
        final currentHeight = ref.read(feedSheetStrategyProvider);

        if (currentHeight > peekOverviewFraction) {
          strategy.minimize();
        } else {
          strategy.showFullList();
        }
      },
      child: Container(
        width: double.infinity,
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
