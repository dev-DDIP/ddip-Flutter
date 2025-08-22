// lib/features/ddip_event/domain/entities/mission_stage.dart

import 'package:flutter/material.dart';

// ▼▼▼ 새로운 파일을 생성하고 아래 코드를 추가해주세요. ▼▼▼
/// 특정 미션 단계의 모든 UI 상태를 정의하는 불변(immutable) 클래스입니다.
/// 이 클래스 하나로 타이머와 배너의 모든 정보가 결정됩니다.
@immutable
class MissionStage {
  /// 현재 타이머가 활성화 상태인지 여부
  final bool isActive;

  /// 타이머의 전체 시간
  final Duration totalDuration;

  /// 타이머가 끝나야 하는 절대 시간
  final DateTime endTime;

  /// 현재 사용자가 봐야 할 가이드 배너 텍스트
  final String guideText;

  /// 배너에 표시될 아이콘
  final IconData guideIcon;

  /// 배너에 적용될 색상
  final Color guideColor;

  const MissionStage({
    required this.isActive,
    required this.totalDuration,
    required this.endTime,
    required this.guideText,
    required this.guideIcon,
    required this.guideColor,
  });

  // 비어있는 초기 상태를 쉽게 만들기 위한 factory 생성자
  factory MissionStage.inactive() {
    return MissionStage(
      isActive: false,
      totalDuration: Duration.zero,
      endTime: DateTime.now(),
      guideText: '',
      guideIcon: Icons.hourglass_disabled,
      guideColor: Colors.grey,
    );
  }
}

// ▲▲▲ 새로운 파일을 생성하고 위 코드를 추가해주세요. ▲▲▲
