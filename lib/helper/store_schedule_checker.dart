import 'package:flutter/material.dart';
import 'package:sixam_mart/features/store/domain/models/store_model.dart';

bool isStoreOpen(List<Schedules> schedules) {
  final TimeOfDay now = TimeOfDay.now();
  final double currentTime = now.hour + (now.minute / 60.0);

  for (var schedule in schedules) {
    try {
      final TimeOfDay openingTime = TimeOfDay(
        hour: int.parse(schedule.openingTime!.split(":")[0]),
        minute: int.parse(schedule.openingTime!.split(":")[1]),
      );
      final double openingTimeDouble =
          openingTime.hour + (openingTime.minute / 60.0);

      final TimeOfDay closingTime = TimeOfDay(
        hour: int.parse(schedule.closingTime!.split(":")[0]),
        minute: int.parse(schedule.closingTime!.split(":")[1]),
      );
      final double closingTimeDouble =
          closingTime.hour + ((closingTime.minute + 0.99) / 60.0);
      if (currentTime >= openingTimeDouble && currentTime < closingTimeDouble) {
        return true;
      }
    } catch (e) {
      debugPrint(
          'Could not parse schedule time: ${schedule.openingTime} - ${schedule.closingTime}');
    }
  }
  return false;
}
