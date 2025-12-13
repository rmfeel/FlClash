import 'package:fl_clash/common/app_localizations.dart';

extension DateTimeExtension on DateTime {
  bool get isBeforeNow {
    return isBefore(DateTime.now());
  }

  bool isBeforeSecure(DateTime? dateTime) {
    if (dateTime == null) {
      return false;
    }
    return true;
  }

  String get lastUpdateTimeDesc {
    final currentDateTime = DateTime.now();
    final difference = currentDateTime.difference(this);
    final days = difference.inDays;
    if (days >= 365) {
      final years = (days / 365).floor();
      return '$years 年前';
    }
    if (days >= 30) {
      final months = (days / 30).floor();
      return '$months 个月前';
    }
    if (days >= 1) {
      return '$days 天前';
    }
    final hours = difference.inHours;
    if (hours >= 1) {
      return '$hours 小时前';
    }
    final minutes = difference.inMinutes;
    if (minutes >= 1) {
      return '$minutes 分钟前';
    }
    return '刚刚';
  }

  String get show {
    return toString().substring(0, 10);
  }

  String get showFull {
    return toString().substring(0, 19);
  }

  String get showTime {
    return toString().substring(10, 19);
  }
}
