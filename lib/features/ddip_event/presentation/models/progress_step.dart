// ▼▼▼ lib/features/ddip_event/presentation/models/progress_step.dart ▼▼▼
import 'package:flutter/material.dart';

/// 프로그레스 바 각 단계의 논리적 상태를 상세하게 정의하는 Enum
enum StepStatus {
  // --- 과거 상태 (완료된 단계) ---
  success, // 성공적으로 완료 (✅ 아이콘)
  rejected, // 반려 또는 거절됨 (❌ 아이콘)
  stopped, // 중단 또는 취소됨 (🛑 아이콘)
  question, // 질문으로 인해 완료됨 (✅ (질문) 텍스트)
  // --- 현재 및 미래 상태 ---
  current, // 현재 진행중 (강조 표시)
  future, // 예정 (흐린 표시)
}

/// 예측적 슬라이딩 윈도우의 한 칸을 구성하는 데이터 모델 클래스
@immutable
class ProgressStep {
  final String label;
  final StepStatus status;

  /// 이 단계가 '?'로 표시되어야 하는지 결정하는 플래그입니다.
  final bool isPredictive;
  final IconData icon;

  const ProgressStep({
    required this.label,
    required this.status,
    this.isPredictive = false,
    required this.icon,
  });
}

// ▲▲▲ lib/features/ddip_event/presentation/models/progress_step.dart ▲▲▲
