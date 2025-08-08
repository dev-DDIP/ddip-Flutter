// 3. responder_stats_view.dart
import 'package:ddip/features/profile/domain/entities/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class ResponderStatsView extends StatelessWidget {
  final RoleStats stats;
  final List<ActivityArea> activityAreas;

  const ResponderStatsView({
    super.key,
    required this.stats,
    required this.activityAreas,
  });

  @override
  Widget build(BuildContext context) {
    final successRate =
        (stats.successCount / (stats.totalCount == 0 ? 1 : stats.totalCount));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircularPercentIndicator(
                    radius: 45.0,
                    lineWidth: 10.0,
                    percent: successRate,
                    center: Text(
                      "${(successRate * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    progressColor: Colors.green,
                    backgroundColor: Colors.green.shade100,
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '수행 성공률',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '성공 ${stats.successCount}회 / 실패 ${stats.failCount}회',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '주요 활동 구역',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (activityAreas.isEmpty)
            const Text('아직 활동 기록이 없어요.', style: TextStyle(color: Colors.grey))
          else
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children:
                  activityAreas
                      .map(
                        (area) => Chip(
                          label: Text('${area.areaName} (${area.count}회)'),
                        ),
                      )
                      .toList(),
            ),
          const SizedBox(height: 24),
          Text(
            '최근 받은 피드백',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (stats.recentFeedbacks.isEmpty)
            const Text('아직 받은 피드백이 없어요.', style: TextStyle(color: Colors.grey))
          else
            ...stats.recentFeedbacks.map(
              (feedback) => ListTile(
                leading: const Icon(
                  Icons.thumb_up_alt_outlined,
                  color: Colors.blue,
                ),
                title: Text('"$feedback"'),
                dense: true,
              ),
            ),
        ],
      ),
    );
  }
}
