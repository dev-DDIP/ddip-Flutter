// [신규] DraggableScrollableSheet와 그 내용물을 별도 위젯으로 분리
import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/applicant_list_view.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/event_action_button.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/event_details_view.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/interaction_timeline_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventBottomSheet extends ConsumerWidget {
  final DdipEvent event;

  const EventBottomSheet({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    final isRequester = currentUser?.id == event.requesterId;
    final isSelectable = event.status == DdipEventStatus.open;

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.15,
      maxChildSize: 0.9,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10),
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
                      ApplicantListView(event: event, isRequester: isRequester),
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
    );
  }
}
