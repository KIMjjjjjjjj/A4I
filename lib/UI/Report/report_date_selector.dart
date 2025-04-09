import 'package:flutter/material.dart';

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

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
  Widget build(BuildContext context) {
    // 날짜 정규화
    final normalizedDates = availableReportDates.map(normalizeDate).toSet();
    final sortedDates = normalizedDates.toList()..sort();
    final firstAvailable = sortedDates.first;
    final lastAvailable = sortedDates.last;

    final normalizedSelected = normalizeDate(selectedDate);

    // selectedDate가 유효하지 않으면 가장 최근 날짜로 fallback
    final initialDate = normalizedDates.contains(normalizedSelected)
        ? normalizedSelected
        : lastAvailable;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "${initialDate.year}년 ${initialDate.month.toString().padLeft(2, '0')}월 ${initialDate.day.toString().padLeft(2, '0')}일",
          style: const TextStyle(fontSize: 16),
        ),
        IconButton(
          icon: const Icon(Icons.event, color: Colors.black),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: firstAvailable,
              lastDate: lastAvailable,
              selectableDayPredicate: (day) {
                return normalizedDates.contains(normalizeDate(day));
              },
            );
            if (picked != null && normalizeDate(picked) != normalizedSelected) {
              onDateSelected(normalizeDate(picked));
            }
          },
        ),
      ],
    );
  }
}
