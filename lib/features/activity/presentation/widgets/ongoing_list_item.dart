// ▼▼▼ lib/features/activity/presentation/widgets/ongoing_list_item.dart (파일 전체 교체) ▼▼▼
import 'dart:async';

import 'package:ddip/features/activity/presentation/models/ongoing_mission_summary.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// '현재 진행중' 탭에 표시될 개별 미션 카드를 그리는 최종 위젯입니다.
class OngoingListItem extends StatelessWidget {
  final OngoingMissionSummary summary;

  const OngoingListItem({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push('/feed/${summary.event.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildStatusBar(context),
              const SizedBox(height: 16),
              // ★★★ 핵심 수정: 새로운 상태 기반 태그 표시기를 호출합니다. ★★★
              _buildMilestoneIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  /// [상단] 미션 개요 UI를 빌드합니다.
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary.event.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                '파트너: ${summary.partnerName}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '${NumberFormat('#,###').format(summary.event.reward)}원',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  /// [중단] 상태 표시줄 UI를 빌드합니다.
  Widget _buildStatusBar(BuildContext context) {
    // 타이머가 없는 경우(e.g., 미션 종료) 빈 위젯을 반환합니다.
    if (summary.timerEndTime == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: summary.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(summary.guideIcon, color: summary.accentColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              summary.guideText,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: summary.accentColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          // 디테일 화면의 타이머 로직을 재사용합니다.
          // 참고: 이 _TimerDisplay 위젯은 이상적으로는 별도의 공용 파일로 분리하여
          // mission_control_header.dart와 이 파일 양쪽에서 import하여 사용하는 것이 좋습니다.
          _TimerDisplay(
            key: ValueKey(
              summary.timerEndTime,
            ), // Key를 주어 상태 변경 시 위젯을 새로 그리도록 함
            endTime: summary.timerEndTime!,
            totalDuration: summary.timerTotalDuration!,
          ),
        ],
      ),
    );
  }

  /// [하단] 상태 기반 태그 표시기 UI를 빌드합니다.
  Widget _buildMilestoneIndicator() {
    return Row(
      children: List.generate(summary.milestones.length * 2 - 1, (index) {
        if (index.isEven) {
          // 짝수 인덱스는 마일스톤 태그
          final milestone = summary.milestones[index ~/ 2];
          return Expanded(child: _MilestoneTag(state: milestone));
        } else {
          // 홀수 인덱스는 연결선
          return const _Connector();
        }
      }),
    );
  }
}

/// 마일스톤 태그 하나를 그리는 위젯
class _MilestoneTag extends StatelessWidget {
  final MilestoneState state;
  const _MilestoneTag({required this.state});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Colors.transparent;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.grey.shade500;
    FontWeight fontWeight = FontWeight.normal;
    Widget? icon;

    switch (state.status) {
      case MilestoneStatus.completed:
        backgroundColor = Colors.grey.shade200;
        borderColor = Colors.grey.shade300;
        textColor = Colors.grey.shade700;
        icon = Icon(Icons.check, size: 14, color: textColor);
        break;
      case MilestoneStatus.inProgress:
        borderColor = Theme.of(context).primaryColor;
        textColor = Theme.of(context).primaryColor;
        fontWeight = FontWeight.bold;
        break;
      case MilestoneStatus.pending:
        // 기본값 사용
        break;
      case MilestoneStatus.failed:
        backgroundColor = Colors.red.shade100;
        borderColor = Colors.red.shade200;
        textColor = Colors.red.shade800;
        fontWeight = FontWeight.bold;
        icon = Icon(Icons.close, size: 14, color: textColor);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[icon, const SizedBox(width: 4)],
          Flexible(
            child: Text(
              state.label,
              style: TextStyle(
                fontSize: 11,
                color: textColor,
                fontWeight: fontWeight,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// 태그 사이의 연결선(---)을 그리는 위젯
class _Connector extends StatelessWidget {
  const _Connector();
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Container(width: 10, height: 1, color: Colors.grey.shade300),
      ),
    );
  }
}

/// 남은 시간을 시각적으로 표시하는 타이머 위젯 (mission_control_header.dart에서 가져옴)
class _TimerDisplay extends StatefulWidget {
  final DateTime endTime;
  final Duration totalDuration;

  const _TimerDisplay({
    super.key,
    required this.endTime,
    required this.totalDuration,
  });

  @override
  State<_TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<_TimerDisplay> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    if (!mounted) return;
    final now = DateTime.now();
    final remaining = widget.endTime.difference(now);
    setState(() {
      _remaining = remaining.isNegative ? Duration.zero : remaining;
    });
    if (remaining.isNegative) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remainingSeconds = _remaining.inSeconds;
    final minutes = _remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = remainingSeconds.remainder(60).toString().padLeft(2, '0');
    final timeString = '$minutes:$seconds';
    final isUrgent = remainingSeconds < 60; // 1분 미만일 때 긴급 상태로 간주

    return Text(
      timeString,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 15,
        color:
            isUrgent
                ? Colors.red
                : Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }
}

// ▲▲▲ lib/features/activity/presentation/widgets/ongoing_list_item.dart (파일 전체 교체) ▲▲▲
