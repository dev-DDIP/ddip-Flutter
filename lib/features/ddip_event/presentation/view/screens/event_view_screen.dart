// lib/features/ddip_event/presentation/view/screens/event_view_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ddip/features/ddip_event/presentation/view/providers/event_view_provider.dart';
import '../widgets/event_details_view.dart';
import '../widgets/event_map_view.dart';
import '../widgets/event_action_button.dart';

class EventViewScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventViewScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventViewScreen> createState() => _EventViewScreenState();
}

class _EventViewScreenState extends ConsumerState<EventViewScreen> {
  bool _showFullScreenImage = false;

  @override
  Widget build(BuildContext context) {
    final eventState = ref.watch(eventViewProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('요청 정보')),
      body: eventState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('오류가 발생했습니다: $error')),
        data: (event) {
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    EventDetailsView(event: event),
                    Expanded(
                      child: EventMapView(
                        event: event,
                        onMarkerTapped: () {
                          setState(() => _showFullScreenImage = true);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    EventActionButton(event: event),
                  ],
                ),
              ),
              if (_showFullScreenImage && event.responsePhotoUrl != null)
                GestureDetector(
                  onTap: () => setState(() => _showFullScreenImage = false),
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    alignment: Alignment.center,
                    child: Image.file(File(event.responsePhotoUrl!)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
