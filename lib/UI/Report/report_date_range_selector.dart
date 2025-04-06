import 'package:flutter/material.dart';


class DateRangePicker {
  static Future<DateTimeRange?> selectDateRange(BuildContext context) async {
    final DateTime now = DateTime.now();

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(Duration(days: 7)), end: now,
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
