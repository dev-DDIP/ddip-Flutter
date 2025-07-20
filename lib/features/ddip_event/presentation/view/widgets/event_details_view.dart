// lib/features/ddip_event/presentation/view/widgets/event_details_view.dart

import 'package:flutter/material.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';

class EventDetailsView extends StatelessWidget {
  final DdipEvent event;

  const EventDetailsView({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(event.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.monetization_on_outlined,
              size: 18,
              color: Colors.black54,
            ),
            const SizedBox(width: 4),
            Text('보상: ${event.reward}원', style: const TextStyle(fontSize: 16)),
            const Spacer(),
            const Icon(Icons.person_outline, size: 18, color: Colors.black54),
            const SizedBox(width: 4),
            Text(
              '작성자: ${event.requesterId}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const Divider(height: 32),
        Text(event.content, style: const TextStyle(fontSize: 16, height: 1.5)),
        const SizedBox(height: 24),
      ],
    );
  }
}
