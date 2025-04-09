import 'package:flutter/material.dart';
import 'report_date_service.dart';

class DateRangePicker {
  // 보고서가 존재하는 날짜 범위에서만 선택 가능하도록
  static Future<DateTimeRange?> showValidDateRangePicker(BuildContext context) async {
    final service = ReportDateService();
    final availableDates = await service.fetchAvailableReportDates();

    if (availableDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("선택 가능한 날짜가 없습니다.")),
      );
      return null;
    }

    // 유효 날짜 정렬
    final sortedDates = availableDates.toList()..sort();
    final firstDate = sortedDates.first;
    final lastDate = sortedDates.last;

    // 초기 날짜 범위 설정
    DateTime initialEnd = lastDate;
    DateTime initialStart = lastDate.subtract(const Duration(days: 6));

    // 초기 날짜가 availableDates 안에 포함되는지 확인
    if (!availableDates.contains(initialStart)) {
      // fallback: 초기 시작일을 가장 가까운 유효한 날짜로 조정
      final fallbackStart = sortedDates
          .where((d) => d.isBefore(initialEnd))
          .take(7)
          .toList()
          .reversed
          .toList();
      if (fallbackStart.isNotEmpty) {
        initialStart = fallbackStart.last;
      } else {
        initialStart = initialEnd;
      }
    }

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: DateTimeRange(
        start: initialStart,
        end: initialEnd,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return null;

    // 선택한 날짜 중, 실제로 데이터가 존재하는 날짜가 포함되어 있는지 확인
    final selectedRangeDates = List<DateTime>.generate(
      picked.end.difference(picked.start).inDays + 1,
          (index) => DateTime(picked.start.year, picked.start.month, picked.start.day + index),
    ).where((d) => availableDates.contains(d)).toList();

    if (selectedRangeDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("선택한 범위에 보고서가 없습니다.")),
      );
      return null;
    }

    return picked;
  }
}
