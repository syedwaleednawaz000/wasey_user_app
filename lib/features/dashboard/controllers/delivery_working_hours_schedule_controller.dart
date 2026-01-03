import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixam_mart/util/app_constants.dart';
import '../../../api/api_client.dart';
import '../models/delivery_working_hours_schedule_model.dart';
import '../widgets/delivery_working_hours_bottom_sheet.dart';

class TimeSlotController extends GetxController {
  final ApiClient apiClient;

  TimeSlotController({required this.apiClient});

  final _timeSlot = Rxn<ZoneTimeSlot>();
  final _isLoading = true.obs;
  final _error = RxnString();

  ZoneTimeSlot? get timeSlot => _timeSlot.value;

  bool get isLoading => _isLoading.value;

  String? get error => _error.value;

  // @override
  // void onInit() {
  //   super.onInit();
  //   // fetchTimeSlots();
  // }

  Future<void> fetchTimeSlots() async {
    try {
      _isLoading(true);
      _error(null);

      final response = await apiClient.getData(AppConstants.deliveryTimeSlotsUri);

      log("API Response: ${response.statusCode} ${response.request?.url}");
      log("Raw Body: ${response.body}");

      if (response.statusCode == 200) {
        final json = response.body as Map<String, dynamic>;

        if (json['data'] != null && (json['data'] as List).isNotEmpty) {
          final timeSlotResponse = TimeSlotResponse.fromJson(json);
          _timeSlot.value = timeSlotResponse.data.first; // This line was missing!
          log("Parsed TimeSlot: ${_timeSlot.value?.zoneName}");
          log("parsedData DeliverySystemEnable: ${_timeSlot.value?.deliverySlotSystemEnabled}");
        } else {
          _error('No time slot data');
        }
      } else {
        _error('HTTP ${response.statusCode}');
      }
    } catch (e, stack) {
      log("Error in fetchTimeSlots: $e", stackTrace: stack);
      _error(e.toString());
    } finally {
      _isLoading(false);
    }
  }

  Future<void> checkAndShowWorkingHoursPopup({
    required BuildContext context,
    required bool mounted,
  }) async {
    const hasShown = false; // Or use SharedPreferences

    if (!hasShown && mounted) {
      log("working hours triggered");

      // final controller = Get.find<TimeSlotController>();

      // Wait for data to load
      await fetchTimeSlots();

      // Now it's safe to access
      log("Weekly Pickup: ${timeSlot?.weeklyPickupTimeSlots}");

      if (timeSlot != null) {
        if(timeSlot?.weeklyPickupTimeSlots != null && !timeSlot!.deliverySlotSystemEnabled) {
          showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const WorkingHoursBottomSheet(),
        );
        }else{
          log("Delivery System Disabled");
        }
      } else {
        log("No time slot data available");
      }
    }
  }

// Future<void> fetchTimeSlots() async {
  //   try {
  //     _isLoading(true);
  //     _error(null);
  //
  //     final response =
  //         await apiClient.getData(AppConstants.deliveryTimeSlotsUri);
  //
  //     log("fetchTimeSlots triggered");
  //     // if (response.statusCode == 200) {
  //     //   log("fetchTimeSlots succeed");
  //     //   log(response.body);
  //     //   final timeSlotResponse = TimeSlotResponse.fromJson(response.body);
  //     //   if (timeSlotResponse.data.isNotEmpty) {
  //     //     _timeSlot.value = timeSlotResponse.data.first;
  //     //   }
  //     // }
  //     if (response.statusCode == 200 && response.body['data'] != null) {
  //       log("fetchTimeSlots succeed");
  //       log(response.body);
  //       final timeSlotResponse = TimeSlotResponse.fromJson(response.body);
  //       if (timeSlotResponse.data.isNotEmpty) {
  //         _timeSlot.value = timeSlotResponse.data.first;
  //       }
  //     } else {
  //       log("fetchTimeSlots error");
  //       _error('Failed to load time slots');
  //     }
  //   } catch (e) {
  //     _error(e.toString());
  //   } finally {
  //     _isLoading(false);
  //   }
  // }
}
