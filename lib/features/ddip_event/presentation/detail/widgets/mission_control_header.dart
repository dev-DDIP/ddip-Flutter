// ▼▼▼ lib/features/ddip_event/presentation/detail/widgets/mission_control_header.dart (전체 코드 수정) ▼▼▼
import 'dart:async';

import 'package:ddip/features/ddip_event/domain/entities/mission_stage.dart';
import 'package:flutter/material.dart';

/// 상황별 가이드 배너와 타이머를 함께 묶어 표시하는 통합 위젯
class MissionControlHeader extends StatelessWidget {
  final MissionStage stage;

  const MissionControlHeader({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    if (!stage.isActive) {
      return const SizedBox.shrink();
    }

    return Card(
      // ▼▼▼ [수정] 외부 margin을 제거하고, 대신 위쪽에만 패딩을 줍니다.
      margin: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
      // ▲▲▲ [수정]
      elevation: 0,
      color: stage.guideColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: stage.guideColor.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(stage.guideIcon, color: stage.guideColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    stage.guideText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: stage.guideColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _TimerDisplay(
              key: ValueKey(stage.endTime),
              endTime: stage.endTime,
              totalDuration: stage.totalDuration,
            ),
          ],
        ),
      ),
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
              minHeight: 10,
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

// ▲▲▲ lib/features/ddip_event/presentation/detail/widgets/mission_control_header.dart (전체 코드 수정) ▲▲▲
