import 'package:flutter/material.dart';
// 날짜 선택 위젯 메서드
class ReportDateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Set<DateTime> availableReportDates;
  final Function(DateTime) onDateSelected;

  const ReportDateSelector({
    Key? key,
    required this.selectedDate,
    required this.availableReportDates,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "${selectedDate.year}년 ${selectedDate.month.toString().padLeft(2, '0')}월 ${selectedDate.day.toString().padLeft(2, '0')}일",
          style: const TextStyle(fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.event, color: Colors.black),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              selectableDayPredicate: (day) {
                return availableReportDates.contains(DateTime(day.year, day.month, day.day));
              },
            );
            if (picked != null && picked != selectedDate) {
              onDateSelected(picked);
            }
          },
        ),
      ],
    );
  }
}
