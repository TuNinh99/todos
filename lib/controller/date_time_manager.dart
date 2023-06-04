import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class DateTimeManager {
  //HH - 24hours; hh - 12 hours
  static DateFormat dateTimeFormat = DateFormat('dd-MM-yyyy');

  static String formatToString(DateTime dateTime) {
    return dateTimeFormat.format(dateTime);
  }

  static DateTime formatToDateTime(String dateTimeStr) {
    return dateTimeFormat.parse(dateTimeStr);
  }

  static Future<TimeOfDay?> pickTime(BuildContext context, TimeOfDay time) {
    return showTimePicker(
      context: context,
      initialTime: time,
      builder: (context, widget) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: widget!,
        );
      },
    );
  }

  static Future<DateTime?> pickDate(BuildContext context, DateTime dateTime) {
    return showDatePicker(
      context: context,
      initialDate: dateTime,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
  }
}
