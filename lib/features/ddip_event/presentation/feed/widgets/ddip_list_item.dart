import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:flutter/material.dart';

class DdipListItem extends StatelessWidget {
  final DdipEvent event;

  const DdipListItem({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(event.title),
      subtitle: Text('보상: ${event.reward}원'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // TODO: 상세 화면으로 이동하는 로직 구현
      },
    );
  }
}