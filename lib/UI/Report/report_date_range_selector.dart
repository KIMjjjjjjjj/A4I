import 'package:flutter/material.dart';


class ReportDateRangeSelector {
  static Future<DateTimeRange?> selectDateRange(BuildContext context, Set<DateTime> availableReportDates) async {
    final DateTime now = DateTime.now();

    final sortedDates = availableReportDates.toList()..sort();
    final latestAvailableDate = sortedDates.isNotEmpty ? sortedDates.last : now;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange( // 존재하는 날짜 중 가장 최근 날짜로 데이터 불러오기
        start: latestAvailableDate.subtract(Duration(days: 7)), end: latestAvailableDate,
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            dialogBackgroundColor: Color(0xFFF3E5F5),
          ),
          child: child!,
        );
      },
    );
    return picked;
  }
}
