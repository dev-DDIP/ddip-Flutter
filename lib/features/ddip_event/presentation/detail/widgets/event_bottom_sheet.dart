// lib/features/ddip_event/presentation/detail/widgets/event_bottom_sheet.dart

import 'package:ddip/features/auth/providers/auth_provider.dart';
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/applicant_list_view.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/event_action_button.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/event_details_view.dart';
import 'package:ddip/features/ddip_event/presentation/detail/widgets/interaction_timeline_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ========== INSERT: 필요한 컴포넌트와 Provider를 import 합니다. ==========
import 'package:ddip/features/ddip_event/presentation/widgets/multi_stage_bottom_sheet.dart';
import 'package:ddip/features/ddip_event/providers/ddip_event_providers.dart';
import 'package:ddip/features/ddip_event/presentation/strategy/detail_sheet_strategy.dart';
// ===================================================================

class EventBottomSheet extends ConsumerWidget {
  final DdipEvent event;
  const EventBottomSheet({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    final isRequester = currentUser?.id == event.requesterId;
    final isSelectable = event.status == DdipEventStatus.open;

    // ========== MODIFY: 기존 DraggableScrollableSheet를 MultiStageBottomSheet으로 교체합니다. ==========
    return MultiStageBottomSheet(
      // 방금 만든 상세화면용 Strategy Provider를 주입합니다.
      strategyProvider: detailSheetStrategyProvider,
      minSnapSize: detailPeekFraction,
      maxSnapSize: detailFullFraction,
      snapSizes: const [
        detailPeekFraction,
        detailMidFraction,
        detailFullFraction,
      ],
      // builder를 통해 시트 내부에 들어갈 콘텐츠를 동일하게 정의합니다.
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: EdgeInsets.zero,
          children: [
            // 핸들 위젯
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
            // 기존 콘텐츠는 그대로 유지합니다.
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
        );
      },
    );
  }
}
