// ▼▼▼ lib/features/ddip_event/presentation/widgets/predictive_progress_bar.dart (전체 코드) ▼▼▼
import 'package:ddip/features/ddip_event/presentation/models/progress_step.dart';
import 'package:flutter/material.dart';

/// ViewModel로부터 List<ProgressStep>을 받아
/// 예측적 슬라이딩 윈도우 UI를 그리는 전용 위젯입니다.
class PredictiveProgressBar extends StatelessWidget {
  final List<ProgressStep> steps;

  const PredictiveProgressBar({super.key, required this.steps});

  /// StepStatus로부터 색상을 결정하는 헬퍼 메서드
  Color _getColor(BuildContext context, StepStatus status) {
    switch (status) {
      case StepStatus.success:
      case StepStatus.question:
        return Colors.green;
      case StepStatus.rejected:
        return Colors.red;
      case StepStatus.stopped:
        return Colors.grey.shade600;
      case StepStatus.current:
        return Theme.of(context).primaryColor;
      case StepStatus.future:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 4개의 step이 없으면 아무것도 그리지 않아 오류를 방지합니다.
    if (steps.length != 4) {
      return const SizedBox.shrink();
    }

    // 위젯 리스트를 동적으로 생성
    final List<Widget> children = [];
    for (int i = 0; i < steps.length; i++) {
      final step = steps[i];
      final color = _getColor(context, step.status);

      // Step 아이템 추가
      children.add(
        Expanded(
          flex: 3, // 아이템 영역을 더 넓게
          child: _StepItem(step: step, color: color),
        ),
      );

      // 마지막 아이템이 아니면 연결선 추가
      if (i < steps.length - 1) {
        final nextStep = steps[i + 1];
        final nextColor = _getColor(context, nextStep.status);
        children.add(
          Expanded(
            flex: 2, // 연결선 영역
            child: _Connector(startColor: color, endColor: nextColor),
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// 그라데이션 연결선을 그리는 위젯
class _Connector extends StatelessWidget {
  final Color startColor;
  final Color endColor;

  const _Connector({required this.startColor, required this.endColor});

  @override
  Widget build(BuildContext context) {
    // _StepItem의 아이콘 높이(28)와 위아래 패딩을 고려하여 아이콘 중앙에 선이 오도록 함
    return Padding(
      padding: const EdgeInsets.only(top: 14.0), // 아이콘 크기의 절반
      child: Column(
        children: [
          Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [startColor, endColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          // 아이콘 아래 텍스트 영역만큼 공간을 확보하여 높이를 맞춤
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

/// 프로그레스 바의 각 칸(아이템)을 그리는 위젯
class _StepItem extends StatelessWidget {
  final ProgressStep step;
  final Color color;

  const _StepItem({required this.step, required this.color});

  @override
  Widget build(BuildContext context) {
    // isPredictive 플래그가 true이면 물음표 UI를 렌더링
    if (step.isPredictive) {
      return _buildPredictiveStep(context);
    }

    IconData displayIcon;
    FontWeight fontWeight = FontWeight.normal;
    Color textColor = Colors.grey;

    // 상태에 따라 표시할 아이콘과 스타일 결정
    switch (step.status) {
      case StepStatus.success:
      case StepStatus.question:
        displayIcon = Icons.check_circle;
        textColor = Colors.black87;
        break;
      case StepStatus.rejected:
        displayIcon = Icons.cancel;
        textColor = Colors.black87;
        break;
      case StepStatus.stopped:
        displayIcon = Icons.stop_circle;
        textColor = Colors.black87;
        break;
      case StepStatus.current:
        displayIcon = step.icon; // 현재 단계는 고유 아이콘 사용
        fontWeight = FontWeight.bold;
        textColor = color;
        break;
      case StepStatus.future:
        displayIcon = step.icon; // 미래 단계도 고유 아이콘 사용
        break;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(displayIcon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(
          step.label,
          style: TextStyle(
            fontSize: 12,
            color: textColor,
            fontWeight: fontWeight,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// '?' 예측 단계를 그리는 별도 메서드
  Widget _buildPredictiveStep(BuildContext context) {
    final color = Colors.grey.shade300;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              '?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          step.label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ▲▲▲ lib/features/ddip_event/presentation/widgets/predictive_progress_bar.dart (전체 코드) ▲▲▲
