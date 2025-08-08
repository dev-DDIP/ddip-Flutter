// ▼▼▼ lib/common/utils/time_utils.dart ▼▼▼
import 'package:intl/intl.dart';

String formatTimeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return '방금 전';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}분 전';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}시간 전';
  } else if (difference.inDays == 1) {
    return '어제';
  } else {
    // 날짜가 다를 경우 'M월 d일' 형식으로 표시
    return DateFormat('M월 d일').format(dateTime);
  }
}

// ▲▲▲ lib/common/utils/time_utils.dart ▲▲▲
