// lib/features/ddip_event/presentation/detail/widgets/mission_control_header.dart
import 'dart:async';
import 'package:ddip/features/ddip_event/domain/entities/mission_stage.dart';
import 'package:flutter/material.dart';

// ▼▼▼ 새로운 파일을 생성하고 아래 코드를 추가해주세요. ▼▼▼
/// 상황별 가이드 배너와 타이머를 함께 묶어 표시하는 통합 위젯
class MissionControlHeader extends StatelessWidget {
  final MissionStage stage;
  const MissionControlHeader({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    // 타이머가 비활성 상태이면 아무것도 그리지 않습니다.
    if (!stage.isActive) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        // 1. 상황별 가이드 배너 (고강조 스타일 적용)
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: stage.guideColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: stage.guideColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(stage.guideIcon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  stage.guideText,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 2. 타이머 디스플레이
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _TimerDisplay(
            key: ValueKey(stage.endTime), // endTime이 바뀌면 타이머를 새로 그리도록 key 설정
            endTime: stage.endTime,
            totalDuration: stage.totalDuration,
          ),
        ),
      ],
    );
  }
}

/// 남은 시간을 시각적으로 표시하는 타이머 위젯
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
    final totalSeconds = widget.totalDuration.inSeconds;
    final remainingSeconds = _remaining.inSeconds;
    final progress =
        totalSeconds > 0
            ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0)
            : 0.0;

    final minutes = _remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = remainingSeconds.remainder(60).toString().padLeft(2, '0');
    final timeString = '$minutes:$seconds';

    final barColor =
        progress < 0.2
            ? Colors.red
            : (progress < 0.5 ? Colors.orange : Colors.blue);

    return Row(
      children: [
        Icon(Icons.timer_outlined, color: Colors.grey.shade600, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          timeString,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}

// ▲▲▲ 새로운 파일을 생성하고 위 코드를 추가해주세요. ▲▲▲
