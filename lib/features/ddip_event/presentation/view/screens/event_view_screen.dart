// lib/features/ddip_event/presentation/view/screens/event_view_screen.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/view/widgets/applicant_list_view.dart';
import 'package:ddip/features/ddip_event/presentation/view/widgets/event_action_button.dart';
import 'package:ddip/features/ddip_event/presentation/view/widgets/event_details_view.dart';
import 'package:ddip/features/ddip_event/presentation/view/widgets/event_map_view.dart';
import 'package:ddip/features/ddip_event/presentation/view/widgets/interaction_timeline_view.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EventViewScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventViewScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventViewScreen> createState() => _EventViewScreenState();
}

class _EventViewScreenState extends ConsumerState<EventViewScreen> {
  // '읽음' 상태를 관리하기 위한 Set은 유지합니다.
  final Set<String> _viewedPhotoIds = {};

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(eventDetailProvider(widget.eventId));
    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentUser = ref.watch(authProvider);
    final isRequester = currentUser?.id == event.requesterId;
    final isSelectable = event.status == DdipEventStatus.open;

    return Scaffold(
      body: Stack(
        children: [
          EventMapView(event: event, viewedPhotoIds: _viewedPhotoIds),
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.15,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 12.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EventDetailsView(event: event),
                          if (isSelectable && event.applicants.isNotEmpty)
                            ApplicantListView(
                              event: event,
                              isRequester: isRequester,
                            ),
                          if (isRequester ||
                              (currentUser != null &&
                                  event.selectedResponderId == currentUser.id))
                            InteractionTimelineView(event: event),
                          const SizedBox(height: 24),
                          EventActionButton(event: event),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.5),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
