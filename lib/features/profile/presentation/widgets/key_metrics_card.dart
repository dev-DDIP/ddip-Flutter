// 2. key_metrics_card.dart
import 'package:ddip/features/profile/domain/entities/user_profile.dart';
import 'package:flutter/material.dart';

class KeyMetricsCard extends StatelessWidget {
  final UserProfileStats stats;
  const KeyMetricsCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final responderSuccessRate =
        (stats.responderStats.successCount /
            (stats.responderStats.totalCount == 0
                ? 1
                : stats.responderStats.totalCount)) *
        100;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      elevation: 0,
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMetricItem(
              context,
              '수행 성공률',
              '${responderSuccessRate.toStringAsFixed(1)}%',
            ),
            _buildMetricItem(
              context,
              '총 완료',
              '${stats.responderStats.successCount}회',
            ),
            _buildMetricItem(
              context,
              '평점',
              '${stats.responderStats.averageRating.toStringAsFixed(1)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
      ],
    );
  }
}
