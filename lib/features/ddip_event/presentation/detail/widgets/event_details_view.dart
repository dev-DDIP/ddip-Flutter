// lib/features/ddip_event/presentation/detail/widgets/event_details_view.dart

import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventDetailsView extends ConsumerWidget {
  final DdipEvent event;
  const EventDetailsView({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // [수정] 이제 이 위젯은 '상세 정보' 탭에 표시될 상세 내용(content) UI만 담당합니다.
    // 제목, 요청자, 보상 등의 정보는 EventBottomSheet의 _FixedHeader로 이동했습니다.
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
        child: Text(
          event.content,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}
