// ▼▼▼ lib/features/activity/presentation/models/ongoing_mission_summary.dart (파일 전체 교체) ▼▼▼
import 'package:ddip/features/ddip_event/domain/entities/ddip_event.dart';
import 'package:flutter/material.dart';

/// 각 마일스톤 태그의 상태를 상세하게 정의하는 클래스입니다.
@immutable
class MilestoneState {
  final String label; // 태그에 표시될 텍스트 (e.g., "제출", "Q&A", "2차 제출")
  final MilestoneStatus status; // 태그의 시각적 스타일을 결정할 상태

  const MilestoneState({required this.label, required this.status});
}

/// 마일스톤 태그의 4가지 시각적 상태를 정의하는 Enum입니다.
enum MilestoneStatus {
  completed, // 완료됨 (채워진 회색 배경, 체크 아이콘)
  inProgress, // 현재 진행중 (강조된 외곽선)
  pending, // 아직 도달하지 않음 (옅은 회색 외곽선)
  failed, // 실패함 (붉은색 배경, X 아이콘)
}

/// '현재 진행중' 카드 UI를 그리는 데 필요한 모든 정보를 담는 최종 데이터 클래스입니다.
@immutable
class OngoingMissionSummary {
  // --- 카드 상단부 데이터 ---
  final DdipEvent event;
  final String partnerName;

  // --- 카드 중단부 (상태 표시줄) 데이터 ---
  final Color accentColor;
  final IconData guideIcon;
  final String guideText;
  final DateTime? timerEndTime;
  final Duration? timerTotalDuration;

  // --- [핵심 수정] 카드 하단부 (상태 태그 표시기) 데이터 ---
  /// 4개의 마일스톤 각각의 상태를 담는 리스트입니다.
  final List<MilestoneState> milestones;

  const OngoingMissionSummary({
    required this.event,
    required this.partnerName,
    required this.accentColor,
    required this.guideIcon,
    required this.guideText,
    this.timerEndTime,
    this.timerTotalDuration,
    required this.milestones,
  });
}

// ▲▲▲ lib/features/activity/presentation/models/ongoing_mission_summary.dart (파일 전체 교체) ▲▲▲
